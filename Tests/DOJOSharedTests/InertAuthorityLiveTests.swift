import Foundation
import XCTest
@testable import DOJOShared

final class InertAuthorityLiveTests: XCTestCase {
    func testSingleUseInertAuthorityAndReplayRejection() async throws {
        let environment = ProcessInfo.processInfo.environment
        guard environment["FIELD_LIVE_INERT_AUTHORITY"] == "1" else {
            throw XCTSkip("Set FIELD_LIVE_INERT_AUTHORITY=1 for the bounded fixture.")
        }

        let receiptID = try XCTUnwrap(environment["FIELD_INERT_RECEIPT_ID"])
        let nonce = try XCTUnwrap(environment["FIELD_INERT_NONCE"])
        let correlationID = try XCTUnwrap(
            UUID(uuidString: try XCTUnwrap(environment["FIELD_INERT_CORRELATION_ID"]))
        )
        let verificationID = UUID()
        let proof = CockpitAuthorityProof(
            receiptID: receiptID,
            toolName: "inert_authority_echo_v0",
            nonce: nonce,
            verificationID: verificationID
        )
        let arguments = [
            "simulation": "KC_DOJO_INERT_MUTATION_SIMULATION_V0",
            "intent": "prove_single_use_tool_scoped_authority",
            "payload": "noop",
        ]
        let client = SpinningTopClient(baseURL: "http://127.0.0.1:7410")

        let first = try await client.callTool(
            name: "inert_authority_echo_v0",
            arguments: arguments,
            effect: .consequential,
            correlationID: correlationID,
            authorityProof: proof
        )
        let body = try XCTUnwrap(
            JSONSerialization.jsonObject(with: first.responseBody) as? [String: Any]
        )
        XCTAssertEqual(body["correlation_id"] as? String, correlationID.uuidString)
        XCTAssertEqual(body["cockpit_verification_id"] as? String, verificationID.uuidString)
        XCTAssertEqual(body["tool_name"] as? String, "inert_authority_echo_v0")
        XCTAssertEqual(body["result"] as? String, "NOOP")
        XCTAssertEqual(body["permitted"] as? Bool, true)

        do {
            _ = try await client.callTool(
                name: "inert_authority_echo_v0",
                arguments: arguments,
                effect: .consequential,
                correlationID: correlationID,
                authorityProof: proof
            )
            XCTFail("Second use must be rejected")
        } catch SpinningTopClient.SpinningTopError.permissionDenied {
            // Cockpit verification sees the consumed receipt and stops replay
            // before the second DOJO dispatch.
        } catch {
            XCTFail("Unexpected replay error: \(error)")
        }
    }
}
