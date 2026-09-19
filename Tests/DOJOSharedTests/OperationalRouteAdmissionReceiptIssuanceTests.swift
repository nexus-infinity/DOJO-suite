import Foundation
import XCTest
@testable import DOJOShared

@MainActor
final class OperationalRouteAdmissionReceiptIssuanceTests: XCTestCase {
    private let correlationID = UUID(
        uuidString: "2a96b49f-a403-44aa-821d-6208934c7d25"
    )!
    private let issuedAt = Date(timeIntervalSince1970: 1_789_848_598)
    private let expiresAt = Date(timeIntervalSince1970: 1_789_848_898)
    private let fixtureNow = Date(timeIntervalSince1970: 1_789_848_599)
    private let receiptID =
        "KC-ROUTE-39898cef-5df1-4381-b046-1ee633efc2d4.receipt.json"
    private func receipt(
        id: String? = nil,
        correlationID: UUID? = nil,
        issuedAt: Date? = nil,
        expiresAt: Date? = nil
    ) -> ChamberRouteAdmissionReceipt {
        ChamberRouteAdmissionReceipt(
            receiptID: id ?? receiptID,
            chamberKey: "arkadas",
            endpoint: "http://127.0.0.1:7170",
            correlationID: correlationID ?? self.correlationID,
            issuedAt: issuedAt ?? self.issuedAt,
            expiresAt: expiresAt ?? self.expiresAt
        )
    }

    func testOperationalReceiptAdmitsOnceAndPersistsAtomicReplayClaim() async throws {
        let operationalReceipt = receipt()
        let verifier = KingsChamberRouteAdmissionVerifier()
        guard await verifier.permits(
            operationalReceipt,
            chamberKey: operationalReceipt.chamberKey,
            correlationID: correlationID
        ) else {
            throw XCTSkip("HOLD.KingsChamberOperationalReceiptUnavailable")
        }
        let ledgerURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("route-admission-ledger.json")
        let ledger = FileRouteAdmissionReplayLedger(fileURL: ledgerURL)
        let router = ChamberRouter(
            admissionVerifier: verifier,
            replayLedger: ledger,
            now: { self.fixtureNow }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: operationalReceipt,
            correlationID: correlationID
        )
        XCTAssertTrue(admitted)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .receiptAdmittedSpecializedRoute
        )

        let replayed = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: operationalReceipt,
            correlationID: correlationID
        )
        XCTAssertFalse(replayed)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let snapshot = await ledger.snapshot()
        XCTAssertEqual(snapshot?.entries.count, 1)
        XCTAssertNotNil(snapshot?.entries[receiptID])
    }

    func testFallbackForAbsentInvalidExpiredUncorrelatedAndImproperIssuance() async throws {
        let absentRouter = ChamberRouter(now: { self.fixtureNow })
        XCTAssertEqual(
            absentRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let invalidRouter = ChamberRouter(now: { self.fixtureNow })
        let invalid = await invalidRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(id: "missing-operational-route.receipt.json"),
            correlationID: correlationID
        )
        XCTAssertFalse(invalid)

        let expiredRouter = ChamberRouter(now: { self.fixtureNow })
        let expired = await expiredRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(expiresAt: fixtureNow),
            correlationID: correlationID
        )
        XCTAssertFalse(expired)

        let uncorrelatedRouter = ChamberRouter(now: { self.fixtureNow })
        let uncorrelated = await uncorrelatedRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(),
            correlationID: UUID()
        )
        XCTAssertFalse(uncorrelated)

        let legacyNow = Date(timeIntervalSince1970: 1_784_951_100)
        let improperRouter = ChamberRouter(now: { legacyNow })
        let improper = try await improperRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(
                id: "KC-ROUTE-ARKADAS-LIVE-V0.receipt.json",
                correlationID: XCTUnwrap(UUID(
                    uuidString: "f6db30c3-4964-4eed-9930-21e6d6b88fd1"
                )),
                issuedAt: Date(timeIntervalSince1970: 1_784_950_620),
                expiresAt: Date(timeIntervalSince1970: 1_784_952_420)
            ),
            correlationID: XCTUnwrap(UUID(
                uuidString: "f6db30c3-4964-4eed-9930-21e6d6b88fd1"
            ))
        )
        XCTAssertFalse(improper)

        for router in [
            invalidRouter,
            expiredRouter,
            uncorrelatedRouter,
            improperRouter,
        ] {
            XCTAssertEqual(
                router.routingDisposition(for: .arkadas),
                .canonicalDOJOFallback
            )
        }
    }
}
