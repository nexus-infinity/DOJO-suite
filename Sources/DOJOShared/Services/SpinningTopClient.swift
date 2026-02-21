import Foundation

/// HTTP client for connecting to Spinning Top HTTP Server
/// Port: 7410 (DOJO Free Radical MCP)
public class SpinningTopClient {
    
    // MARK: - Configuration
    
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: String = "http://localhost:7410") {
        self.baseURL = URL(string: baseURL)!
        self.session = URLSession.shared
    }
    
    // MARK: - Request/Response Models
    
    public struct ChatRequest: Codable {
        public let message: String
        public let model: String
        public let context: [String: String]?
        
        public init(message: String, model: String = "llama3:latest", context: [String: String]? = nil) {
            self.message = message
            self.model = model
            self.context = context
        }
    }
    
    public struct ChatResponse: Codable {
        public let response: String
        public let vertex_anchor: String
        public let frequency: Int
        public let chamber: String
        public let model_used: String
        public let particles_data: ParticlesData?
        
        public struct ParticlesData: Codable {
            public let attractor_vertex: String
            public let intensity: Double
            public let color_shift: String
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
        }
    }
    
    // MARK: - API Methods
    
    /// Send chat message to AI
    public func sendMessage(_ message: String, model: String = "llama3:latest") async throws -> ChatResponse {
        let url = baseURL.appendingPathComponent("chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = ChatRequest(message: message, model: model)
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
    
    /// Check if server is reachable
    public func healthCheck() async throws -> Bool {
        let url = baseURL
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        // Try to parse the response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String {
            return status == "operational"
        }
        
        return false
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
                return "Spinning top server is not reachable at localhost:7410"
            }
        }
    }
}
