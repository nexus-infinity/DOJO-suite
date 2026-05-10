import XCTest
@testable import DOJOShared

// MARK: - PBV-MAX-4  HOLD ergonomics (cell-addressed, preview-safe, binary)
//
// Rule: HOLD is binary and cell-addressed. Accept is disabled when any HOLD is active.
// The doc and image previews are still rendered — HOLD never suppresses the forecast.
// These tests must not be changed to match broken behaviour — fix the codec.

final class ParticleBoardPolicyTests: XCTestCase {

    // MARK: - Fixtures

    private func makeValidBoard() -> ParticleBoardState {
        AikidoOpticsCodec.encode(DocumentPlan(
            title: "Valid Plan",
            sections: [DocumentSection(heading: "Witness", axis: .witness)],
            policyPins: []
        ))
    }

    /// Break the ATLAS invariant at (0,1).
    private func boardWithBadAtlas() -> ParticleBoardState {
        let base = makeValidBoard()
        var cells = base.cells.filter { !($0.row == 0 && $0.col == 1) }
        cells.append(BoardCell(row: 0, col: 1, payload: .routingHome(.tata)))
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        return ParticleBoardState(cells: cells, veneerEnabled: true)
    }

    /// Break the DOJO invariant at (0,2).
    private func boardWithBadDojo() -> ParticleBoardState {
        let base = makeValidBoard()
        var cells = base.cells.filter { !($0.row == 0 && $0.col == 2) }
        cells.append(BoardCell(row: 0, col: 2, payload: .routingHome(.akron)))
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        return ParticleBoardState(cells: cells, veneerEnabled: true)
    }

    /// Partial policy: (2,0) set, (2,2) empty.
    private func boardWithPartialPolicyDraftOnly() -> ParticleBoardState {
        let base = makeValidBoard()
        var cells = base.cells.filter { !($0.row == 2) }
        cells.append(BoardCell(row: 2, col: 0, payload: .routingHome(.obiWan)))
        cells.append(BoardCell(row: 2, col: 1, payload: .empty))
        cells.append(BoardCell(row: 2, col: 2, payload: .empty))  // missing akron
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        return ParticleBoardState(cells: cells, veneerEnabled: true)
    }

    /// Partial policy: (2,2) set, (2,0) empty.
    private func boardWithPartialPolicyPublishOnly() -> ParticleBoardState {
        let base = makeValidBoard()
        var cells = base.cells.filter { !($0.row == 2) }
        cells.append(BoardCell(row: 2, col: 0, payload: .empty))  // missing obiWan
        cells.append(BoardCell(row: 2, col: 1, payload: .empty))
        cells.append(BoardCell(row: 2, col: 2, payload: .routingHome(.akron)))
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        return ParticleBoardState(cells: cells, veneerEnabled: true)
    }

    /// Symmetric policy: (2,0) and (2,2) both set — valid.
    private func boardWithSymmetricPolicy() -> ParticleBoardState {
        let base = makeValidBoard()
        var cells = base.cells.filter { !($0.row == 2) }
        cells.append(BoardCell(row: 2, col: 0, payload: .routingHome(.obiWan)))
        cells.append(BoardCell(row: 2, col: 1, payload: .empty))
        cells.append(BoardCell(row: 2, col: 2, payload: .routingHome(.akron)))
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        return ParticleBoardState(cells: cells, veneerEnabled: true)
    }

    // MARK: - PBV-MAX-4-A  HOLD is cell-addressed

    func testHoldIsCellAddressed() {
        let board = boardWithBadAtlas()
        guard case .hold(let detail) = AikidoOpticsCodec.validate(board) else {
            XCTFail("Expected .hold for ATLAS invariant violation"); return
        }

        XCTAssertFalse(detail.reasons.isEmpty, "HOLD must carry at least one reason")
        XCTAssertTrue(detail.blockedCells.contains("0x1"),
                      "HOLD must name cell (0,1) as blocked when ATLAS invariant is violated")
        XCTAssertNotNil(detail.reasonsByCell["0x1"],
                        "Cell-local reasons must be present for (0,1)")
        XCTAssertFalse(detail.reasonsByCell["0x1"]!.isEmpty,
                       "Cell-local reasons must be non-empty")
    }

    func testHoldReasonsByCell_dojoInvariant() {
        let board = boardWithBadDojo()
        guard case .hold(let detail) = AikidoOpticsCodec.validate(board) else {
            XCTFail("Expected .hold for DOJO invariant violation"); return
        }

        XCTAssertTrue(detail.blockedCells.contains("0x2"),
                      "HOLD must name cell (0,2) as blocked when DOJO invariant is violated")
        XCTAssertNotNil(detail.reasonsByCell["0x2"])
        XCTAssertFalse(detail.minimumFix.isEmpty,
                       "minimumFix must be non-empty for a single-cell HOLD")
    }

    func testHoldCarriesMinimumFix() {
        let board = boardWithBadAtlas()
        guard case .hold(let detail) = AikidoOpticsCodec.validate(board) else {
            XCTFail("Expected .hold"); return
        }

        XCTAssertFalse(detail.minimumFix.isEmpty)
        XCTAssertNotEqual(detail.minimumFix, "Unknown.MinimumMove",
                          "Single-cell ATLAS violation must produce a concrete fix hint")
        XCTAssertTrue(detail.minimumFix.contains("ATLAS"),
                      "Fix hint for (0,1) must reference ATLAS")
    }

    // MARK: - PBV-MAX-4-B  HOLD is preview-safe (doc + image still render)

    func testBlockedForecastStillRendersDocPreview() {
        let current = makeValidBoard()
        let proposed = boardWithBadAtlas()
        let fc = AikidoOpticsCodec.forecast(current: current, proposed: proposed)

        XCTAssertEqual(fc.risk, .blocked, "Risk must be .blocked for ATLAS invariant violation")
        // Even though blocked, doc preview must still be present
        XCTAssertNotNil(fc.draftPreview, "Doc preview must be generated even when forecast is HOLD")
        XCTAssertFalse(fc.draftPreview?.markdown.isEmpty ?? true,
                       "Doc markdown must be non-empty even under HOLD")
    }

    func testBlockedForecastStillRendersImagePreview() {
        let current = makeValidBoard()
        let proposed = boardWithBadDojo()
        let fc = AikidoOpticsCodec.forecast(current: current, proposed: proposed)

        XCTAssertEqual(fc.risk, .blocked)
        XCTAssertNotNil(fc.imageDraftPreview,
                        "Image preview must be generated even when forecast is HOLD")
        XCTAssertFalse(fc.imageDraftPreview?.primitives.isEmpty ?? true,
                       "Image primitives must be non-empty even under HOLD")
    }

    // MARK: - PBV-MAX-4-C  Accept is disabled when HOLD is active

    func testAcceptDisabledWhenHold() {
        // Simulate the controller: acceptForecast() is guarded by fc.validation == .pass
        // We test this at the codec level by confirming the forecast never passes when blocked.
        let current = makeValidBoard()
        let proposed = boardWithBadAtlas()
        let fc = AikidoOpticsCodec.forecast(current: current, proposed: proposed)

        if case .hold = fc.validation {
            // Correct — accept must be disabled
        } else {
            XCTFail("Forecast for an ATLAS violation must be .hold — accept must be disabled")
        }
        XCTAssertEqual(fc.risk, .blocked)
    }

    // MARK: - PBV-MAX-4-D  Unblocking a single edit enables accept

    func testUnblockSingleEditEnablesAccept() {
        // Start with a HOLD on ATLAS, then restore (0,1) to the correct value
        let current = boardWithBadAtlas()
        guard case .hold = AikidoOpticsCodec.validate(current) else {
            XCTFail("Fixture must start as HOLD"); return
        }

        // Restore (0,1) to ATLAS
        var fixedCells = current.cells.filter { !($0.row == 0 && $0.col == 1) }
        fixedCells.append(BoardCell(row: 0, col: 1, payload: .routingHome(.atlas)))
        fixedCells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        let fixed = ParticleBoardState(cells: fixedCells, veneerEnabled: true)

        XCTAssertEqual(AikidoOpticsCodec.validate(fixed), .pass,
                       "Restoring (0,1) to ATLAS must lift the HOLD and enable accept")
    }

    // MARK: - PBV-MAX-4-E  Policy stress fixtures (Rule 4)

    func testPartialPolicyDraftOnlyIsHeld() {
        let board = boardWithPartialPolicyDraftOnly()
        guard case .hold(let detail) = AikidoOpticsCodec.validate(board) else {
            XCTFail("Partial policy (2,0) set / (2,2) empty must produce HOLD"); return
        }

        XCTAssertTrue(detail.blockedCells.contains("2x2"),
                      "HOLD must name (2,2) when it is absent while (2,0) is set")
        XCTAssertNotNil(detail.reasonsByCell["2x2"],
                        "Cell-local reasons must be present for (2,2)")
    }

    func testPartialPolicyPublishOnlyIsHeld() {
        let board = boardWithPartialPolicyPublishOnly()
        guard case .hold(let detail) = AikidoOpticsCodec.validate(board) else {
            XCTFail("Partial policy (2,2) set / (2,0) empty must produce HOLD"); return
        }

        XCTAssertTrue(detail.blockedCells.contains("2x0"),
                      "HOLD must name (2,0) when it is absent while (2,2) is set")
        XCTAssertNotNil(detail.reasonsByCell["2x0"],
                        "Cell-local reasons must be present for (2,0)")
    }

    func testSymmetricPolicyPasses() {
        let board = boardWithSymmetricPolicy()
        XCTAssertEqual(AikidoOpticsCodec.validate(board), .pass,
                       "Policy row with both (2,0) and (2,2) occupied must pass validation")
    }

    func testAllPolicyEmptyPasses() {
        // Empty policy row (no pins at all) must also pass — the rule targets asymmetry only
        let board = makeValidBoard()  // fixture has no policyPins → all row-2 cells are .empty
        XCTAssertEqual(AikidoOpticsCodec.validate(board), .pass,
                       "All-empty policy row must pass — no pins means no asymmetry")
    }

    func testMultipleHoldsReportAllViolations() {
        // Break both ATLAS (0,1) and DOJO (0,2) simultaneously
        let base = makeValidBoard()
        var cells = base.cells.filter { !($0.row == 0 && $0.col == 1) && !($0.row == 0 && $0.col == 2) }
        cells.append(BoardCell(row: 0, col: 1, payload: .routingHome(.tata)))
        cells.append(BoardCell(row: 0, col: 2, payload: .routingHome(.akron)))
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        let broken = ParticleBoardState(cells: cells, veneerEnabled: true)

        guard case .hold(let detail) = AikidoOpticsCodec.validate(broken) else {
            XCTFail("Dual invariant violation must produce HOLD"); return
        }

        XCTAssertTrue(detail.blockedCells.contains("0x1"), "HOLD must name (0,1)")
        XCTAssertTrue(detail.blockedCells.contains("0x2"), "HOLD must name (0,2)")
        XCTAssertGreaterThanOrEqual(detail.reasons.count, 2,
                                    "Multiple violations must each produce a reason")
    }

    func testHoldDetailEquality() {
        // Two identical violations must produce equivalent HoldDetail (Equatable conformance)
        let b1 = boardWithBadAtlas()
        let b2 = boardWithBadAtlas()
        let r1 = AikidoOpticsCodec.validate(b1)
        let r2 = AikidoOpticsCodec.validate(b2)
        XCTAssertEqual(r1, r2, "Identical violations must produce equal ValidationResults")
    }
}
