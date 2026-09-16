import Foundation

/// The smallest typed processing-to-experience seam for Today.
///
/// This is a processing contract, not a view model, store, registry, or authority
/// surface. It keeps unresolved fields explicit so a future producer can feed the
/// existing Today experience without embedding processing inside the wireframe.
public struct TodayProcessingPacket: Codable, Equatable, Hashable, Sendable, Identifiable {
    public enum ResolutionState: String, Codable, CaseIterable, Hashable, Sendable {
        case ready
        case hold = "HOLD"
        case unknown = "Unknown"
    }

    public enum EvidenceState: String, Codable, CaseIterable, Hashable, Sendable {
        case notCollected = "not_collected"
        case partial
        case witnessed
        case sealed
        case unknown = "Unknown"
    }

    public struct ArkadasState: Codable, Equatable, Hashable, Sendable {
        public enum Continuity: String, Codable, CaseIterable, Hashable, Sendable {
            case continuous
            case interrupted
            case notObserved = "not_observed"
            case unknown = "Unknown"
        }

        public enum Disagreement: String, Codable, CaseIterable, Hashable, Sendable {
            case noneObserved = "none_observed"
            case detected
            case notObserved = "not_observed"
            case unknown = "Unknown"
        }

        public let continuity: Continuity
        public let disagreement: Disagreement
        public let source: String

        public init(
            continuity: Continuity = .unknown,
            disagreement: Disagreement = .unknown,
            source: String = "Unknown"
        ) {
            self.continuity = continuity
            self.disagreement = disagreement
            self.source = source
        }
    }

    public let packetID: String
    public var id: String { packetID }
    public let currentObjectID: String?
    public let intention: String?
    public let intendedSequence: [String]
    public let minimumSteps: [String]
    public let evaluationQuestion: String?
    public let unresolvedDecision: String?
    public let evidenceState: EvidenceState
    public let resolution: ResolutionState
    public let holdReason: String?
    public let arkadas: ArkadasState
    public let source: String
    public let observedAt: Date?

    public init(
        packetID: String,
        currentObjectID: String? = nil,
        intention: String? = nil,
        intendedSequence: [String] = [],
        minimumSteps: [String] = [],
        evaluationQuestion: String? = nil,
        unresolvedDecision: String? = nil,
        evidenceState: EvidenceState = .unknown,
        resolution: ResolutionState = .unknown,
        holdReason: String? = nil,
        arkadas: ArkadasState = ArkadasState(),
        source: String = "Unknown",
        observedAt: Date? = nil
    ) {
        self.packetID = packetID
        self.currentObjectID = currentObjectID
        self.intention = intention
        self.intendedSequence = intendedSequence
        self.minimumSteps = minimumSteps
        self.evaluationQuestion = evaluationQuestion
        self.unresolvedDecision = unresolvedDecision
        self.evidenceState = evidenceState
        self.resolution = resolution
        self.holdReason = holdReason
        self.arkadas = arkadas
        self.source = source
        self.observedAt = observedAt
    }

    /// Whether the packet contains enough separately named state to be consumed
    /// by an experience adapter. This does not grant authority or make an action
    /// executable.
    public var isComplete: Bool {
        hasText(currentObjectID) &&
        hasText(intention) &&
        !intendedSequence.isEmpty &&
        !minimumSteps.isEmpty &&
        hasText(evaluationQuestion) &&
        hasText(unresolvedDecision) &&
        evidenceState != .unknown &&
        resolution != .unknown &&
        arkadas.continuity != .unknown &&
        arkadas.disagreement != .unknown &&
        hasText(source)
    }

    /// A separate guard for a future experience projection. HOLD, disagreement,
    /// missing evidence, and incomplete fields remain visible rather than being
    /// silently promoted to a resolved result.
    public var mayProjectResolvedState: Bool {
        isComplete &&
        resolution == .ready &&
        (evidenceState == .witnessed || evidenceState == .sealed) &&
        arkadas.disagreement == .noneObserved
    }

    /// Runtime producer for the existing DOJO portal completion seam.
    /// A portal response proves that a response object exists, but it does not
    /// prove intention parsing, sequence, evaluation, evidence, or Arkadaş
    /// continuity. Keep those fields unresolved instead of manufacturing them.
    public static func portalResponseHold(
        objectID: String,
        source: String = "DOJO portal response",
        observedAt: Date = Date()
    ) -> TodayProcessingPacket {
        TodayProcessingPacket(
            packetID: "today-processing-\(objectID)",
            currentObjectID: objectID,
            evidenceState: .partial,
            resolution: .hold,
            holdReason: "Portal response received; Today intention, sequence, evaluation, and Arkadaş state remain unprocessed",
            source: source,
            observedAt: observedAt
        )
    }

    private func hasText(_ value: String?) -> Bool {
        guard let value else { return false }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
