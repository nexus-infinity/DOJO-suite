import Foundation

/// Stable identity for an Arkadas addressability decision. This is not the
/// DOJO intention identity and not the projection identity.
public struct ArkadasAddressabilityIdentity: Codable, Equatable, Hashable, Sendable {
    public let addressabilityID: String

    public init(addressabilityID: String = "Unknown.ArkadasAddressability") {
        self.addressabilityID = addressabilityID
    }

    public static let unknown = ArkadasAddressabilityIdentity()
}

/// Bounded reference to a DOJO intention. Arkadas carries this identity so it
/// can align the candidate with the external field, but it does not interpret
/// semantic meaning or decide fulfillment.
public struct ArkadasIntentionReference: Codable, Equatable, Hashable, Sendable {
    public let intentionID: String
    public let sourceObject: FieldObjectIdentity
    public let boundedSummary: String

    public init(
        intentionID: String = "Unknown.Intention",
        sourceObject: FieldObjectIdentity = .unknown,
        boundedSummary: String = "Unknown"
    ) {
        self.intentionID = intentionID
        self.sourceObject = sourceObject
        self.boundedSummary = boundedSummary
    }

    public static let unknown = ArkadasIntentionReference()
}

/// Channel availability for a concrete surface. This is evidence for possible
/// addressability only; it does not send, render, notify, or grant authority.
public struct SurfaceAvailability: Codable, Equatable, Hashable, Sendable {
    public let surface: DeviceSurface
    public let outputMode: OutputMode
    public let isAvailable: Bool
    public let boundaryReference: String?
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]

    public init(
        surface: DeviceSurface = .unknown,
        outputMode: OutputMode = .unknown,
        isAvailable: Bool = false,
        boundaryReference: String? = nil,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) {
        self.surface = surface
        self.outputMode = outputMode
        self.isAvailable = isAvailable
        self.boundaryReference = boundaryReference
        self.unknownDimensions = surface == .unknown && !unknownDimensions.contains(.observerRelation)
            ? unknownDimensions + [.observerRelation]
            : unknownDimensions
        self.holdReasons = holdReasons
    }

    public static let unknown = SurfaceAvailability(
        unknownDimensions: [.observerRelation],
        holdReasons: [.authority]
    )

    public var mayBeSelectedForAddressability: Bool {
        isAvailable &&
            surface != .unknown &&
            outputMode != .unknown &&
            unknownDimensions.isEmpty &&
            holdReasons.isEmpty
    }
}

/// Observer-side cohabitation frame. It describes the external geometry Arkadas
/// can address. Missing dimensions stay explicit rather than becoming a hidden
/// assumption.
public struct ObserverCohabitationFrame: Codable, Equatable, Sendable {
    public let observerID: String?
    public let interactionContext: InteractionContext
    public let spatialAnchor: SpatialAnchor?
    public let orientationLabel: String?
    public let observedAt: Date?
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]

    public init(
        observerID: String? = nil,
        interactionContext: InteractionContext = .unknown,
        spatialAnchor: SpatialAnchor? = nil,
        orientationLabel: String? = nil,
        observedAt: Date? = nil,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) {
        self.observerID = observerID
        self.interactionContext = interactionContext
        self.spatialAnchor = spatialAnchor
        self.orientationLabel = orientationLabel
        self.observedAt = observedAt

        var resolvedUnknowns = unknownDimensions
        if observerID == nil && !resolvedUnknowns.contains(.observerRelation) {
            resolvedUnknowns.append(.observerRelation)
        }
        if spatialAnchor == nil && !resolvedUnknowns.contains(.geometricReturn) {
            resolvedUnknowns.append(.geometricReturn)
        }
        self.unknownDimensions = resolvedUnknowns
        self.holdReasons = holdReasons
    }

    public static let unknown = ObserverCohabitationFrame(
        unknownDimensions: [.observerRelation, .geometricReturn]
    )
}

/// Geometric correspondence state between an internal candidate and the
/// observer's external/cohabitation frame.
public enum GeometricCorrespondenceState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case addressable = "ADDRESSABLE"
    case partial = "PARTIAL"
    case held = "HOLD"
    case unknown = "UNKNOWN"
}

/// Inferences Arkadas must withhold. These are named in the contract so a
/// caller can verify Arkadas is returning geometry, not interpretation.
public enum ArkadasWithheldInference: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case consent = "NO_CONSENT_INFERENCE"
    case semanticMeaning = "NO_SEMANTIC_MEANING_INFERENCE"
    case fulfillment = "NO_FULFILLMENT_INFERENCE"
    case correctness = "NO_CORRECTNESS_INFERENCE"
    case observerIntention = "NO_OBSERVER_INTENTION_INFERENCE"
    case runtimeAuthority = "NO_RUNTIME_AUTHORITY_INFERENCE"
}

/// Arkadas exterior-interior correspondence result. It makes a DOJO intention
/// or projection candidate situationally addressable without rendering,
/// notifying, routing, syncing, or interpreting the observer.
public struct ArkadasAddressabilityResult: Codable, Equatable, Sendable {
    public let identity: ArkadasAddressabilityIdentity
    public let intention: ArkadasIntentionReference
    public let projectionCandidate: ProjectionIdentity?
    public let projectionGrounding: ProjectionGrounding?
    public let cohabitationFrame: ObserverCohabitationFrame
    public let availableSurfaces: [SurfaceAvailability]
    public let selectedSurface: SurfaceAvailability?
    public let temporalValidity: TemporalValidity
    public let correspondenceState: GeometricCorrespondenceState
    public let authorityStatus: ProjectionAuthorityStatus
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]
    public let withheldInferences: [ArkadasWithheldInference]

    public init(
        identity: ArkadasAddressabilityIdentity = .unknown,
        intention: ArkadasIntentionReference = .unknown,
        projectionCandidate: ProjectionIdentity? = nil,
        projectionGrounding: ProjectionGrounding? = nil,
        cohabitationFrame: ObserverCohabitationFrame = .unknown,
        availableSurfaces: [SurfaceAvailability] = [],
        selectedSurface: SurfaceAvailability? = nil,
        temporalValidity: TemporalValidity = .unknown,
        correspondenceState: GeometricCorrespondenceState = .unknown,
        authorityStatus: ProjectionAuthorityStatus = .unknown,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = [],
        withheldInferences: [ArkadasWithheldInference] = ArkadasWithheldInference.allCases
    ) {
        self.identity = identity
        self.intention = intention
        self.projectionCandidate = projectionCandidate ?? projectionGrounding?.projectionIdentity
        self.projectionGrounding = projectionGrounding
        self.cohabitationFrame = cohabitationFrame
        self.availableSurfaces = availableSurfaces
        self.selectedSurface = selectedSurface
        self.temporalValidity = temporalValidity
        self.correspondenceState = correspondenceState
        self.authorityStatus = authorityStatus
        self.unknownDimensions = Self.merged(
            Self.merged(
                Self.merged(unknownDimensions, cohabitationFrame.unknownDimensions),
                selectedSurface?.unknownDimensions ?? []
            ),
            projectionGrounding?.unknownDimensions ?? []
        )
        self.holdReasons = Self.merged(
            Self.merged(
                Self.merged(holdReasons, cohabitationFrame.holdReasons),
                selectedSurface?.holdReasons ?? []
            ),
            projectionGrounding?.holdReasons ?? []
        )
        self.withheldInferences = withheldInferences
    }

    public static let unknown = ArkadasAddressabilityResult()

    public var mayAddressObserverField: Bool {
        correspondenceState == .addressable &&
            authorityStatus.decision == .pass &&
            selectedSurface?.mayBeSelectedForAddressability == true &&
            unknownDimensions.isEmpty &&
            holdReasons.isEmpty &&
            preservesNonInferenceBoundary
    }

    public var preservesNonInferenceBoundary: Bool {
        Set(withheldInferences) == Set(ArkadasWithheldInference.allCases)
    }

    private static func merged<T: Equatable>(_ lhs: [T], _ rhs: [T]) -> [T] {
        rhs.reduce(lhs) { partial, value in
            partial.contains(value) ? partial : partial + [value]
        }
    }
}

/// Geometry returned after a lived encounter window. This reports external
/// geometric change only. It does not decide whether the observer consented,
/// whether the intention succeeded, or whether the content was correct.
public struct ExternalGeometryReturn: Codable, Equatable, Sendable {
    public enum Outcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
        case encountered = "ENCOUNTERED"
        case ignored = "IGNORED"
        case delayed = "DELAYED"
        case corrected = "CORRECTED"
        case refused = "REFUSED"
        case movedAway = "MOVED_AWAY"
        case surfaceUnavailable = "SURFACE_UNAVAILABLE"
        case unknown = "UNKNOWN"
    }

    public let returnID: String
    public let addressabilityIdentity: ArkadasAddressabilityIdentity
    public let observedAt: Date?
    public let surface: DeviceSurface
    public let outcome: Outcome
    public let changedSpatialAnchor: SpatialAnchor?
    public let evidenceAnchors: [EvidenceAnchor]
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]
    public let withheldInferences: [ArkadasWithheldInference]

    public init(
        returnID: String = "Unknown.ExternalGeometryReturn",
        addressabilityIdentity: ArkadasAddressabilityIdentity = .unknown,
        observedAt: Date? = nil,
        surface: DeviceSurface = .unknown,
        outcome: Outcome = .unknown,
        changedSpatialAnchor: SpatialAnchor? = nil,
        evidenceAnchors: [EvidenceAnchor] = [.unknownSource],
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = [],
        withheldInferences: [ArkadasWithheldInference] = ArkadasWithheldInference.allCases
    ) {
        self.returnID = returnID
        self.addressabilityIdentity = addressabilityIdentity
        self.observedAt = observedAt
        self.surface = surface
        self.outcome = outcome
        self.changedSpatialAnchor = changedSpatialAnchor
        self.evidenceAnchors = evidenceAnchors

        var resolvedUnknowns = unknownDimensions
        if observedAt == nil && !resolvedUnknowns.contains(.temporalValidity) {
            resolvedUnknowns.append(.temporalValidity)
        }
        if evidenceAnchors.contains(where: { $0.kind == .unknown || $0.sourceID == nil }) &&
            !resolvedUnknowns.contains(.source) {
            resolvedUnknowns.append(.source)
        }
        self.unknownDimensions = resolvedUnknowns
        self.holdReasons = holdReasons
        self.withheldInferences = withheldInferences
    }

    public static let unknown = ExternalGeometryReturn()

    public var preservesNonInferenceBoundary: Bool {
        Set(withheldInferences) == Set(ArkadasWithheldInference.allCases)
    }
}
