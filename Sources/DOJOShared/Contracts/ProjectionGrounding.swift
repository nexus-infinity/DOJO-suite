import Foundation

/// Stable FIELD object identity. This identifies the object being represented,
/// not the surface element that happens to display it.
public struct FieldObjectIdentity: Codable, Equatable, Hashable, Sendable {
    public let objectID: String
    public let ontologyKind: FieldOntologyKind
    public let displayLabel: String
    public let sourceObjectID: String?

    public init(
        objectID: String,
        ontologyKind: FieldOntologyKind = .unknown,
        displayLabel: String = "Unknown",
        sourceObjectID: String? = nil
    ) {
        self.objectID = objectID
        self.ontologyKind = ontologyKind
        self.displayLabel = displayLabel
        self.sourceObjectID = sourceObjectID
    }

    public static let unknown = FieldObjectIdentity(
        objectID: "Unknown.Identity",
        ontologyKind: .unknown,
        displayLabel: "Unknown"
    )
}

/// Minimal ontology vocabulary for shared projection and inverse grounding.
public enum FieldOntologyKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case person = "PERSON"
    case place = "PLACE"
    case device = "DEVICE"
    case capture = "CAPTURE"
    case observation = "OBSERVATION"
    case event = "EVENT"
    case boundary = "BOUNDARY"
    case route = "ROUTE"
    case projection = "PROJECTION"
    case generatedObject = "GENERATED_OBJECT"
    case unknown = "UNKNOWN"
}

/// Intertemporal validity for a projection. These dates are intentionally
/// separate; a rendered representation must not imply they are simultaneous.
public struct TemporalValidity: Codable, Equatable, Hashable, Sendable {
    public enum Freshness: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
        case current = "CURRENT"
        case historical = "HISTORICAL"
        case partial = "PARTIAL"
        case expired = "EXPIRED"
        case unknown = "UNKNOWN"
    }

    public let eventTime: Date?
    public let observationTime: Date?
    public let recordingTime: Date?
    public let resolutionTime: Date?
    public let projectionTime: Date?
    public let decisionTime: Date?
    public let expiryTime: Date?
    public let correctionTime: Date?
    public let freshness: Freshness

    public init(
        eventTime: Date? = nil,
        observationTime: Date? = nil,
        recordingTime: Date? = nil,
        resolutionTime: Date? = nil,
        projectionTime: Date? = nil,
        decisionTime: Date? = nil,
        expiryTime: Date? = nil,
        correctionTime: Date? = nil,
        freshness: Freshness = .unknown
    ) {
        self.eventTime = eventTime
        self.observationTime = observationTime
        self.recordingTime = recordingTime
        self.resolutionTime = resolutionTime
        self.projectionTime = projectionTime
        self.decisionTime = decisionTime
        self.expiryTime = expiryTime
        self.correctionTime = correctionTime
        self.freshness = freshness
    }

    public static let unknown = TemporalValidity()
}

/// Evidence pointer for inverse return. It points to an existing source or
/// explicitly records that the source is unresolved.
public struct EvidenceAnchor: Codable, Equatable, Hashable, Sendable {
    public enum Kind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
        case localCaptureReceipt = "LOCAL_CAPTURE_RECEIPT"
        case processingPacket = "PROCESSING_PACKET"
        case providerResult = "PROVIDER_RESULT"
        case humanReport = "HUMAN_REPORT"
        case generatedObject = "GENERATED_OBJECT"
        case unknown = "UNKNOWN"
    }

    public enum State: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
        case notCollected = "NOT_COLLECTED"
        case partial = "PARTIAL"
        case witnessed = "WITNESSED"
        case sealed = "SEALED"
        case unknown = "UNKNOWN"
    }

    public let anchorID: String
    public let kind: Kind
    public let sourceID: String?
    public let state: State
    public let claim: String

    public init(
        anchorID: String,
        kind: Kind = .unknown,
        sourceID: String? = nil,
        state: State = .unknown,
        claim: String = "Unknown"
    ) {
        self.anchorID = anchorID
        self.kind = kind
        self.sourceID = sourceID
        self.state = state
        self.claim = claim
    }

    public static let unknownSource = EvidenceAnchor(
        anchorID: "Unknown.Source",
        kind: .unknown,
        sourceID: nil,
        state: .unknown,
        claim: "Source unresolved"
    )
}

/// Stable representation identity. This is deliberately distinct from the
/// object identity it claims to represent.
public struct ProjectionIdentity: Codable, Equatable, Hashable, Sendable {
    public enum RepresentationKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
        case mapAnnotation = "MAP_ANNOTATION"
        case card = "CARD"
        case row = "ROW"
        case overlay = "OVERLAY"
        case notification = "NOTIFICATION"
        case diagnostic = "DIAGNOSTIC"
        case unknown = "UNKNOWN"
    }

    public let projectionID: String
    public let surface: DeviceSurface
    public let representationKind: RepresentationKind

    public init(
        projectionID: String,
        surface: DeviceSurface = .unknown,
        representationKind: RepresentationKind = .unknown
    ) {
        self.projectionID = projectionID
        self.surface = surface
        self.representationKind = representationKind
    }
}

/// Shared authority/capability status for a projection. This records boundary
/// state only; it does not grant runtime authority or execute a capability.
public struct ProjectionAuthorityStatus: Codable, Equatable, Hashable, Sendable {
    public enum Decision: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
        case pass = "PASS"
        case fail = "FAIL"
        case unknown = "UNKNOWN"
        case hold = "HOLD"
    }

    public let decision: Decision
    public let boundaryReference: String?
    public let nextEvidence: String?

    public init(
        decision: Decision = .unknown,
        boundaryReference: String? = nil,
        nextEvidence: String? = nil
    ) {
        self.decision = decision
        self.boundaryReference = boundaryReference
        self.nextEvidence = nextEvidence
    }

    public static let unknown = ProjectionAuthorityStatus()
    public static let authorityHold = ProjectionAuthorityStatus(
        decision: .hold,
        boundaryReference: "HOLD.Authority",
        nextEvidence: "Recover authority before projection can be promoted."
    )
}

/// A route for correcting the represented claim while preserving history.
public struct CorrectionRoute: Codable, Equatable, Hashable, Sendable {
    public let routeID: String
    public let destination: String
    public let preservesHistory: Bool

    public init(
        routeID: String,
        destination: String = "Unknown",
        preservesHistory: Bool = true
    ) {
        self.routeID = routeID
        self.destination = destination
        self.preservesHistory = preservesHistory
    }

    public static let unknown = CorrectionRoute(
        routeID: "Unknown.CorrectionRoute",
        destination: "Unknown",
        preservesHistory: true
    )
}

/// Explicit unknown dimensions in an inverse trace.
public enum UnknownDimension: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case identity = "Unknown.Identity"
    case source = "Unknown.Source"
    case observerRelation = "Unknown.ObserverRelation"
    case geometricReturn = "Unknown.GeometricReturn"
    case somaticConsequence = "Unknown.SomaticConsequence"
    case temporalValidity = "Unknown.TemporalValidity"
    case semanticClaim = "Unknown.SemanticClaim"
    case authority = "Unknown.Authority"
    case correctionRoute = "Unknown.CorrectionRoute"
}

/// Explicit HOLD reasons in an inverse trace.
public enum ProjectionHoldReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case authority = "HOLD.Authority"
    case somaticConsequence = "HOLD.SomaticConsequence"
    case temporalValidity = "HOLD.TemporalValidity"
    case evidence = "HOLD.Evidence"
    case correction = "HOLD.Correction"
}

/// Dual FIELD projection contract. It describes what a surface element
/// represents and how it returns to bounded evidence, context, authority, and
/// correction. It does not claim to reconstruct the complete embodied object.
public struct ProjectionGrounding: Codable, Equatable, Sendable {
    public let projectionIdentity: ProjectionIdentity
    public let representedObject: FieldObjectIdentity
    public let interactionContext: InteractionContext
    public let evidenceAnchors: [EvidenceAnchor]
    public let temporalValidity: TemporalValidity
    public let authorityStatus: ProjectionAuthorityStatus
    public let correctionRoute: CorrectionRoute
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]
    public let inverseScopeNote: String

    public init(
        projectionIdentity: ProjectionIdentity,
        representedObject: FieldObjectIdentity = .unknown,
        interactionContext: InteractionContext = .unknown,
        evidenceAnchors: [EvidenceAnchor] = [.unknownSource],
        temporalValidity: TemporalValidity = .unknown,
        authorityStatus: ProjectionAuthorityStatus = .unknown,
        correctionRoute: CorrectionRoute = .unknown,
        unknownDimensions: [UnknownDimension] = [.source],
        holdReasons: [ProjectionHoldReason] = [],
        inverseScopeNote: String = ProjectionGrounding.defaultInverseScopeNote
    ) {
        self.projectionIdentity = projectionIdentity
        self.representedObject = representedObject
        self.interactionContext = interactionContext
        self.evidenceAnchors = evidenceAnchors
        self.temporalValidity = temporalValidity
        self.authorityStatus = authorityStatus
        self.correctionRoute = correctionRoute
        self.unknownDimensions = unknownDimensions
        self.holdReasons = holdReasons
        self.inverseScopeNote = inverseScopeNote
    }

    public static let defaultInverseScopeNote = "Inverse trace returns bounded claims and evidence only; it does not reconstruct the complete FIELD object."

    public var hasAuthorityHold: Bool {
        authorityStatus.decision == .hold || holdReasons.contains(.authority)
    }

    public var hasUnknownSource: Bool {
        unknownDimensions.contains(.source) ||
            evidenceAnchors.contains { $0.kind == .unknown || $0.sourceID == nil }
    }
}

/// Pure adapters from seated DOJO evidence types into projection grounding.
/// These factories create data only; they do not render, sync, write receipts,
/// or promote runtime authority.
public enum ProjectionGroundingFactory {
    public static func fromLocalCaptureReceipt(
        _ receipt: LocalCaptureReceipt?,
        projectionIdentity: ProjectionIdentity,
        interactionContext: InteractionContext = .unknown,
        authorityStatus: ProjectionAuthorityStatus = .unknown,
        projectionTime: Date? = nil
    ) -> ProjectionGrounding {
        guard let receipt else {
            return ProjectionGrounding(
                projectionIdentity: projectionIdentity,
                representedObject: .unknown,
                interactionContext: interactionContext,
                evidenceAnchors: [.unknownSource],
                temporalValidity: .unknown,
                authorityStatus: authorityStatus,
                correctionRoute: .unknown,
                unknownDimensions: [.identity, .source, .temporalValidity],
                holdReasons: [.evidence] + authorityHoldReasons(for: authorityStatus)
            )
        }

        let unknowns = authorityStatus.decision == .unknown ? [UnknownDimension.authority] : []
        return ProjectionGrounding(
            projectionIdentity: projectionIdentity,
            representedObject: FieldObjectIdentity(
                objectID: receipt.objectID,
                ontologyKind: .capture,
                displayLabel: "\(receipt.operation) · \(receipt.result)",
                sourceObjectID: receipt.objectID
            ),
            interactionContext: interactionContext,
            evidenceAnchors: [
                EvidenceAnchor(
                    anchorID: receipt.receiptID,
                    kind: .localCaptureReceipt,
                    sourceID: receipt.receiptID,
                    state: evidenceState(for: receipt),
                    claim: "Local capture receipt recorded \(receipt.operation) as \(receipt.result)"
                )
            ],
            temporalValidity: TemporalValidity(
                recordingTime: receipt.issuedAt,
                projectionTime: projectionTime ?? receipt.issuedAt,
                freshness: authorityStatus.decision == .pass ? .current : .partial
            ),
            authorityStatus: authorityStatus,
            correctionRoute: CorrectionRoute(
                routeID: "local-capture-correction:\(receipt.receiptID)",
                destination: receipt.receiptPath,
                preservesHistory: true
            ),
            unknownDimensions: unknowns,
            holdReasons: authorityHoldReasons(for: authorityStatus)
        )
    }

    private static func evidenceState(for receipt: LocalCaptureReceipt) -> EvidenceAnchor.State {
        switch receipt.result {
        case LocalCaptureReceipt.Outcome.captured, LocalCaptureReceipt.Outcome.completed:
            return .sealed
        default:
            return .partial
        }
    }

    private static func authorityHoldReasons(
        for authorityStatus: ProjectionAuthorityStatus
    ) -> [ProjectionHoldReason] {
        authorityStatus.decision == .hold ? [.authority] : []
    }
}
