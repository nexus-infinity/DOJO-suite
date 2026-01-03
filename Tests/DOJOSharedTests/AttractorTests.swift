import XCTest
@testable import DOJOShared

/// Tests for attractor force calculations
final class AttractorTests: XCTestCase {
    
    // MARK: - Basic Attractor Force Tests
    
    func testAttractorForceDirection() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractorPos = SIMD3<Float>(10, 0, 0)
        
        let force = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: attractorPos,
            strength: 10.0,
            falloff: 2.0
        )
        
        // Force should point towards attractor (positive X direction)
        XCTAssertGreaterThan(force.x, 0)
        XCTAssertEqual(force.y, 0, accuracy: 0.001)
        XCTAssertEqual(force.z, 0, accuracy: 0.001)
    }
    
    func testAttractorForceRepulsion() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractorPos = SIMD3<Float>(10, 0, 0)
        
        // Negative strength should repel
        let force = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: attractorPos,
            strength: -10.0,
            falloff: 2.0
        )
        
        // Force should point away from attractor (negative X direction)
        XCTAssertLessThan(force.x, 0)
    }
    
    func testAttractorForceZeroDistance() {
        let particlePos = SIMD3<Float>(5, 5, 5)
        let attractorPos = SIMD3<Float>(5, 5, 5)
        
        // Zero distance should not cause division by zero
        let force = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: attractorPos,
            strength: 10.0,
            falloff: 2.0
        )
        
        // Force should be finite (not NaN or infinite)
        XCTAssertTrue(force.x.isFinite)
        XCTAssertTrue(force.y.isFinite)
        XCTAssertTrue(force.z.isFinite)
        
        // Force should be small due to minimum distance threshold
        let forceMagnitude = simdLength(force)
        XCTAssertLessThan(forceMagnitude, 1000.0)
    }
    
    func testAttractorForceMagnitude() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractorPos = SIMD3<Float>(1, 0, 0)  // Distance = 1
        
        let force = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: attractorPos,
            strength: 10.0,
            falloff: 2.0
        )
        
        // With distance = 1, falloff = 2, force magnitude should be ~10
        let forceMagnitude = simdLength(force)
        XCTAssertEqual(forceMagnitude, 10.0, accuracy: 0.1)
    }
    
    func testAttractorForceFalloff() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        
        // Test at distance 1
        let force1 = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: SIMD3<Float>(1, 0, 0),
            strength: 10.0,
            falloff: 2.0
        )
        
        // Test at distance 2
        let force2 = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: SIMD3<Float>(2, 0, 0),
            strength: 10.0,
            falloff: 2.0
        )
        
        // With inverse square falloff, force at distance 2 should be 1/4 of force at distance 1
        let magnitude1 = simdLength(force1)
        let magnitude2 = simdLength(force2)
        
        XCTAssertEqual(magnitude2, magnitude1 / 4.0, accuracy: 0.1)
    }
    
    func testAttractorForceLinearFalloff() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        
        // Test at distance 1
        let force1 = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: SIMD3<Float>(1, 0, 0),
            strength: 10.0,
            falloff: 1.0  // Linear falloff
        )
        
        // Test at distance 2
        let force2 = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: SIMD3<Float>(2, 0, 0),
            strength: 10.0,
            falloff: 1.0  // Linear falloff
        )
        
        // With linear falloff, force at distance 2 should be 1/2 of force at distance 1
        let magnitude1 = simdLength(force1)
        let magnitude2 = simdLength(force2)
        
        XCTAssertEqual(magnitude2, magnitude1 / 2.0, accuracy: 0.1)
    }
    
    func testAttractorForceMaxCapping() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractorPos = SIMD3<Float>(0.001, 0, 0)  // Very close
        
        // Very close distance with high strength should be capped
        let force = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: attractorPos,
            strength: 1000.0,
            falloff: 2.0
        )
        
        let forceMagnitude = simdLength(force)
        
        // Force should be capped at maxForce (100.0 in implementation)
        XCTAssertLessThanOrEqual(forceMagnitude, 100.0)
    }
    
    // MARK: - Multi-Attractor Tests
    
    func testMultiAttractorForce() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractors: [(position: SIMD3<Float>, strength: Float)] = [
            (SIMD3<Float>(10, 0, 0), 10.0),
            (SIMD3<Float>(-10, 0, 0), 10.0)
        ]
        
        let force = GeometryTransforms.multiAttractorForce(
            particlePosition: particlePos,
            attractors: attractors,
            falloff: 2.0
        )
        
        // Equal attractors on opposite sides should cancel out
        XCTAssertEqual(force.x, 0, accuracy: 0.01)
        XCTAssertEqual(force.y, 0, accuracy: 0.01)
        XCTAssertEqual(force.z, 0, accuracy: 0.01)
    }
    
    func testMultiAttractorForceAsymmetric() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractors: [(position: SIMD3<Float>, strength: Float)] = [
            (SIMD3<Float>(10, 0, 0), 10.0),
            (SIMD3<Float>(0, 10, 0), 10.0)
        ]
        
        let force = GeometryTransforms.multiAttractorForce(
            particlePosition: particlePos,
            attractors: attractors,
            falloff: 2.0
        )
        
        // Force should point diagonally (towards both attractors)
        XCTAssertGreaterThan(force.x, 0)
        XCTAssertGreaterThan(force.y, 0)
        
        // X and Y components should be approximately equal
        XCTAssertEqual(force.x, force.y, accuracy: 0.01)
    }
    
    func testMultiAttractorEmpty() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractors: [(position: SIMD3<Float>, strength: Float)] = []
        
        let force = GeometryTransforms.multiAttractorForce(
            particlePosition: particlePos,
            attractors: attractors,
            falloff: 2.0
        )
        
        // No attractors should result in zero force
        XCTAssertEqual(force.x, 0)
        XCTAssertEqual(force.y, 0)
        XCTAssertEqual(force.z, 0)
    }
    
    // MARK: - 3D Tests
    
    func testAttractorForce3D() {
        let particlePos = SIMD3<Float>(0, 0, 0)
        let attractorPos = SIMD3<Float>(1, 1, 1)
        
        let force = GeometryTransforms.attractorForce(
            particlePosition: particlePos,
            attractorPosition: attractorPos,
            strength: 10.0,
            falloff: 2.0
        )
        
        // Force should point towards attractor in 3D
        XCTAssertGreaterThan(force.x, 0)
        XCTAssertGreaterThan(force.y, 0)
        XCTAssertGreaterThan(force.z, 0)
        
        // All components should be approximately equal (diagonal)
        XCTAssertEqual(force.x, force.y, accuracy: 0.001)
        XCTAssertEqual(force.y, force.z, accuracy: 0.001)
    }
    
    // MARK: - Sacred Pyramid Vertex Position Tests
    
    func testPyramidVertexPositions() {
        // Test that vertex positions are computed correctly
        let obiWanPos = PyramidGeometry.vertexPosition(for: OOOEntity.obiWan)
        let dojoPos = PyramidGeometry.vertexPosition(for: OOOEntity.dojo)
        let kingsChamberPos = PyramidGeometry.vertexPosition(for: OOOEntity.kingsChamber)
        
        // OBI-WAN at apex (y = 1.0)
        XCTAssertEqual(obiWanPos.y, 1.0)
        
        // DOJO at manifestation apex (y = 0.667)
        XCTAssertEqual(dojoPos.y, 0.667, accuracy: 0.001)
        
        // King's Chamber at balance point (y = 0.333)
        XCTAssertEqual(kingsChamberPos.y, 0.333, accuracy: 0.001)
        
        // Verify vertical ordering
        XCTAssertGreaterThan(obiWanPos.y, dojoPos.y)
        XCTAssertGreaterThan(dojoPos.y, kingsChamberPos.y)
    }
    
    func testPyramidBaseVertices() {
        let tataPos = PyramidGeometry.vertexPosition(for: OOOEntity.tata)
        let atlasPos = PyramidGeometry.vertexPosition(for: OOOEntity.atlas)
        let akronPos = PyramidGeometry.vertexPosition(for: OOOEntity.akronGateway)
        
        // All base vertices should be at y = 0
        XCTAssertEqual(tataPos.y, 0.0)
        XCTAssertEqual(atlasPos.y, 0.0)
        XCTAssertEqual(akronPos.y, 0.0)
    }
}
