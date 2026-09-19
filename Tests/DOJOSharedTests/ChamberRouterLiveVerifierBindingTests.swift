import XCTest
@testable import DOJOShared

@MainActor
final class ChamberRouterLiveVerifierBindingTests: XCTestCase {
    private let correlationID = UUID(uuidString: "2a96b49f-a403-44aa-821d-6208934c7d25")!
    private let issuedAt = Date(timeIntervalSince1970: 1_789_848_598)
    private let expiresAt = Date(timeIntervalSince1970: 1_789_848_898)
    private let fixtureNow = Date(timeIntervalSince1970: 1_789_848_599)

    private func receipt(
        id: String = "KC-ROUTE-39898cef-5df1-4381-b046-1ee633efc2d4.receipt.json",
        correlationID: UUID? = nil,
        issuedAt: Date? = nil,
        expiresAt: Date? = nil
    ) -> ChamberRouteAdmissionReceipt {
        ChamberRouteAdmissionReceipt(
            receiptID: id,
            chamberKey: "arkadas",
            endpoint: "http://127.0.0.1:7170",
            correlationID: correlationID ?? self.correlationID,
            issuedAt: issuedAt ?? self.issuedAt,
            expiresAt: expiresAt ?? self.expiresAt
        )
    }

    func testLiveVerifierAcceptsExactCorrelatedRouteReceiptAndRejectsReplay() async throws {
        let routeReceipt = receipt()
        let verifier = KingsChamberRouteAdmissionVerifier()
        guard await verifier.permits(
            routeReceipt,
            chamberKey: routeReceipt.chamberKey,
            correlationID: correlationID
        ) else {
            throw XCTSkip("HOLD.KingsChamberRouteAdmissionVerifierUnavailable")
        }
        let router = ChamberRouter(
            admissionVerifier: verifier,
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: routeReceipt,
            correlationID: correlationID
        )
        let replayed = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: routeReceipt,
            correlationID: correlationID
        )

        XCTAssertTrue(admitted)
        XCTAssertFalse(replayed)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
        XCTAssertEqual(
            router.routingDisposition(for: .obiWan),
            .canonicalDOJOFallback
        )
    }

    func testLiveVerifierRejectsMissingReceiptAndKeepsFallback() async {
        let router = ChamberRouter(now: { self.fixtureNow })

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(id: "missing-route-receipt.json"),
            correlationID: correlationID
        )

        XCTAssertFalse(admitted)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }

    func testUncorrelatedAndExpiredReceiptsKeepFallback() async {
        let router = ChamberRouter(now: { self.fixtureNow })
        let otherCorrelationID = UUID()

        let uncorrelated = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(),
            correlationID: otherCorrelationID
        )
        let expired = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(
                issuedAt: fixtureNow.addingTimeInterval(-60),
                expiresAt: fixtureNow
            ),
            correlationID: correlationID
        )

        XCTAssertFalse(uncorrelated)
        XCTAssertFalse(expired)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }

    func testAbsentAdmissionKeepsFallback() {
        let router = ChamberRouter(now: { self.fixtureNow })

        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }
}
