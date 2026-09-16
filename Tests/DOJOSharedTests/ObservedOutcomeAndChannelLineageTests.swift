import Foundation
import Testing
@testable import DOJOShared

@Suite("Observed outcomes and sovereign channel lineage")
struct ObservedOutcomeAndChannelLineageTests {
    private let now = Date(timeIntervalSince1970: 1_789_473_600)

    @Test("Observed outcome attributes only the bounded system relationship")
    func observedOutcomeAttribution() throws {
        let observation = try makeObservation()
        let endedAt = now.addingTimeInterval(4 * 60 * 60)
        let outcome = DojoObservedOutcome.record(
            observation: observation,
            endedAt: endedAt,
            primaryOutcome: .adjustmentExpiredNormally,
            supportingOutcomes: [.adjustmentApplied, .essentialCueProtected],
            nonessentialHapticsSuppressed: 3,
            essentialHapticsDelivered: 1,
            observerResponse: .noResponse,
            revertedAt: endedAt,
            notes: "No inference from observer silence."
        )

        #expect(outcome.feedbackSignalID == observation.feedbackSignal.id)
        #expect(outcome.receiptID == observation.evidenceReceipt.id)
        #expect(outcome.targetMurmurID == "watch_ultra_murmur")
        #expect(outcome.nonessentialHapticsSuppressed == 3)
        #expect(outcome.essentialHapticsDelivered == 1)
        #expect(outcome.observerResponse == .noResponse)
        #expect(outcome.interpretationBoundary == DojoObservedOutcome.interpretationLimit)
        #expect(outcome.invariantViolations().isEmpty)
    }

    @Test("Outcome rejects causal overclaim and inconsistent safety evidence")
    func hostileOutcomeFailsClosed() throws {
        let observation = try makeObservation()
        let outcome = DojoObservedOutcome(
            id: "",
            feedbackSignalID: "",
            receiptID: "",
            targetMurmurID: "general_decision_surface",
            observationStartedAt: now,
            observationEndedAt: now.addingTimeInterval(-1),
            signalExpiresAt: now.addingTimeInterval(60),
            policyVersion: "",
            primaryOutcome: .observerConfirmedUseful,
            supportingOutcomes: [.essentialCueProtected],
            nonessentialHapticsSuppressed: -1,
            essentialHapticsDelivered: 0,
            essentialHapticsLost: 1,
            blockedEscalationCount: -1,
            observerResponse: .noResponse,
            notes: "The observer agreed with DOJO.",
            interpretationBoundary: "The observer was diagnosed from silence."
        )

        #expect(!outcome.invariantViolations().isEmpty)
        #expect(outcome.invariantViolations().contains("observed outcome interpretation boundary was changed"))
        #expect(outcome.invariantViolations().contains("essential-cue protection cannot be claimed when a cue was lost"))
        #expect(observation.appliedAction == nil)
    }

    @Test("Observed outcome round trips through Codable")
    func observedOutcomeCodableRoundTrip() throws {
        let observation = try makeObservation()
        let outcome = DojoObservedOutcome.record(
            observation: observation,
            endedAt: now.addingTimeInterval(60),
            primaryOutcome: .observationIncomplete
        )

        #expect(
            try JSONDecoder().decode(
                DojoObservedOutcome.self,
                from: JSONEncoder().encode(outcome)
            ) == outcome
        )
    }

    @Test("Aikido Optics owns visual lineage while HAL coordinates only")
    func channelLineagesRemainDistinct() {
        let visual = SovereignChannelLineageContract.iPhone14CameraVisualLineage
        let acoustic = SovereignChannelLineageContract.arkadasAcousticLineage
        let coordinator = SovereignChannelLineageContract.halCoordinationLineage

        #expect(visual.channel == .aikidoOptics)
        #expect(visual.sourceSurfaceID == "iphone14_camera")
        #expect(visual.capabilityUsed == "cameraLensImageCapture")
        #expect(visual.coordinatorID == "hal")
        #expect(acoustic.channel == .arkadas)
        #expect(coordinator.channel == .hal)
        #expect(!visual.mappedCapabilityOwnsChannelIdentity)
        #expect(!visual.coordinatorOwnsSourceSignal)
        #expect(!coordinator.coordinatorOwnsSourceSignal)
        #expect(SovereignChannelLineageContract.invariantViolations().isEmpty)
    }

    @Test("Mapped capability and coordinator ownership claims fail closed")
    func hostileChannelLineageFailsClosed() {
        let hostile = ChannelLineageRef(
            channel: .aikidoOptics,
            geometricRole: "visualPatternAndSpatialRelationRecognition",
            sourceSurfaceID: "iphone14_camera",
            capabilityUsed: "cameraLensImageCapture",
            coordinatorID: "apple_camera",
            destinationSurfaceID: "field_macos_dojo_visual_surface",
            mappedCapabilityOwnsChannelIdentity: true,
            coordinatorOwnsSourceSignal: true,
            authorityEscalationAllowed: true
        )

        #expect(hostile.invariantViolations().contains("cross-channel coordinator must be HAL"))
        #expect(hostile.invariantViolations().contains("mapped Apple capability cannot own sovereign channel identity"))
        #expect(hostile.invariantViolations().contains("HAL coordinates but cannot own the source signal"))
        #expect(hostile.invariantViolations().contains("channel lineage cannot escalate authority"))
    }

    @Test("Channel lineage round trips through Codable")
    func channelLineageCodableRoundTrip() throws {
        let lineage = SovereignChannelLineageContract.iPhone14CameraVisualLineage

        #expect(
            try JSONDecoder().decode(
                ChannelLineageRef.self,
                from: JSONEncoder().encode(lineage)
            ) == lineage
        )
    }

    private func makeObservation() throws -> DojoMurmurFeedbackObservation {
        let target = try #require(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        let policy = FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy
        let cue = ReadinessCue(
            level: .low,
            hrvRatio: 0.75,
            rhrRatio: 1,
            hrvSDNNMilliseconds: 37.5,
            restingHeartRateBPM: 60,
            baselineHRVMilliseconds: 50,
            baselineRestingHeartRateBPM: 60,
            evaluatedAt: now,
            sourceSampleDate: now.addingTimeInterval(-300),
            sourceSampleIDs: ["hrv-opaque", "rhr-opaque"],
            baselineStartDate: now.addingTimeInterval(-30 * 86_400),
            baselineEndDate: now.addingTimeInterval(-86_400),
            baselineSampleCount: 14,
            consecutiveLowEvaluations: 2,
            quality: .valid
        )
        let snapshot = MurmurUtilisationSnapshot(
            capturedAt: now,
            openMinutes: 0.5,
            requestsPerMinute: 0.5,
            setpoints: policy.setpoints
        )
        return DojoNonVerbalFeedbackChannel.receive(
            readinessCue: cue,
            receivedAt: now.addingTimeInterval(60),
            preAdjustmentState: snapshot,
            policy: policy,
            sourceSurface: AppleWatchContract.appleWatchBiometric,
            targetSurface: target
        )
    }
}
