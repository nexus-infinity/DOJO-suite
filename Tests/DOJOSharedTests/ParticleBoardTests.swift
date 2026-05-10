import XCTest
@testable import DOJOShared

// MARK: - PBV-3  Golden tests (receipt-bearing)
// Rule: these tests must not be changed to match broken behaviour.
// If they break, the codec broke — fix the codec.

final class ParticleBoardTests: XCTestCase {

    // MARK: - Fixtures

    private var threeSection: DocumentPlan {
        DocumentPlan(
            title: "Field Report — April 2026",
            sections: [
                DocumentSection(heading: "Observations", axis: .witness),
                DocumentSection(heading: "Environment Reading", axis: .environment),
                DocumentSection(heading: "Logic Path", axis: .logic)
            ],
            policyPins: [
                PolicyPin(allowedAction: "export", constraint: "requires witness seat")
            ]
        )
    }

    private var singleSection: DocumentPlan {
        DocumentPlan(
            title: "Stable Snapshot",
            sections: [DocumentSection(heading: "Witness", axis: .witness)],
            policyPins: []
        )
    }

    private var emptyPlan: DocumentPlan {
        DocumentPlan(title: "Empty Plan", sections: [], policyPins: [])
    }

    // MARK: - PBV-0  Schema invariants

    func testBoardAlwaysHasNineCells() {
        let state = AikidoOpticsCodec.encode(threeSection)
        XCTAssertEqual(state.cells.count, 9)
        XCTAssertTrue(state.isValid)
    }

    func testAllCellAddressesUnique() {
        let state = AikidoOpticsCodec.encode(threeSection)
        let ids = state.cells.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate cell address detected")
    }

    func testCellKindAndPhaseMatchAddress() {
        let state = AikidoOpticsCodec.encode(threeSection)
        for cell in state.cells {
            XCTAssertEqual(cell.cellKind, CellKind.from(row: cell.row))
            XCTAssertEqual(cell.phase, Phase.from(col: cell.col))
        }
    }

    func testGlyphIsDerivedFromPayload() {
        let state = AikidoOpticsCodec.encode(threeSection)
        for cell in state.cells {
            XCTAssertEqual(cell.glyph, cell.payload.glyph, "Glyph mismatch at \(cell.id)")
        }
    }

    // MARK: - PBV-1  Encoding contract

    func testIntentRowRoutingInvariants() {
        let state = AikidoOpticsCodec.encode(threeSection)
        // (0,1) must always be ATLAS
        XCTAssertEqual(state[0, 1]?.payload, .routingHome(.atlas))
        // (0,2) must always be DOJO
        XCTAssertEqual(state[0, 2]?.payload, .routingHome(.dojo))
    }

    func testPrimaryAxisFromFirstSection() {
        let state = AikidoOpticsCodec.encode(threeSection)
        XCTAssertEqual(state[0, 0]?.payload, .axis(.witness))
    }

    func testPrimaryAxisDefaultsToWitnessWhenNoSections() {
        let state = AikidoOpticsCodec.encode(emptyPlan)
        XCTAssertEqual(state[0, 0]?.payload, .axis(.witness))
    }

    func testStructureRowMapsToSectionAxes() {
        let state = AikidoOpticsCodec.encode(threeSection)
        XCTAssertEqual(state[1, 0]?.payload, .axis(.witness))
        XCTAssertEqual(state[1, 1]?.payload, .axis(.environment))
        XCTAssertEqual(state[1, 2]?.payload, .axis(.logic))
    }

    func testStructureRowIsEmptyWhenNoSections() {
        let state = AikidoOpticsCodec.encode(emptyPlan)
        XCTAssertEqual(state[1, 0]?.payload, .empty)
        XCTAssertEqual(state[1, 1]?.payload, .empty)
        XCTAssertEqual(state[1, 2]?.payload, .empty)
    }

    func testPolicyRowPopulatedWhenPinsPresent() {
        let state = AikidoOpticsCodec.encode(threeSection)
        XCTAssertEqual(state[2, 0]?.payload, .routingHome(.obiWan))
        XCTAssertEqual(state[2, 2]?.payload, .routingHome(.akron))
    }

    func testPolicyRowEmptyWhenNoPins() {
        let state = AikidoOpticsCodec.encode(emptyPlan)
        XCTAssertEqual(state[2, 0]?.payload, .empty)
        XCTAssertEqual(state[2, 1]?.payload, .empty)
        XCTAssertEqual(state[2, 2]?.payload, .empty)
    }

    // MARK: - PBV-2  Decode → DocumentDraft

    func testDecodeProducesValidDraft() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let draft = try AikidoOpticsCodec.decodeToDocument(state).get()
        XCTAssertFalse(draft.markdown.isEmpty)
        XCTAssertEqual(draft.sourceID, state.boardID)
    }

    func testDecodedMetadataMatchesPlan() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let draft = try AikidoOpticsCodec.decodeToDocument(state).get()
        XCTAssertEqual(draft.metadata.primaryAxis, .witness)
        XCTAssertEqual(draft.metadata.sectionCount, 3)
        XCTAssertTrue(draft.metadata.hasPolicyPins)
        XCTAssertEqual(draft.metadata.validationHome, .atlas)
        XCTAssertEqual(draft.metadata.publishHome, .dojo)
    }

    // MARK: - PBV-3  Round-trip bijection (golden snapshot)

    func testRoundTripProducesConsistentDraft() throws {
        let state = AikidoOpticsCodec.encode(singleSection)
        let draft = try AikidoOpticsCodec.decodeToDocument(state).get()

        // Encode the same plan again — should produce identical metadata
        let state2 = AikidoOpticsCodec.encode(singleSection)
        let draft2 = try AikidoOpticsCodec.decodeToDocument(state2).get()

        XCTAssertEqual(draft.metadata, draft2.metadata)
        XCTAssertEqual(draft.markdown, draft2.markdown, "Markdown is non-deterministic")
    }

    func testGoldenSnapshotMarkdown() throws {
        let state = AikidoOpticsCodec.encode(singleSection)
        let draft = try AikidoOpticsCodec.decodeToDocument(state).get()

        // These strings must not change unless codec intentionally changes.
        XCTAssertTrue(draft.markdown.contains("# [Witness]"), "Intent header missing")
        XCTAssertTrue(draft.markdown.contains("## Witness"), "Section heading missing")
        XCTAssertTrue(draft.markdown.contains("ATLAS"), "Validation home missing")
        XCTAssertTrue(draft.markdown.contains("DOJO"), "Publish home missing")
        XCTAssertFalse(draft.markdown.contains("**Policy:**"), "Policy block should be absent")
    }

    func testGoldenSnapshotWithPolicy() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let draft = try AikidoOpticsCodec.decodeToDocument(state).get()
        XCTAssertTrue(draft.markdown.contains("**Policy:**"), "Policy block missing")
    }

    // MARK: - Bijection: symbol set is unique

    func testCategoryAxisGlyphsAreUnique() {
        let glyphs = CategoryAxis.allCases.map { CellPayload.axis($0).glyph }
        XCTAssertEqual(glyphs.count, Set(glyphs).count, "CategoryAxis glyph collision detected")
    }

    func testPersistenceHomeSymbolsAreUnique() {
        let symbols = PersistenceHome.allCases.map { $0.boardSymbol }
        XCTAssertEqual(symbols.count, Set(symbols).count, "PersistenceHome board symbol collision detected")
    }

    // MARK: - Validation

    func testValidBoardPasses() {
        let state = AikidoOpticsCodec.encode(threeSection)
        XCTAssertEqual(AikidoOpticsCodec.validate(state), .pass)
    }

    func testInvalidBoardHolds() {
        // Build a board with only 1 cell — structurally invalid
        let broken = ParticleBoardState(
            cells: [BoardCell(row: 0, col: 0, payload: .empty)],
            veneerEnabled: true
        )
        if case .hold(let reasons) = AikidoOpticsCodec.validate(broken) {
            XCTAssertFalse(reasons.isEmpty)
        } else {
            XCTFail("Expected .hold for invalid board")
        }
    }

    // MARK: - Shadow-casting forecast

    func testForecastDiffIsNonEmpty() {
        let s1 = AikidoOpticsCodec.encode(emptyPlan)
        let s2 = AikidoOpticsCodec.encode(singleSection)
        let fc = AikidoOpticsCodec.forecast(current: s1, proposed: s2)
        XCTAssertFalse(fc.diffs.isEmpty, "Diff should detect structural change")
    }

    func testForecastDoesNotMutateCurrentBoard() {
        let s1 = AikidoOpticsCodec.encode(emptyPlan)
        let s1Cells = s1.cells
        let s2 = AikidoOpticsCodec.encode(singleSection)
        _ = AikidoOpticsCodec.forecast(current: s1, proposed: s2)
        XCTAssertEqual(s1.cells, s1Cells, "forecast() must not mutate the current board")
    }

    func testForecastNoDiffWhenIdentical() {
        let s1 = AikidoOpticsCodec.encode(emptyPlan)
        // Encode same plan separately — boardIDs will differ, cells will match
        let s2 = AikidoOpticsCodec.encode(emptyPlan)
        let fc = AikidoOpticsCodec.forecast(current: s1, proposed: s2)
        XCTAssertTrue(fc.diffs.isEmpty, "No diff expected for structurally identical boards")
        XCTAssertEqual(fc.risk, .none)
    }

    func testForecastBlockedOnInvalidBoard() {
        let invalid = ParticleBoardState(cells: [BoardCell(row: 0, col: 0, payload: .empty)], veneerEnabled: true)
        let fc = AikidoOpticsCodec.forecast(current: nil, proposed: invalid)
        XCTAssertEqual(fc.risk, .blocked)
    }

    // MARK: - PBV-4  Toggle equivalence

    func testVeneerOnOffProducesConsistentMetadata() throws {
        let plan = DocumentPlan(title: "Toggle Test", sections: [
            DocumentSection(heading: "Logic", axis: .logic)
        ], policyPins: [])

        // Veneer ON — through codec
        let onState  = AikidoOpticsCodec.encode(plan, veneerEnabled: true)
        let onDraft  = try AikidoOpticsCodec.decodeToDocument(onState).get()

        // Veneer OFF — also through codec (both use the same codec path in v0;
        //              the toggle controls whether the state is cached downstream)
        let offState = AikidoOpticsCodec.encode(plan, veneerEnabled: false)
        let offDraft = try AikidoOpticsCodec.decodeToDocument(offState).get()

        // Canonical structural output must be identical regardless of toggle
        XCTAssertEqual(onDraft.metadata, offDraft.metadata)
        XCTAssertEqual(onDraft.markdown, offDraft.markdown)
    }

    // MARK: - Image draft (v0 stub)

    func testDecodeToImageProducesPrimitives() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let image = try AikidoOpticsCodec.decodeToImage(state).get()
        // 9 cells × 2 primitives (rect + text) each
        XCTAssertEqual(image.primitives.count, 18)
    }

    // MARK: - Codable round-trip

    func testParticleBoardStateIsCodeable() throws {
        let state = AikidoOpticsCodec.encode(threeSection)
        let data  = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(ParticleBoardState.self, from: data)
        XCTAssertEqual(state, decoded)
    }

    func testCellPayloadTaggedUnionRoundTrips() throws {
        let payloads: [CellPayload] = [
            .axis(.witness), .axis(.environment), .axis(.soma), .axis(.logic),
            .routingHome(.atlas), .routingHome(.dojo), .routingHome(.akron),
            .empty
        ]
        for payload in payloads {
            let cell = BoardCell(row: 0, col: 0, payload: payload)
            let data = try JSONEncoder().encode(cell)
            let decoded = try JSONDecoder().decode(BoardCell.self, from: data)
            XCTAssertEqual(decoded.payload, payload, "Codable round-trip failed for \(payload)")
        }
    }
}
