import Foundation

/// Directional role of a surface in a signal path. `signalAndReceiver` means
/// both directions are possible at the surface boundary; it never merges the
/// source object, its representation, or its native authority.
public enum FieldSignalDirection: String, Codable, CaseIterable, Equatable, Sendable {
    case signal = "SIGNAL"
    case receiver = "RECEIVER"
    case signalAndReceiver = "SIGNAL_AND_RECEIVER"
    case observerOnly = "OBSERVER_ONLY"
    case conductorOnly = "CONDUCTOR_ONLY"
    case unknown = "UNKNOWN"
}

public enum FieldManifestationFamily: String, Codable, CaseIterable, Equatable, Sendable {
    case externalIntake = "EXTERNAL_INTAKE"
    case externalMirror = "EXTERNAL_MIRROR"
    case internalRuntime = "INTERNAL_RUNTIME"
    case dojoSuite = "DOJO_SUITE"
    case dojoToday = "DOJO_TODAY"
    case deviceFeedback = "DEVICE_FEEDBACK"
}

/// Relationship between a surface and the observer/environment. This is a
/// contextual relationship, not a claim that the digital surface is an
/// organic observer or that it has authority over the observer.
public enum FieldObserverRelationship: String, Codable, CaseIterable, Equatable, Sendable {
    case externalSourceBoundary = "EXTERNAL_SOURCE_BOUNDARY"
    case humanObserver = "HUMAN_OBSERVER"
    case digitalObserver = "DIGITAL_OBSERVER"
    case cohabitationalSovereignDigitalObserver = "COHABITATIONAL_SOVEREIGN_DIGITAL_OBSERVER"
    case unknown = "UNKNOWN"
}

public enum FieldLiveExperienceState: String, Codable, CaseIterable, Equatable, Sendable {
    case notApplicable = "NOT_APPLICABLE"
    case witnessedBounded = "WITNESSED_BOUNDED"
    case partial = "PARTIAL"
    case held = "HELD"
    case unknown = "UNKNOWN"
}

/// A read-only capability expression for one manifestation surface. It is a
/// projection contract: it says what the surface can presently expose or
/// receive, and what remains held. It does not create a connector or route.
public struct FieldManifestationCapabilityEntry: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let genotypeID: String
    public let surfaceID: String
    public let family: FieldManifestationFamily
    public let signalDirection: FieldSignalDirection
    public let observerRelationship: FieldObserverRelationship
    public let nativeResidence: String
    public let liveExperience: FieldLiveExperienceState
    public let evidenceState: FieldSurfaceEvidenceState
    public let authorityCeiling: String
    public let availableFunctions: [String]
    public let heldFunctions: [String]
    public let globalFieldAuthority: Bool

    public init(
        genotypeID: String = FieldManifestationCapabilityCatalog.genotypeID,
        surfaceID: String,
        family: FieldManifestationFamily,
        signalDirection: FieldSignalDirection,
        observerRelationship: FieldObserverRelationship,
        nativeResidence: String,
        liveExperience: FieldLiveExperienceState,
        evidenceState: FieldSurfaceEvidenceState,
        authorityCeiling: String,
        availableFunctions: [String],
        heldFunctions: [String],
        globalFieldAuthority: Bool = false
    ) {
        self.id = surfaceID
        self.genotypeID = genotypeID
        self.surfaceID = surfaceID
        self.family = family
        self.signalDirection = signalDirection
        self.observerRelationship = observerRelationship
        self.nativeResidence = nativeResidence
        self.liveExperience = liveExperience
        self.evidenceState = evidenceState
        self.authorityCeiling = authorityCeiling
        self.availableFunctions = availableFunctions
        self.heldFunctions = heldFunctions
        self.globalFieldAuthority = globalFieldAuthority
    }
}

/// Capability catalogue for the horizontal surface ecosystems. Entries remain
/// separate even when they share a family or directional signal role.
public enum FieldManifestationCapabilityCatalog {
    public static let genotypeID = FieldSurfaceCoordinationCatalog.genotypeID

    public static let entries: [FieldManifestationCapabilityEntry] = [
        .init(
            surfaceID: "akron",
            family: .externalIntake,
            signalDirection: .signalAndReceiver,
            observerRelationship: .externalSourceBoundary,
            nativeResidence: "Akron external source custody and intake boundary",
            liveExperience: .notApplicable,
            evidenceState: .partial,
            authorityCeiling: "POINTER_ONLY",
            availableFunctions: ["receive external source pointers", "preserve source custody", "route admitted metadata"],
            heldFunctions: ["replace source truth", "direct external content into internal circulation"]
        ),
        .init(
            surfaceID: "notion",
            family: .externalMirror,
            signalDirection: .signalAndReceiver,
            observerRelationship: .humanObserver,
            nativeResidence: "Notion architecture and intention pages",
            liveExperience: .partial,
            evidenceState: .witnessed,
            authorityCeiling: "REFERENCE_ONLY",
            availableFunctions: ["receive and present refined architecture pointers", "return narrative mirror updates"],
            heldFunctions: ["become implementation authority", "replace native source objects"]
        ),
        .init(
            surfaceID: "google_drive",
            family: .externalMirror,
            signalDirection: .signalAndReceiver,
            observerRelationship: .humanObserver,
            nativeResidence: "Google Workspace native documents, sheets, and evidence files",
            liveExperience: .partial,
            evidenceState: .witnessed,
            authorityCeiling: "MIRROR_ONLY",
            availableFunctions: ["receive and present evidence pointers", "return editable mirror representations"],
            heldFunctions: ["replace native evidence custody", "self-promote mirrored content"]
        ),
        .init(
            surfaceID: "vercel",
            family: .externalMirror,
            signalDirection: .signalAndReceiver,
            observerRelationship: .humanObserver,
            nativeResidence: "Vercel hosted projects, deployments, and provider billing surface",
            liveExperience: .partial,
            evidenceState: .partial,
            authorityCeiling: "PROVIDER_WITNESS_ONLY",
            availableFunctions: ["present hosted phenotype and provider state"],
            heldFunctions: ["replace local source", "adjudicate billing", "execute deployment without separate approval"]
        ),
        .init(
            surfaceID: "canva",
            family: .externalMirror,
            signalDirection: .signalAndReceiver,
            observerRelationship: .humanObserver,
            nativeResidence: "Canva visual design and presentation workspace",
            liveExperience: .partial,
            evidenceState: .partial,
            authorityCeiling: "VISUAL_WITNESS_ONLY",
            availableFunctions: ["present visual phenotype candidates", "receive design review context"],
            heldFunctions: ["replace visual source custody", "claim implementation or execution authority"]
        ),
        .init(
            surfaceID: "obiwan",
            family: .internalRuntime,
            signalDirection: .observerOnly,
            observerRelationship: .digitalObserver,
            nativeResidence: "OBI-WAN observer state and observation records",
            liveExperience: .witnessedBounded,
            evidenceState: .witnessed,
            authorityCeiling: "OBSERVATION_ONLY",
            availableFunctions: ["receive bounded observations", "return observation packets to DOJO"],
            heldFunctions: ["infer organic state without a witness", "promote authority"]
        ),
        .init(
            surfaceID: "dojo",
            family: .internalRuntime,
            signalDirection: .conductorOnly,
            observerRelationship: .digitalObserver,
            nativeResidence: "DOJO accepted chamber streams and orchestration state",
            liveExperience: .witnessedBounded,
            evidenceState: .witnessed,
            authorityCeiling: "OBSERVATION_ONLY",
            availableFunctions: ["conduct accepted observer returns", "record bounded internal circulation"],
            heldFunctions: ["replace the source object", "promote a model or provider result automatically"]
        ),
        .init(
            surfaceID: "dojo_suite",
            family: .dojoSuite,
            signalDirection: .signalAndReceiver,
            observerRelationship: .cohabitationalSovereignDigitalObserver,
            nativeResidence: "DOJO Suite local working surface and local object/receipt seams",
            liveExperience: .partial,
            evidenceState: .partial,
            authorityCeiling: "MIRROR_AND_LOCAL_PREPARE_ONLY",
            availableFunctions: ["present observer-aligned local projections", "materialise bounded local objects", "prepare receipt-backed handoffs"],
            heldFunctions: ["become DOJO authority", "claim full live device sensing", "promote external provider output"]
        ),
        .init(
            surfaceID: "dojo_today",
            family: .dojoToday,
            signalDirection: .signalAndReceiver,
            observerRelationship: .cohabitationalSovereignDigitalObserver,
            nativeResidence: "DOJO Today ordinary working surface and experience shell",
            liveExperience: .witnessedBounded,
            evidenceState: .partial,
            authorityCeiling: "EXPERIENCE_AND_LOCAL_CAPTURE_ONLY",
            availableFunctions: ["receive bounded human input", "present object-scoped live experience", "show explicit HOLD states"],
            heldFunctions: ["produce the full Today processing packet at runtime", "claim live organic/device sensing", "become a dashboard-wide authority"]
        ),
        .init(
            surfaceID: "computer_breathing",
            family: .deviceFeedback,
            signalDirection: .unknown,
            observerRelationship: .unknown,
            nativeResidence: "consent-bound device and environmental feedback boundary",
            liveExperience: .unknown,
            evidenceState: .unknown,
            authorityCeiling: "HOLD_UNKNOWN",
            availableFunctions: [],
            heldFunctions: ["all device feedback until callable runtime and consent witness exist"]
        )
    ]

    public static func entry(for surfaceID: String) -> FieldManifestationCapabilityEntry? {
        entries.first { $0.surfaceID == surfaceID }
    }

    public static func invariantViolations() -> [String] {
        var violations: [String] = []
        let ids = entries.map(\.surfaceID)
        if Set(ids).count != ids.count { violations.append("duplicate manifestation surface ID") }
        if entries.contains(where: { $0.genotypeID != genotypeID }) {
            violations.append("manifestation genotype drift")
        }
        if entries.contains(where: { $0.globalFieldAuthority }) {
            violations.append("manifestation surface claims global FIELD authority")
        }
        if entries.contains(where: { $0.authorityCeiling.isEmpty }) {
            violations.append("manifestation authority ceiling is empty")
        }
        return violations
    }
}
