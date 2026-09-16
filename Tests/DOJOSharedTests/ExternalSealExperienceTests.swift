import XCTest
@testable import DOJOShared

/// Deterministic External Seal Experience contract tests.
/// Spec: docs/EXTERNAL_SEAL_EXPERIENCE_REFINEMENT_HANDOFF_V0.md
final class ExternalSealExperienceTests: XCTestCase {

    func testOriginatorCannotSelfSeal() {
        XCTAssertFalse(ESEStateMachine.originatorCanSelfSeal())
    }

    func testCandidateImmutableHashAfterSubmission() {
        let c = makeCandidate()
        XCTAssertTrue(c.hashIntact)
        XCTAssertEqual(c.recomputeHash(), c.candidateHash)
        // Any field change requires a new candidate identity — hash of altered body differs.
        let altered = ESESealCandidate(
            candidateId: c.candidateId,
            predecessorRunId: c.predecessorRunId,
            subjectObjectIds: c.subjectObjectIds,
            declaredOutcome: "tampered",
            expectedManifestation: c.expectedManifestation,
            acceptanceCriteria: c.acceptanceCriteria,
            forbiddenChanges: c.forbiddenChanges,
            evidenceAnchorPointers: c.evidenceAnchorPointers,
            knownUnknowns: c.knownUnknowns,
            knownHolds: c.knownHolds,
            originatingSurface: c.originatingSurface,
            originatingWeaver: c.originatingWeaver,
            submittedAt: c.submittedAt,
            candidateHash: c.candidateHash
        )
        XCTAssertFalse(altered.hashIntact)
    }

    func testCannotJumpCandidateReceivedToSealed() {
        var m = ESEStateMachine(candidateId: "c1")
        XCTAssertEqual(m.state, .candidateReceived)
        XCTAssertFalse(m.apply(.recordJudgementMatches))
        XCTAssertEqual(m.state, .candidateReceived)
    }

    func testOpeningIsNotVerification() {
        // candidateReceived announcement is arrival only
        var m = ESEStateMachine(candidateId: "c1")
        XCTAssertTrue(m.lastReturnMessage.contains("independent verification"))
        XCTAssertNotEqual(m.state, .sealed)
        XCTAssertTrue(m.apply(.identify))
        XCTAssertEqual(m.state, .identified)
        XCTAssertNotEqual(
            ESEStateMachine.returnState(machineState: m.state, judgement: nil, anchorsPresent: true),
            .sealed
        )
    }

    func testCalibrationMustTieToAcceptanceCriterion() {
        var m = ESEStateMachine(candidateId: "c1", calibrationTiedToCriterion: false)
        XCTAssertTrue(m.apply(.identify))
        XCTAssertTrue(m.apply(.presentDeclared))
        XCTAssertFalse(m.apply(.beginCalibration))
        XCTAssertEqual(m.state, .declaredPresented)

        let plan = ESEParticipatoryCalibrationPlan(
            planId: "cal1",
            candidateId: "c1",
            tiedAcceptanceCriterion: "Output route matches selected speaker",
            observerActionDescription: "Hear channel-identification tone on selected output",
            sensoryModalities: ["calibration_stimulus"],
            contributesToMeasurement: true,
            reversible: true,
            accessible: true
        )
        XCTAssertTrue(plan.isLawfulCalibration)

        let decorative = ESEParticipatoryCalibrationPlan(
            planId: "cal2",
            candidateId: "c1",
            tiedAcceptanceCriterion: "",
            observerActionDescription: "Pretty chime",
            sensoryModalities: ["theatre"],
            contributesToMeasurement: false,
            reversible: true,
            accessible: true
        )
        XCTAssertFalse(decorative.isLawfulCalibration)
    }

    func testMismatchProducesDeltaNeverSilentRepair() {
        var m = fullPathToComparison(anchors: true)
        XCTAssertTrue(m.apply(.recordJudgementDiffers))
        XCTAssertEqual(m.state, .delta)
        XCTAssertTrue(m.lastReturnMessage.contains("NOT SEALED"))
        // No automatic transition to sealed
        XCTAssertFalse(m.apply(.recordJudgementMatches))
    }

    func testMissingAnchorProducesIntentionallyUnsealedWithReturnPoint() {
        var m = fullPathToComparison(anchors: false)
        XCTAssertTrue(m.apply(.recordJudgementMatches))
        XCTAssertEqual(m.state, .intentionallyUnsealed)
        XCTAssertTrue(m.lastReturnMessage.contains("NOT SEALED"))
        XCTAssertTrue(m.lastReturnMessage.contains("Return point"))
        XCTAssertTrue(m.lastReturnMessage.contains("anchors") || m.lastReturnMessage.contains("Missing"))
    }

    func testHappyPathSealWithAnchors() {
        var m = fullPathToComparison(anchors: true)
        XCTAssertTrue(m.apply(.recordJudgementMatches))
        XCTAssertEqual(m.state, .sealed)
        XCTAssertEqual(m.lastReturnMessage, "SEALED")
        XCTAssertEqual(
            ESEStateMachine.returnState(
                machineState: m.state,
                judgement: .valid,
                anchorsPresent: true
            ),
            .sealed
        )
    }

    func testMaterialChangeInvalidatesSealInheritance() {
        XCTAssertTrue(ESEConfigurationEpochRules.materialChangeInvalidatesInheritance())
        let epoch = sampleEpoch(active: true)
        let change = ESEMaterialChangeDelta(
            deltaId: "d1",
            epochId: epoch.epochId,
            changeClass: "microphone_route_change",
            description: "Preferred mic changed",
            detectedAt: "2026-08-07T16:40:00+10:00",
            invalidatesSealInheritance: true
        )
        XCTAssertTrue(change.invalidatesSealInheritance)
        let (frozen, request) = ESEConfigurationEpochRules.applyMaterialChange(
            activeEpoch: epoch,
            change: change
        )
        XCTAssertFalse(frozen.active)
        XCTAssertEqual(request.predecessorEpochId, epoch.epochId)
        XCTAssertEqual(request.materialChangeDeltaId, change.deltaId)
        XCTAssertFalse(request.returnPoint.isEmpty)
    }

    func testPredecessorEpochRemainsIntactAndSuccessorLinks() {
        let pred = sampleEpoch(active: false)
        let succ = ESEConfigurationEpochRules.linkSuccessor(
            predecessor: pred,
            newEpochId: "epoch.successor",
            candidateId: "cand.new",
            sealedAt: "2026-08-07T17:00:00+10:00"
        )
        XCTAssertEqual(succ.predecessorEpochIdOrUnknown, pred.epochId)
        XCTAssertTrue(succ.active)
        // Predecessor object unchanged
        XCTAssertEqual(pred.epochId, "epoch.pred")
        XCTAssertFalse(pred.active)
    }

    func testEmergencyFailSafeUnsealsWithoutResealClaim() {
        var m = fullPathToComparison(anchors: true)
        XCTAssertTrue(m.apply(.recordJudgementMatches))
        XCTAssertEqual(m.state, .sealed)
        XCTAssertTrue(m.apply(.emergencyFailSafe))
        XCTAssertEqual(m.state, .intentionallyUnsealed)
        XCTAssertTrue(m.lastReturnMessage.hasPrefix("NOT SEALED"))
        // Must not claim a successful SEALED return after fail-safe
        XCTAssertNotEqual(m.lastReturnMessage.trimmingCharacters(in: .whitespacesAndNewlines), "SEALED")
    }

    func testSensoryLayersRemainDistinctLabels() {
        let layers = Set(ESESensoryLayer.allCases.map(\.rawValue))
        XCTAssertEqual(layers.count, 4)
        XCTAssertTrue(layers.contains("audioInput"))
        XCTAssertTrue(layers.contains("calibrationStimulus"))
        XCTAssertTrue(layers.contains("assistanceOutput"))
        XCTAssertTrue(layers.contains("observerAcknowledgement"))
    }

    // MARK: - Helpers

    private func makeCandidate() -> ESESealCandidate {
        ESESealCandidate(
            predecessorRunId: "run.oaa.seat",
            subjectObjectIds: ["voice.capture.settings.mac"],
            declaredOutcome: "Preferred mic selectable and test capture produces measurable level",
            expectedManifestation: "Settings → Voice & capture shows permission, pickers, Test capture",
            acceptanceCriteria: [
                "Mic permission status visible",
                "Input/output pickers list system default + devices",
                "Test capture reports level without claiming STT"
            ],
            forbiddenChanges: [
                "Fake STT success",
                "Self-seal from originating weave",
                "Collapse audio input with assistance output"
            ],
            evidenceAnchorPointers: [
                "docs/EXTERNAL_SEAL_EXPERIENCE_REFINEMENT_HANDOFF_V0.md",
                "Sources/DOJOApp/Services/VoiceCaptureSettingsModel.swift"
            ],
            knownUnknowns: ["Live Hermen dock not verified"],
            knownHolds: ["HOLD.NOT_IMPLEMENTED_OR_VERIFIED live physical seal"],
            originatingSurface: "DOJOApp.Settings.VoiceCapture",
            originatingWeaver: "grok-oaw",
            submittedAt: "2026-08-07T16:35:00+10:00"
        )
    }

    private func fullPathToComparison(anchors: Bool) -> ESEStateMachine {
        var m = ESEStateMachine(
            candidateId: "c-path",
            anchorsPresent: anchors,
            calibrationTiedToCriterion: true
        )
        XCTAssertTrue(m.apply(.identify))
        XCTAssertTrue(m.apply(.presentDeclared))
        XCTAssertTrue(m.apply(.beginCalibration))
        XCTAssertTrue(m.apply(.completeCalibration))
        XCTAssertTrue(m.apply(.readyForComparison))
        XCTAssertEqual(m.state, .comparisonReady)
        return m
    }

    private func sampleEpoch(active: Bool) -> ESEConfigurationEpoch {
        ESEConfigurationEpoch(
            epochId: "epoch.pred",
            candidateId: "cand.1",
            physicalIdentity: "Mac Studio + selected mic",
            digitalIdentity: "org.field.dojo VoiceCapture prefs",
            hardwareFirmwareState: "Unknown",
            channelMap: ["sense": "mic", "assist": "speakers"],
            executionHost: "Mac",
            humanInputSurface: "microphone_intention_input",
            activeEnvironmentalAttentionSurface: "desktop_settings",
            permissionState: "mic_allowed",
            authorityCeilings: ["OBSERVE_ONLY", "LOCAL_PREPARE_ONLY"],
            calibrationResults: ["test_capture": "level_ok"],
            observerJudgement: .valid,
            evidenceAnchors: ["anchor.1"],
            receiptPointer: "Unknown",
            sealedAt: "2026-08-07T16:00:00+10:00",
            predecessorEpochIdOrUnknown: "Unknown",
            active: active
        )
    }
}
