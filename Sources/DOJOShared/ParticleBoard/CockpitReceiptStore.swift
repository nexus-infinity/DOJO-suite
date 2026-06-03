import CryptoKit
import Foundation

// MARK: - Receipt types

public struct CockpitReceipt: Codable, Sendable {
    public let receiptID: UUID       // stable unique ID for this receipt event
    public let timestamp: String
    public let event: String         // "commit.accepted" | "commit.blocked"
    public let actor: String
    public let boardTitle: String
    public let stateHash: String
    public let draftPresent: Bool
    public let policyResult: String  // "ok" | "hold"
    public let addressesChanged: [String]
    public let holdReasons: [HoldReasonReceipt]?

    public init(
        receiptID: UUID = UUID(),
        timestamp: String,
        event: String,
        actor: String,
        boardTitle: String,
        stateHash: String,
        draftPresent: Bool,
        policyResult: String,
        addressesChanged: [String],
        holdReasons: [HoldReasonReceipt]?
    ) {
        self.receiptID = receiptID
        self.timestamp = timestamp
        self.event = event
        self.actor = actor
        self.boardTitle = boardTitle
        self.stateHash = stateHash
        self.draftPresent = draftPresent
        self.policyResult = policyResult
        self.addressesChanged = addressesChanged
        self.holdReasons = holdReasons
    }
}

public struct HoldReasonReceipt: Codable, Sendable {
    public let address: String
    public let code: String
    public let detail: String

    public init(address: String, code: String, detail: String) {
        self.address = address
        self.code = code
        self.detail = detail
    }
}

// MARK: - Store

/// Append-only JSONL receipt log written to Application Support/DOJO/cockpit_receipts.jsonl.
/// Writes are dispatched off the main thread — caller is never blocked.
public struct CockpitReceiptStore: Sendable {
    public let fileURL: URL

    public init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("DOJO", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("cockpit_receipts.jsonl")
    }

    public func emit(_ receipt: CockpitReceipt) {
        let url = fileURL
        DispatchQueue.global(qos: .utility).async {
            let encoder = JSONEncoder()
            guard let lineData = try? encoder.encode(receipt),
                  var line = String(data: lineData, encoding: .utf8) else { return }
            line += "\n"
            guard let data = line.data(using: .utf8) else { return }
            if FileManager.default.fileExists(atPath: url.path) {
                guard let handle = try? FileHandle(forWritingTo: url) else { return }
                defer { try? handle.close() }
                handle.seekToEndOfFile()
                handle.write(data)
            } else {
                try? data.write(to: url, options: .atomic)
            }
        }
    }

    /// Real SHA-256 over the pipe-joined components.
    public static func sha256(from components: String...) -> String {
        let raw = components.joined(separator: "|")
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
