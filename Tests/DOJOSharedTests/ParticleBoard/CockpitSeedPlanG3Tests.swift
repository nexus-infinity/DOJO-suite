import XCTest
@testable import DOJOShared

/// Cockpit G3 — CockpitVeneer3×3 first-launch plan content must not be empty.
/// Naming lock: not ParticleBoard.*; Particle Board reserved for Geometrical Particle Board.
final class CockpitSeedPlanG3Tests: XCTestCase {

    func testSeedVersionPinned() {
        XCTAssertFalse(CockpitSeedPlan.seedVersion.isEmpty)
        XCTAssertTrue(CockpitSeedPlan.seedVersion.hasPrefix("G3"))
        XCTAssertTrue(CockpitSeedPlan.seedVersion.contains("naming"))
    }

    func testLawfulLaneIsCockpitVeneerNotParticleBoard() {
        XCTAssertEqual(CockpitSeedPlan.lawfulLaneName, "CockpitVeneer3x3")
        let title = CockpitSeedPlan.plan.title
        XCTAssertTrue(title.contains("CockpitVeneer"), "Title must use CockpitVeneer3×3")
        XCTAssertFalse(title.contains("ParticleBoard"), "Must not use ParticleBoard prefix")
        XCTAssertFalse(title.lowercased().contains("particle board"), "Must not use Particle Board name")
        XCTAssertFalse(title.lowercased().contains("visualmatter"), "Must not claim VisualMatter")
        XCTAssertFalse(title.lowercased().contains("living"), "Must not claim living board")
    }

    func testMakeSeedStateHasNineCells() {
        let state = CockpitSeedPlan.makeSeedState()
        XCTAssertEqual(state.cells.count, 9)
    }

    func testEightCellsSeededPolicyGateEmpty() {
        let state = CockpitSeedPlan.makeSeedState()
        XCTAssertEqual(CockpitSeedPlan.seededNonEmptyCount, 8)

        let gate = state.cell(at: GridAddress(row: 2, col: 2)!)
        XCTAssertEqual(gate?.payload, .empty, "[2,2] must remain empty so Accept stays POLICY_GATE_LOCKED")
    }

    func testPolicyEngineHoldsAcceptOnSeed() {
        let state = CockpitSeedPlan.makeSeedState()
        let result = PolicyEngine.validate(state)
        guard case .hold(let reasons) = result else {
            XCTFail("Seed state must HOLD Accept while [2,2] empty")
            return
        }
        XCTAssertTrue(reasons.contains { $0.code == "POLICY_GATE_LOCKED" })
        XCTAssertTrue(reasons.contains { $0.address == GridAddress(row: 2, col: 2)! })
    }

    func testSeededCellsUseOIRIntentsAndNoParticleBoardClaim() {
        let state = CockpitSeedPlan.makeSeedState()
        var intents = Set<String>()
        for cell in state.cells {
            if case .route(let intent, let action) = cell.payload {
                intents.insert(intent)
                XCTAssertFalse(action.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                XCTAssertFalse(action.lowercased().contains("visualmatter progress"))
                // Surface name must not claim ParticleBoard.* as this lane
                XCTAssertFalse(action.contains("ParticleBoard.Veneer"), "Demoted: ParticleBoard.Veneer3x3")
            }
        }
        XCTAssertEqual(intents, Set(["Observed", "Interpretation", "Recommendation"]))
    }

    func testDocumentPlanHasSectionsAndPolicyPins() {
        let plan = CockpitSeedPlan.plan
        XCTAssertEqual(plan.sections.count, 3)
        XCTAssertEqual(plan.policyPins.count, 3)
        XCTAssertFalse(plan.placeholders.isEmpty)
    }
}
