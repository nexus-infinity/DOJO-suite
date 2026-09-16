import Foundation
import DOJOShared

/// Bowls one Today Capture Keep through the same journal the composer uses.
/// Object JSON matches `GeneratedObjectShell` so Proof can load it after a refresh.
@main
struct TodayKeep {
    static func main() throws {
        let note = CommandLine.arguments.dropFirst().joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let body = note.isEmpty
            ? "Lived Keep — CSIA base slope. Capture, object, receipt."
            : note

        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("org.field.dojo", isDirectory: true)
        try FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        let objectURL = support.appendingPathComponent("generated_objects.json")
        let receiptURL = support.appendingPathComponent("local_capture_receipts.jsonl")

        let objectID = UUID()
        let createdAt = Date()
        let title = "Capture · \(body.prefix(48))"
        let receipt = LocalCaptureReceiptJournal.make(
            objectID: objectID.uuidString,
            kind: "document",
            home: "captures",
            title: title,
            body: body,
            subtitle: "Local capture",
            createdAt: createdAt,
            sourcePrompt: body,
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            objectPath: objectURL.path,
            receiptPath: receiptURL.path
        )
        try LocalCaptureReceiptJournal.append(receipt, to: receiptURL)

        var objects = try loadObjects(from: objectURL)
        let kept = KeepObjectRecord(
            id: objectID,
            kind: "document",
            home: "captures",
            title: title,
            body: body,
            subtitle: "Local capture",
            isDeveloperOnly: false,
            createdAt: createdAt,
            sourcePrompt: body,
            localReceipt: receipt,
            isSavedLocally: true,
            lastStablePoint: "capture_kept",
            nextAvailableAction: "Review · Save · Export · Continue",
            changedWhileAway: "none"
        )
        objects.insert(kept, at: 0)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(objects).write(to: objectURL, options: .atomic)

        FileHandle.standardOutput.write(
            Data("CAPTURED \(receipt.receiptID) \(receipt.contentSHA256)\n".utf8)
        )
    }

    private static func loadObjects(from url: URL) throws -> [KeepObjectRecord] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([KeepObjectRecord].self, from: data)
    }
}

/// Wire-compatible with `GeneratedObjectShell` Codable keys used on disk.
private struct KeepObjectRecord: Codable {
    let id: UUID
    let kind: String
    let home: String
    let title: String
    let body: String
    let subtitle: String
    let isDeveloperOnly: Bool
    let createdAt: Date
    var providerID: String? = nil
    var modelID: String? = nil
    var sourcePrompt: String?
    var localReceipt: LocalCaptureReceipt?
    var processingPacket: TodayProcessingPacket? = nil
    let isSavedLocally: Bool
    let lastStablePoint: String
    let nextAvailableAction: String
    let changedWhileAway: String
}
