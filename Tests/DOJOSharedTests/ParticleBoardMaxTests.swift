import XCTest
@testable import DOJOShared

// MARK: - PBV-MAX-2  Channel stress tests (codec-level invariants)
//
// Rule: channels are non-canonical. They must never change draft output,
// must never appear as payload diffs in forecasts, and must not affect
// the board's structural validity.
//
// These tests sit alongside (not inside) the 28 locked PBV-0→PBV-4 tests.
// If they break, investigate the codec — not these tests.

final class ParticleBoardMaxTests: XCTestCase {

    // MARK: - Fixtures

    private var threeSection: DocumentPlan {
        DocumentPlan(
            title: "Field Report — April 2026",
            sections: [
                DocumentSection(heading: "Observations",        axis: .witness),
                DocumentSection(heading: "Environment Reading", axis: .environment),
                DocumentSection(heading: "Logic Path",          axis: .logic)
            ],
            policyPins: [PolicyPin(allowedAction: "export", constraint: "requires witness seat")]
        )
    }

    private var singleSection: DocumentPlan {
        DocumentPlan(
            title: "Single Section",
            sections: [DocumentSection(heading: "Witness", axis: .witness)],
            policyPins: []
        )
    }

    private var emptyPlan: DocumentPlan {
        DocumentPlan(title: "Empty Plan", sections: [], policyPins: [])
    }

    // MARK: - Stress fixture: all-cells-hot

    /// Channels at max intensity must not invalidate the board or change the draft.
    func testAllCellsHotDraftUnchanged() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let hotCells = state.cells.map { cell in
            BoardCell(row: cell.row, col: cell.col, payload: cell.payload,
                      channels: CellChannels(color: "amber", motion: "pulse", intensity: 1.0))
        }
        let hotState = ParticleBoardState(boardID: state.boardID, cells: hotCells, veneerEnabled: true)

        XCTAssertTrue(hotState.isValid, "All-cells-hot board must remain valid")

        let plain = try AikidoOpticsCodec.decodeToDocument(state).get()
        let hot   = try AikidoOpticsCodec.decodeToDocument(hotState).get()

        XCTAssertEqual(plain.markdown,  hot.markdown,  "Max intensity channels must not change markdown output")
        XCTAssertEqual(plain.metadata,  hot.metadata,  "Max intensity channels must not change draft metadata")
    }

    func testAllCellsHotImageUnchanged() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let hotCells = state.cells.map { cell in
            BoardCell(row: cell.row, col: cell.col, payload: cell.payload,
                      channels: CellChannels(color: "violet", motion: "pulse", intensity: 1.0))
        }
        let hotState = ParticleBoardState(boardID: state.boardID, cells: hotCells, veneerEnabled: true)

        let plain = try AikidoOpticsCodec.decodeToImage(state).get()
        let hot   = try AikidoOpticsCodec.decodeToImage(hotState).get()

        // Primitive count and labels must be identical — channels are invisible to image codec
        XCTAssertEqual(plain.primitives.count, hot.primitives.count)
    }

    // MARK: - Stress fixture: conflicting signals

    /// A blocked forecast must report .blocked regardless of channel intensity.
    /// High channel activity must not suppress risk visibility.
    func testBlockedForecastIgnoresChannelIntensity() {
        let base = AikidoOpticsCodec.encode(emptyPlan)

        // Break the ATLAS invariant to force .blocked
        var badCells = base.cells.filter { !($0.row == 0 && $0.col == 1) }
        badCells.append(BoardCell(
            row: 0, col: 1,
            payload: .routingHome(.tata),                           // NOT atlas — invariant violation
            channels: CellChannels(color: "cyan", intensity: 0.1)  // low intensity
        ))
        badCells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        let proposed = ParticleBoardState(cells: badCells, veneerEnabled: true)

        // Validation must return .hold regardless of channel state
        let result = AikidoOpticsCodec.validate(proposed)
        if case .hold(let reasons) = result {
            XCTAssertFalse(reasons.isEmpty, "Blocked forecast must carry reasons")
        } else {
            XCTFail("Expected .hold when ATLAS invariant is violated — channels must not mask the error")
        }

        let fc = AikidoOpticsCodec.forecast(current: base, proposed: proposed)
        XCTAssertEqual(fc.risk, .blocked, "Risk must be .blocked regardless of low channel intensity")
    }

    /// High-intensity channels on a clean forecast must not upgrade risk to .blocked.
    func testHighIntensityChannelsDoNotUpgradeRisk() {
        let s1 = AikidoOpticsCodec.encode(emptyPlan)
        // Add one valid payload change with high-intensity channel
        var cells = s1.cells.filter { !($0.row == 1 && $0.col == 0) }
        cells.append(BoardCell(
            row: 1, col: 0,
            payload: .axis(.logic),
            channels: CellChannels(color: "rose", motion: "pulse", intensity: 1.0)
        ))
        cells.sort { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
        let s2 = ParticleBoardState(cells: cells, veneerEnabled: true)

        let fc = AikidoOpticsCodec.forecast(current: s1, proposed: s2)
        XCTAssertNotEqual(fc.risk, .blocked, "High-intensity channels on a valid change must not block acceptance")
    }

    // MARK: - Stress fixture: motion overload legibility clamp

    /// Motion threshold is canonical data: intensity below it means animation is suppressed.
    /// Test that the threshold value itself is consistent and documentable.
    func testMotionThresholdDataContract() {
        // Cells below threshold store motion: "pulse" but the rendering layer will suppress it.
        let lowIntensityCell = BoardCell(
            row: 0, col: 0,
            payload: .axis(.witness),
            channels: CellChannels(color: "amber", motion: "pulse", intensity: 0.2)
        )
        let highIntensityCell = BoardCell(
            row: 0, col: 1,
            payload: .axis(.witness),
            channels: CellChannels(color: "amber", motion: "pulse", intensity: 0.8)
        )

        // Data contract: 0.3 is the threshold. Neither channels nor codec enforce it — the
        // view layer does. Here we assert the data values are unambiguous.
        XCTAssertLessThan(lowIntensityCell.channels!.intensity!, 0.3,
                          "Low-intensity cell must be below motion threshold")
        XCTAssertGreaterThan(highIntensityCell.channels!.intensity!, 0.3,
                             "High-intensity cell must exceed motion threshold")

        // Both must still decode identically — the threshold is view-only, not codec-level
        let s1 = ParticleBoardState(cells: [
            lowIntensityCell,
            BoardCell(row: 0, col: 1, payload: .routingHome(.atlas)),
            BoardCell(row: 0, col: 2, payload: .routingHome(.dojo)),
            BoardCell(row: 1, col: 0, payload: .empty),
            BoardCell(row: 1, col: 1, payload: .empty),
            BoardCell(row: 1, col: 2, payload: .empty),
            BoardCell(row: 2, col: 0, payload: .empty),
            BoardCell(row: 2, col: 1, payload: .empty),
            BoardCell(row: 2, col: 2, payload: .empty),
        ], veneerEnabled: true)

        let s2 = ParticleBoardState(cells: [
            highIntensityCell,
            BoardCell(row: 0, col: 1, payload: .routingHome(.atlas)),
            BoardCell(row: 0, col: 2, payload: .routingHome(.dojo)),
            BoardCell(row: 1, col: 0, payload: .empty),
            BoardCell(row: 1, col: 1, payload: .empty),
            BoardCell(row: 1, col: 2, payload: .empty),
            BoardCell(row: 2, col: 0, payload: .empty),
            BoardCell(row: 2, col: 1, payload: .empty),
            BoardCell(row: 2, col: 2, payload: .empty),
        ], veneerEnabled: true)

        let d1 = try? AikidoOpticsCodec.decodeToDocument(s1).get()
        let d2 = try? AikidoOpticsCodec.decodeToDocument(s2).get()
        XCTAssertEqual(d1?.markdown, d2?.markdown,
                       "Different motion intensities must produce identical drafts")
    }

    // MARK: - Channels do not appear in forecast diffs

    /// Changing only channels between two states must produce zero payload diffs.
    func testChannelOnlyChangeProducesZeroDiffs() {
        let state = AikidoOpticsCodec.encode(singleSection)

        // Clone with all cells getting channels — payloads unchanged
        let withChannels = ParticleBoardState(
            boardID: UUID(),
            cells: state.cells.map { cell in
                BoardCell(row: cell.row, col: cell.col, payload: cell.payload,
                          channels: CellChannels(color: "gold", motion: "pulse", intensity: 0.9))
            },
            veneerEnabled: true
        )

        let fc = AikidoOpticsCodec.forecast(current: state, proposed: withChannels)
        XCTAssertTrue(fc.diffs.isEmpty,
                      "Channel-only changes must produce no payload diffs in forecast")
        XCTAssertEqual(fc.risk, .none,
                       "Channel-only change must have no forecast risk")
    }

    /// Removing all channels must also produce zero payload diffs.
    func testChannelClearProducesZeroDiffs() {
        // Start: all cells have channels
        let base = AikidoOpticsCodec.encode(singleSection)
        let withChannels = ParticleBoardState(
            boardID: UUID(),
            cells: base.cells.map { cell in
                BoardCell(row: cell.row, col: cell.col, payload: cell.payload,
                          channels: CellChannels(color: "cyan", intensity: 0.7))
            },
            veneerEnabled: true
        )

        // Remove all channels
        let cleared = ParticleBoardState(
            boardID: UUID(),
            cells: withChannels.cells.map { cell in
                BoardCell(row: cell.row, col: cell.col, payload: cell.payload, channels: nil)
            },
            veneerEnabled: true
        )

        let fc = AikidoOpticsCodec.forecast(current: withChannels, proposed: cleared)
        XCTAssertTrue(fc.diffs.isEmpty, "Clearing channels must produce no payload diffs")
    }

    // MARK: - Channel Codable round-trip

    func testChannelsRoundTripThroughCodable() throws {
        let channels = CellChannels(color: "violet", motion: "pulse", intensity: 0.75)
        let cell = BoardCell(row: 1, col: 2, payload: .axis(.logic), channels: channels)
        let data = try JSONEncoder().encode(cell)
        let decoded = try JSONDecoder().decode(BoardCell.self, from: data)

        XCTAssertEqual(decoded.channels?.color,     channels.color)
        XCTAssertEqual(decoded.channels?.motion,    channels.motion)
        XCTAssertEqual(decoded.channels?.intensity, channels.intensity)
        XCTAssertEqual(decoded.payload,             cell.payload)
    }

    func testNilChannelsRoundTrip() throws {
        let cell = BoardCell(row: 0, col: 0, payload: .axis(.witness), channels: nil)
        let data = try JSONEncoder().encode(cell)
        let decoded = try JSONDecoder().decode(BoardCell.self, from: data)
        XCTAssertNil(decoded.channels)
        XCTAssertEqual(decoded.payload, .axis(.witness))
    }

    // MARK: - Channel state isolation from canonical

    /// encode() must never produce channels — encoding is always channel-free.
    func testEncodeNeverProducesChannels() {
        let state = AikidoOpticsCodec.encode(threeSection)
        for cell in state.cells {
            XCTAssertNil(cell.channels, "encode() must not populate channels — they are non-canonical")
        }
    }

    /// A board state with channels and one without must produce equivalent forecasts
    /// when the canonical payloads are identical.
    func testChannelPresenceDoesNotAffectForecastEquality() {
        let s1 = AikidoOpticsCodec.encode(emptyPlan)
        let s2WithChannels = ParticleBoardState(
            boardID: UUID(),
            cells: AikidoOpticsCodec.encode(singleSection).cells.map { cell in
                BoardCell(row: cell.row, col: cell.col, payload: cell.payload,
                          channels: CellChannels(color: "rose", intensity: 1.0))
            },
            veneerEnabled: true
        )
        let s2Plain = AikidoOpticsCodec.encode(singleSection)

        let fcWithChannels = AikidoOpticsCodec.forecast(current: s1, proposed: s2WithChannels)
        let fcPlain        = AikidoOpticsCodec.forecast(current: s1, proposed: s2Plain)

        // Diffs and risk must be identical regardless of channels
        XCTAssertEqual(fcWithChannels.diffs.map(\.address), fcPlain.diffs.map(\.address))
        XCTAssertEqual(fcWithChannels.risk, fcPlain.risk)
        XCTAssertEqual(fcWithChannels.draftPreview?.markdown, fcPlain.draftPreview?.markdown)
    }
}
