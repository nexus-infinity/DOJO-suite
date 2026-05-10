import CryptoKit
import Foundation

// v0 file-backed store. Each packet is one JSON file under
// ~/Library/Application Support/DOJO/packets/<uuid>.json
// Replace with PacketCoreDataStore in v1.
public final class PacketFileStore: PacketRepository, @unchecked Sendable {
    private let directory: URL

    public init() {
        let support = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        directory = support.appendingPathComponent("DOJO/packets", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
    }

    private func fileURL(for id: UUID) -> URL {
        directory.appendingPathComponent("\(id.uuidString).json")
    }

    public func save(_ packet: Packet) async throws {
        let data = try JSONEncoder().encode(packet)
        try data.write(to: fileURL(for: packet.id), options: .atomic)
    }

    public func load(id: UUID) async throws -> Packet? {
        let url = fileURL(for: id)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return try JSONDecoder().decode(Packet.self, from: data)
    }

    public func loadAll() async throws -> [Packet] {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        )) ?? []
        return urls
            .filter { $0.pathExtension == "json" }
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap { try? JSONDecoder().decode(Packet.self, from: $0) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func delete(id: UUID) async throws {
        try? FileManager.default.removeItem(at: fileURL(for: id))
    }

    public static func integrityHash(text: String, mediaRefs: [String] = []) -> String {
        let raw = ([text] + mediaRefs).joined(separator: "|")
        return SHA256.hash(data: Data(raw.utf8))
            .map { String(format: "%02x", $0) }.joined()
    }
}
