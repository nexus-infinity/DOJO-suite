import Foundation

/**
 * PersistentObservation.swift
 * \u{25CF} 963 Hz \u2014 Persistent Memory Unit
 */
public struct PersistentObservation: Codable, Identifiable {
    public let id: UUID
    public let data: String
    public let context: String
    public let timestamp: Date
    
    public init(data: String, context: String = "Spinning Top On-Device") {
        self.id = UUID()
        self.data = data
        self.context = context
        self.timestamp = Date()
    }
}

/**
 * LocalEventQueue.swift
 * ◻ AKRON-level persistence on-device
 */
public class LocalEventQueue {
    private let fileURL: URL
    
    public init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.fileURL = paths[0].appendingPathComponent("PendingObservations.json")
    }
    
    public func enqueue(_ observation: PersistentObservation) {
        var queue = dequeueAll()
        queue.append(observation)
        save(queue)
    }
    
    public func dequeueAll() -> [PersistentObservation] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([PersistentObservation].self, from: data)) ?? []
    }
    
    public func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private func save(_ queue: [PersistentObservation]) {
        if let data = try? JSONEncoder().encode(queue) {
            try? data.write(to: fileURL)
        }
    }
}
