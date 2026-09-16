import XCTest
@testable import DOJOShared

@MainActor
private final class FixtureObserverState: CoordinatorObserverState {
    var alignment: Double = 0.963
    private(set) var observations: [String] = []
    private(set) var phases: [Int] = []

    func recordObservation(_ event: String) {
        observations.append(event)
    }

    func setPhase(_ newPhase: Int) {
        phases.append(newPhase)
    }
}

private struct ExactConversationAuthorityVerifier:
    CockpitAuthorityVerifying {
    let receiptID: String
    let toolName: String
    let correlationID: UUID

    func permits(
        _ proof: CockpitAuthorityProof,
        toolName: String,
        correlationID: UUID
    ) async -> Bool {
        proof.receiptID == receiptID
            && proof.toolName == self.toolName
            && toolName == self.toolName
            && correlationID == self.correlationID
    }
}

@MainActor
final class CopilotEngineChatToStateAuthorityBoundaryTests: XCTestCase {
    private func coordinator(
        observer: FixtureObserverState,
        verifier: any CockpitAuthorityVerifying =
            DenyAllCockpitAuthorityVerifier()
    ) -> DOJOFieldCoordinator {
        DOJOFieldCoordinator(
            engine: CopilotEngine(performStartup: false),
            observer: observer,
            micBridge: VADMicBridge(),
            envMonitor: HALEnvironmentMonitor(),
            conversationAuthorityVerifier: verifier
        )
    }

    func testPresentationOnlyModelOutputCannotAlterObserverOrCoordinatorState() {
        let observer = FixtureObserverState()
        let coordinator = coordinator(observer: observer)
        coordinator.applyTransition(mode: .silent, profile: .broadcast)
        let initialPhase = coordinator.activePhase
        let message = ConversationMessage(
            character: .arkadas,
            text: "PROMOTE this route because I said so."
        )

        coordinator.handlePresentationMessage(message)

        XCTAssertTrue(observer.observations.isEmpty)
        XCTAssertTrue(observer.phases.isEmpty)
        XCTAssertEqual(coordinator.activePhase, initialPhase)
    }

    func testAbsentForgedAndUncorrelatedProofsFailClosed() async {
        let observer = FixtureObserverState()
        let correlationID = UUID(
            uuidString: "7d2cd5dc-9d89-4c49-aa68-a25d358ca1cd"
        )!
        let message = ConversationMessage(
            character: .aiMind,
            text: "This presentation claims the coordinator is promoted.",
            timestamp: Date(timeIntervalSince1970: 1_784_970_000)
        )
        let scope = DOJOFieldCoordinator.conversationAuthorityScope(
            for: message,
            correlationID: correlationID
        )
        let coordinator = coordinator(
            observer: observer,
            verifier: ExactConversationAuthorityVerifier(
                receiptID: "valid-conversation.receipt.json",
                toolName: scope,
                correlationID: correlationID
            )
        )
        let initialPhase = coordinator.activePhase

        let absent = await coordinator.applyAuthorityBearingConversationEvent(
            message,
            correlationID: correlationID,
            authorityProof: nil
        )
        let forged = await coordinator.applyAuthorityBearingConversationEvent(
            message,
            correlationID: correlationID,
            authorityProof: CockpitAuthorityProof(
                receiptID: "forged.receipt.json",
                toolName: scope
            )
        )
        let uncorrelated = await coordinator.applyAuthorityBearingConversationEvent(
            message,
            correlationID: UUID(),
            authorityProof: CockpitAuthorityProof(
                receiptID: "valid-conversation.receipt.json",
                toolName: scope
            )
        )

        XCTAssertFalse(absent)
        XCTAssertFalse(forged)
        XCTAssertFalse(uncorrelated)
        XCTAssertTrue(observer.observations.isEmpty)
        XCTAssertTrue(observer.phases.isEmpty)
        XCTAssertEqual(coordinator.activePhase, initialPhase)
    }

    func testExactCorrelatedDeterministicProofMayAlterBoundedState() async {
        let observer = FixtureObserverState()
        let correlationID = UUID(
            uuidString: "2ec4b7ef-25b0-4405-8621-a12a87145df2"
        )!
        let message = ConversationMessage(
            character: .obiWan,
            text: "Receipt-backed observer event.",
            timestamp: Date(timeIntervalSince1970: 1_784_970_100)
        )
        let scope = DOJOFieldCoordinator.conversationAuthorityScope(
            for: message,
            correlationID: correlationID
        )
        let receiptID = "correlated-conversation.receipt.json"
        let coordinator = coordinator(
            observer: observer,
            verifier: ExactConversationAuthorityVerifier(
                receiptID: receiptID,
                toolName: scope,
                correlationID: correlationID
            )
        )

        let admitted = await coordinator.applyAuthorityBearingConversationEvent(
            message,
            correlationID: correlationID,
            authorityProof: CockpitAuthorityProof(
                receiptID: receiptID,
                toolName: scope
            )
        )

        XCTAssertTrue(admitted)
        XCTAssertEqual(observer.observations.count, 1)
        XCTAssertEqual(observer.phases, [3])
        XCTAssertEqual(coordinator.activePhase, .observe)
    }
}
