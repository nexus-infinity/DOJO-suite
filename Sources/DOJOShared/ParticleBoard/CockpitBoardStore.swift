import Foundation

// MARK: - Snapshot schema

public struct CockpitBoardSnapshot: Codable, Sendable {
    public let schemaVersion: Int
    public let savedAt: String
    public let boardTitle: String
    public let committedState: ParticleBoardState

    public init(
        schemaVersion: Int = 1,
        savedAt: String,
        boardTitle: String,
        committedState: ParticleBoardState
    ) {
        self.schemaVersion = schemaVersion
        self.savedAt = savedAt
        self.boardTitle = boardTitle
        self.committedState = committedState
    }
}

// MARK: - Store

/// Atomic JSON persistence for the committed ParticleBoard state.
/// Saves asynchronously on a utility queue; load is synchronous (called once at startup).
/// Returns nil on missing file, decoding failure, or schema mismatch — never throws.
public struct CockpitBoardStore: Sendable {
    public let fileURL: URL

    public init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("DOJO", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("cockpit_board.json")
    }

    public func save(_ state: ParticleBoardState, title: String) {
        let snapshot = CockpitBoardSnapshot(
            savedAt: ISO8601DateFormatter().string(from: Date()),
            boardTitle: title,
            committedState: state
        )
        let url = fileURL
        DispatchQueue.global(qos: .utility).async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    public func load() -> ParticleBoardState? {
        // Case A: file absent — fresh install. Seed is correct. No action needed.
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        // Case B: file present but undecodable — schema evolution or partial write.
        // Preserve before seeding so user data is recoverable. Silent drop here is
        // a silent overwrite on the next acceptForecast.
        guard let snapshot = try? JSONDecoder().decode(CockpitBoardSnapshot.self, from: data),
              snapshot.schemaVersion == 1 else {
            let bakURL = fileURL.deletingPathExtension().appendingPathExtension("json.bak")
            try? data.write(to: bakURL)               // overwrite any previous bak
            try? FileManager.default.removeItem(at: fileURL)
            print("◆ CockpitBoardStore: unreadable snapshot preserved to \(bakURL.lastPathComponent) — falling back to seed.")
            return nil
        }
        return snapshot.committedState
    }
}
