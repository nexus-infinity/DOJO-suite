import Foundation
import DOJOShared

public enum ParticleBoardVisualState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case quiet
    case lucid
    case receivingCandidate
    case evaluatingPresentation
    case attracting
    case crystallizing
    case revealed
    case revising
    case dissolving
    case returned
    case held
    case unknown
}

public enum ParticleBoardVisualEvent: Equatable, Sendable {
    case chooseQuiet
    case chooseLucid
    case introduceDraft(DraftManifestationEnvelope?)
    case evaluate
    case advance
    case revise
    case saveDraft
    case dismiss
}

public enum DraftCandidateType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case screenshot
    case image
    case documentPreview
}

public enum ParticleBoardFidelity: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case glyph
    case preview
    case readable
    case photographic

    public var particleCount: Int {
        switch self {
        case .glyph: return 96
        case .preview: return 180
        case .readable: return 320
        case .photographic: return 420
        }
    }
}

public enum ParticlePrimitive: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case circle
    case triangle
    case square
    case diamond
    case hexagon
}

public enum ParticleSemanticRole: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case quietTrace
    case wireframe
    case activeFocus
    case wisdomAccent
    case hold
    case unknown
}

public struct ParticleBoardTransitionDecision: Equatable, Sendable {
    public let state: ParticleBoardVisualState
    public let accepted: Bool
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]

    public init(
        state: ParticleBoardVisualState,
        accepted: Bool,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) {
        self.state = state
        self.accepted = accepted
        self.unknownDimensions = unknownDimensions
        self.holdReasons = holdReasons
    }
}
