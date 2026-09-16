import XCTest
@testable import DOJOShared
@testable import DOJOUI

final class GeometrySeparationAndSpinContractTests: XCTestCase {
    func testAiMindIsPresentationOnly() {
        XCTAssertTrue(GeometricCharacter.aiMind.glyph.isEmpty)
        XCTAssertEqual(GeometricCharacter.aiMind.frequencyHz, 0.0)
        XCTAssertNotEqual(GeometricCharacter.aiMind.glyph, "⊗")
    }

    func testDashboardChamberMappingsKeepArkadasAndKingsChamberSeparate() {
        XCTAssertEqual(Chamber.arkadas.oooEntity?.name, "Arkadaş")
        XCTAssertEqual(Chamber.kings.oooEntity?.name, "King's Chamber")
        XCTAssertEqual(Chamber.arkadas.frequency, 717)
        XCTAssertEqual(Chamber.kings.frequency, 852)
    }

    func testAkronVisualShapeAndRouteSymbolRemainSeparate() {
        XCTAssertEqual(OOOEntity.akronGateway.geometric.shape, .diamond)
        XCTAssertEqual(OOOEntity.akronGateway.geometric.shape.rawValue, "◆")
        XCTAssertEqual(OOOEntity.akronGateway.geometric.canonicalRouteSymbol, "◻")
    }

    func testFullS0S11ContractPreservesEveryStage() {
        let contract = FieldS0S11CoverageContract.v0

        XCTAssertEqual(contract.stages.count, 12)
        XCTAssertTrue(contract.hasAllStagesInOrder)
        XCTAssertTrue(contract.hasNoCollapsedStages)
        XCTAssertEqual(contract.stages.first?.rawValue, "S0")
        XCTAssertEqual(contract.stages.last?.rawValue, "S11")
        XCTAssertNotEqual(FieldSpinStage.s5, FieldSpinStage.s9)
        XCTAssertNotEqual(FieldSpinStage.s0, FieldSpinStage.s11)
    }
}
