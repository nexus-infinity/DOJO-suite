import Foundation

struct PersistedMessage: Codable, Identifiable {
    let id: UUID
    let role: String
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

struct PersistedConversation: Codable, Identifiable {
    let id: UUID
    var createdAt: Date
    var updatedAt: Date
    var messages: [PersistedMessage]

    init(id: UUID = UUID()) {
        self.id = id
        self.createdAt = Date()
        self.updatedAt = Date()
        self.messages = []
    }
}

@MainActor
class ConversationStore: ObservableObject {
    @Published private(set) var current: PersistedConversation

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DOJOApp", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("current_conversation.json")

        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode(PersistedConversation.self, from: data) {
            current = saved
        } else {
            current = PersistedConversation()
        }
    }

    func append(role: String, content: String) {
        current.messages.append(PersistedMessage(role: role, content: content))
        current.updatedAt = Date()
        persist()
    }

    func newConversation() {
        current = PersistedConversation()
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(current) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
