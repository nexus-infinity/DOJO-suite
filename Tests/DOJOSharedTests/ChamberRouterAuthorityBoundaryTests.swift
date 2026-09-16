import XCTest
@testable import DOJOShared

private struct ExactRouteAdmissionVerifier: ChamberRouteAdmissionVerifying {
    let receiptID: String

    func permits(
        _ receipt: ChamberRouteAdmissionReceipt,
        chamberKey: String,
        correlationID: UUID
    ) async -> Bool {
        receipt.receiptID == receiptID
            && receipt.chamberKey == chamberKey
            && receipt.correlationID == correlationID
    }
}

@MainActor
final class ChamberRouterAuthorityBoundaryTests: XCTestCase {
    private let fixtureNow = Date(timeIntervalSince1970: 1_800_000_000)

    private func receipt(
        id: String = "route-receipt-001",
        chamberKey: String = "arkadas",
        endpoint: String = "http://127.0.0.1:7170",
        correlationID: UUID,
        issuedAt: Date? = nil,
        expiresAt: Date? = nil
    ) -> ChamberRouteAdmissionReceipt {
        ChamberRouteAdmissionReceipt(
            receiptID: id,
            chamberKey: chamberKey,
            endpoint: endpoint,
            correlationID: correlationID,
            issuedAt: issuedAt ?? fixtureNow.addingTimeInterval(-30),
            expiresAt: expiresAt ?? fixtureNow.addingTimeInterval(30)
        )
    }

    func testTopologyObservationsCannotPromotePreferredRoutes() async {
        let router = ChamberRouter(dojoBaseURL: "http://127.0.0.1:1")

        await router.refreshTopology()

        XCTAssertFalse(router.isPreferredChamberLive(for: .arkadas))
        XCTAssertFalse(router.isPreferredChamberLive(for: .obiWan))
        XCTAssertFalse(router.isPreferredChamberLive(for: .aiMind))
    }

    func testRequestSuccessCannotManufactureRoutingAuthority() async {
        let router = ChamberRouter(dojoBaseURL: "http://127.0.0.1:1")

        router.recordSuccess(for: .arkadas)
        router.recordSuccess(for: .obiWan)
        await router.refreshTopology()

        XCTAssertFalse(router.isPreferredChamberLive(for: .arkadas))
        XCTAssertFalse(router.isPreferredChamberLive(for: .obiWan))
    }

    func testValidCorrelatedReceiptAdmitsOneSpecializedRoute() async {
        let correlationID = UUID()
        let router = ChamberRouter(
            admissionVerifier: ExactRouteAdmissionVerifier(receiptID: "route-receipt-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(correlationID: correlationID),
            correlationID: correlationID
        )

        XCTAssertTrue(admitted)
        XCTAssertTrue(router.isPreferredChamberLive(for: .arkadas))
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .receiptAdmittedSpecializedRoute
        )
        XCTAssertEqual(
            router.routingDisposition(for: .obiWan),
            .canonicalDOJOFallback
        )
    }

    func testAdmissionReceiptReplayIsRejectedAndRestoresCanonicalFallback() async {
        let correlationID = UUID()
        let router = ChamberRouter(
            admissionVerifier: ExactRouteAdmissionVerifier(receiptID: "route-receipt-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )
        let admissionReceipt = receipt(correlationID: correlationID)

        let firstAdmission = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: admissionReceipt,
            correlationID: correlationID
        )
        let replayAdmission = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: admissionReceipt,
            correlationID: correlationID
        )

        XCTAssertTrue(firstAdmission)
        XCTAssertFalse(replayAdmission)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
        XCTAssertEqual(
            router.routingDisposition(for: .obiWan),
            .canonicalDOJOFallback
        )
    }

    func testAbsentReceiptLeavesCanonicalDOJOFallback() {
        let router = ChamberRouter()

        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }

    func testInvalidReceiptIsDeniedAndLeavesCanonicalDOJOFallback() async {
        let correlationID = UUID()
        let router = ChamberRouter(
            admissionVerifier: ExactRouteAdmissionVerifier(receiptID: "expected-receipt"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(id: "forged-receipt", correlationID: correlationID),
            correlationID: correlationID
        )

        XCTAssertFalse(admitted)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }

    func testExpiredReceiptIsDeniedAndLeavesCanonicalDOJOFallback() async {
        let correlationID = UUID()
        let router = ChamberRouter(
            admissionVerifier: ExactRouteAdmissionVerifier(receiptID: "route-receipt-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(
                correlationID: correlationID,
                issuedAt: fixtureNow.addingTimeInterval(-60),
                expiresAt: fixtureNow
            ),
            correlationID: correlationID
        )

        XCTAssertFalse(admitted)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }

    func testUncorrelatedReceiptIsDeniedAndLeavesCanonicalDOJOFallback() async {
        let receiptCorrelationID = UUID()
        let router = ChamberRouter(
            admissionVerifier: ExactRouteAdmissionVerifier(receiptID: "route-receipt-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(correlationID: receiptCorrelationID),
            correlationID: UUID()
        )

        XCTAssertFalse(admitted)
        XCTAssertEqual(
            router.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )
    }
}
