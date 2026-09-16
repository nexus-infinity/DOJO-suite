import XCTest
@testable import DOJOShared

/// Specimen 1 — Geometrical Particle Board phase + recognition proofs.
/// Does not import or reference DeadEnd.MisroutedUIBuild / ParticleBoard types.
final class GeometricalParticleBoardSpecimenTests: XCTestCase {

    func testPhasesMapFromCycle() {
        XCTAssertEqual(GPBPhase.from(cycle: 0.05), .smoke)
        XCTAssertEqual(GPBPhase.from(cycle: 0.25), .pressure)
        XCTAssertEqual(GPBPhase.from(cycle: 0.45), .coalesce)
        XCTAssertEqual(GPBPhase.from(cycle: 0.65), .stillness)
        XCTAssertEqual(GPBPhase.from(cycle: 0.90), .dissolve)
    }

    func testDriverStartsDiffuse() {
        let driver = GPBSpecimenDriver(particleCount: 64, seedLayout: true)
        XCTAssertEqual(driver.phase, .smoke)
        XCTAssertFalse(driver.recognition.isRecognisable)
        XCTAssertLessThan(driver.recognition.score, 0.55)
    }

    func testStillnessCanBecomeRecognisable() {
        let driver = GPBSpecimenDriver(particleCount: 96, seedLayout: true)
        // Hold cycle in stillness while stepping physics (do not let tick advance out of band)
        for _ in 0..<120 {
            driver.simulate(atCycle: 0.65, dt: 0.03)
        }
        let nearGlyph = driver.recognition.meanDistance < driver.fieldSize * 0.22
        XCTAssertTrue(
            driver.recognition.isRecognisable || nearGlyph || driver.recognition.score >= 0.45,
            "Specimen should approach recognisable structure in stillness; got score=\(driver.recognition.score) meanΔ=\(driver.recognition.meanDistance)"
        )
    }

    func testCoalesceRaisesRecognitionAboveSmoke() {
        let driver = GPBSpecimenDriver(particleCount: 80, seedLayout: true)
        let smokeScore = driver.recognition.score

        for _ in 0..<90 {
            driver.simulate(atCycle: 0.45, dt: 0.04)
        }

        XCTAssertGreaterThan(driver.recognition.score, smokeScore,
                             "Recognition should rise as particles crystallise toward the glyph")
    }

    func testResetReturnsToSmoke() {
        let driver = GPBSpecimenDriver(particleCount: 40, seedLayout: true)
        for _ in 0..<40 { driver.tick(dt: 0.1) }
        driver.reset()
        XCTAssertEqual(driver.phase, .smoke)
        XCTAssertEqual(driver.cycle, 0, accuracy: 0.0001)
        XCTAssertFalse(driver.recognition.isRecognisable)
    }

    func testGlyphHasThreeVertices() {
        let driver = GPBSpecimenDriver(particleCount: 10, seedLayout: true)
        XCTAssertEqual(driver.glyphVertices.count, 3)
    }
}
