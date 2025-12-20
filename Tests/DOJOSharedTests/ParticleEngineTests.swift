import XCTest
@testable import DOJOShared

/// Tests for ParticleEngine
final class ParticleEngineTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testParticleEngineInitialization() {
        let engine = ParticleEngine(count: 100)
        
        XCTAssertEqual(engine.count, 100)
        XCTAssertEqual(engine.particles.count, 100)
    }
    
    func testParticleInitialProperties() {
        let engine = ParticleEngine(count: 10)
        
        for particle in engine.particles {
            // Each particle should have valid properties
            XCTAssertNotNil(particle.id)
            XCTAssertTrue(particle.position.x.isFinite)
            XCTAssertTrue(particle.position.y.isFinite)
            XCTAssertTrue(particle.position.z.isFinite)
            XCTAssertEqual(particle.velocity, SIMD3<Float>(0, 0, 0))
            XCTAssertEqual(particle.mass, 1.0)
        }
    }
    
    func testParticleInitialPositionsWithinBounds() {
        let fieldSize: Float = 20.0
        let engine = ParticleEngine(count: 100, fieldSize: fieldSize)
        let halfSize = fieldSize / 2.0
        
        for particle in engine.particles {
            // Particles should be within field bounds
            XCTAssertGreaterThanOrEqual(particle.position.x, -halfSize)
            XCTAssertLessThanOrEqual(particle.position.x, halfSize)
            XCTAssertGreaterThanOrEqual(particle.position.y, -halfSize)
            XCTAssertLessThanOrEqual(particle.position.y, halfSize)
            XCTAssertGreaterThanOrEqual(particle.position.z, -halfSize)
            XCTAssertLessThanOrEqual(particle.position.z, halfSize)
        }
    }
    
    // MARK: - Step Tests
    
    func testParticleStepWithNoForce() {
        let engine = ParticleEngine(count: 1)
        let initialPos = engine.particles[0].position
        
        // Step with no forces applied
        engine.step(dt: 0.1)
        
        // Position should not change significantly (damping may cause tiny changes)
        let finalPos = engine.particles[0].position
        let distance = simdLength(finalPos - initialPos)
        XCTAssertLessThan(distance, 0.001)
    }
    
    func testParticleStepWithConstantForce() {
        let engine = ParticleEngine(count: 1)
        
        // Set damping to 1.0 to avoid velocity decay
        engine.setDamping(1.0)
        
        let initialPos = engine.particles[0].position
        
        // Apply constant force
        for _ in 0..<10 {
            engine.particles[0].acceleration = SIMD3<Float>(1, 0, 0)
            engine.step(dt: 0.1)
        }
        
        let finalPos = engine.particles[0].position
        
        // Particle should have moved in positive X direction
        XCTAssertGreaterThan(finalPos.x, initialPos.x)
    }
    
    func testParticleDamping() {
        let engine = ParticleEngine(count: 1)
        
        // Give particle initial velocity
        engine.particles[0].velocity = SIMD3<Float>(10, 0, 0)
        
        // Step multiple times with damping
        for _ in 0..<100 {
            engine.step(dt: 0.1)
        }
        
        // Velocity should have decreased due to damping
        let finalSpeed = simdLength(engine.particles[0].velocity)
        XCTAssertLessThan(finalSpeed, 10.0)
    }
    
    func testParticleMaxSpeed() {
        let engine = ParticleEngine(count: 1)
        let maxSpeed: Float = 5.0
        engine.setMaxSpeed(maxSpeed)
        
        // Apply very large force
        engine.particles[0].acceleration = SIMD3<Float>(1000, 0, 0)
        engine.step(dt: 1.0)
        
        // Velocity should be capped at maxSpeed
        let speed = simdLength(engine.particles[0].velocity)
        XCTAssertLessThanOrEqual(speed, maxSpeed * 1.1)  // Allow small tolerance
    }
    
    func testParticleWrapping() {
        let fieldSize: Float = 20.0
        let engine = ParticleEngine(count: 1, fieldSize: fieldSize)
        let halfSize = fieldSize / 2.0
        
        // Place particle at edge and give it velocity to go out of bounds
        engine.particles[0].position = SIMD3<Float>(halfSize - 1, 0, 0)
        engine.particles[0].velocity = SIMD3<Float>(10, 0, 0)
        
        // Step multiple times
        for _ in 0..<20 {
            engine.step(dt: 0.1)
        }
        
        // Particle should have wrapped around and still be within bounds
        XCTAssertGreaterThanOrEqual(engine.particles[0].position.x, -halfSize)
        XCTAssertLessThanOrEqual(engine.particles[0].position.x, halfSize)
    }
    
    // MARK: - Attractor Tests
    
    func testApplyAttractor() {
        let engine = ParticleEngine(count: 1)
        engine.particles[0].position = SIMD3<Float>(0, 0, 0)
        engine.particles[0].velocity = SIMD3<Float>(0, 0, 0)
        
        let attractorPos = SIMD3<Float>(10, 0, 0)
        
        // Apply attractor and step
        engine.applyAttractor(position: attractorPos, strength: 10.0)
        engine.step(dt: 0.1)
        
        // Particle should have moved towards attractor
        XCTAssertGreaterThan(engine.particles[0].position.x, 0)
    }
    
    func testApplySacredAttractors() {
        let engine = ParticleEngine(count: 10)
        
        // Record initial positions
        let initialPositions = engine.particles.map { $0.position }
        
        // Apply sacred vertex attractors with higher strength
        engine.applySacredAttractors(vertices: OOOEntity.sacredVertices, strength: 50.0)
        
        // Step engine multiple times
        for _ in 0..<50 {
            engine.applySacredAttractors(vertices: OOOEntity.sacredVertices, strength: 50.0)
            engine.step(dt: 0.1)
        }
        
        // Particles should have moved from initial positions
        var moved = false
        for (i, particle) in engine.particles.enumerated() {
            let distance = simdLength(particle.position - initialPositions[i])
            if distance > 0.1 {
                moved = true
                break
            }
        }
        
        XCTAssertTrue(moved, "Particles should move under sacred attractor influence")
    }
    
    // MARK: - Reset Test
    
    func testReset() {
        let engine = ParticleEngine(count: 10)
        
        // Modify particles
        for i in 0..<engine.particles.count {
            engine.particles[i].velocity = SIMD3<Float>(5, 5, 5)
            engine.particles[i].position = SIMD3<Float>(100, 100, 100)
        }
        
        // Reset
        engine.reset()
        
        // Particles should be re-initialized
        XCTAssertEqual(engine.count, 10)
        for particle in engine.particles {
            XCTAssertEqual(particle.velocity, SIMD3<Float>(0, 0, 0))
            XCTAssertNotEqual(particle.position, SIMD3<Float>(100, 100, 100))
        }
    }
    
    // MARK: - Configuration Tests
    
    func testSetFieldSize() {
        let engine = ParticleEngine(count: 10, fieldSize: 20.0)
        
        engine.setFieldSize(40.0)
        engine.reset()
        
        // Particles should now be distributed in larger field
        let halfSize: Float = 20.0
        var hasLargeCoordinate = false
        
        for particle in engine.particles {
            if abs(particle.position.x) > halfSize * 0.7 ||
               abs(particle.position.y) > halfSize * 0.7 ||
               abs(particle.position.z) > halfSize * 0.7 {
                hasLargeCoordinate = true
                break
            }
        }
        
        // At least some particles should use the larger field space
        XCTAssertTrue(hasLargeCoordinate)
    }
    
    func testSetDamping() {
        let engine = ParticleEngine(count: 1)
        
        engine.setDamping(0.5)  // High damping
        engine.particles[0].velocity = SIMD3<Float>(10, 0, 0)
        
        // Step multiple times
        for _ in 0..<10 {
            engine.step(dt: 0.1)
        }
        
        // Velocity should decrease rapidly with high damping
        let speed = simdLength(engine.particles[0].velocity)
        XCTAssertLessThan(speed, 1.0)
    }
    
    // MARK: - Turbulence Test
    
    func testApplyTurbulence() {
        let engine = ParticleEngine(count: 10)
        
        // Set all velocities to zero
        for i in 0..<engine.particles.count {
            engine.particles[i].velocity = SIMD3<Float>(0, 0, 0)
            engine.particles[i].acceleration = SIMD3<Float>(0, 0, 0)
        }
        
        // Apply turbulence
        engine.applyTurbulence(strength: 1.0)
        
        // Particles should have non-zero acceleration
        var hasAcceleration = false
        for particle in engine.particles {
            if simdLength(particle.acceleration) > 0.01 {
                hasAcceleration = true
                break
            }
        }
        
        XCTAssertTrue(hasAcceleration)
    }
    
    // MARK: - Vortex Test
    
    func testApplyVortex() {
        let engine = ParticleEngine(count: 1)
        engine.particles[0].position = SIMD3<Float>(5, 0, 0)
        engine.particles[0].velocity = SIMD3<Float>(0, 0, 0)
        engine.particles[0].acceleration = SIMD3<Float>(0, 0, 0)
        
        let vortexCenter = SIMD3<Float>(0, 0, 0)
        
        // Apply vortex force
        engine.applyVortex(center: vortexCenter, strength: 10.0, axis: SIMD3<Float>(0, 1, 0))
        
        // Particle should have tangential acceleration (perpendicular to radius)
        let acceleration = engine.particles[0].acceleration
        let accelerationMagnitude = simdLength(acceleration)
        
        XCTAssertGreaterThan(accelerationMagnitude, 0)
        
        // For a particle at (5, 0, 0) with vortex at origin and Y axis,
        // acceleration should be primarily in Z direction
        XCTAssertGreaterThan(abs(acceleration.z), abs(acceleration.x))
    }
    
    // MARK: - Geometric Particle Tests
    
    func testGeometricParticleProperties() {
        let particle = GeometricParticle(
            position: SIMD3<Float>(1, 2, 3),
            velocity: SIMD3<Float>(4, 5, 6),
            acceleration: SIMD3<Float>(7, 8, 9),
            mass: 2.0,
            color: .violet,
            shape: .circle
        )
        
        XCTAssertEqual(particle.position, SIMD3<Float>(1, 2, 3))
        XCTAssertEqual(particle.velocity, SIMD3<Float>(4, 5, 6))
        XCTAssertEqual(particle.acceleration, SIMD3<Float>(7, 8, 9))
        XCTAssertEqual(particle.mass, 2.0)
        XCTAssertEqual(particle.color, .violet)
        XCTAssertEqual(particle.shape, .circle)
    }
    
    func testParticleEngineGeometricVariety() {
        let engine = ParticleEngine(count: 100)
        
        // Check that particles have variety in colors and shapes
        let colors = Set(engine.particles.map { $0.color })
        let shapes = Set(engine.particles.map { $0.shape })
        
        // With 100 particles, we should have multiple colors and shapes
        XCTAssertGreaterThan(colors.count, 1)
        XCTAssertGreaterThan(shapes.count, 1)
    }
}
