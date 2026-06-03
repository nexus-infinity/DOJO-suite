import Foundation

/// ARCH-2026-DOJO-MULTI Phase 3 shared registry.
///
/// The category registry namespace is separate from chamber routing:
/// - `●`, `∿`, `⚓`, and `▼` below are category identifiers, not new chamber vertices.
/// - Persistence compiles into `OBI-WAN`, `TATA`, `ATLAS`, `DOJO`, and `AKRON` only.
/// - King's Chamber remains translation/registry metadata only.
/// - HAL and ARKADAS remain runtime bridge or homeostasis metadata only.
public enum CategoryAxis: String, CaseIterable, Codable, Sendable {
    case witness = "●"
    case environment = "∿"
    case soma = "⚓"
    case logic = "▼"

    public var stableIdentifier: String {
        switch self {
        case .witness:
            return "witness"
        case .environment:
            return "environment"
        case .soma:
            return "soma"
        case .logic:
            return "logic"
        }
    }

    public var displayName: String {
        switch self {
        case .witness:
            return "Witness"
        case .environment:
            return "Environment"
        case .soma:
            return "Soma"
        case .logic:
            return "Logic"
        }
    }

    public var defaultRoutingPin: RoutingPin {
        RoutingPin.categoryDefault(for: self)
    }
}

/// Canonical persistence homes. Deliberately excludes King's Chamber, HAL, and ARKADAS.
public enum PersistenceHome: String, CaseIterable, Codable, Sendable {
    case obiWan = "OBI-WAN"
    case tata = "TATA"
    case atlas = "ATLAS"
    case dojo = "DOJO"
    case akron = "AKRON"
}

/// Runtime-only bridge metadata. These are not persistence seats.
public enum RuntimeBridge: String, CaseIterable, Codable, Sendable {
    case arkadas = "ARKADAS"
    case halToArkadas = "HAL→ARKADAS"
}

public struct RoutingPin: Codable, Equatable, Sendable {
    public let canonicalHome: PersistenceHome
    public let validationHome: PersistenceHome
    public let compileHome: PersistenceHome
    public let manifestHome: PersistenceHome
    public let runtimeBridge: RuntimeBridge
    public let archiveHome: PersistenceHome

    public init(
        canonicalHome: PersistenceHome,
        validationHome: PersistenceHome,
        compileHome: PersistenceHome,
        manifestHome: PersistenceHome,
        runtimeBridge: RuntimeBridge,
        archiveHome: PersistenceHome
    ) {
        self.canonicalHome = canonicalHome
        self.validationHome = validationHome
        self.compileHome = compileHome
        self.manifestHome = manifestHome
        self.runtimeBridge = runtimeBridge
        self.archiveHome = archiveHome
    }

    public static func categoryDefault(for axis: CategoryAxis) -> RoutingPin {
        switch axis {
        case .witness:
            return RoutingPin(
                canonicalHome: .obiWan,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .arkadas,
                archiveHome: .akron
            )
        case .environment:
            return RoutingPin(
                canonicalHome: .obiWan,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .halToArkadas,
                archiveHome: .akron
            )
        case .soma:
            return RoutingPin(
                canonicalHome: .obiWan,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .halToArkadas,
                archiveHome: .akron
            )
        case .logic:
            return RoutingPin(
                canonicalHome: .tata,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .arkadas,
                archiveHome: .akron
            )
        }
    }
}

public enum OriginDevice: String, CaseIterable, Codable, Sendable {
    case iphone = "iPhone"
    case appleWatch = "Apple Watch"
    case appleTV = "Apple TV"
    case ipad = "iPad"
    case mac = "Mac"
    case carPlay = "CarPlay"
    case appleHome = "Apple Home"
    case unknown = "Unknown"
}

public enum MurmurLocalState: String, CaseIterable, Codable, Sendable {
    case queued = "queued"
    case degraded = "degraded"
    case ratificationQueued = "ratificationQueued"
    case promoted = "promoted"
    case purged = "purged"
}

public enum SaveIntent: String, CaseIterable, Codable, Sendable {
    case queuedOnly = "queuedOnly"
    case explicitSave = "explicitSave"
    case discardAfterWindow = "discardAfterWindow"
}

public struct MurmurEnvelope: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let axis: CategoryAxis
    public let originDevice: OriginDevice
    public let observedAt: Date
    public let payloadRef: String
    public let confidence: Double
    public let localState: MurmurLocalState
    public let saveIntent: SaveIntent
    public let routingPin: RoutingPin

    public init(
        id: UUID = UUID(),
        axis: CategoryAxis,
        originDevice: OriginDevice,
        observedAt: Date = Date(),
        payloadRef: String,
        confidence: Double,
        localState: MurmurLocalState,
        saveIntent: SaveIntent,
        routingPin: RoutingPin? = nil
    ) {
        self.id = id
        self.axis = axis
        self.originDevice = originDevice
        self.observedAt = observedAt
        self.payloadRef = payloadRef
        self.confidence = confidence
        self.localState = localState
        self.saveIntent = saveIntent
        self.routingPin = routingPin ?? axis.defaultRoutingPin
    }

    /// `Environment` and `Soma` remain queued-only unless the user explicitly saves them.
    public var requiresExplicitSaveForPromotion: Bool {
        axis == .environment || axis == .soma
    }

    public var staysLocalUntilExplicitSave: Bool {
        requiresExplicitSaveForPromotion && saveIntent != .explicitSave
    }

    /// Registry-only phase expresses the hash requirement as contract intent.
    public var shouldHashPayloadOnPromotion: Bool {
        !staysLocalUntilExplicitSave
    }

    public var shouldCreateWitnessSeat: Bool {
        !staysLocalUntilExplicitSave
    }

    public var shouldQueueTataRatification: Bool {
        !staysLocalUntilExplicitSave
    }

    public var shouldArchivePayload: Bool {
        !staysLocalUntilExplicitSave
    }

    public var nextLocalStateAfterQueueWindow: MurmurLocalState {
        if staysLocalUntilExplicitSave {
            return .purged
        }
        return .ratificationQueued
    }
}

public struct RegistryMetadata: Codable, Equatable, Sendable {
    public static let currentVersion = "1.0.0"

    public let version: String
    public let effectiveAtUTC: Date
    public let translationAuthority: String

    public init(
        version: String = RegistryMetadata.currentVersion,
        effectiveAtUTC: Date = Date(),
        translationAuthority: String = "King's Chamber"
    ) {
        self.version = version
        self.effectiveAtUTC = effectiveAtUTC
        self.translationAuthority = translationAuthority
    }
}

public enum PulsePrimitive {
    public static let canonical = "≈"
    public static let retiredLegacy = "∿"

    public static func accepts(_ symbol: String) -> Bool {
        symbol == canonical
    }
}

public enum InvestigationExtension {
    /// ATLAS-led investigation extension. Not a fifth category axis or a new vertex.
    public struct BreachBrick: Codable, Equatable, Sendable {
        public struct WitnessCompanion: Codable, Equatable, Sendable {
            public let evidenceRef: String
            public let sensitivity: String
            public let excerpt: String
            public let sourceAnchor: String

            public init(
                evidenceRef: String,
                sensitivity: String,
                excerpt: String,
                sourceAnchor: String
            ) {
                self.evidenceRef = evidenceRef
                self.sensitivity = sensitivity
                self.excerpt = excerpt
                self.sourceAnchor = sourceAnchor
            }
        }

        public struct RatificationCompanion: Codable, Equatable, Sendable {
            public let tataAnchor: String
            public let validationPin: String
            public let timeWindow: String
            public let fact: String
            public let unresolvedGeometry: String?

            public init(
                tataAnchor: String = "TATA Anchor",
                validationPin: String,
                timeWindow: String,
                fact: String,
                unresolvedGeometry: String? = nil
            ) {
                self.tataAnchor = tataAnchor
                self.validationPin = validationPin
                self.timeWindow = timeWindow
                self.fact = fact
                self.unresolvedGeometry = unresolvedGeometry
            }
        }

        public struct ManifestationCompanion: Codable, Equatable, Sendable {
            public let dojoAllowedActions: String
            public let requestMissingEvidence: Bool
            public let filing: Bool
            public let additionalActions: [String]

            public init(
                dojoAllowedActions: String = "DOJO Allowed Actions",
                requestMissingEvidence: Bool,
                filing: Bool,
                additionalActions: [String] = []
            ) {
                self.dojoAllowedActions = dojoAllowedActions
                self.requestMissingEvidence = requestMissingEvidence
                self.filing = filing
                self.additionalActions = additionalActions
            }
        }

        public let brickID: String
        public let actID: String
        public let actor: String
        public let duty: String
        public let confidence: Double
        public let probeList: [String]
        public let siblingBricks: [String]
        public let witnessCompanion: WitnessCompanion
        public let ratificationCompanion: RatificationCompanion
        public let manifestationCompanion: ManifestationCompanion

        public init(
            brickID: String,
            actID: String,
            actor: String,
            duty: String,
            confidence: Double,
            probeList: [String],
            siblingBricks: [String] = [],
            witnessCompanion: WitnessCompanion,
            ratificationCompanion: RatificationCompanion,
            manifestationCompanion: ManifestationCompanion
        ) {
            self.brickID = brickID
            self.actID = actID
            self.actor = actor
            self.duty = duty
            self.confidence = confidence
            self.probeList = probeList
            self.siblingBricks = siblingBricks
            self.witnessCompanion = witnessCompanion
            self.ratificationCompanion = ratificationCompanion
            self.manifestationCompanion = manifestationCompanion
        }
    }
}
