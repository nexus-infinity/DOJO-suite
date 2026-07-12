// DOJOShared v0.2 contract surface.
// Meaning is profile-qualified: frequency alone is not meaning.

public enum SphereProfile: String, Codable, Sendable, Equatable, CaseIterable {
    case dojo
    case soma
    case metatronBridge
    case chakraResonance
    case uiWorkLayer
    case brandUI
    case unknown
}

public enum GeometryProfile: String, Codable, Sendable, Equatable, CaseIterable {
    case dojoFirstPrinciples
    case somaResonanceLattice
    case metatronTranslation
    case chakraSubstrate
    case uiWorkLayer
    case unknown
}

public struct ResonanceSignature: Codable, Sendable, Equatable {
    public let sphere: SphereProfile
    public let geometry: GeometryProfile
    public let frequencyHz: Int?
    public let prime: Int?
    public let symbol: String?
    public let colorHex: String?
    public let function: String
    public let stage: String?
    public let meaning: String
    public let notes: String?

    public init(
        sphere: SphereProfile,
        geometry: GeometryProfile,
        frequencyHz: Int? = nil,
        prime: Int? = nil,
        symbol: String? = nil,
        colorHex: String? = nil,
        function: String,
        stage: String? = nil,
        meaning: String,
        notes: String? = nil
    ) {
        self.sphere = sphere
        self.geometry = geometry
        self.frequencyHz = frequencyHz
        self.prime = prime
        self.symbol = symbol
        self.colorHex = colorHex
        self.function = function
        self.stage = stage
        self.meaning = meaning
        self.notes = notes
    }
}

public enum WorkLayerStatus: String, Codable, Sendable, Equatable, CaseIterable {
    case workLayer
    case prototypeNotCanon
    case canonCandidate
    case canonApproved
    case productReady
    case hold
    case unknown
}

public enum SemanticHoldReason: String, Codable, Sendable, Equatable, CaseIterable {
    case missingSphereProfile
    case missingGeometryProfile
    case missingResonanceSignature
    case unqualifiedFrequency
    case unqualifiedRoute
    case akronReceiptMissing
    case packetBoundaryUnresolved
    case fieldKitAuthorityUnresolved
    case implementationLeakedIntoContract
    case unknown
}
