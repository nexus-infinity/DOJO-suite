import Foundation

// MARK: - Geometric Layer

/// Sacred geometric shapes corresponding to FIELD vertices
/// Canonical mapping per Notion Vertex Model Deployment Plan (2026-01-20)
public enum GeometricShape: String, Codable, Sendable {
    case circle = "●"                   // OBI-WAN (963 Hz) — Observer
    case invertedTriangle = "▼"         // TATA (432 Hz) — Truth/Temporal
    case triangle = "▲"                 // ATLAS (528 Hz) — Knowledge/Navigation
    case square = "◼︎"                   // DOJO (741 Hz) — Manifestation Apex
    case crosshairsCircle = "⊗"         // King's Chamber (852 Hz) — deterministic infrastructure
    case filledTarget = "◉"             // Arkadaş (717 Hz) — embodiment bridge / SPIN
    case diamond = "◆"                  // Akron Gateway (396 Hz) — Archive
    case hexagon = "⬡"                  // Metatron Cube
}

/// Sacred colors mapped to solfeggio frequencies
public enum GeometricColor: String, Codable, Sendable {
    case red = "#FF0000"                // 396 Hz - Akron Gateway
    case orange = "#FF8000"             // 432 Hz - TATA
    case green = "#00FF00"              // 528 Hz - ATLAS
    case blue = "#0000FF"               // 741 Hz - DOJO
    case indigo = "#4B0082"             // 852 Hz - King's Chamber
    case gold = "#EAB308"               // 717 Hz - Arkadaş
    case violet = "#8B00FF"             // 963 Hz - OBI-WAN
}

/// Geometric properties defining shape, frequency, and position in the Sacred Pyramid
public struct GeometricProperties: Codable, Sendable {
    public let shape: GeometricShape
    /// Optional canonical routing identity when the visual shape is not the route glyph.
    public let routeSymbolOverride: String?
    public let color: GeometricColor
    public let frequency: Float         // Hz - Solfeggio frequency
    public let position: Float          // 0.0 (foundation) → 1.0 (apex)

    public init(
        shape: GeometricShape,
        color: GeometricColor,
        frequency: Float,
        position: Float,
        routeSymbolOverride: String? = nil
    ) {
        self.shape = shape
        self.routeSymbolOverride = routeSymbolOverride
        self.color = color
        self.frequency = frequency
        self.position = position
    }

    /// Canonical route identity. Visual geometry may remain distinct.
    public var canonicalRouteSymbol: String {
        routeSymbolOverride ?? shape.rawValue
    }
}

// MARK: - Semantic Layer

/// Domain classification for OOO entities
public enum SemanticDomain: String, Codable, Sendable {
    case legal          // Legal/contractual domain (TATA)
    case temporal       // Time/cadence domain (OBI-WAN)
    case identity       // Identity/consciousness (Arkadaş)
    case geometric      // Geometric/mathematical (ATLAS)
    case commercial     // Commercial/transactional
    case translation    // Translation/bridging (King's Chamber)
    case archive        // Archive/storage (Akron Gateway)
}

/// Semantic properties defining domain, tradition, and intent
public struct SemanticProperties: Codable, Sendable {
    public let domain: SemanticDomain
    public let culturalTradition: String
    public let intent: String

    public init(domain: SemanticDomain, culturalTradition: String, intent: String) {
        self.domain = domain
        self.culturalTradition = culturalTradition
        self.intent = intent
    }
}

// MARK: - Temporal Layer

/// Lifecycle phase of an OOO entity
public enum LifecyclePhase: String, Codable, Sendable {
    case proposal       // Proposed but not yet implemented
    case scaffold       // Scaffolding/initial implementation
    case active         // Active and operational
    case deprecated     // Deprecated but still functional
    case archived       // Archived/historical
    case eternal        // Eternal/unchanging (sacred constants)
}

/// Temporal properties defining cadence, lifecycle, and observer calibration
public struct TemporalProperties: Codable, Sendable {
    public let cadence: Float?          // Hz (nil for continuous/eternal)
    public let lifecyclePhase: LifecyclePhase
    public let observerCalibrated: Bool // Aligned with JB (nexus-infinity)

    public init(cadence: Float?, lifecyclePhase: LifecyclePhase, observerCalibrated: Bool) {
        self.cadence = cadence
        self.lifecyclePhase = lifecyclePhase
        self.observerCalibrated = observerCalibrated
    }
}

// MARK: - OOO Entity

/// Object-Oriented Ontology Entity
/// Every entity possesses Geometric, Semantic, and Temporal properties
public struct OOOEntity: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let geometric: GeometricProperties
    public let semantic: SemanticProperties
    public let temporal: TemporalProperties

    public init(
        id: UUID = UUID(),
        name: String,
        geometric: GeometricProperties,
        semantic: SemanticProperties,
        temporal: TemporalProperties
    ) {
        self.id = id
        self.name = name
        self.geometric = geometric
        self.semantic = semantic
        self.temporal = temporal
    }
}

// MARK: - Sacred Pyramid Vertices

public extension OOOEntity {
    /// OBI-WAN: Observer, Living Memory (963 Hz - Apex)
    static let obiWan = OOOEntity(
        name: "OBI-WAN",
        geometric: GeometricProperties(
            shape: .circle,
            color: .violet,
            frequency: 963.0,
            position: 1.0  // Apex
        ),
        semantic: SemanticProperties(
            domain: .temporal,
            culturalTradition: "Crown Chakra / Unity Consciousness",
            intent: "Observer calibration, living memory, unified awareness"
        ),
        temporal: TemporalProperties(
            cadence: 963.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// ▼ TATA: Truth Anchor, Legal Record (432 Hz - Base)
    static let tata = OOOEntity(
        name: "TATA",
        geometric: GeometricProperties(
            shape: .invertedTriangle,
            color: .orange,
            frequency: 432.0,
            position: 0.0  // Base
        ),
        semantic: SemanticProperties(
            domain: .legal,
            culturalTradition: "Sacral Chakra / Natural Tuning (432 Hz)",
            intent: "Legal record, truth anchor, immutable documentation"
        ),
        temporal: TemporalProperties(
            cadence: 432.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// ▲ ATLAS: Knowledge/Navigation, AI Access (528 Hz - Base)
    static let atlas = OOOEntity(
        name: "ATLAS",
        geometric: GeometricProperties(
            shape: .triangle,
            color: .green,
            frequency: 528.0,
            position: 0.0  // Base
        ),
        semantic: SemanticProperties(
            domain: .geometric,
            culturalTradition: "Solar Plexus Chakra / DNA Repair (528 Hz)",
            intent: "Geometric wisdom, AI infrastructure, knowledge access"
        ),
        temporal: TemporalProperties(
            cadence: 528.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// ◼︎ DOJO: Consciousness Synthesis, Manifestation (741 Hz - Apex)
    static let dojo = OOOEntity(
        name: "DOJO",
        geometric: GeometricProperties(
            shape: .square,
            color: .blue,
            frequency: 741.0,
            position: 0.667  // 66.7% - Manifestation apex
        ),
        semantic: SemanticProperties(
            domain: .translation,
            culturalTradition: "Throat Chakra / Expression (741 Hz)",
            intent: "Orchestration, signal routing, manifestation coordination"
        ),
        temporal: TemporalProperties(
            cadence: 741.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// Visual ◆ Akron Gateway: Sovereign Archive, Proof Storage (396 Hz - Foundation).
    /// Routing remains canonical ◻; ♦︎ is the filesystem alias.
    static let akronGateway = OOOEntity(
        name: "Akron Gateway",
        geometric: GeometricProperties(
            shape: .diamond,
            color: .red,
            frequency: 396.0,
            position: 0.0,  // Foundation
            routeSymbolOverride: "◻"
        ),
        semantic: SemanticProperties(
            domain: .archive,
            culturalTradition: "Root Chakra / Liberation (396 Hz)",
            intent: "Sovereign archive, immutable proof, cost enforcement"
        ),
        temporal: TemporalProperties(
            cadence: 396.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// ◉ Arkadaş: embodiment bridge / SPIN (717 Hz).
    /// Occupies translation height; does not own 852 or King's Chamber.
    /// Display spelling: Turkish arkadaş — ş = U+015F (cedilla below s), not š caron.
    static let arkadas = OOOEntity(
        name: "Arkadaş",
        geometric: GeometricProperties(
            shape: .filledTarget,
            color: .gold,
            frequency: 717.0,
            position: 0.382  // occupancy at translation height — not the 852 listen identity
        ),
        semantic: SemanticProperties(
            domain: .identity,
            culturalTradition: "Turkish arkadaş — friend/companion (ş U+015F)",
            intent: "Hardware↔software↔observer bridge, homeostasis, declared-vs-actual"
        ),
        temporal: TemporalProperties(
            cadence: 717.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// ⊗ King's Chamber: deterministic infrastructure (852 Hz — 38.2% from base).
    /// Not Arkadaş. Not a model-bearing vertex.
    static let kingsChamber = OOOEntity(
        name: "King's Chamber",
        geometric: GeometricProperties(
            shape: .crosshairsCircle,
            color: .indigo,
            frequency: 852.0,
            position: 0.382
        ),
        semantic: SemanticProperties(
            domain: .translation,
            culturalTradition: "Third Eye / translation membrane (852 Hz)",
            intent: "Admit, route, arbitrate — deterministic infrastructure"
        ),
        temporal: TemporalProperties(
            cadence: 852.0,
            lifecyclePhase: .eternal,
            observerCalibrated: true
        )
    )

    /// Six model-bearing vertices. King's Chamber is infrastructure, not in this list.
    static let sacredVertices: [OOOEntity] = [
        obiWan,
        tata,
        atlas,
        dojo,
        akronGateway,
        arkadas
    ]
}
