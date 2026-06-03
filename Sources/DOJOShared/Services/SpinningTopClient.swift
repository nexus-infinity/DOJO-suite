import Foundation

/// HTTP client for connecting to Spinning Top HTTP Server
/// Port: 7410 (DOJO Free Radical MCP)
public class SpinningTopClient {
    
    // MARK: - Configuration
    
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: String = "http://localhost:7410") {
        self.baseURL = URL(string: baseURL)!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 4
        config.timeoutIntervalForResource = 6
        self.session = URLSession(configuration: config)
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

        public var model_used: String { model ?? "unknown" }
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

    private struct SSEChunk: Decodable {
        let content: String?
        let done: Bool?
    }

    /// Stream tokens from DOJO MCP `POST /chat/stream` (SSE, port 7410).
    public func streamMessage(
        _ message: String,
        conversationId: String,
        character: String = "padawan",
        onToken: @escaping @Sendable (String) -> Void
    ) async throws {
        let url = baseURL.appendingPathComponent("chat").appendingPathComponent("stream")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        let body = ChatRequest(
            userMessage: message,
            character: character,
            conversationContext: nil,
            conversationId: conversationId
        )
        request.httpBody = try JSONEncoder().encode(body)
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw SpinningTopError.invalidResponse
        }
        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }
            let jsonSlice = line.dropFirst(6)
            guard let data = jsonSlice.data(using: .utf8),
                  let chunk = try? JSONDecoder().decode(SSEChunk.self, from: data) else { continue }
            if chunk.done == true { break }
            if let token = chunk.content { onToken(token) }
        }
    }

    // MARK: - Errors

    public enum SpinningTopError: LocalizedError {
        case invalidResponse
        case serverUnavailable
        
        public var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from spinning top server"
            case .serverUnavailable:
                return "DOJO MCP is not reachable at http://localhost:7410"
            }
        }
    }
}
