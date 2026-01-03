import Foundation

// MARK: - Geometric Particle

/// A particle with geometric and physical properties
public struct GeometricParticle: Identifiable, Sendable {
    public let id: UUID
    public var position: SIMD3<Float>
    public var velocity: SIMD3<Float>
    public var acceleration: SIMD3<Float>
    public var mass: Float
    public var color: GeometricColor
    public var shape: GeometricShape
    
    public init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        velocity: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        acceleration: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        mass: Float = 1.0,
        color: GeometricColor = .violet,
        shape: GeometricShape = .circle
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.mass = mass
        self.color = color
        self.shape = shape
    }
}

// MARK: - Particle Engine

/// Particle engine for FIELD visualization
public class ParticleEngine: @unchecked Sendable {
    public var particles: [GeometricParticle]
    private let particleCount: Int
    private var fieldSize: Float
    
    // Physics parameters
    private var damping: Float = 0.98
    private var maxSpeed: Float = 5.0
    
    public init(count: Int, fieldSize: Float = 20.0) {
        self.particleCount = count
        self.fieldSize = fieldSize
        self.particles = []
        
        // Initialize particles
        initializeParticles()
    }
    
    /// Initialize particles with random positions
    private func initializeParticles() {
        particles.removeAll(keepingCapacity: true)
        
        for _ in 0..<particleCount {
            let particle = GeometricParticle(
                position: randomPosition(),
                velocity: SIMD3<Float>(0, 0, 0),
                color: randomColor(),
                shape: randomShape()
            )
            particles.append(particle)
        }
    }
    
    /// Generate random position within field bounds
    private func randomPosition() -> SIMD3<Float> {
        let range = fieldSize / 2.0
        return SIMD3<Float>(
            Float.random(in: -range...range),
            Float.random(in: -range...range),
            Float.random(in: -range...range)
        )
    }
    
    /// Generate random color from sacred colors
    private func randomColor() -> GeometricColor {
        let colors: [GeometricColor] = [.red, .orange, .green, .blue, .indigo, .violet]
        return colors.randomElement() ?? .violet
    }
    
    /// Generate random shape from sacred shapes
    private func randomShape() -> GeometricShape {
        let shapes: [GeometricShape] = [
            .circle, .triangle, .square, .diamond,
            .invertedTriangle, .circleWithCrosshairs
        ]
        return shapes.randomElement() ?? .circle
    }
    
    /// Update particle positions (Euler integration)
    /// - Parameter dt: Time delta in seconds
    public func step(dt: Float) {
        for i in 0..<particles.count {
            // Update velocity: v = v + a * dt
            particles[i].velocity += particles[i].acceleration * dt
            
            // Apply damping
            particles[i].velocity *= damping
            
            // Clamp velocity
            let speed = simdLength(particles[i].velocity)
            if speed > maxSpeed {
                particles[i].velocity = simdNormalize(particles[i].velocity) * maxSpeed
            }
            
            // Update position: p = p + v * dt
            particles[i].position += particles[i].velocity * dt
            
            // Wrap around field boundaries
            particles[i].position = wrapPosition(particles[i].position)
            
            // Reset acceleration
            particles[i].acceleration = SIMD3<Float>(0, 0, 0)
        }
    }
    
    /// Wrap position around field boundaries (toroidal topology)
    private func wrapPosition(_ position: SIMD3<Float>) -> SIMD3<Float> {
        let halfSize = fieldSize / 2.0
        var wrapped = position
        
        // Wrap X
        if wrapped.x > halfSize {
            wrapped.x -= fieldSize
        } else if wrapped.x < -halfSize {
            wrapped.x += fieldSize
        }
        
        // Wrap Y
        if wrapped.y > halfSize {
            wrapped.y -= fieldSize
        } else if wrapped.y < -halfSize {
            wrapped.y += fieldSize
        }
        
        // Wrap Z
        if wrapped.z > halfSize {
            wrapped.z -= fieldSize
        } else if wrapped.z < -halfSize {
            wrapped.z += fieldSize
        }
        
        return wrapped
    }
    
    /// Apply attractor force to all particles
    /// - Parameters:
    ///   - position: Position of the attractor
    ///   - strength: Strength of attraction (positive attracts, negative repels)
    ///   - falloff: Falloff exponent (2.0 = inverse square)
    public func applyAttractor(position: SIMD3<Float>, strength: Float, falloff: Float = 2.0) {
        for i in 0..<particles.count {
            let force = GeometryTransforms.attractorForce(
                particlePosition: particles[i].position,
                attractorPosition: position,
                strength: strength,
                falloff: falloff
            )
            
            // Apply force: F = ma -> a = F/m
            particles[i].acceleration += force / particles[i].mass
        }
    }
    
    /// Apply force from sacred pyramid vertices
    /// - Parameter vertices: Array of OOO vertices to use as attractors
    public func applySacredAttractors(vertices: [OOOEntity], strength: Float = 10.0) {
        for vertex in vertices {
            let position = PyramidGeometry.vertexPosition(for: vertex)
            applyAttractor(position: position, strength: strength, falloff: 2.0)
        }
    }
    
    /// Reset particles to random positions
    public func reset() {
        initializeParticles()
    }
    
    /// Update field size
    public func setFieldSize(_ size: Float) {
        self.fieldSize = size
    }
    
    /// Update damping factor
    public func setDamping(_ value: Float) {
        self.damping = max(0.0, min(1.0, value))
    }
    
    /// Update maximum speed
    public func setMaxSpeed(_ value: Float) {
        self.maxSpeed = max(0.1, value)
    }
}

// MARK: - Particle Engine Extensions

public extension ParticleEngine {
    /// Get particles as array (for rendering)
    var particleArray: [GeometricParticle] {
        particles
    }
    
    /// Get particle count
    var count: Int {
        particles.count
    }
    
    /// Apply turbulence to particles
    func applyTurbulence(strength: Float) {
        for i in 0..<particles.count {
            let noise = SIMD3<Float>(
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -1...1)
            )
            particles[i].acceleration += simdNormalize(noise) * strength
        }
    }
    
    /// Apply vortex force at position
    func applyVortex(center: SIMD3<Float>, strength: Float, axis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)) {
        let normalizedAxis = simdNormalize(axis)
        
        for i in 0..<particles.count {
            let delta = particles[i].position - center
            let distance = simdLength(delta)
            
            if distance > 0.1 {
                // Tangential force (perpendicular to radius)
                let radial = simdNormalize(delta)
                let tangent = simdCross(normalizedAxis, radial)
                
                let forceMagnitude = strength / (distance * distance)
                let force = tangent * forceMagnitude
                
                particles[i].acceleration += force / particles[i].mass
            }
        }
    }
}
