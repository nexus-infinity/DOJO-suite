import XCTest
@testable import DOJOShared

final class FieldSurfaceEnvironmentalFeedbackTests: XCTestCase {
    func testPacketKeepsSurfaceEnvironmentSourceAndReceiptDistinct() throws {
        let packet = FieldSurfaceEnvironmentalFeedbackPacket(
            id: "FIELD_LIVE_LOCAL_HEALTH_20260914T124222",
            surfaceID: "kings_chamber",
            environmentID: "local_mac_studio:host_loopback",
            feedbackKind: .localRuntimeHealth,
            observedAt: Date(timeIntervalSince1970: 1_757_816_662),
            sourcePointer: "http://127.0.0.1:8520/health",
            observedState: "HTTP_200_HEALTHY",
            receiptPointer: "/Users/field/◎Kings-Chamber/chronicle/FIELD_LIVE_LOCAL_RUNTIME_FEEDBACK_20260914_024222.receipt.json"
        )

        XCTAssertTrue(packet.invariantViolations().isEmpty)
        XCTAssertNotEqual(packet.surfaceID, packet.environmentID)
        XCTAssertNotEqual(packet.sourcePointer, packet.receiptPointer)
        XCTAssertEqual(packet.authorityCeiling, "OBSERVATION_ONLY")
        XCTAssertFalse(packet.globalFieldAuthority)
    }

    func testPacketCodableRoundTripPreservesEvidenceBoundaries() throws {
        let packet = FieldSurfaceEnvironmentalFeedbackPacket(
            id: "feedback-1",
            genotypeID: FieldSurfaceCoordinationCatalog.genotypeID,
            surfaceID: "obiwan",
            environmentID: "local_mac_studio:host_loopback",
            feedbackKind: .localRuntimeHealth,
            observedAt: Date(timeIntervalSince1970: 1_757_816_662),
            sourcePointer: "http://127.0.0.1:8520/health",
            observedState: "accepted_and_stored",
            receiptPointer: "chronicle/feedback.receipt.json"
        )

        let encoded = try JSONEncoder().encode(packet)
        let decoded = try JSONDecoder().decode(FieldSurfaceEnvironmentalFeedbackPacket.self, from: encoded)
        XCTAssertEqual(decoded, packet)
    }

    func testPacketRejectsCollapsedOrUnboundEvidenceShape() {
        let packet = FieldSurfaceEnvironmentalFeedbackPacket(
            id: "",
            surfaceID: "same",
            environmentID: "same",
            feedbackKind: .unknown,
            observedAt: Date(timeIntervalSince1970: 0),
            sourcePointer: "",
            observedState: "",
            authorityCeiling: "",
            receiptPointer: "",
            globalFieldAuthority: true
        )

        let violations = packet.invariantViolations()
        XCTAssertTrue(violations.contains("feedback packet ID is empty"))
        XCTAssertTrue(violations.contains("surface and environment are collapsed"))
        XCTAssertTrue(violations.contains("feedback source pointer is empty"))
        XCTAssertTrue(violations.contains("feedback receipt pointer is empty"))
        XCTAssertTrue(violations.contains("environmental feedback claims global FIELD authority"))
    }

    func testPacketRejectsGenotypeDrift() {
        let packet = FieldSurfaceEnvironmentalFeedbackPacket(
            id: "feedback-drift",
            genotypeID: "OTHER.GENOTYPE",
            surfaceID: "obiwan",
            environmentID: "local_mac_studio:host_loopback",
            feedbackKind: .unknown,
            observedAt: Date(timeIntervalSince1970: 0),
            sourcePointer: "source",
            observedState: "unknown",
            receiptPointer: "receipt"
        )

        XCTAssertEqual(packet.invariantViolations(), ["feedback genotype drift"])
    }
}
