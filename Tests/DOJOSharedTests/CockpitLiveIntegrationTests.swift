import Foundation
import XCTest
@testable import DOJOShared

final class CockpitLiveIntegrationTests: XCTestCase {
    func testProductionClientReplaysSameSyntheticSpecimen() async throws {
        guard ProcessInfo.processInfo.environment["FIELD_LIVE_COCKPIT_REPLAY"] == "1" else {
            throw XCTSkip("Set FIELD_LIVE_COCKPIT_REPLAY=1 for the bounded live replay.")
        }

        let client = SpinningTopClient(baseURL: "http://127.0.0.1:7410")
        let response = try await client.sendMessage(
            "FIELD_RUNTIME_FIXTURE_20260830: observe pattern when date path map truth",
            character: "padawan"
        )

        XCTAssertEqual(response.chamber, "DOJO")
        XCTAssertEqual(response.frequency, 741)
        XCTAssertTrue(response.status == "ok" || response.status == "inference_unavailable")
    }

    func testLiveReadOnlyDOJOStatusPreservesCorrelation() async throws {
        guard ProcessInfo.processInfo.environment["FIELD_LIVE_COCKPIT_REPLAY"] == "1" else {
            throw XCTSkip("Set FIELD_LIVE_COCKPIT_REPLAY=1 for the bounded live replay.")
        }

        let correlationID = UUID()
        let client = SpinningTopClient(baseURL: "http://127.0.0.1:7410")
        let receipt = try await client.callTool(
            name: "dojo_status",
            effect: .readOnly,
            correlationID: correlationID
        )

        XCTAssertEqual(receipt.correlationID, correlationID)
        XCTAssertEqual(receipt.toolName, "dojo_status")
        XCTAssertEqual(receipt.effect, .readOnly)
        XCTAssertEqual(receipt.httpStatus, 200)

        let response = try XCTUnwrap(
            JSONSerialization.jsonObject(with: receipt.responseBody) as? [String: Any]
        )
        XCTAssertEqual(response["correlation_id"] as? String, correlationID.uuidString)
        XCTAssertEqual(response["name"] as? String, "DOJO")
        XCTAssertEqual(response["status"] as? String, "operational")
    }
}
