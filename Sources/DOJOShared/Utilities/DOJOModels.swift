import Foundation

// MARK: - DOJO Chat Models

struct DOJOChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let agent: DOJOAgent
    let chamber: String?
    let timestamp = Date()
}

struct DOJOAgent {
    let name: String
    let symbol: String
    let frequency: Int
}

// MARK: - Particle Models

struct ParticleNode: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let frequency: Int
    let filePath: URL?
}
