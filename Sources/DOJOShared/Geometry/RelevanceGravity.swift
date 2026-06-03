import CoreGraphics
import Foundation

// MARK: - Relevance Gravity

/// Spatial positioning for murmors relative to the Observer node.
///
/// Formula (from Geometric Observer-Oriented Ontology):
///   orbitRadius = activeRadius + (1 − activity) × (idleRadius − activeRadius)
///
/// Activity 1.0 → orbit at activeRadius (150 units)  — fully engaged murmor
/// Activity 0.0 → orbit at idleRadius  (450 units)  — offline / drifted murmor
///
/// The `scale` parameter maps logical units to screen coordinates.
/// Example: for a 200pt canvas, use scale = 200.0 / idleRadius.
public enum RelevanceGravity {

    public static let activeRadius: Double = 150
    public static let idleRadius:   Double = 450

    // MARK: - Core formula

    /// Logical orbit radius for the given activity level (0.0–1.0).
    public static func orbitRadius(activity: Double) -> Double {
        let a = min(max(activity, 0), 1)
        return activeRadius + (1 - a) * (idleRadius - activeRadius)
    }

    // MARK: - Single position

    /// 2D position relative to Observer center (origin) for one murmor.
    /// - Parameters:
    ///   - activity: 0.0 (idle, periphery) → 1.0 (active, close)
    ///   - angleDegrees: 0 = right, -90 = top, 90 = bottom
    ///   - scale: multiplier mapping logical units to view coordinates
    public static func position(
        activity: Double,
        angleDegrees: Double,
        scale: Double = 1.0
    ) -> CGPoint {
        let r = orbitRadius(activity: activity) * scale
        let rad = angleDegrees * .pi / 180
        return CGPoint(x: r * cos(rad), y: r * sin(rad))
    }

    // MARK: - Registry layout

    /// Distribute a murmor registry around the Observer, evenly spaced by angle.
    /// Most active murmors start at the top (-90°) and go clockwise.
    ///
    /// - Parameters:
    ///   - identities: the registered murmors
    ///   - scale: maps logical units to view coordinates
    /// - Returns: (identity, CGPoint) pairs sorted activity-descending
    public static func layout(
        for identities: [MurmorIdentity],
        scale: Double = 1.0
    ) -> [(identity: MurmorIdentity, point: CGPoint)] {
        guard !identities.isEmpty else { return [] }
        let sorted = identities.sorted { $0.activityLevel > $1.activityLevel }
        let step = 360.0 / Double(sorted.count)
        return sorted.enumerated().map { i, identity in
            let angle = Double(i) * step - 90   // top-first, clockwise
            let pt = position(activity: identity.activityLevel, angleDegrees: angle, scale: scale)
            return (identity, pt)
        }
    }

    // MARK: - Normalized layout (0–1 space)

    /// Same as `layout(for:scale:)` but coordinates are in 0–1 normalised space
    /// centred on (0.5, 0.5). Multiply by view size to get screen points.
    public static func normalizedLayout(
        for identities: [MurmorIdentity]
    ) -> [(identity: MurmorIdentity, point: CGPoint)] {
        let scale = 0.5 / idleRadius   // maps idleRadius → 0.5 (edge of unit square)
        return layout(for: identities, scale: scale).map { identity, pt in
            (identity, CGPoint(x: pt.x + 0.5, y: pt.y + 0.5))
        }
    }
}
