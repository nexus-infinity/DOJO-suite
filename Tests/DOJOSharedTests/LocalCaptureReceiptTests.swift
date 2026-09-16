import XCTest
@testable import DOJOShared

final class LocalCaptureReceiptTests: XCTestCase {
    func testContentDigestIsStableForSameObjectFields() {
        let date = Date(timeIntervalSince1970: 1_735_689_600)
        let first = LocalCaptureReceipt.contentDigest(
            objectID: "object-1",
            kind: "document",
            home: "captures",
            title: "A note",
            body: "The captured body",
            subtitle: "Local capture",
            createdAt: date,
            sourcePrompt: "The captured body"
        )
        let second = LocalCaptureReceipt.contentDigest(
            objectID: "object-1",
            kind: "document",
            home: "captures",
            title: "A note",
            body: "The captured body",
            subtitle: "Local capture",
            createdAt: date,
            sourcePrompt: "The captured body"
        )

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.count, 64)
    }

    func testReceiptRoundTripsWithItsEvidenceFields() throws {
        let receipt = LocalCaptureReceipt(
            receiptID: "receipt-1",
            objectID: "object-1",
            surface: "DOJO Today · macOS",
            operation: "local_capture",
            result: "CAPTURED",
            issuedAt: Date(timeIntervalSince1970: 1_735_689_600),
            contentSHA256: String(repeating: "a", count: 64),
            objectPath: "/tmp/generated_objects.json",
            receiptPath: "/tmp/local_capture_receipts.jsonl"
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(receipt)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        XCTAssertEqual(try decoder.decode(LocalCaptureReceipt.self, from: data), receipt)
    }

    func testComposerOperationsRemainDistinctNamedSeams() {
        XCTAssertEqual(LocalCaptureReceipt.Operation.capture, "local_capture")
        XCTAssertEqual(LocalCaptureReceipt.Operation.hostedAnswer, "hosted_answer")
        XCTAssertEqual(LocalCaptureReceipt.Operation.portalResponse, "portal_response")
        XCTAssertNotEqual(
            LocalCaptureReceipt.Operation.capture,
            LocalCaptureReceipt.Operation.hostedAnswer
        )
        XCTAssertEqual(LocalCaptureReceipt.Outcome.captured, "CAPTURED")
        XCTAssertEqual(LocalCaptureReceipt.Outcome.completed, "COMPLETED")
    }
}
