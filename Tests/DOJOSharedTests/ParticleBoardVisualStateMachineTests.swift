import XCTest
@testable import DOJOUI

final class ParticleBoardVisualStateMachineTests: XCTestCase {
    func testValidStateTransitionsReachRevealed() {
        let envelope = ParticleBoardSampleArtifact.eligibleEnvelope()

        XCTAssertEqual(ParticleBoardStateMachine.reduce(state: .quiet, event: .chooseLucid).state, .lucid)
        XCTAssertEqual(ParticleBoardStateMachine.reduce(state: .lucid, event: .introduceDraft(envelope)).state, .receivingCandidate)
        XCTAssertEqual(ParticleBoardStateMachine.reduce(state: .receivingCandidate, event: .evaluate).state, .evaluatingPresentation)
        XCTAssertEqual(ParticleBoardStateMachine.evaluateCandidate(envelope).state, .attracting)
        XCTAssertEqual(ParticleBoardStateMachine.reduce(state: .attracting, event: .advance).state, .crystallizing)
        XCTAssertEqual(ParticleBoardStateMachine.reduce(state: .crystallizing, event: .advance).state, .revealed)
    }

    func testInvalidTransitionsFailClosed() {
        let decision = ParticleBoardStateMachine.reduce(state: .quiet, event: .advance)

        XCTAssertEqual(decision.state, .quiet)
        XCTAssertFalse(decision.accepted)
    }

    func testHeldDraftCannotReachAttractingOrRevealed() {
        let envelope = ParticleBoardSampleArtifact.heldEnvelope()
        let decision = ParticleBoardStateMachine.evaluateCandidate(envelope)

        XCTAssertEqual(decision.state, .held)
        XCTAssertTrue(decision.holdReasons.contains(.authority))
        XCTAssertFalse(ParticleBoardStateMachine.canRevealContent(state: .held, envelope: envelope))
    }

    func testUnknownDraftCannotRevealContent() {
        let envelope = ParticleBoardSampleArtifact.unknownEnvelope()
        let decision = ParticleBoardStateMachine.evaluateCandidate(envelope)

        XCTAssertEqual(decision.state, .unknown)
        XCTAssertTrue(decision.unknownDimensions.contains(.source))
        XCTAssertFalse(ParticleBoardStateMachine.canRevealContent(state: .unknown, envelope: envelope))
    }

    func testDismissReturnsToQuiet() {
        let dissolving = ParticleBoardStateMachine.reduce(state: .revealed, event: .dismiss)
        let returned = ParticleBoardStateMachine.reduce(state: dissolving.state, event: .advance)
        let quiet = ParticleBoardStateMachine.reduce(state: returned.state, event: .advance)

        XCTAssertEqual(dissolving.state, .dissolving)
        XCTAssertEqual(returned.state, .returned)
        XCTAssertEqual(quiet.state, .quiet)
    }

    func testSaveSendPublishApplicationControlAndConsentRemainFalse() {
        let envelope = ParticleBoardSampleArtifact.eligibleEnvelope()

        XCTAssertFalse(envelope.saveEnabled)
        XCTAssertFalse(envelope.sendEnabled)
        XCTAssertFalse(envelope.publishEnabled)
        XCTAssertFalse(envelope.applicationControlEnabled)
        XCTAssertFalse(envelope.consentInferred)
        XCTAssertTrue(envelope.sideEffectsRemainClosed)
        XCTAssertTrue(envelope.phenotype.preservesRuntimeBoundary)
    }

    func testEnvelopeCodableRoundTripPreservesClosedSideEffects() throws {
        let envelope = ParticleBoardSampleArtifact.eligibleEnvelope()

        let data = try JSONEncoder().encode(envelope)
        let decoded = try JSONDecoder().decode(DraftManifestationEnvelope.self, from: data)

        XCTAssertEqual(decoded, envelope)
        XCTAssertTrue(decoded.sideEffectsRemainClosed)
        XCTAssertTrue(decoded.isPresentationEligible)
    }

    func testContractTypesAreSendableCompatible() {
        assertSendable(ParticleBoardVisualState.quiet)
        assertSendable(ParticleBoardSampleArtifact.eligibleEnvelope())
        assertSendable(ParticleBoardTransitionDecision(state: .quiet, accepted: true))
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
