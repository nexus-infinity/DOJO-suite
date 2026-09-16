import Foundation

/// Stable phenotype identity. This identifies one expression proposal and
/// preserves its genotype/projection lineage without becoming either one.
public struct PEPPhenotypeIdentity: Codable, Equatable, Hashable, Sendable {
    public let phenotypeID: String
    public let genotypeObject: FieldObjectIdentity
    public let projectionIdentity: ProjectionIdentity
    public let schemaVersion: String
    public let sourceExpression: String
    public let parentPhenotypeID: String?

    public init(
        phenotypeID: String = "Unknown.PEPPhenotype",
        genotypeObject: FieldObjectIdentity = .unknown,
        projectionIdentity: ProjectionIdentity = ProjectionIdentity(
            projectionID: "Unknown.Projection",
            surface: .unknown,
            representationKind: .unknown
        ),
        schemaVersion: String = "PEPPhenotype.v1",
        sourceExpression: String = "Unknown",
        parentPhenotypeID: String? = nil
    ) {
        self.phenotypeID = phenotypeID
        self.genotypeObject = genotypeObject
        self.projectionIdentity = projectionIdentity
        self.schemaVersion = schemaVersion
        self.sourceExpression = sourceExpression
        self.parentPhenotypeID = parentPhenotypeID
    }

    public static let unknown = PEPPhenotypeIdentity()

    public var preservesIdentitySeparation: Bool {
        phenotypeID != genotypeObject.objectID && phenotypeID != projectionIdentity.projectionID
    }
}

/// Abstract surface classes for shared PEP contracts. Platform-specific names
/// and renderers stay outside DOJOShared.
public enum PEPSurfaceClass: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case desktop = "DESKTOP"
    case handheld = "HANDHELD"
    case wearable = "WEARABLE"
    case sharedDisplay = "SHARED_DISPLAY"
    case vehicle = "VEHICLE"
    case print = "PRINT"
    case terminal = "TERMINAL"
    case unknown = "UNKNOWN"
}

/// Semantic colour role only. This is not RGB, hex, SwiftUI.Color, or a theme.
public enum PEPColorRole: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case neutral = "NEUTRAL"
    case evidence = "EVIDENCE"
    case authority = "AUTHORITY"
    case attention = "ATTENTION"
    case caution = "CAUTION"
    case hold = "HOLD"
    case correction = "CORRECTION"
    case unknown = "UNKNOWN"
}

/// Expressive geometric role only. Geometry does not grant permission.
public enum PEPGeometryRole: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case boundary = "BOUNDARY"
    case center = "CENTER"
    case anchor = "ANCHOR"
    case sequence = "SEQUENCE"
    case connection = "CONNECTION"
    case separation = "SEPARATION"
    case correspondence = "CORRESPONDENCE"
    case `return` = "RETURN"
    case unknown = "UNKNOWN"
}

/// Expressive motion role only. This contract does not start animation.
public enum PEPMotionRole: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none = "NONE"
    case appear = "APPEAR"
    case transition = "TRANSITION"
    case pulse = "PULSE"
    case progress = "PROGRESS"
    case hold = "HOLD"
    case `return` = "RETURN"
    case unknown = "UNKNOWN"
}

/// Communication capability vocabulary. A mode is not a send operation.
public enum PEPCommunicationMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case textual = "TEXTUAL"
    case visual = "VISUAL"
    case auditory = "AUDITORY"
    case haptic = "HAPTIC"
    case spatial = "SPATIAL"
    case multimodal = "MULTIMODAL"
    case unknown = "UNKNOWN"
}

/// Proposed interaction affordance. Even action representation is descriptive;
/// this value cannot execute or authorize the action.
public enum PEPInteractionAffordanceState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none = "NONE"
    case inspectable = "INSPECTABLE"
    case correctable = "CORRECTABLE"
    case actionRepresentable = "ACTION_REPRESENTABLE"
    case unknown = "UNKNOWN"
}

public enum PEPExpressionDensity: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case compact = "COMPACT"
    case standard = "STANDARD"
    case expanded = "EXPANDED"
    case unknown = "UNKNOWN"
}

public enum PEPExpressionPriority: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case low = "LOW"
    case normal = "NORMAL"
    case elevated = "ELEVATED"
    case hold = "HOLD"
    case unknown = "UNKNOWN"
}

/// One traceable expression attribute. The attribute may carry evidence,
/// authority state, uncertainty, and correction; it cannot independently confer
/// authority, complete meaning, or permission.
public struct PEPAttribute: Codable, Equatable, Sendable {
    public let attributeID: String
    public let semanticRole: String
    public let colorRole: PEPColorRole
    public let geometryRole: PEPGeometryRole
    public let motionRole: PEPMotionRole
    public let communicationMode: PEPCommunicationMode
    public let evidenceAnchor: EvidenceAnchor
    public let authorityStatus: ProjectionAuthorityStatus
    public let confidence: Double?
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]
    public let correctionRoute: CorrectionRoute

    public init(
        attributeID: String = "Unknown.PEPAttribute",
        semanticRole: String = "Unknown",
        colorRole: PEPColorRole = .unknown,
        geometryRole: PEPGeometryRole = .unknown,
        motionRole: PEPMotionRole = .none,
        communicationMode: PEPCommunicationMode = .unknown,
        evidenceAnchor: EvidenceAnchor = .unknownSource,
        authorityStatus: ProjectionAuthorityStatus = .unknown,
        confidence: Double? = nil,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = [],
        correctionRoute: CorrectionRoute = .unknown
    ) {
        self.attributeID = attributeID
        self.semanticRole = semanticRole
        self.colorRole = colorRole
        self.geometryRole = geometryRole
        self.motionRole = motionRole
        self.communicationMode = communicationMode
        self.evidenceAnchor = evidenceAnchor
        self.authorityStatus = authorityStatus
        self.confidence = confidence.map { min(max($0, 0), 1) }
        self.unknownDimensions = Self.resolvedUnknowns(
            evidenceAnchor: evidenceAnchor,
            authorityStatus: authorityStatus,
            correctionRoute: correctionRoute,
            unknownDimensions: unknownDimensions
        )
        self.holdReasons = holdReasons
        self.correctionRoute = correctionRoute
    }

    public static let unknown = PEPAttribute(
        unknownDimensions: [.source, .authority, .semanticClaim, .correctionRoute],
        holdReasons: [.evidence]
    )

    public var independentlyCompletesMeaning: Bool { false }
    public var independentlyConfersAuthority: Bool { false }
    public var independentlyGrantsPermission: Bool { false }

    private static func resolvedUnknowns(
        evidenceAnchor: EvidenceAnchor,
        authorityStatus: ProjectionAuthorityStatus,
        correctionRoute: CorrectionRoute,
        unknownDimensions: [UnknownDimension]
    ) -> [UnknownDimension] {
        var resolved = unknownDimensions
        if (evidenceAnchor.kind == .unknown || evidenceAnchor.sourceID == nil) && !resolved.contains(.source) {
            resolved.append(.source)
        }
        if authorityStatus.decision == .unknown && !resolved.contains(.authority) {
            resolved.append(.authority)
        }
        if correctionRoute == .unknown && !resolved.contains(.correctionRoute) {
            resolved.append(.correctionRoute)
        }
        return resolved
    }
}

/// Boundary for describing a phenotype on a selected abstract surface. It is a
/// value contract only; delivery, consent inference, and runtime authority are
/// permanently false/none here.
public struct PEPExpressionBoundary: Codable, Equatable, Sendable {
    public let authorityStatus: ProjectionAuthorityStatus
    public let allowedExpressionModes: [PEPCommunicationMode]
    public let forbiddenExpressionModes: [PEPCommunicationMode]
    public let allowsInteractionAffordance: Bool
    public let deliveryAllowed: Bool
    public let consentInferred: Bool
    public let runtimeAuthority: String
    public let correctionRoute: CorrectionRoute
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]

    private enum CodingKeys: String, CodingKey {
        case authorityStatus
        case allowedExpressionModes
        case forbiddenExpressionModes
        case allowsInteractionAffordance
        case deliveryAllowed
        case consentInferred
        case runtimeAuthority
        case correctionRoute
        case unknownDimensions
        case holdReasons
    }

    public init(
        authorityStatus: ProjectionAuthorityStatus = .unknown,
        allowedExpressionModes: [PEPCommunicationMode] = [],
        forbiddenExpressionModes: [PEPCommunicationMode] = [],
        allowsInteractionAffordance: Bool = false,
        correctionRoute: CorrectionRoute = .unknown,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) {
        self.authorityStatus = authorityStatus
        self.allowedExpressionModes = allowedExpressionModes
        self.forbiddenExpressionModes = forbiddenExpressionModes
        self.allowsInteractionAffordance = allowsInteractionAffordance
        self.deliveryAllowed = false
        self.consentInferred = false
        self.runtimeAuthority = "none"
        self.correctionRoute = correctionRoute

        var resolvedUnknowns = unknownDimensions
        if authorityStatus.decision == .unknown && !resolvedUnknowns.contains(.authority) {
            resolvedUnknowns.append(.authority)
        }
        if correctionRoute == .unknown && !resolvedUnknowns.contains(.correctionRoute) {
            resolvedUnknowns.append(.correctionRoute)
        }
        self.unknownDimensions = resolvedUnknowns

        var resolvedHolds = holdReasons
        if authorityStatus.decision == .hold && !resolvedHolds.contains(.authority) {
            resolvedHolds.append(.authority)
        }
        self.holdReasons = resolvedHolds
    }

    public static let unknown = PEPExpressionBoundary(
        unknownDimensions: [.authority, .correctionRoute],
        holdReasons: [.authority]
    )

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            authorityStatus: try container.decodeIfPresent(
                ProjectionAuthorityStatus.self,
                forKey: .authorityStatus
            ) ?? .unknown,
            allowedExpressionModes: try container.decodeIfPresent(
                [PEPCommunicationMode].self,
                forKey: .allowedExpressionModes
            ) ?? [],
            forbiddenExpressionModes: try container.decodeIfPresent(
                [PEPCommunicationMode].self,
                forKey: .forbiddenExpressionModes
            ) ?? [],
            allowsInteractionAffordance: try container.decodeIfPresent(
                Bool.self,
                forKey: .allowsInteractionAffordance
            ) ?? false,
            correctionRoute: try container.decodeIfPresent(
                CorrectionRoute.self,
                forKey: .correctionRoute
            ) ?? .unknown,
            unknownDimensions: try container.decodeIfPresent(
                [UnknownDimension].self,
                forKey: .unknownDimensions
            ) ?? [],
            holdReasons: try container.decodeIfPresent(
                [ProjectionHoldReason].self,
                forKey: .holdReasons
            ) ?? []
        )
    }

    public var preservesRuntimeBoundary: Bool {
        deliveryAllowed == false && consentInferred == false && runtimeAuthority == "none"
    }

    public func permits(_ mode: PEPCommunicationMode) -> Bool {
        authorityStatus.decision == .pass &&
            allowedExpressionModes.contains(mode) &&
            !forbiddenExpressionModes.contains(mode)
    }
}

/// Immutable description of how one phenotype may be expressed on a selected
/// abstract surface. This is not a renderer and it does not select the surface.
public struct PEPSurfaceExpression: Codable, Equatable, Sendable {
    public let surfaceClass: PEPSurfaceClass
    public let semanticEmphasis: String
    public let attributes: [PEPAttribute]
    public let density: PEPExpressionDensity
    public let priority: PEPExpressionPriority
    public let legibilityRequirements: [String]
    public let availableCommunicationModes: [PEPCommunicationMode]
    public let interactionAffordance: PEPInteractionAffordanceState
    public let isSelectedSurface: Bool
    public let isRendered: Bool
    public let isDelivered: Bool

    private enum CodingKeys: String, CodingKey {
        case surfaceClass
        case semanticEmphasis
        case attributes
        case density
        case priority
        case legibilityRequirements
        case availableCommunicationModes
        case interactionAffordance
        case isSelectedSurface
        case isRendered
        case isDelivered
    }

    public init(
        surfaceClass: PEPSurfaceClass = .unknown,
        semanticEmphasis: String = "Unknown",
        attributes: [PEPAttribute] = [.unknown],
        density: PEPExpressionDensity = .unknown,
        priority: PEPExpressionPriority = .unknown,
        legibilityRequirements: [String] = [],
        availableCommunicationModes: [PEPCommunicationMode] = [.unknown],
        interactionAffordance: PEPInteractionAffordanceState = .none,
        isSelectedSurface: Bool = false
    ) {
        self.surfaceClass = surfaceClass
        self.semanticEmphasis = semanticEmphasis
        self.attributes = attributes
        self.density = density
        self.priority = priority
        self.legibilityRequirements = legibilityRequirements
        self.availableCommunicationModes = availableCommunicationModes
        self.interactionAffordance = interactionAffordance
        self.isSelectedSurface = isSelectedSurface
        self.isRendered = false
        self.isDelivered = false
    }

    public static let unknown = PEPSurfaceExpression()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            surfaceClass: try container.decodeIfPresent(PEPSurfaceClass.self, forKey: .surfaceClass) ?? .unknown,
            semanticEmphasis: try container.decodeIfPresent(String.self, forKey: .semanticEmphasis) ?? "Unknown",
            attributes: try container.decodeIfPresent([PEPAttribute].self, forKey: .attributes) ?? [.unknown],
            density: try container.decodeIfPresent(PEPExpressionDensity.self, forKey: .density) ?? .unknown,
            priority: try container.decodeIfPresent(PEPExpressionPriority.self, forKey: .priority) ?? .unknown,
            legibilityRequirements: try container.decodeIfPresent(
                [String].self,
                forKey: .legibilityRequirements
            ) ?? [],
            availableCommunicationModes: try container.decodeIfPresent(
                [PEPCommunicationMode].self,
                forKey: .availableCommunicationModes
            ) ?? [.unknown],
            interactionAffordance: try container.decodeIfPresent(
                PEPInteractionAffordanceState.self,
                forKey: .interactionAffordance
            ) ?? .none,
            isSelectedSurface: try container.decodeIfPresent(Bool.self, forKey: .isSelectedSurface) ?? false
        )
    }

    public var unknownDimensions: [UnknownDimension] {
        attributes.reduce(surfaceClass == .unknown ? [.observerRelation] : []) { partial, attribute in
            Self.merged(partial, attribute.unknownDimensions)
        }
    }

    public var holdReasons: [ProjectionHoldReason] {
        attributes.reduce([]) { partial, attribute in
            Self.merged(partial, attribute.holdReasons)
        }
    }

    private static func merged<T: Equatable>(_ lhs: [T], _ rhs: [T]) -> [T] {
        rhs.reduce(lhs) { partial, value in
            partial.contains(value) ? partial : partial + [value]
        }
    }
}

public enum PEPPhenotypeResolutionState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case eligible = "ELIGIBLE"
    case held = "HELD"
    case unknown = "UNKNOWN"
    case forbidden = "FORBIDDEN"
}

/// Result of pure PEP contract evaluation. It returns an immutable phenotype
/// description only. Visibility, rendering, delivery, encounter, consent, and
/// runtime authority remain outside this type.
public struct PEPPhenotypeResolution: Codable, Equatable, Sendable {
    public let state: PEPPhenotypeResolutionState
    public let identity: PEPPhenotypeIdentity
    public let projectionGrounding: ProjectionGrounding?
    public let addressabilityResult: ArkadasAddressabilityResult?
    public let selectedSurfaceClass: PEPSurfaceClass
    public let surfaceExpression: PEPSurfaceExpression
    public let expressionBoundary: PEPExpressionBoundary
    public let resolvedAttributes: [PEPAttribute]
    public let surfaceVariants: [PEPSurfaceExpression]
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]
    public let correctionRoute: CorrectionRoute
    public let isVisible: Bool
    public let isRendered: Bool
    public let isDelivered: Bool
    public let isEncountered: Bool
    public let consentInferred: Bool
    public let runtimeAuthority: String

    private enum CodingKeys: String, CodingKey {
        case state
        case identity
        case projectionGrounding
        case addressabilityResult
        case selectedSurfaceClass
        case surfaceExpression
        case expressionBoundary
        case resolvedAttributes
        case surfaceVariants
        case unknownDimensions
        case holdReasons
        case correctionRoute
        case isVisible
        case isRendered
        case isDelivered
        case isEncountered
        case consentInferred
        case runtimeAuthority
    }

    public init(
        state: PEPPhenotypeResolutionState = .unknown,
        identity: PEPPhenotypeIdentity = .unknown,
        projectionGrounding: ProjectionGrounding? = nil,
        addressabilityResult: ArkadasAddressabilityResult? = nil,
        selectedSurfaceClass: PEPSurfaceClass = .unknown,
        surfaceExpression: PEPSurfaceExpression = .unknown,
        expressionBoundary: PEPExpressionBoundary = .unknown,
        resolvedAttributes: [PEPAttribute] = [.unknown],
        surfaceVariants: [PEPSurfaceExpression] = [],
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = [],
        correctionRoute: CorrectionRoute = .unknown
    ) {
        self.state = state
        self.identity = identity
        self.projectionGrounding = projectionGrounding
        self.addressabilityResult = addressabilityResult
        self.selectedSurfaceClass = selectedSurfaceClass
        self.surfaceExpression = surfaceExpression
        self.expressionBoundary = expressionBoundary
        self.resolvedAttributes = resolvedAttributes
        self.surfaceVariants = surfaceVariants
        self.unknownDimensions = unknownDimensions.isEmpty
            ? Self.defaultUnknowns(
                projectionGrounding: projectionGrounding,
                surfaceExpression: surfaceExpression,
                expressionBoundary: expressionBoundary,
                attributes: resolvedAttributes
            )
            : unknownDimensions
        self.holdReasons = holdReasons.isEmpty
            ? Self.defaultHolds(
                projectionGrounding: projectionGrounding,
                surfaceExpression: surfaceExpression,
                expressionBoundary: expressionBoundary,
                attributes: resolvedAttributes
            )
            : holdReasons
        self.correctionRoute = correctionRoute
        self.isVisible = false
        self.isRendered = false
        self.isDelivered = false
        self.isEncountered = false
        self.consentInferred = false
        self.runtimeAuthority = "none"
    }

    public static let unknown = PEPPhenotypeResolution()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            state: try container.decodeIfPresent(PEPPhenotypeResolutionState.self, forKey: .state) ?? .unknown,
            identity: try container.decodeIfPresent(PEPPhenotypeIdentity.self, forKey: .identity) ?? .unknown,
            projectionGrounding: try container.decodeIfPresent(
                ProjectionGrounding.self,
                forKey: .projectionGrounding
            ),
            addressabilityResult: try container.decodeIfPresent(
                ArkadasAddressabilityResult.self,
                forKey: .addressabilityResult
            ),
            selectedSurfaceClass: try container.decodeIfPresent(
                PEPSurfaceClass.self,
                forKey: .selectedSurfaceClass
            ) ?? .unknown,
            surfaceExpression: try container.decodeIfPresent(
                PEPSurfaceExpression.self,
                forKey: .surfaceExpression
            ) ?? .unknown,
            expressionBoundary: try container.decodeIfPresent(
                PEPExpressionBoundary.self,
                forKey: .expressionBoundary
            ) ?? .unknown,
            resolvedAttributes: try container.decodeIfPresent(
                [PEPAttribute].self,
                forKey: .resolvedAttributes
            ) ?? [.unknown],
            surfaceVariants: try container.decodeIfPresent(
                [PEPSurfaceExpression].self,
                forKey: .surfaceVariants
            ) ?? [],
            unknownDimensions: try container.decodeIfPresent(
                [UnknownDimension].self,
                forKey: .unknownDimensions
            ) ?? [],
            holdReasons: try container.decodeIfPresent(
                [ProjectionHoldReason].self,
                forKey: .holdReasons
            ) ?? [],
            correctionRoute: try container.decodeIfPresent(CorrectionRoute.self, forKey: .correctionRoute) ?? .unknown
        )
    }

    public static func resolve(
        projectionGrounding: ProjectionGrounding,
        addressabilityResult: ArkadasAddressabilityResult? = nil,
        selectedSurfaceClass: PEPSurfaceClass,
        surfaceExpression: PEPSurfaceExpression,
        expressionBoundary: PEPExpressionBoundary,
        attributes: [PEPAttribute],
        surfaceVariants: [PEPSurfaceExpression] = []
    ) -> PEPPhenotypeResolution {
        let identity = PEPPhenotypeIdentity(
            phenotypeID: "pep:\(projectionGrounding.projectionIdentity.projectionID):\(selectedSurfaceClass.rawValue)",
            genotypeObject: projectionGrounding.representedObject,
            projectionIdentity: projectionGrounding.projectionIdentity,
            sourceExpression: surfaceExpression.semanticEmphasis
        )
        let unknowns = defaultUnknowns(
            projectionGrounding: projectionGrounding,
            surfaceExpression: surfaceExpression,
            expressionBoundary: expressionBoundary,
            attributes: attributes
        )
        let holds = defaultHolds(
            projectionGrounding: projectionGrounding,
            surfaceExpression: surfaceExpression,
            expressionBoundary: expressionBoundary,
            attributes: attributes
        )
        let state = resolvedState(
            projectionGrounding: projectionGrounding,
            surfaceExpression: surfaceExpression,
            expressionBoundary: expressionBoundary,
            attributes: attributes,
            unknowns: unknowns,
            holds: holds
        )

        return PEPPhenotypeResolution(
            state: state,
            identity: identity,
            projectionGrounding: projectionGrounding,
            addressabilityResult: addressabilityResult,
            selectedSurfaceClass: selectedSurfaceClass,
            surfaceExpression: surfaceExpression,
            expressionBoundary: expressionBoundary,
            resolvedAttributes: attributes,
            surfaceVariants: surfaceVariants,
            unknownDimensions: unknowns,
            holdReasons: holds,
            correctionRoute: projectionGrounding.correctionRoute
        )
    }

    public var preservesLineage: Bool {
        guard let projectionGrounding else { return false }
        return identity.genotypeObject == projectionGrounding.representedObject &&
            identity.projectionIdentity == projectionGrounding.projectionIdentity &&
            identity.preservesIdentitySeparation
    }

    public var preservesRuntimeBoundary: Bool {
        !isVisible && !isRendered && !isDelivered && !isEncountered &&
            !consentInferred && runtimeAuthority == "none" &&
            expressionBoundary.preservesRuntimeBoundary
    }

    public var mayRepresentInteractionAffordance: Bool {
        state == .eligible &&
            expressionBoundary.allowsInteractionAffordance &&
            expressionBoundary.authorityStatus.decision == .pass &&
            holdReasons.isEmpty
    }

    private static func resolvedState(
        projectionGrounding: ProjectionGrounding,
        surfaceExpression: PEPSurfaceExpression,
        expressionBoundary: PEPExpressionBoundary,
        attributes: [PEPAttribute],
        unknowns: [UnknownDimension],
        holds: [ProjectionHoldReason]
    ) -> PEPPhenotypeResolutionState {
        if expressionBoundary.authorityStatus.decision == .fail {
            return .forbidden
        }
        if projectionGrounding.hasAuthorityHold || expressionBoundary.authorityStatus.decision == .hold || holds.contains(.authority) {
            return .held
        }
        if expressionBoundary.authorityStatus.decision == .unknown || projectionGrounding.hasUnknownSource || unknowns.contains(.source) {
            return .unknown
        }
        let expressionModes = surfaceExpression.availableCommunicationModes
        let hasPermittedMode = expressionModes.contains { expressionBoundary.permits($0) }
        if !hasPermittedMode || surfaceExpression.surfaceClass == .unknown || attributes.isEmpty {
            return .held
        }
        return .eligible
    }

    private static func defaultUnknowns(
        projectionGrounding: ProjectionGrounding?,
        surfaceExpression: PEPSurfaceExpression,
        expressionBoundary: PEPExpressionBoundary,
        attributes: [PEPAttribute]
    ) -> [UnknownDimension] {
        var resolved: [UnknownDimension] = []
        resolved = merged(resolved, projectionGrounding?.unknownDimensions ?? [.identity, .source, .authority])
        resolved = merged(resolved, surfaceExpression.unknownDimensions)
        resolved = merged(resolved, expressionBoundary.unknownDimensions)
        for attribute in attributes {
            resolved = merged(resolved, attribute.unknownDimensions)
        }
        return resolved
    }

    private static func defaultHolds(
        projectionGrounding: ProjectionGrounding?,
        surfaceExpression: PEPSurfaceExpression,
        expressionBoundary: PEPExpressionBoundary,
        attributes: [PEPAttribute]
    ) -> [ProjectionHoldReason] {
        var resolved: [ProjectionHoldReason] = []
        resolved = merged(resolved, projectionGrounding?.holdReasons ?? [.evidence])
        resolved = merged(resolved, surfaceExpression.holdReasons)
        resolved = merged(resolved, expressionBoundary.holdReasons)
        for attribute in attributes {
            resolved = merged(resolved, attribute.holdReasons)
        }
        return resolved
    }

    private static func merged<T: Equatable>(_ lhs: [T], _ rhs: [T]) -> [T] {
        rhs.reduce(lhs) { partial, value in
            partial.contains(value) ? partial : partial + [value]
        }
    }
}
