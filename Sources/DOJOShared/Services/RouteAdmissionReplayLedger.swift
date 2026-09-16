import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public protocol RouteAdmissionReplayLedger: Sendable {
    /// Atomically claim a receipt identifier. Returns false when it was already
    /// consumed or when durable state cannot be read or written.
    func claim(receiptID: String, consumedAt: Date) async -> Bool
}

public actor InMemoryRouteAdmissionReplayLedger: RouteAdmissionReplayLedger {
    private var consumed: Set<String> = []

    public init() {}

    public func claim(receiptID: String, consumedAt: Date) async -> Bool {
        consumed.insert(receiptID).inserted
    }
}

public actor FileRouteAdmissionReplayLedger: RouteAdmissionReplayLedger {
    public struct Entry: Codable, Equatable, Sendable {
        public let consumedAt: Date

        enum CodingKeys: String, CodingKey {
            case consumedAt = "consumed_at"
        }
    }

    public struct Document: Codable, Equatable, Sendable {
        public let schemaID: String
        public var entries: [String: Entry]

        enum CodingKeys: String, CodingKey {
            case schemaID = "schema_id"
            case entries
        }
    }

    public static let schemaID = "DURABLE_ROUTE_ADMISSION_REPLAY_LEDGER_V0"

    private let fileURL: URL

    public init(fileURL: URL? = nil) {
        #if os(iOS)
        let defaultBaseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let defaultFileURL = defaultBaseURL
            .appendingPathComponent("DOJO", isDirectory: true)
            .appendingPathComponent("DURABLE_ROUTE_ADMISSION_REPLAY_LEDGER_V0.ledger.json")
        #else
        let defaultFileURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("◎Kings-Chamber/chronicle")
            .appendingPathComponent("DURABLE_ROUTE_ADMISSION_REPLAY_LEDGER_V0.ledger.json")
        #endif
        self.fileURL = fileURL ?? defaultFileURL
    }

    public func claim(receiptID: String, consumedAt: Date) async -> Bool {
        guard !receiptID.isEmpty else { return false }

        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let lockURL = fileURL.appendingPathExtension("lock")
            let descriptor = lockURL.path.withCString {
                open($0, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
            }
            guard descriptor >= 0 else { return false }
            defer {
                _ = flock(descriptor, LOCK_UN)
                _ = close(descriptor)
            }
            guard flock(descriptor, LOCK_EX) == 0 else { return false }

            var document = try load()
            guard document.entries[receiptID] == nil else { return false }
            document.entries[receiptID] = Entry(consumedAt: consumedAt)

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            let data = try encoder.encode(document)
            try data.write(to: fileURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    public func snapshot() async -> Document? {
        try? load()
    }

    private func load() throws -> Document {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return Document(schemaID: Self.schemaID, entries: [:])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let document = try decoder.decode(
            Document.self,
            from: Data(contentsOf: fileURL)
        )
        guard document.schemaID == Self.schemaID else {
            throw LedgerError.schemaMismatch
        }
        return document
    }

    private enum LedgerError: Error {
        case schemaMismatch
    }
}
