import XCTest
@testable import DOJOShared

/// Tests for Object-Oriented Ontology (OOO) framework
final class OOOTests: XCTestCase {
    
    // MARK: - Sacred Vertex Tests
    
    func testObiWanVertex() {
        let obiWan = OOOEntity.obiWan
        
        // Test geometric properties
        XCTAssertEqual(obiWan.name, "OBI-WAN")
        XCTAssertEqual(obiWan.geometric.shape, .circle)
        XCTAssertEqual(obiWan.geometric.color, .violet)
        XCTAssertEqual(obiWan.geometric.frequency, 963.0)
        XCTAssertEqual(obiWan.geometric.position, 1.0)  // Apex
        
        // Test semantic properties
        XCTAssertEqual(obiWan.semantic.domain, .temporal)
        
        // Test temporal properties
        XCTAssertEqual(obiWan.temporal.cadence, 963.0)
        XCTAssertEqual(obiWan.temporal.lifecyclePhase, .eternal)
        XCTAssertTrue(obiWan.temporal.observerCalibrated)
    }
    
    func testTataVertex() {
        let tata = OOOEntity.tata
        
        XCTAssertEqual(tata.name, "TATA")
        XCTAssertEqual(tata.geometric.shape, .triangle)
        XCTAssertEqual(tata.geometric.color, .orange)
        XCTAssertEqual(tata.geometric.frequency, 432.0)
        XCTAssertEqual(tata.geometric.position, 0.0)  // Base
        XCTAssertEqual(tata.semantic.domain, .legal)
        XCTAssertTrue(tata.temporal.observerCalibrated)
    }
    
    func testAtlasVertex() {
        let atlas = OOOEntity.atlas
        
        XCTAssertEqual(atlas.name, "ATLAS")
        XCTAssertEqual(atlas.geometric.shape, .square)
        XCTAssertEqual(atlas.geometric.color, .green)
        XCTAssertEqual(atlas.geometric.frequency, 528.0)
        XCTAssertEqual(atlas.geometric.position, 0.0)  // Base
        XCTAssertEqual(atlas.semantic.domain, .geometric)
        XCTAssertTrue(atlas.temporal.observerCalibrated)
    }
    
    func testDojoVertex() {
        let dojo = OOOEntity.dojo
        
        XCTAssertEqual(dojo.name, "DOJO")
        XCTAssertEqual(dojo.geometric.shape, .diamond)
        XCTAssertEqual(dojo.geometric.color, .blue)
        XCTAssertEqual(dojo.geometric.frequency, 741.0)
        XCTAssertEqual(dojo.geometric.position, 0.667, accuracy: 0.001)  // Manifestation apex
        XCTAssertEqual(dojo.semantic.domain, .translation)
        XCTAssertTrue(dojo.temporal.observerCalibrated)
    }
    
    func testAkronGatewayVertex() {
        let akron = OOOEntity.akronGateway
        
        XCTAssertEqual(akron.name, "Akron Gateway")
        XCTAssertEqual(akron.geometric.shape, .invertedTriangle)
        XCTAssertEqual(akron.geometric.color, .red)
        XCTAssertEqual(akron.geometric.frequency, 396.0)
        XCTAssertEqual(akron.geometric.position, 0.0)  // Foundation
        XCTAssertEqual(akron.semantic.domain, .archive)
        XCTAssertTrue(akron.temporal.observerCalibrated)
    }
    
    func testKingsChamberVertex() {
        let kingsChamber = OOOEntity.kingsChamber
        
        XCTAssertEqual(kingsChamber.name, "King's Chamber")
        XCTAssertEqual(kingsChamber.geometric.shape, .circleWithCrosshairs)
        XCTAssertEqual(kingsChamber.geometric.color, .indigo)
        XCTAssertEqual(kingsChamber.geometric.frequency, 852.0)
        XCTAssertEqual(kingsChamber.geometric.position, 0.333, accuracy: 0.001)  // 33.3% - Balance point
        XCTAssertEqual(kingsChamber.semantic.domain, .translation)
        XCTAssertTrue(kingsChamber.temporal.observerCalibrated)
    }
    
    // MARK: - Sacred Vertices Array Test
    
    func testSacredVerticesArray() {
        let vertices = OOOEntity.sacredVertices
        
        // Verify count
        XCTAssertEqual(vertices.count, 6)
        
        // Verify all vertices are present
        let names = vertices.map { $0.name }
        XCTAssertTrue(names.contains("OBI-WAN"))
        XCTAssertTrue(names.contains("TATA"))
        XCTAssertTrue(names.contains("ATLAS"))
        XCTAssertTrue(names.contains("DOJO"))
        XCTAssertTrue(names.contains("Akron Gateway"))
        XCTAssertTrue(names.contains("King's Chamber"))
        
        // Verify all are observer calibrated
        XCTAssertTrue(vertices.allSatisfy { $0.temporal.observerCalibrated })
        
        // Verify all are eternal
        XCTAssertTrue(vertices.allSatisfy { $0.temporal.lifecyclePhase == .eternal })
    }
    
    // MARK: - Frequency Ordering Test
    
    func testFrequencyOrdering() {
        let vertices = OOOEntity.sacredVertices
        let frequencies = vertices.map { $0.geometric.frequency }.sorted()
        
        // Verify solfeggio frequency ordering
        XCTAssertEqual(frequencies[0], 396.0)  // Akron Gateway
        XCTAssertEqual(frequencies[1], 432.0)  // TATA
        XCTAssertEqual(frequencies[2], 528.0)  // ATLAS
        XCTAssertEqual(frequencies[3], 741.0)  // DOJO
        XCTAssertEqual(frequencies[4], 852.0)  // King's Chamber
        XCTAssertEqual(frequencies[5], 963.0)  // OBI-WAN
    }
    
    // MARK: - Position Hierarchy Test
    
    func testPositionHierarchy() {
        // Test vertical hierarchy in Sacred Pyramid
        XCTAssertEqual(OOOEntity.obiWan.geometric.position, 1.0)  // Apex
        XCTAssertGreaterThan(OOOEntity.dojo.geometric.position, OOOEntity.kingsChamber.geometric.position)
        XCTAssertGreaterThan(OOOEntity.kingsChamber.geometric.position, OOOEntity.tata.geometric.position)
        
        // Test base vertices are at foundation
        XCTAssertEqual(OOOEntity.tata.geometric.position, 0.0)
        XCTAssertEqual(OOOEntity.atlas.geometric.position, 0.0)
        XCTAssertEqual(OOOEntity.akronGateway.geometric.position, 0.0)
    }
    
    // MARK: - Portal Tests
    
    func testDojoSuitePortal() {
        let portal = Portal.dojoSuite
        
        XCTAssertEqual(portal.repositoryName, "nexus-infinity/DOJO-suite")
        XCTAssertTrue(portal.vertexAnchor.contains("DOJO"))
        XCTAssertTrue(portal.vertexAnchor.contains("King's Chamber"))
        XCTAssertEqual(portal.platform, "iOS/macOS (SwiftPM)")
        XCTAssertEqual(portal.oooProperties.temporal.lifecyclePhase, .active)
        XCTAssertTrue(portal.oooProperties.temporal.observerCalibrated)
    }
    
    func testBerjakFREPortal() {
        let portal = Portal.berjakFRE
        
        XCTAssertEqual(portal.repositoryName, "nexus-infinity/berjak-fre-dojo")
        XCTAssertTrue(portal.vertexAnchor.contains("ATLAS"))
        XCTAssertTrue(portal.vertexAnchor.contains("TATA"))
        XCTAssertEqual(portal.platform, "Web (React)")
        XCTAssertEqual(portal.oooProperties.temporal.lifecyclePhase, .active)
    }
    
    func testSomalinkPortalUnderReview() {
        let portal = Portal.somalink
        
        XCTAssertEqual(portal.repositoryName, "nexus-infinity/somalink")
        XCTAssertTrue(portal.vertexAnchor.contains("Under Review"))
        XCTAssertEqual(portal.oooProperties.temporal.lifecyclePhase, .proposal)
        XCTAssertFalse(portal.oooProperties.temporal.observerCalibrated)
    }
    
    func testActivePortals() {
        let activePortals = Portal.activePortals
        
        // Only DOJO-suite and berjak-fre should be active
        XCTAssertEqual(activePortals.count, 2)
        
        let activeNames = activePortals.map { $0.repositoryName }
        XCTAssertTrue(activeNames.contains("nexus-infinity/DOJO-suite"))
        XCTAssertTrue(activeNames.contains("nexus-infinity/berjak-fre-dojo"))
        XCTAssertFalse(activeNames.contains("nexus-infinity/somalink"))
    }
    
    // MARK: - Portal Validation Tests
    
    func testValidPortalValidation() {
        let portal = Portal.dojoSuite
        let result = PortalValidator.validate(portal)
        
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.issues.isEmpty)
    }
    
    func testInvalidPortalValidation() {
        let portal = Portal.somalink
        let result = PortalValidator.validate(portal)
        
        XCTAssertFalse(result.isValid)
        XCTAssertFalse(result.issues.isEmpty)
        
        // Should have issues with frequency, vertex anchors, and observer calibration
        let issuesText = result.issues.joined(separator: " ")
        XCTAssertTrue(issuesText.contains("frequency") || issuesText.contains("vertex"))
    }
    
    // MARK: - Non-Portal Tests
    
    func testNonPortalClassifications() {
        let nonPortals = NonPortal.nonPortals
        
        XCTAssertEqual(nonPortals.count, 5)
        
        let names = nonPortals.map { $0.repositoryName }
        XCTAssertTrue(names.contains("Field-MacOS-DOJO-0i"))
        XCTAssertTrue(names.contains("DOJO-Python"))
        XCTAssertTrue(names.contains("King's Chamber"))
        XCTAssertTrue(names.contains("TATA"))
        XCTAssertTrue(names.contains("ATLAS"))
    }
    
    // MARK: - Codable Tests
    
    func testOOOEntityCodable() throws {
        let entity = OOOEntity.kingsChamber
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(entity)
        
        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OOOEntity.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.name, entity.name)
        XCTAssertEqual(decoded.geometric.frequency, entity.geometric.frequency)
        XCTAssertEqual(decoded.geometric.position, entity.geometric.position)
        XCTAssertEqual(decoded.temporal.lifecyclePhase, entity.temporal.lifecyclePhase)
    }
    
    func testPortalCodable() throws {
        let portal = Portal.dojoSuite
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(portal)
        
        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Portal.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.repositoryName, portal.repositoryName)
        XCTAssertEqual(decoded.platform, portal.platform)
        XCTAssertEqual(decoded.oooProperties.name, portal.oooProperties.name)
    }
}
