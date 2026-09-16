import Foundation
import XCTest
@testable import DOJOShared

final class ArkadasCorrelatedAdapterLiveTests: XCTestCase {
    func testProductionClientConsumesCorrelatedReadOnlyArkadasStatusReceipt() async throws {
        let correlationID = UUID()
        let client = SpinningTopClient(baseURL: "http://127.0.0.1:7170")

        let receipt = try await client.callTool(
            name: "arkadas_status",
            effect: .readOnly,
            correlationID: correlationID
        )

        XCTAssertEqual(receipt.correlationID, correlationID)
        XCTAssertEqual(receipt.toolName, "arkadas_status")
        XCTAssertEqual(receipt.effect, .readOnly)
        XCTAssertEqual(receipt.httpStatus, 200)

        let body = try XCTUnwrap(
            JSONSerialization.jsonObject(with: receipt.responseBody) as? [String: Any]
        )
        XCTAssertEqual(body["correlation_id"] as? String, correlationID.uuidString)
        XCTAssertEqual(body["tool"] as? String, "arkadas_status")
        XCTAssertEqual(body["effect"] as? String, "readOnly")

        let transportReceipt = try XCTUnwrap(
            body["transport_receipt"] as? [String: Any]
        )
        XCTAssertEqual(
            transportReceipt["schema_id"] as? String,
            "ARKADAS_CORRELATED_READONLY_TRANSPORT_RECEIPT_V0"
        )
        XCTAssertEqual(transportReceipt["chamber"] as? String, "arkadas")
        XCTAssertEqual(transportReceipt["port"] as? Int, 7170)
        XCTAssertEqual(
            transportReceipt["correlation_id"] as? String,
            correlationID.uuidString
        )
    }
}
