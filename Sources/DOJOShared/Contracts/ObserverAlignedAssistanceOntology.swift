import Foundation

// MARK: - Observer-Aligned Assistance Ontology V0 (design-time types)
// Source: docs/OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl
// Mapping: docs/OBSERVER_ALIGNED_ASSISTANCE_ATTRIBUTE_MAPPING_V0.md
// Status: HOLD.NOT_IMPLEMENTED_OR_VERIFIED — types for contracts/tests only.
// No runtime camera, cue engine, or medical claims.

// MARK: Axes

public enum OAAAlignmentAxis: String, Codable, CaseIterable, Sendable {
    case geometric
    case semantic
    case temporal
    case epistemic
    case authority
    case provenance
}

public enum OAAEpistemicStatus: String, Codable, Sendable {
    case witnessed = "Witnessed"
    case attributed = "Attributed"
    case hypothesis = "Hypothesis"
    case unknown = "Unknown"
    case contradicted = "Contradicted"
    case verified = "Verified"
}

public enum OAATemporalValidity: String, Codable, Sendable {
    case live = "LIVE"
    case delayed = "DELAYED"
    case stale = "STALE"
    case untrusted = "UNTRUSTED"
}

public enum OAAAuthorityState: String, Codable, Sendable {
    case observeOnly = "OBSERVE_ONLY"
    case localPrepareOnly = "LOCAL_PREPARE_ONLY"
    case cuePermitted = "CUE_PERMITTED"
    case suggestionPermitted = "SUGGESTION_PERMITTED"
    case explicitConfirmationRequired = "EXPLICIT_CONFIRMATION_REQUIRED"
    case hold = "HOLD"
}

public enum OAAGateDecision: String, Codable, Sendable {
    case promote = "PROMOTE"
    case hold = "HOLD"
    case demote = "DEMOTE"
}

// MARK: Sensing vs assistance (non-collapse)

/// Inbound evidence modalities — never mixed with assistance output.
public enum OAASensingModality: String, Codable, Sendable {
    case cameraScene = "camera_scene"
    case microphoneIntentionInput = "microphone_intention_input"
    case deviceState = "device_state"
    case manualInput = "manual_input"
    case locationContext = "location_context"
    case unknown = "Unknown"
}

/// Outbound assistance modalities — separate even on one wearable.
public enum OAAAssistanceModality: String, Codable, Sendable {
    case silence
    case earcon
    case audioWords = "audio_words"
    case spokenAudio = "spoken_audio"
    case haptic
    case visualGlance = "visual_glance"
    case screenDetail = "screen_detail"
}

public enum OAACueLevel: String, Codable, Sendable {
    case silence
    case ambientSignal = "ambient_signal"
    case oneWord = "one_word"
    case twoOrThreeWords = "two_or_three_words"
    case briefOrientation = "brief_orientation"
    case boundedQuestion = "bounded_question"
    case conversation
}

public enum OAAAttentionMode: String, Codable, Sendable {
    case denseDesktopWork = "dense_desktop_work"
    case mobileConversation = "mobile_conversation"
    case glance
    case sharedRoomAmbient = "shared_room_ambient"
    case physicalTask = "physical_task"
    case drivingSafeVoicePrimary = "driving_safe_voice_primary"
    case unknown = "Unknown"
}

public enum OAAIntentionAuthorityStatus: String, Codable, Sendable {
    case expressed = "EXPRESSED"
    case pinned = "PINNED"
    case confirmed = "CONFIRMED"
    case rejected = "REJECTED"
    case expired = "EXPIRED"
    case unknown = "Unknown"
}

// MARK: Core objects (design stubs)

public struct OAAObserver: Codable, Sendable, Equatable, Identifiable {
    public var id: String { observerId }
    public var observerId: String
    public var consentProfileIdOrUnknown: String
    public var preferredCueVocabulary: [String]?
    public var accessibilityPreferences: [String: String]?

    public init(
        observerId: String,
        consentProfileIdOrUnknown: String = "Unknown",
        preferredCueVocabulary: [String]? = nil,
        accessibilityPreferences: [String: String]? = nil
    ) {
        self.observerId = observerId
        self.consentProfileIdOrUnknown = consentProfileIdOrUnknown
        self.preferredCueVocabulary = preferredCueVocabulary
        self.accessibilityPreferences = accessibilityPreferences
    }
}

public struct OAAGeometricAxis: Codable, Sendable, Equatable {
    public var frameId: String
    public var observerPoseOrUnknown: String
    public var observedRegionOrUnknown: String
    public var spatialRelation: String
    public var source: String
    public var uncertainty: String
}

public struct OAASemanticAxis: Codable, Sendable, Equatable {
    public var observedFact: String
    public var candidateMeaning: String
    public var epistemicStatus: OAAEpistemicStatus
    public var confidenceOrUnknown: String
    public var contradictions: [String]
    public var source: String
}

public struct OAATemporalAxis: Codable, Sendable, Equatable {
    public var observedAt: String
    public var timezone: String
    public var validity: OAATemporalValidity
    public var predecessorIds: [String]
    public var retentionUntilOrUnknown: String
    public var sequenceRelation: String
}

public struct OAAEpistemicAxis: Codable, Sendable, Equatable {
    public var status: OAAEpistemicStatus
    public var evidenceAnchorIds: [String]
    public var unknowns: [String]
}

public struct OAAProvenanceAxis: Codable, Sendable, Equatable {
    public var sourceObjectIds: [String]
    public var transformationIds: [String]
    public var receiptPointerOrUnknown: String
    public var retentionPolicy: String
}

public struct OAAObservationEvent: Codable, Sendable, Equatable, Identifiable {
    public var id: String { observationId }
    public var observationId: String
    public var observerId: String
    public var observedAt: String
    public var sourceChannelId: String
    public var geometric: OAAGeometricAxis
    public var semantic: OAASemanticAxis
    public var temporal: OAATemporalAxis
    public var epistemic: OAAEpistemicAxis
    public var provenance: OAAProvenanceAxis
}

public struct OAAHumanIntention: Codable, Sendable, Equatable, Identifiable {
    public var id: String { intentionId }
    public var intentionId: String
    public var observerId: String
    public var content: String
    public var evidenceAnchorIds: [String]
    public var expressedAt: String
    public var validUntil: String
    public var authorityStatus: OAAIntentionAuthorityStatus
}

public struct OAAAttentionContext: Codable, Sendable, Equatable, Identifiable {
    public var id: String { attentionContextId }
    public var attentionContextId: String
    public var activeEnvironmentalAttentionSurface: String
    public var attentionMode: OAAAttentionMode
    public var interactionDensityCeiling: OAACueLevel
    public var safetyState: String
    public var source: String
}

public struct OAASurfacePresence: Codable, Sendable, Equatable, Identifiable {
    public var id: String { surfacePresenceId }
    public var surfacePresenceId: String
    public var humanInputSurface: String
    public var executionHost: String
    public var activeEnvironmentalAttentionSurface: String
    public var attentionMode: OAAAttentionMode
}

public struct OAASensingChannel: Codable, Sendable, Equatable, Identifiable {
    public var id: String { channelId }
    public var channelId: String
    public var modality: OAASensingModality
    public var direction: String
    public var permissionState: String
    public var visibilityState: String
    public var retentionPolicy: String
}

public struct OAAAssistanceChannel: Codable, Sendable, Equatable, Identifiable {
    public var id: String { channelId }
    public var channelId: String
    public var modality: OAAAssistanceModality
    public var direction: String
    public var attentionCost: String
    public var privacyMode: String
    public var availability: String
}

public struct OAACueCandidate: Codable, Sendable, Equatable, Identifiable {
    public var id: String { cueId }
    public var cueId: String
    public var observerId: String
    public var sourceIntentionIdOrUnknown: String
    public var sourceObservationIds: [String]
    public var content: String
    public var cueLevel: OAACueLevel
    public var epistemicStatus: OAAEpistemicStatus
    public var authorityState: OAAAuthorityState
    public var expiry: String
}

public struct OAAAuthorityGate: Codable, Sendable, Equatable, Identifiable {
    public var id: String { gateId }
    public var gateId: String
    public var inputObjectIds: [String]
    public var decision: OAAGateDecision
    public var reasonCodes: [String]
    public var permittedNextOperations: [String]
    public var forbiddenNextOperations: [String]
    public var requiredNextEvidence: String
}

public struct OAAConsentGrant: Codable, Sendable, Equatable, Identifiable {
    public var id: String { consentId }
    public var consentId: String
    public var observerId: String
    public var purpose: String
    public var permittedModalities: [String]
    public var permittedUses: [String]
    public var forbiddenUses: [String]
    public var grantedAt: String
    public var expiresAt: String
    public var revocationPath: String
}

public struct OAAReceiptPointer: Codable, Sendable, Equatable, Identifiable {
    public var id: String { receiptPointerId }
    public var receiptPointerId: String
    public var subjectObjectIds: [String]
    public var receiptPathOrUnknown: String
    public var receiptStatus: String
    public var witnessStatus: String
}

// MARK: Constraints (named failure states)

public enum OAABlockingConstraint: String, Codable, CaseIterable, Sendable {
    case surfaceOrAuthorityCollapse = "HOLD.SurfaceOrAuthorityCollapse"
    case geometryAuthorityOverreach = "HOLD.GeometryAuthorityOverreach"
    case attentionCeilingExceeded = "HOLD.AttentionCeilingExceeded"
    case retentionAuthorityMissing = "HOLD.RetentionAuthorityMissing"
    case medicalClaimUnsupported = "HOLD.MedicalClaimUnsupported"
}

// MARK: Gate helper (deterministic design rule — not a live engine)

public enum OAAAssistanceGateRules {
    /// Geometry / scene alone may not promote a HumanIntention or authority.
    public static func intentionFromSceneAloneIsForbidden() -> Bool { true }

    /// Cue level must not exceed attention density ceiling.
    public static func cueFitsAttention(
        cue: OAACueLevel,
        ceiling: OAACueLevel
    ) -> Bool {
        cueRank(cue) <= cueRank(ceiling)
    }

    public static func cueRank(_ level: OAACueLevel) -> Int {
        switch level {
        case .silence: return 0
        case .ambientSignal: return 1
        case .oneWord: return 2
        case .twoOrThreeWords: return 3
        case .briefOrientation: return 4
        case .boundedQuestion: return 5
        case .conversation: return 6
        }
    }

    /// Sensing modality must not be treated as assistance modality.
    public static func channelsCollapsed(
        sensing: OAASensingModality,
        assistance: OAAAssistanceModality
    ) -> Bool {
        // Separate types — collapse would require an invalid cast; always false at type level.
        _ = sensing
        _ = assistance
        return false
    }
}

// MARK: Ontology meta

public enum OAAOntologyMeta {
    public static let ontologyId = "dojo.observer_aligned_assistance.v0"
    public static let version = "0.1.0"
    public static let status = "HOLD.NOT_IMPLEMENTED_OR_VERIFIED"
    public static let sourceJSONL = "docs/OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl"
    public static let mappingDoc = "docs/OBSERVER_ALIGNED_ASSISTANCE_ATTRIBUTE_MAPPING_V0.md"
    public static let classCount = 12
    public static let axisCount = 6
    public static let expectedJSONLRecords = 32
}
