import Foundation

// MARK: - DEPRECATED: Legacy Sacred Geometry Constants
//
// ⚠️ DEPRECATION NOTICE
// This file contains legacy sacred geometry constants and is DEPRECATED.
// New code should use the OOO framework in Sources/DOJOShared/OOO/
//
// Migration path:
// - Use OOOEntity.sacredVertices instead of these constants
// - Use GeometricProperties for frequency/color/shape definitions
// - Use PortalRegistry for portal classification
//
// This file is maintained for backward compatibility only and will be
// removed in a future version.

@available(*, deprecated, message: "Use OOOEntity.sacredVertices from OOO/GeometricEntity.swift instead")
public struct SacredGeometry {
    
    // MARK: - Sacred Frequencies (Hz)
    
    @available(*, deprecated, message: "Use OOOEntity.akronGateway.geometric.frequency")
    public static let akronFrequency: Float = 396.0  // Root Chakra - Liberation
    
    @available(*, deprecated, message: "Use OOOEntity.tata.geometric.frequency")
    public static let tataFrequency: Float = 432.0   // Sacral Chakra - Natural Tuning
    
    @available(*, deprecated, message: "Use OOOEntity.atlas.geometric.frequency")
    public static let atlasFrequency: Float = 528.0  // Solar Plexus - DNA Repair
    
    @available(*, deprecated, message: "Use OOOEntity.dojo.geometric.frequency")
    public static let dojoFrequency: Float = 741.0   // Throat Chakra - Expression
    
    @available(*, deprecated, message: "Use OOOEntity.kingsChamber.geometric.frequency")
    public static let kingsChamberFrequency: Float = 852.0  // Third Eye - Intuition
    
    @available(*, deprecated, message: "Use OOOEntity.obiWan.geometric.frequency")
    public static let obiWanFrequency: Float = 963.0 // Crown Chakra - Unity
    
    // MARK: - Sacred Positions
    
    @available(*, deprecated, message: "Use OOOEntity.obiWan.geometric.position")
    public static let apexPosition: Float = 1.0      // OBI-WAN apex
    
    @available(*, deprecated, message: "Use OOOEntity.dojo.geometric.position")
    public static let dojoPosition: Float = 0.667    // DOJO manifestation apex
    
    @available(*, deprecated, message: "Use OOOEntity.kingsChamber.geometric.position")
    public static let kingsChamberPosition: Float = 0.333  // King's Chamber balance point
    
    @available(*, deprecated, message: "Use OOOEntity.[vertex].geometric.position")
    public static let basePosition: Float = 0.0      // TATA, ATLAS, Akron Gateway
    
    // MARK: - Sacred Colors (Hex)
    
    @available(*, deprecated, message: "Use GeometricColor enum")
    public static let akronColor = "#FF0000"         // Red
    
    @available(*, deprecated, message: "Use GeometricColor enum")
    public static let tataColor = "#FF8000"          // Orange
    
    @available(*, deprecated, message: "Use GeometricColor enum")
    public static let atlasColor = "#00FF00"         // Green
    
    @available(*, deprecated, message: "Use GeometricColor enum")
    public static let dojoColor = "#0000FF"          // Blue
    
    @available(*, deprecated, message: "Use GeometricColor enum")
    public static let kingsChamberColor = "#4B0082"  // Indigo
    
    @available(*, deprecated, message: "Use GeometricColor enum")
    public static let obiWanColor = "#8B00FF"        // Violet
    
    // MARK: - Sacred Shapes
    
    @available(*, deprecated, message: "Use GeometricShape enum")
    public static let circleShape = "●"              // OBI-WAN
    
    @available(*, deprecated, message: "Use GeometricShape enum")
    public static let triangleShape = "▲"            // TATA
    
    @available(*, deprecated, message: "Use GeometricShape enum")
    public static let squareShape = "◼︎"              // ATLAS
    
    @available(*, deprecated, message: "Use GeometricShape enum")
    public static let diamondShape = "◆"             // DOJO
    
    @available(*, deprecated, message: "Use GeometricShape enum")
    public static let invertedTriangleShape = "▼"    // Akron Gateway
    
    @available(*, deprecated, message: "Use GeometricShape enum")
    public static let circleWithCrosshairsShape = "⊕" // King's Chamber
}

// MARK: - Legacy Helper Functions

@available(*, deprecated, message: "Use OOOEntity static properties instead")
public extension SacredGeometry {
    /// Get all vertex frequencies in ascending order
    static var allFrequencies: [Float] {
        [
            akronFrequency,
            tataFrequency,
            atlasFrequency,
            dojoFrequency,
            kingsChamberFrequency,
            obiWanFrequency
        ]
    }
    
    /// Get vertex name for a given frequency
    static func vertexName(for frequency: Float) -> String? {
        switch frequency {
        case 396.0: return "Akron Gateway"
        case 432.0: return "TATA"
        case 528.0: return "ATLAS"
        case 741.0: return "DOJO"
        case 852.0: return "King's Chamber"
        case 963.0: return "OBI-WAN"
        default: return nil
        }
    }
}
