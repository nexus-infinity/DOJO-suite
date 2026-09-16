import XCTest
@testable import DOJOShared

final class DojoRenderProjectionV1Tests: XCTestCase {
    func testWitnessedDojoSnapshotProjectsTwoTypedTuples() {
        let result = DojoRenderProjectionV1.project()
        XCTAssertEqual(result.tuples.count, 2)
        XCTAssertEqual(result.writePolicy, "read_only")
        XCTAssertEqual(result.chamberScope, "dojo")
        XCTAssertEqual(result.droppedReasons, [])

        XCTAssertEqual(result.tuples[0].geometry, .pyramid)
        XCTAssertEqual(result.tuples[0].chamber, "dojo")
        XCTAssertEqual(result.tuples[0].role, .structure)
        XCTAssertEqual(result.tuples[0].evidence, .hold)
        XCTAssertEqual(result.tuples[0].authority, .observe)
        XCTAssertEqual(result.tuples[0].next, "Feed one chamber row and watch the quiet projection.")
        XCTAssertEqual(result.tuples[0].primeState, .holdNotEmbodied)
        XCTAssertEqual(result.tuples[0].role.dojoHex, "#2563EB")

        XCTAssertEqual(result.tuples[1].geometry, .octagon)
        XCTAssertEqual(result.tuples[1].role, .flow)
        XCTAssertEqual(result.tuples[1].authority, .compose)
        XCTAssertEqual(result.tuples[1].role.dojoHex, "#14B8A6")
    }

    func testNonDojoRowsAreDropped() {
        let mixed = DojoRenderProjectionV1.witnessedDojoSnapshot + [
            DojoRenderRawRow(
                url: "https://app.notion.com/3c704c15e4f18144a984c6873df9883c",
                geometry: "spiral",
                chamber: "kings",
                role: "observer",
                evidence: "HOLD",
                authority: "none",
                next: "Keep story non-authoritative; return one architectural question only.",
                primeState: "HOLD · not embodied"
            )
        ]
        let result = DojoRenderProjectionV1.project(rows: mixed)
        XCTAssertEqual(result.tuples.count, 2)
        XCTAssertTrue(result.tuples.allSatisfy { $0.chamber == "dojo" })
        XCTAssertTrue(result.droppedReasons.contains { $0.contains("kings") })
    }

    func testEmptyNextFailsClosed() {
        let row = DojoRenderRawRow(
            url: "https://example.invalid/empty",
            geometry: "pyramid",
            chamber: "dojo",
            role: "structure",
            evidence: "HOLD",
            authority: "observe",
            next: "**  ",
            primeState: "HOLD · not embodied"
        )
        switch DojoRenderProjectionV1.admit(row) {
        case .admitted:
            XCTFail("empty next must fail closed")
        case .rejected(let reason):
            XCTAssertEqual(reason, "hold.empty_or_unknown:next")
        }
    }

    func testLeakStripRemovesMarkdownEmojiAndUrls() {
        let stripped = DojoRenderProjectionV1.stripNext(
            "• **Next** feed https://app.notion.com/p/abc one chamber 🔶"
        )
        XCTAssertEqual(stripped, "Next feed one chamber")
    }

    func testConsumeTupleDoesNotCarryWorkshopFields() {
        let tuple = DojoRenderProjectionV1.project().tuples[0]
        XCTAssertEqual(
            tuple.consumeKeys,
            ["geometry", "chamber", "role", "evidence", "authority", "next", "prime_state"]
        )
        let mirror = Mirror(reflecting: tuple)
        let names = Set(mirror.children.compactMap(\.label))
        XCTAssertFalse(names.contains("name"))
        XCTAssertFalse(names.contains("workplace"))
        XCTAssertFalse(names.contains("source_page"))
        XCTAssertFalse(names.contains("page_body"))
    }

    func testPreservedHoldsRemainNamed() {
        XCTAssertEqual(
            DojoRenderProjectionV1.preservedHolds,
            [
                "HOLD.LocalDojoNotConsumingLiveNotionMCP",
                "HOLD.RoleColourRetinting",
                "HOLD.SomaPrimeNotEmbodied",
                "HOLD.TrekInTrash"
            ]
        )
        XCTAssertFalse(DojoRenderRole.allCasesContainsGreen)
    }

    func testWalkOnGeometryIsDroppedWhileTrekRemainsInTrash() {
        let trek = DojoRenderRawRow(
            url: "https://example.invalid/trek",
            geometry: "walk-on",
            chamber: "dojo",
            role: "structure",
            evidence: "HOLD",
            authority: "none",
            next: "Restore Trek later as a row, not new logic.",
            primeState: "HOLD · not embodied"
        )
        let result = DojoRenderProjectionV1.project(rows: [trek])
        XCTAssertEqual(result.tuples, [])
        XCTAssertEqual(result.droppedReasons, ["hold.trek_in_trash"])
    }

    func testLocalDojoTodayBridgeConsumesVerifiedFeedWithoutCrossingHolds() {
        let receipt = LocalDojoTodayRenderBridge.consumeVerifiedFeed()

        XCTAssertTrue(receipt.consumedVerifiedReadOnlyFeed)
        XCTAssertFalse(receipt.liveNotionMCPInvoked)
        XCTAssertFalse(receipt.roleColourRetintingApplied)
        XCTAssertFalse(receipt.somaEmbodied)
        XCTAssertFalse(receipt.trekRestored)

        XCTAssertEqual(receipt.schema, DojoRenderProjectionV1.schema)
        XCTAssertEqual(receipt.dataSourceID, DojoRenderProjectionV1.dataSourceID)
        XCTAssertEqual(receipt.projection.writePolicy, "read_only")
        XCTAssertEqual(receipt.projection.chamberScope, "dojo")
        XCTAssertEqual(receipt.projection.tuples.count, 2)
        XCTAssertEqual(receipt.projection.droppedReasons, [])
        XCTAssertEqual(
            receipt.receiptLine,
            "DOJO.RenderProjection.V1 · 61eb4b55-e283-454b-a628-5656c228dfc6 · read_only · dojo · tuples:2 · dropped:0 · live_notion_mcp:false · role_retint:false · soma:false · trek:false"
        )
    }
}

private extension DojoRenderRole {
    static var allCasesContainsGreen: Bool {
        [structure, flow, interface, observer, validation].contains { $0.dojoHex.uppercased() == "#22C55E" }
    }
}
