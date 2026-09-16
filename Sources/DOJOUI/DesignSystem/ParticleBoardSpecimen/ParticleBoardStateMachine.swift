import Foundation
import DOJOShared

public enum ParticleBoardStateMachine {
    public static func reduce(
        state: ParticleBoardVisualState,
        event: ParticleBoardVisualEvent
    ) -> ParticleBoardTransitionDecision {
        switch (state, event) {
        case (_, .chooseQuiet):
            return .init(state: .quiet, accepted: true)
        case (_, .chooseLucid):
            return .init(state: .lucid, accepted: true)
        case (.quiet, .introduceDraft(let envelope)),
             (.lucid, .introduceDraft(let envelope)):
            guard let envelope else {
                return .init(state: .unknown, accepted: true, unknownDimensions: [.identity, .source], holdReasons: [.evidence])
            }
            return .init(
                state: .receivingCandidate,
                accepted: true,
                unknownDimensions: envelope.phenotype.unknownDimensions,
                holdReasons: envelope.phenotype.holdReasons
            )
        case (.receivingCandidate, .evaluate):
            return .init(state: .evaluatingPresentation, accepted: true)
        case (.evaluatingPresentation, .advance):
            return .init(state: .unknown, accepted: true, unknownDimensions: [.identity, .source], holdReasons: [.evidence])
        case (.attracting, .advance):
            return .init(state: .crystallizing, accepted: true)
        case (.crystallizing, .advance):
            return .init(state: .revealed, accepted: true)
        case (.revealed, .revise):
            return .init(state: .revising, accepted: true)
        case (.revealed, .saveDraft):
            return .init(state: .revealed, accepted: true)
        case (.revealed, .dismiss),
             (.revising, .dismiss):
            return .init(state: .dissolving, accepted: true)
        case (.dissolving, .advance):
            return .init(state: .returned, accepted: true)
        case (.returned, .advance):
            return .init(state: .quiet, accepted: true)
        default:
            return .init(state: state, accepted: false)
        }
    }

    public static func evaluateCandidate(
        _ envelope: DraftManifestationEnvelope?
    ) -> ParticleBoardTransitionDecision {
        guard let envelope else {
            return .init(state: .unknown, accepted: true, unknownDimensions: [.identity, .source], holdReasons: [.evidence])
        }
        if envelope.isPresentationEligible {
            return .init(state: .attracting, accepted: true)
        }
        if envelope.isHeld {
            return .init(
                state: .held,
                accepted: true,
                unknownDimensions: envelope.phenotype.unknownDimensions,
                holdReasons: envelope.phenotype.holdReasons.isEmpty ? [.authority] : envelope.phenotype.holdReasons
            )
        }
        return .init(
            state: .unknown,
            accepted: true,
            unknownDimensions: envelope.phenotype.unknownDimensions.isEmpty ? [.source] : envelope.phenotype.unknownDimensions,
            holdReasons: envelope.phenotype.holdReasons.isEmpty ? [.evidence] : envelope.phenotype.holdReasons
        )
    }

    public static func canRevealContent(
        state: ParticleBoardVisualState,
        envelope: DraftManifestationEnvelope?
    ) -> Bool {
        guard let envelope else { return false }
        return (state == .attracting || state == .crystallizing || state == .revealed || state == .revising || state == .dissolving) &&
            envelope.isPresentationEligible
    }
}
