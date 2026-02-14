import Foundation

// MARK: - Camera

/// Camera parameters for orthographic projection
public struct Camera: Sendable {
    public var position: SIMD3<Float>
    public var target: SIMD3<Float>
    public var up: SIMD3<Float>
    public var fieldSize: Float  // Size of the field in world units
    
    public init(
        position: SIMD3<Float> = SIMD3<Float>(0, 0, 10),
        target: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        up: SIMD3<Float> = SIMD3<Float>(0, 1, 0),
        fieldSize: Float = 20.0
    ) {
        self.position = position
        self.target = target
        self.up = up
        self.fieldSize = fieldSize
    }
}

// MARK: - Geometry Transforms

/// Geometry transformation utilities for FIELD visualization
public struct GeometryTransforms {
    
    /// Convert field coordinates to screen coordinates (orthographic projection)
    /// - Parameters:
    ///   - fieldPosition: Position in field space (3D)
    ///   - camera: Camera parameters
    ///   - screenSize: Size of the screen/canvas in pixels
    /// - Returns: Screen position (2D) in pixels
    public static func fieldToScreen(
        fieldPosition: SIMD3<Float>,
        camera: Camera,
        screenSize: CGSize
    ) -> CGPoint {
        // Simple orthographic projection
        let viewDir = simdNormalize(camera.target - camera.position)
        let right = simdNormalize(simdCross(viewDir, camera.up))
        let up = simdCross(right, viewDir)
        
        // Transform to camera space
        let relativePos = fieldPosition - camera.target
        let x = simdDot(relativePos, right)
        let y = simdDot(relativePos, up)
        
        // Map to screen space [-fieldSize/2, fieldSize/2] -> [0, screenSize]
        let normalizedX = (x / camera.fieldSize + 0.5)
        let normalizedY = (y / camera.fieldSize + 0.5)
        
        return CGPoint(
            x: Double(normalizedX) * screenSize.width,
            y: Double(normalizedY) * screenSize.height
        )
    }
    
    /// Convert screen coordinates to field coordinates
    /// - Parameters:
    ///   - screenPosition: Position on screen in pixels
    ///   - camera: Camera parameters
    ///   - screenSize: Size of the screen/canvas in pixels
    /// - Returns: Field position (3D) - assumes z = 0 plane
    public static func screenToField(
        screenPosition: CGPoint,
        camera: Camera,
        screenSize: CGSize
    ) -> SIMD3<Float> {
        // Normalize screen coordinates to [0, 1]
        let normalizedX = Float(screenPosition.x / screenSize.width)
        let normalizedY = Float(screenPosition.y / screenSize.height)
        
        // Map to field space [-fieldSize/2, fieldSize/2]
        let fieldX = (normalizedX - 0.5) * camera.fieldSize
        let fieldY = (normalizedY - 0.5) * camera.fieldSize
        
        let viewDir = simdNormalize(camera.target - camera.position)
        let right = simdNormalize(simdCross(viewDir, camera.up))
        let up = simdCross(right, viewDir)
        
        // Project onto field plane (z = 0 in camera target space)
        let position = camera.target + right * fieldX + up * fieldY
        
        return position
    }
    
    /// Calculate attractor force from a point source
    /// - Parameters:
    ///   - particlePosition: Position of the particle
    ///   - attractorPosition: Position of the attractor
    ///   - strength: Strength of the attraction (positive attracts, negative repels)
    ///   - falloff: Falloff exponent (2.0 = inverse square, 1.0 = linear)
    /// - Returns: Force vector to apply to particle
    public static func attractorForce(
        particlePosition: SIMD3<Float>,
        attractorPosition: SIMD3<Float>,
        strength: Float,
        falloff: Float = 2.0
    ) -> SIMD3<Float> {
        let delta = attractorPosition - particlePosition
        let distanceSquared = simdDot(delta, delta)
        
        // Safe handling of zero distance
        // Use a minimum distance threshold to prevent division by zero
        let minDistanceSquared: Float = 0.01
        let safeDistanceSquared = max(distanceSquared, minDistanceSquared)
        
        // Calculate distance for falloff
        let distance = sqrt(safeDistanceSquared)
        
        // Normalize direction
        let direction = delta / distance
        
        // Apply falloff: force = strength / distance^falloff
        let forceMagnitude = strength / pow(distance, falloff)
        
        // Cap maximum force to prevent instability
        let maxForce: Float = 100.0
        let cappedForceMagnitude = min(forceMagnitude, maxForce)
        
        return direction * cappedForceMagnitude
    }
    
    /// Calculate force from multiple attractors
    /// - Parameters:
    ///   - particlePosition: Position of the particle
    ///   - attractors: Array of (position, strength) tuples
    ///   - falloff: Falloff exponent
    /// - Returns: Combined force vector
    public static func multiAttractorForce(
        particlePosition: SIMD3<Float>,
        attractors: [(position: SIMD3<Float>, strength: Float)],
        falloff: Float = 2.0
    ) -> SIMD3<Float> {
        var totalForce = SIMD3<Float>(0, 0, 0)
        
        for attractor in attractors {
            let force = attractorForce(
                particlePosition: particlePosition,
                attractorPosition: attractor.position,
                strength: attractor.strength,
                falloff: falloff
            )
            totalForce += force
        }
        
        return totalForce
    }
}

// MARK: - Pyramid Geometry

/// Sacred Pyramid geometry calculations
public struct PyramidGeometry {
    /// Calculate the 3D position of a vertex in the Sacred Pyramid
    /// - Parameter vertex: OOO entity representing the vertex
    /// - Returns: 3D position in pyramid space
    public static func vertexPosition(for vertex: OOOEntity) -> SIMD3<Float> {
        let position = vertex.geometric.position
        
        // Map position to pyramid geometry
        // Base vertices (position = 0.0) are arranged in a triangle/square at y = 0
        // Apex (position = 1.0) is at y = 1.0
        // DOJO at 0.667 is at y = 0.667
        // King's Chamber at 0.333 is at y = 0.333
        
        switch vertex.name {
        case "OBI-WAN":
            // Apex at top center
            return SIMD3<Float>(0, position, 0)
            
        case "TATA":
            // Base triangle corner 1
            return SIMD3<Float>(-1, position, -1)
            
        case "ATLAS":
            // Base square corner 2
            return SIMD3<Float>(1, position, -1)
            
        case "Akron Gateway":
            // Foundation center (inverted triangle)
            return SIMD3<Float>(0, position, 1)
            
        case "DOJO":
            // Manifestation apex at 66.7%
            return SIMD3<Float>(0, position, 0)
            
        case "King's Chamber":
            // Balance point at 33.3% (internal to DOJO)
            return SIMD3<Float>(0, position, 0)
            
        default:
            // Default to position-based placement
            return SIMD3<Float>(0, position, 0)
        }
    }
}
