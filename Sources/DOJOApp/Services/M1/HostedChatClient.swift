import Foundation

/// M1 hosted chat client — real HTTPS only. Never fakes success.

struct HostedChatRequest {
    let provider: HostedProviderID
    let modelID: String
    let userMessage: String
    /// Optional prior answer/body for Continue.
    let contextBody: String?
}

struct HostedChatResponse {
    let text: String
    let provider: HostedProviderID
    let modelID: String
    let httpStatus: Int
}

enum HostedChatError: LocalizedError {
    case providerDisabled(HostedProviderID)
    case missingAPIKey(HostedProviderID)
    case invalidURL
    case httpStatus(Int, String)
    case decodeFailed(String)
    case emptyResponse
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .providerDisabled(let p):
            return "\(p.displayName) is not enabled for live calls."
        case .missingAPIKey(let p):
            return "No API key in Keychain for \(p.displayName). Add one in Settings → API keys."
        case .invalidURL:
            return "Invalid API URL."
        case .httpStatus(let code, let body):
            let snippet = body.prefix(280)
            return "HTTP \(code): \(snippet)"
        case .decodeFailed(let detail):
            return "Could not decode response: \(detail)"
        case .emptyResponse:
            return "Provider returned an empty response."
        case .transport(let msg):
            return msg
        }
    }
}

enum HostedChatClient {
    private static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 90
        config.timeoutIntervalForResource = 120
        return URLSession(configuration: config)
    }()

    static func complete(_ request: HostedChatRequest) async throws -> HostedChatResponse {
        guard request.provider.isHostedLive else {
            throw HostedChatError.providerDisabled(request.provider)
        }
        guard let apiKey = APIKeychainStore.load(provider: request.provider), !apiKey.isEmpty else {
            throw HostedChatError.missingAPIKey(request.provider)
        }

        let prompt = composedUserContent(request)

        switch request.provider {
        case .openai, .xai:
            return try await openAICompatible(
                provider: request.provider,
                model: request.modelID,
                apiKey: apiKey,
                userContent: prompt
            )
        case .anthropic:
            return try await anthropic(
                model: request.modelID,
                apiKey: apiKey,
                userContent: prompt
            )
        case .google:
            return try await google(
                model: request.modelID,
                apiKey: apiKey,
                userContent: prompt
            )
        case .local:
            throw HostedChatError.providerDisabled(.local)
        }
    }

    /// Minimal live probe — uses a real HTTP call; does not fake success.
    static func testConnection(provider: HostedProviderID, modelID: String?) async -> Result<String, Error> {
        do {
            let model = HostedProviderCatalog.resolvedModelID(provider: provider, preferred: modelID)
            let response = try await complete(
                HostedChatRequest(
                    provider: provider,
                    modelID: model,
                    userMessage: "Reply with exactly: ok",
                    contextBody: nil
                )
            )
            return .success("HTTP \(response.httpStatus) · model \(response.modelID) · \(response.text.prefix(80))")
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Providers

    private static func openAICompatible(
        provider: HostedProviderID,
        model: String,
        apiKey: String,
        userContent: String
    ) async throws -> HostedChatResponse {
        let base: String
        switch provider {
        case .openai: base = "https://api.openai.com/v1/chat/completions"
        case .xai: base = "https://api.x.ai/v1/chat/completions"
        default: throw HostedChatError.invalidURL
        }
        guard let url = URL(string: base) else { throw HostedChatError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": userContent]
            ],
            "temperature": 0.4
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(status) else {
            throw HostedChatError.httpStatus(status, String(data: data, encoding: .utf8) ?? "")
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let first = choices.first,
            let message = first["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw HostedChatError.decodeFailed("OpenAI-compatible shape")
        }
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw HostedChatError.emptyResponse }
        return HostedChatResponse(text: text, provider: provider, modelID: model, httpStatus: status)
    }

    private static func anthropic(
        model: String,
        apiKey: String,
        userContent: String
    ) async throws -> HostedChatResponse {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw HostedChatError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 2048,
            "messages": [
                ["role": "user", "content": userContent]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(status) else {
            throw HostedChatError.httpStatus(status, String(data: data, encoding: .utf8) ?? "")
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = json["content"] as? [[String: Any]]
        else {
            throw HostedChatError.decodeFailed("Anthropic shape")
        }
        let texts = content.compactMap { block -> String? in
            guard (block["type"] as? String) == "text" else { return nil }
            return block["text"] as? String
        }
        let text = texts.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw HostedChatError.emptyResponse }
        return HostedChatResponse(text: text, provider: .anthropic, modelID: model, httpStatus: status)
    }

    private static func google(
        model: String,
        apiKey: String,
        userContent: String
    ) async throws -> HostedChatResponse {
        guard let url = URL(
            string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"
        ) else { throw HostedChatError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Keep the credential out of the URL and align with Google's current
        // Gemini API authentication contract.
        req.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        let body: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [["text": userContent]]
                ]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(status) else {
            throw HostedChatError.httpStatus(status, String(data: data, encoding: .utf8) ?? "")
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]]
        else {
            throw HostedChatError.decodeFailed("Google shape")
        }
        let text = parts.compactMap { $0["text"] as? String }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw HostedChatError.emptyResponse }
        return HostedChatResponse(text: text, provider: .google, modelID: model, httpStatus: status)
    }

    private static func composedUserContent(_ request: HostedChatRequest) -> String {
        if let context = request.contextBody?.trimmingCharacters(in: .whitespacesAndNewlines),
           !context.isEmpty {
            return """
            Prior object context:
            \(context)

            ---
            User:
            \(request.userMessage)
            """
        }
        return request.userMessage
    }

    private static func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw HostedChatError.transport(error.localizedDescription)
        }
    }
}
