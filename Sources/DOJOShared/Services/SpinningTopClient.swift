import Foundation

/// HTTP client for connecting to Spinning Top HTTP Server
/// Port: 7410 (DOJO Free Radical MCP)
public class SpinningTopClient {

    // MARK: - Configuration

    private let baseURL: URL
    private let session: URLSession
    private let authorityVerifier: any CockpitAuthorityVerifying

    public init(
        baseURL: String = "http://127.0.0.1:7410",
        session: URLSession? = nil,
        authorityVerifier: any CockpitAuthorityVerifying = KingsChamberAuthorityVerifier()
    ) {
        self.baseURL = URL(string: baseURL)!
        self.authorityVerifier = authorityVerifier
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            // The DOJO server has a bounded model window. Keep the client just
            // above it so a model HOLD can return as a typed response instead
            // of becoming an unclassified transport failure.
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 18
            // No disk cache — local DOJO server responses should not be cached,
            // and Cache.db-wal writes will fail when disk is full.
            config.urlCache = nil
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            self.session = URLSession(configuration: config)
        }
    }

    // MARK: - Request/Response Models

    /// Wire format for ◼︎ DOJO `POST /chat` and `POST /chat/stream` (port 7410).
    public struct ChatTurn: Codable {
        public let role: String
        public let content: String
        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
    }

    public struct ChatRequest: Codable {
        public let userMessage: String
        public let character: String
        public let conversationContext: [ChatTurn]?
        /// Client correlation only; DOJO server ignores if present.
        public let conversationId: String?

        public init(
            userMessage: String,
            character: String = "padawan",
            conversationContext: [ChatTurn]? = nil,
            conversationId: String? = nil
        ) {
            self.userMessage = userMessage
            self.character = character
            self.conversationContext = conversationContext
            self.conversationId = conversationId
        }
    }

    public struct ChatResponse: Codable {
        public let response: String
        public let character: String?
        public let chamber: String?
        public let frequency: Int?
        public let model: String?
        /// Transport may succeed while configured model inference is unavailable.
        public let status: String?
        public let inference_available: Bool?

        public var model_used: String { model ?? "unknown" }
        public var inferenceAvailable: Bool {
            inference_available ?? !response.hasPrefix("[DOJO 7410 ✓ — inference unavailable]")
        }
    }

    public struct ModelsResponse: Codable {
        public let ollama: [String]
        public let claude: [String]
    }

    public struct StateResponse: Codable {
        public let coherence: Double
        public let nodes: [Node]
        public let operational: Bool

        public struct Node: Codable {
            public let symbol: String
            public let name: String
            public let state: Bool
            public let coherence: Double
            public let frequency: Int
            public let pid: Int?
            public let mcp_port: Int?
            /// DOJO /state tri-state: healthy | degraded | unknown | unhealthy (nil if older server).
            public let health: String?
        }
    }

    /// Kings-Chamber `GET /chronicle` projection. This is the canonical state
    /// surface; `LAST_SESSION.md` is backing storage, not an HTTP resource.
    public struct ChronicleResponse: Codable {
        public let symbol: String
        public let name: String
        public let endpoint: String
        public let description: String
        public let lastSessionMarkdown: String?

        private enum CodingKeys: String, CodingKey {
            case symbol
            case name
            case endpoint
            case description
            case lastSessionMarkdown = "last_session_md"
        }
    }

    // MARK: - API Methods

    /// Send chat message to DOJO MCP at port 7410 (`POST /chat`).
    public func sendMessage(
        _ message: String,
        character: String = "padawan",
        context: [ChatTurn]? = nil
    ) async throws -> ChatResponse {
        let url = baseURL.appendingPathComponent("chat")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let chatRequest = ChatRequest(userMessage: message, character: character, conversationContext: context, conversationId: nil)
        request.httpBody = try JSONEncoder().encode(chatRequest)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SpinningTopError.invalidResponse
        }

        return try JSONDecoder().decode(ChatResponse.self, from: data)
    }

    /// Get available AI models
    public func getModels() async throws -> ModelsResponse {
        let url = baseURL.appendingPathComponent("models")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SpinningTopError.invalidResponse
        }

        return try JSONDecoder().decode(ModelsResponse.self, from: data)
    }

    /// Get spinning top state (coherence, nodes, etc.)
    public func getState() async throws -> StateResponse {
        let url = baseURL.appendingPathComponent("state")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SpinningTopError.invalidResponse
        }

        return try JSONDecoder().decode(StateResponse.self, from: data)
    }

    /// Get Kings-Chamber projected chronicle state (`GET /chronicle`, port 8520).
    public func getChronicle() async throws -> ChronicleResponse {
        let url = baseURL.appendingPathComponent("chronicle")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SpinningTopError.invalidResponse
        }

        return try JSONDecoder().decode(ChronicleResponse.self, from: data)
    }

    /// Call a DOJO tool through the cockpit adapter.
    ///
    /// Consequential calls fail closed before network dispatch unless the
    /// injected lawful authority verifier accepts the proof. Every response
    /// must echo the request correlation ID before its payload is consumable.
    public func callTool(
        name: String,
        arguments: [String: String] = [:],
        effect: CockpitToolEffect,
        correlationID: UUID = UUID(),
        authorityProof: CockpitAuthorityProof? = nil
    ) async throws -> CockpitToolCallReceipt {
        if effect == .consequential {
            guard let authorityProof,
                  authorityProof.toolName == name,
                  await authorityVerifier.permits(
                    authorityProof,
                    toolName: name,
                    correlationID: correlationID
                  ) else {
                throw SpinningTopError.permissionDenied
            }
        }

        let url = baseURL.appendingPathComponent("mcp/tools/call")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(correlationID.uuidString, forHTTPHeaderField: "X-FIELD-Correlation-ID")
        var body: [String: Any] = [
            "tool": name,
            "arguments": arguments,
            "effect": effect.rawValue,
            "correlation_id": correlationID.uuidString
        ]
        if let authorityProof {
            body["authority_receipt_id"] = authorityProof.receiptID
            body["authority_nonce"] = authorityProof.nonce
            body["cockpit_verification_id"] = authorityProof.verificationID.uuidString
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SpinningTopError.invalidResponse
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let returnedID = object["correlation_id"] as? String,
              returnedID == correlationID.uuidString else {
            throw SpinningTopError.correlationMismatch
        }

        return CockpitToolCallReceipt(
            correlationID: correlationID,
            toolName: name,
            effect: effect,
            httpStatus: httpResponse.statusCode,
            responseBody: data
        )
    }

    /// Check if server is reachable
    public func healthCheck() async throws -> Bool {
        let url = baseURL.appendingPathComponent("health")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }

        // Try to parse the response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String {
            return ["operational", "healthy", "stable", "degraded"].contains(status)
        }

        return true
    }

    // MARK: - SSE Streaming

        /// Stream tokens from DOJO. Server exposes `POST /chat` (no SSE endpoint);
    /// we simulate word-by-word delivery so the streaming UI animates naturally.
    public func streamMessage(
        _ message: String,
        conversationId: String,
        character: String = "padawan",
        onToken: @escaping @Sendable (String) -> Void
    ) async throws {
        let response = try await sendMessage(message, character: character)
        let words = response.response.components(separatedBy: " ")
        for (i, word) in words.enumerated() {
            onToken(i == 0 ? word : " \(word)")
            try await Task.sleep(nanoseconds: 15_000_000)
        }
    }

    // MARK: - Errors

    public enum SpinningTopError: LocalizedError {
        case invalidResponse
        case serverUnavailable
        case permissionDenied
        case correlationMismatch

        public var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from spinning top server"
            case .serverUnavailable:
                return "DOJO MCP is not reachable at http://localhost:7410"
            case .permissionDenied:
                return "Consequential cockpit tool call withheld: authority is missing or invalid"
            case .correlationMismatch:
                return "Cockpit tool response withheld: correlation ID is missing or mismatched"
            }
        }
    }
}
