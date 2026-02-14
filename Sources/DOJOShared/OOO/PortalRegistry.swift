import Foundation

// MARK: - Portal Definition

/// A portal is a working repository that embodies OOO principles
/// and connects to the FIELD geometry
public struct Portal: Codable, Identifiable, Sendable {
    public let id: UUID
    public let repositoryName: String
    public let vertexAnchor: [String]       // Names of OOO vertices this portal anchors to
    public let platform: String
    public let oooProperties: OOOEntity
    
    public init(
        id: UUID = UUID(),
        repositoryName: String,
        vertexAnchor: [String],
        platform: String,
        oooProperties: OOOEntity
    ) {
        self.id = id
        self.repositoryName = repositoryName
        self.vertexAnchor = vertexAnchor
        self.platform = platform
        self.oooProperties = oooProperties
    }
}

// MARK: - Registered Portals

public extension Portal {
    /// DOJO-suite: Swift Package (iOS/macOS)
    /// Primary orchestration portal for particle visualization and OOO framework
    static let dojoSuite = Portal(
        repositoryName: "nexus-infinity/DOJO-suite",
        vertexAnchor: ["DOJO", "King's Chamber"],
        platform: "iOS/macOS (SwiftPM)",
        oooProperties: OOOEntity(
            name: "DOJO-suite Portal",
            geometric: GeometricProperties(
                shape: .diamond,
                color: .blue,
                frequency: 741.0,
                position: 0.667
            ),
            semantic: SemanticProperties(
                domain: .translation,
                culturalTradition: "Swift/SwiftUI, Apple Ecosystem",
                intent: "Primary orchestration portal, particle visualization, OOO framework implementation"
            ),
            temporal: TemporalProperties(
                cadence: 741.0,
                lifecyclePhase: .active,
                observerCalibrated: true
            )
        )
    )
    
    /// berjak-fre-dojo: Web Portal (React)
    /// ATLAS + TATA anchored portal for web-based access
    static let berjakFRE = Portal(
        repositoryName: "nexus-infinity/berjak-fre-dojo",
        vertexAnchor: ["ATLAS", "TATA"],
        platform: "Web (React)",
        oooProperties: OOOEntity(
            name: "Berjak FRE Portal",
            geometric: GeometricProperties(
                shape: .square,
                color: .green,
                frequency: 528.0,
                position: 0.0
            ),
            semantic: SemanticProperties(
                domain: .geometric,
                culturalTradition: "Web/JavaScript, Open Access",
                intent: "Web portal for FIELD access, legal record presentation, AI interface"
            ),
            temporal: TemporalProperties(
                cadence: 528.0,
                lifecyclePhase: .active,
                observerCalibrated: true
            )
        )
    )
    
    /// somalink: Under Review
    /// Pending OOO classification
    static let somalink = Portal(
        repositoryName: "nexus-infinity/somalink",
        vertexAnchor: ["Under Review"],
        platform: "TBD",
        oooProperties: OOOEntity(
            name: "Somalink Portal",
            geometric: GeometricProperties(
                shape: .circle,
                color: .violet,
                frequency: 0.0,  // TBD
                position: 0.0    // TBD
            ),
            semantic: SemanticProperties(
                domain: .translation,
                culturalTradition: "Pending classification",
                intent: "Under review - OOO properties to be determined"
            ),
            temporal: TemporalProperties(
                cadence: nil,
                lifecyclePhase: .proposal,
                observerCalibrated: false
            )
        )
    )
    
    /// All registered portals
    static let registeredPortals: [Portal] = [
        dojoSuite,
        berjakFRE,
        somalink
    ]
    
    /// Active portals (excluding those under review)
    static var activePortals: [Portal] {
        registeredPortals.filter { $0.oooProperties.temporal.lifecyclePhase == .active }
    }
}

// MARK: - Non-Portal Classifications

/// Repositories that are NOT portals (tools, archives, or components)
public struct NonPortal: Codable, Identifiable, Sendable {
    public let id: UUID
    public let repositoryName: String
    public let classification: String
    public let reason: String
    
    public init(
        id: UUID = UUID(),
        repositoryName: String,
        classification: String,
        reason: String
    ) {
        self.id = id
        self.repositoryName = repositoryName
        self.classification = classification
        self.reason = reason
    }
}

public extension NonPortal {
    /// Field-MacOS-DOJO-0i: Archive candidate
    static let fieldMacOSDojo = NonPortal(
        repositoryName: "Field-MacOS-DOJO-0i",
        classification: "Archive Candidate",
        reason: "Legacy macOS implementation, superseded by DOJO-suite"
    )
    
    /// DOJO Python: Tool/Component
    static let dojoPython = NonPortal(
        repositoryName: "DOJO-Python",
        classification: "Tool/Component",
        reason: "Python utilities, not a full portal - no geometric embodiment"
    )
    
    /// King's Chamber: Internal Component
    static let kingsChamberRepo = NonPortal(
        repositoryName: "King's Chamber",
        classification: "Internal Component",
        reason: "Translation engine component, internal to DOJO - not standalone portal"
    )
    
    /// TATA: Separate Service (Under Review)
    static let tataService = NonPortal(
        repositoryName: "TATA",
        classification: "Service (Under Review)",
        reason: "Legal record service, may become separate repo/service"
    )
    
    /// ATLAS: Separate Service (Under Review)
    static let atlasService = NonPortal(
        repositoryName: "ATLAS",
        classification: "Service (Under Review)",
        reason: "AI access service, may become separate repo/service"
    )
    
    /// All non-portals
    static let nonPortals: [NonPortal] = [
        fieldMacOSDojo,
        dojoPython,
        kingsChamberRepo,
        tataService,
        atlasService
    ]
}

// MARK: - Portal Validation

/// Validates portal against OOO framework requirements
public struct PortalValidator {
    /// Checks if a portal meets the three-layer OOO requirements
    public static func validate(_ portal: Portal) -> PortalValidationResult {
        var issues: [String] = []
        
        // Geometric validation
        if portal.oooProperties.geometric.frequency <= 0 {
            issues.append("Invalid frequency: must be > 0")
        }
        
        if portal.oooProperties.geometric.position < 0 || portal.oooProperties.geometric.position > 1 {
            issues.append("Invalid position: must be between 0.0 and 1.0")
        }
        
        // Semantic validation
        if portal.oooProperties.semantic.intent.isEmpty {
            issues.append("Missing intent in semantic layer")
        }
        
        // Temporal validation
        if portal.oooProperties.temporal.lifecyclePhase == .proposal && portal.oooProperties.temporal.observerCalibrated {
            issues.append("Proposal phase entities should not be observer-calibrated")
        }
        
        // Vertex anchor validation
        if portal.vertexAnchor.isEmpty || portal.vertexAnchor.contains("Under Review") {
            issues.append("Portal must have valid vertex anchors")
        }
        
        return PortalValidationResult(
            isValid: issues.isEmpty,
            portal: portal,
            issues: issues
        )
    }
}

/// Result of portal validation
public struct PortalValidationResult: Sendable {
    public let isValid: Bool
    public let portal: Portal
    public let issues: [String]
    
    public init(isValid: Bool, portal: Portal, issues: [String]) {
        self.isValid = isValid
        self.portal = portal
        self.issues = issues
    }
}
