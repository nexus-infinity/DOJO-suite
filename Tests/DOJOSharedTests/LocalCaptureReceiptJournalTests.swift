import XCTest
@testable import DOJOShared

final class LocalCaptureReceiptJournalTests: XCTestCase {
    func testCaptureLoopScoresOneRunOnTheBoard() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("dojo-capture-run-\(UUID().uuidString)", isDirectory: true)
        let objectPath = directory.appendingPathComponent("generated_objects.json").path
        let receiptURL = directory.appendingPathComponent("local_capture_receipts.jsonl")
        defer { try? FileManager.default.removeItem(at: directory) }

        let createdAt = Date(timeIntervalSince1970: 1_735_689_600)
        let first = LocalCaptureReceiptJournal.make(
            objectID: "run-1",
            kind: "document",
            home: "captures",
            title: "Capture · CSIA base-skill run",
            body: "First scored delivery on the Today Capture loop.",
            subtitle: "Local capture",
            createdAt: createdAt,
            sourcePrompt: "First scored delivery on the Today Capture loop.",
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            objectPath: objectPath,
            receiptPath: receiptURL.path
        )
        try LocalCaptureReceiptJournal.append(first, to: receiptURL)

        let second = LocalCaptureReceiptJournal.make(
            objectID: "run-2",
            kind: "document",
            home: "captures",
            title: "Capture · second ball",
            body: "Second scored delivery.",
            subtitle: "Local capture",
            createdAt: createdAt.addingTimeInterval(60),
            sourcePrompt: "Second scored delivery.",
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            objectPath: objectPath,
            receiptPath: receiptURL.path
        )
        try LocalCaptureReceiptJournal.append(second, to: receiptURL)

        let scored = try LocalCaptureReceiptJournal.load(from: receiptURL)
        XCTAssertEqual(scored.count, 2)
        XCTAssertEqual(scored.map(\.result), [
            LocalCaptureReceipt.Outcome.captured,
            LocalCaptureReceipt.Outcome.captured
        ])
        XCTAssertEqual(scored.map(\.operation), [
            LocalCaptureReceipt.Operation.capture,
            LocalCaptureReceipt.Operation.capture
        ])
        XCTAssertEqual(scored[0].objectID, "run-1")
        XCTAssertEqual(scored[1].objectID, "run-2")
        XCTAssertEqual(scored[0].contentSHA256.count, 64)
        XCTAssertNotEqual(scored[0].contentSHA256, scored[1].contentSHA256)
    }

    func testLoadReturnsEmptyWhenJournalIsAbsent() throws {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent("dojo-capture-missing-\(UUID().uuidString).jsonl")
        XCTAssertEqual(try LocalCaptureReceiptJournal.load(from: missing), [])
    }
}
