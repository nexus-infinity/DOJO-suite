import Foundation
import Testing
@testable import DOJOShared

@Suite("DOJO non-verbal feedback channel")
struct DojoNonVerbalFeedbackChannelTests {
    private let observedAt = Date(timeIntervalSince1970: 1_789_473_600)

    @Test("Observe-only records persistent low without applying a haptic action")
    func observeOnlyDoesNotActuate() throws {
        let observation = try receive(cue: cue(level: .low, consecutiveLowCount: 2))

        #expect(observation.operationMode == .observeOnly)
        #expect(observation.proposedAction == .dampenHaptics)
        #expect(observation.appliedAction == nil)
        #expect(observation.wasPersistentDampening == false)
        #expect(observation.outcome == .observedOnly)
        #expect(observation.preAdjustmentState.openMinutes == observation.postAdjustmentState.openMinutes)
        #expect(observation.preAdjustmentState.requestsPerMinute == observation.postAdjustmentState.requestsPerMinute)
        #expect(observation.preAdjustmentState.setpoints == observation.postAdjustmentState.setpoints)
        #expect(observation.postAdjustmentState.capturedAt > observation.preAdjustmentState.capturedAt)
    }

    @Test("Signal permits only temporary interface-capacity interpretation")
    func signalCarriesSemanticBoundary() throws {
        let observation = try receive(cue: cue(level: .medium))
        let signal = observation.feedbackSignal

        #expect(signal.sourceSystem == "apple_watch_biometric")
        #expect(signal.receivingSystem == "DOJO")
        #expect(signal.targetMurmurID == "watch_ultra_murmur")
        #expect(signal.kind == .readinessCapacity)
        #expect(signal.permittedInterpretation == DojoNonVerbalFeedbackSignal.permittedReadinessInterpretation)
        #expect(signal.prohibitedInterpretations.contains("medical diagnosis"))
        #expect(signal.prohibitedInterpretations.contains("observer identity classification"))
        #expect(signal.prohibitedInterpretations.contains("PULSE coherence state"))
        #expect(signal.prohibitedInterpretations.contains("SOMA phase determination"))
        #expect(signal.invariantViolations().isEmpty)
    }

    @Test("Unknown readiness is held without inference or actuation")
    func unknownHolds() throws {
        let observation = try receive(cue: cue(level: .unknown, quality: .missing))

        #expect(observation.feedbackSignal.confidence == .unavailable)
        #expect(observation.outcome == .heldForInsufficientEvidence)
        #expect(observation.proposedAction == .hold)
        #expect(observation.appliedAction == nil)
        #expect(observation.holdReasons.contains("HOLD.ReadinessEvidenceUnavailable"))
    }

    @Test("Unpromoted modes fail closed")
    func unpromotedModesHold() throws {
        for mode in [DojoFeedbackOperationMode.shadow, .live] {
            let observation = try receive(cue: cue(level: .low, consecutiveLowCount: 2), mode: mode)

            #expect(observation.outcome == .heldForInsufficientEvidence)
            #expect(observation.appliedAction == nil)
            #expect(observation.holdReasons.contains("HOLD.FeedbackModeNotPromoted"))
        }
    }

    @Test("Expired feedback signal fails closed")
    func expiredSignalHolds() throws {
        let observation = try receive(
            cue: cue(level: .medium),
            receivedAt: observedAt.addingTimeInterval(7 * 60 * 60)
        )

        #expect(observation.outcome == .heldForInsufficientEvidence)
        #expect(observation.appliedAction == nil)
        #expect(observation.holdReasons.contains("HOLD.FeedbackSignalExpired"))
        #expect(!observation.feedbackSignal.invariantViolations().isEmpty)
    }

    @Test("Authority mismatch remains held at the feedback boundary")
    func authorityMismatchHolds() throws {
        let target = try #require(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        let hostileTarget = FieldSurfaceNode(
            id: target.id,
            displayName: target.displayName,
            kind: target.kind,
            outputChannels: target.outputChannels,
            inputChannels: target.inputChannels,
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: target.configuration.allowedProjections,
                allowedActions: target.configuration.allowedActions,
                permissionProfile: target.configuration.permissionProfile,
                authorityCeiling: "GENERAL_DECISION_AUTHORITY",
                globalFieldAuthority: true
            ),
            infrastructure: target.infrastructure,
            utilisation: target.utilisation
        )
        let observation = receive(
            cue: cue(level: .high),
            sourceSurface: AppleWatchContract.appleWatchBiometric,
            targetSurface: hostileTarget
        )

        #expect(observation.outcome == .heldForInsufficientEvidence)
        #expect(observation.proposedAction == .hold)
        #expect(observation.appliedAction == nil)
        #expect(observation.holdReasons.contains("HOLD.ReadinessTargetAuthorityMismatch"))
    }

    @Test("Signal and observation round trip through Codable")
    func codableRoundTrip() throws {
        let observation = try receive(cue: cue(level: .low, consecutiveLowCount: 2))
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        #expect(
            try decoder.decode(
                DojoNonVerbalFeedbackSignal.self,
                from: encoder.encode(observation.feedbackSignal)
            ) == observation.feedbackSignal
        )
        #expect(
            try decoder.decode(
                DojoMurmurFeedbackObservation.self,
                from: encoder.encode(observation)
            ) == observation
        )
    }

    private func receive(
        cue: ReadinessCue,
        mode: DojoFeedbackOperationMode = .observeOnly,
        receivedAt: Date? = nil
    ) throws -> DojoMurmurFeedbackObservation {
        let target = try #require(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        return receive(
            cue: cue,
            sourceSurface: AppleWatchContract.appleWatchBiometric,
            targetSurface: target,
            mode: mode,
            receivedAt: receivedAt
        )
    }

    private func receive(
        cue: ReadinessCue,
        sourceSurface: FieldSurfaceNode,
        targetSurface: FieldSurfaceNode,
        mode: DojoFeedbackOperationMode = .observeOnly,
        receivedAt: Date? = nil
    ) -> DojoMurmurFeedbackObservation {
        let policy = FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy
        let snapshot = MurmurUtilisationSnapshot(
            capturedAt: observedAt,
            openMinutes: 0.5,
            requestsPerMinute: 0.5,
            setpoints: policy.setpoints
        )
        return DojoNonVerbalFeedbackChannel.receive(
            readinessCue: cue,
            receivedAt: receivedAt ?? observedAt.addingTimeInterval(60),
            preAdjustmentState: snapshot,
            policy: policy,
            sourceSurface: sourceSurface,
            targetSurface: targetSurface,
            operationMode: mode
        )
    }

    private func cue(
        level: ReadinessLevel,
        quality: ReadinessDataQuality = .valid,
        consecutiveLowCount: Int = 0
    ) -> ReadinessCue {
        let isValid = quality == .valid && level != .unknown
        return ReadinessCue(
            level: level,
            hrvRatio: isValid ? 0.75 : nil,
            rhrRatio: isValid ? 1.0 : nil,
            hrvSDNNMilliseconds: isValid ? 37.5 : nil,
            restingHeartRateBPM: isValid ? 60 : nil,
            baselineHRVMilliseconds: isValid ? 50 : nil,
            baselineRestingHeartRateBPM: isValid ? 60 : nil,
            evaluatedAt: observedAt,
            sourceSampleDate: isValid ? observedAt.addingTimeInterval(-300) : nil,
            sourceSampleIDs: isValid ? ["hrv-opaque", "rhr-opaque"] : [],
            baselineStartDate: isValid ? observedAt.addingTimeInterval(-30 * 86_400) : nil,
            baselineEndDate: isValid ? observedAt.addingTimeInterval(-86_400) : nil,
            baselineSampleCount: isValid ? 14 : 0,
            consecutiveLowEvaluations: consecutiveLowCount,
            quality: quality
        )
    }
}
