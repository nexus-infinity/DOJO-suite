import XCTest
@testable import DOJOShared

final class TodayProcessingPacketTests: XCTestCase {
    func testMissingProcessingStateRemainsExplicitlyIncomplete() {
        let packet = TodayProcessingPacket(
            packetID: "today-hold-1",
            resolution: .hold,
            holdReason: "No witnessed processing result"
        )

        XCTAssertFalse(packet.isComplete)
        XCTAssertFalse(packet.mayProjectResolvedState)
        XCTAssertEqual(packet.evidenceState, .unknown)
        XCTAssertEqual(packet.arkadas.continuity, .unknown)
    }

    func testCompletePacketKeepsProcessingFieldsSeparateFromPresentation() {
        let packet = TodayProcessingPacket(
            packetID: "today-ready-1",
            currentObjectID: "object-1",
            intention: "Verify the selected object",
            intendedSequence: ["select", "inspect", "compare"],
            minimumSteps: ["select", "inspect"],
            evaluationQuestion: "Does the evidence support the intended result?",
            unresolvedDecision: "PROMOTE or HOLD",
            evidenceState: .witnessed,
            resolution: .ready,
            arkadas: .init(
                continuity: .continuous,
                disagreement: .noneObserved,
                source: "Arkadaş"
            ),
            source: "Today processing",
            observedAt: Date(timeIntervalSince1970: 0)
        )

        XCTAssertTrue(packet.isComplete)
        XCTAssertTrue(packet.mayProjectResolvedState)
        XCTAssertEqual(packet.intendedSequence, ["select", "inspect", "compare"])
        XCTAssertEqual(packet.minimumSteps, ["select", "inspect"])
        XCTAssertEqual(packet.evaluationQuestion, "Does the evidence support the intended result?")
    }

    func testDisagreementPreventsResolvedProjectionWithoutErasingThePacket() {
        let packet = TodayProcessingPacket(
            packetID: "today-disagreement-1",
            currentObjectID: "object-1",
            intention: "Compare two states",
            intendedSequence: ["observe", "compare"],
            minimumSteps: ["observe"],
            evaluationQuestion: "Do the states agree?",
            unresolvedDecision: "HOLD",
            evidenceState: .witnessed,
            resolution: .hold,
            holdReason: "Arkadaş disagreement detected",
            arkadas: .init(
                continuity: .continuous,
                disagreement: .detected,
                source: "Arkadaş"
            ),
            source: "Today processing"
        )

        XCTAssertTrue(packet.isComplete)
        XCTAssertFalse(packet.mayProjectResolvedState)
        XCTAssertEqual(packet.arkadas.disagreement, .detected)
        XCTAssertEqual(packet.holdReason, "Arkadaş disagreement detected")
    }

    func testPortalResponseProducesObjectScopedHoldWithoutInventingProcessingMeaning() {
        let packet = TodayProcessingPacket.portalResponseHold(
            objectID: "object-portal-1",
            observedAt: Date(timeIntervalSince1970: 0)
        )

        XCTAssertEqual(packet.currentObjectID, "object-portal-1")
        XCTAssertEqual(packet.resolution, .hold)
        XCTAssertEqual(packet.evidenceState, .partial)
        XCTAssertNil(packet.intention)
        XCTAssertTrue(packet.intendedSequence.isEmpty)
        XCTAssertTrue(packet.minimumSteps.isEmpty)
        XCTAssertNil(packet.evaluationQuestion)
        XCTAssertEqual(packet.arkadas.continuity, .unknown)
        XCTAssertFalse(packet.mayProjectResolvedState)
    }
}
