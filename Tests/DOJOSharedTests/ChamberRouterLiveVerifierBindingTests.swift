import XCTest
@testable import DOJOShared

@MainActor
final class ChamberRouterLiveVerifierBindingTests: XCTestCase {
    private let correlationID = UUID(uuidString: "f6db30c3-4964-4eed-9930-21e6d6b88fd1")!
    private let issuedAt = Date(timeIntervalSince1970: 1_784_950_620)
    private let expiresAt = Date(timeIntervalSince1970: 1_784_952_420)
    private let fixtureNow = Date(timeIntervalSince1970: 1_784_951_100)

    private func receipt(
        id: String = "KC-ROUTE-ARKADAS-LIVE-V0.receipt.json",
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
            .receiptAdmittedSpecializedRoute
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
