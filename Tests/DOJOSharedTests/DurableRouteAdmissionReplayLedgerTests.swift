import Foundation
import XCTest
@testable import DOJOShared

private struct DurableLedgerFixtureVerifier: ChamberRouteAdmissionVerifying {
    func permits(
        _ receipt: ChamberRouteAdmissionReceipt,
        chamberKey: String,
        correlationID: UUID
    ) async -> Bool {
        receipt.chamberKey == chamberKey && receipt.correlationID == correlationID
    }
}

@MainActor
final class DurableRouteAdmissionReplayLedgerTests: XCTestCase {
    func testUsedReceiptRemainsRejectedAfterLedgerAndRouterReload() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("durable-route-ledger-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let ledgerURL = directory.appendingPathComponent("replay-ledger.json")
        let now = Date(timeIntervalSince1970: 1_800_100_000)
        let correlationID = UUID()
        let receipt = ChamberRouteAdmissionReceipt(
            receiptID: "durable-route-receipt-001",
            chamberKey: "arkadas",
            endpoint: "http://127.0.0.1:7170",
            correlationID: correlationID,
            issuedAt: now.addingTimeInterval(-30),
            expiresAt: now.addingTimeInterval(300)
        )

        let firstLedger = FileRouteAdmissionReplayLedger(fileURL: ledgerURL)
        let firstRouter = ChamberRouter(
            admissionVerifier: DurableLedgerFixtureVerifier(),
            replayLedger: firstLedger,
            now: { now }
        )

        let firstUse = await firstRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt,
            correlationID: correlationID
        )
        XCTAssertTrue(firstUse)
        XCTAssertEqual(
            firstRouter.routingDisposition(for: .arkadas),
            .receiptAdmittedSpecializedRoute
        )

        let immediateReplay = await firstRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt,
            correlationID: correlationID
        )
        XCTAssertFalse(immediateReplay)
        XCTAssertEqual(
            firstRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let reloadedLedger = FileRouteAdmissionReplayLedger(fileURL: ledgerURL)
        let reloadedRouter = ChamberRouter(
            admissionVerifier: DurableLedgerFixtureVerifier(),
            replayLedger: reloadedLedger,
            now: { now.addingTimeInterval(60) }
        )
        let postReloadReplay = await reloadedRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt,
            correlationID: correlationID
        )
        XCTAssertFalse(postReloadReplay)
        XCTAssertEqual(
            reloadedRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let loadedSnapshot = await reloadedLedger.snapshot()
        let snapshot = try XCTUnwrap(loadedSnapshot)
        XCTAssertEqual(
            snapshot.schemaID,
            FileRouteAdmissionReplayLedger.schemaID
        )
        XCTAssertEqual(snapshot.entries.count, 1)
        XCTAssertEqual(
            snapshot.entries[receipt.receiptID]?.consumedAt,
            now
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: ledgerURL.path))

        let data = try Data(contentsOf: ledgerURL)
        print(
            "DURABLE_ROUTE_LEDGER_EVIDENCE "
                + String(decoding: data, as: UTF8.self)
                    .replacingOccurrences(of: "\n", with: "")
        )
    }

    func testChronicleFixtureLedgerPersistsConsumedIdentifier() async throws {
        let ledgerURL = URL(
            fileURLWithPath:
                "/Users/field/◎Kings-Chamber/chronicle/"
                + "DURABLE_ROUTE_ADMISSION_REPLAY_LEDGER_V0.fixture-ledger.json"
        )
        let receiptID = "DURABLE-ROUTE-REPLAY-FIXTURE-001"
        let consumedAt = Date(timeIntervalSince1970: 1_800_100_000)

        let ledger = FileRouteAdmissionReplayLedger(fileURL: ledgerURL)
        let firstClaimInThisRun = await ledger.claim(
            receiptID: receiptID,
            consumedAt: consumedAt
        )

        let reloadedLedger = FileRouteAdmissionReplayLedger(fileURL: ledgerURL)
        let replayClaim = await reloadedLedger.claim(
            receiptID: receiptID,
            consumedAt: consumedAt.addingTimeInterval(60)
        )
        XCTAssertFalse(replayClaim)

        let loadedSnapshot = await reloadedLedger.snapshot()
        let snapshot = try XCTUnwrap(loadedSnapshot)
        XCTAssertEqual(snapshot.entries[receiptID]?.consumedAt, consumedAt)
        XCTAssertTrue(FileManager.default.fileExists(atPath: ledgerURL.path))

        print(
            "CHRONICLE_ROUTE_LEDGER_EVIDENCE "
                + "first_claim_in_this_run=\(firstClaimInThisRun) "
                + "replay_claim=\(replayClaim) path=\(ledgerURL.path)"
        )
    }
}
