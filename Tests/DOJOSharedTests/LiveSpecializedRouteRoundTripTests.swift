import Foundation
import XCTest
@testable import DOJOShared

@MainActor
final class LiveSpecializedRouteRoundTripTests: XCTestCase {
    private let correlationID = UUID(uuidString: "833f90e9-0b1e-4811-9122-550045ffd715")!
    private let issuedAt = Date(timeIntervalSince1970: 1_784_955_912)
    private let expiresAt = Date(timeIntervalSince1970: 1_784_957_712)
    private let fixtureNow = Date(timeIntervalSince1970: 1_784_956_200)

    private func receipt(
        id: String = "KC-ROUTE-ARKADAS-ROUNDTRIP-V0.receipt.json",
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

    func testOneLiveVerifiedArkadasRouteRoundTripAndFallbackBoundaries() async throws {
        let absentRouter = ChamberRouter(now: { self.fixtureNow })
        XCTAssertEqual(
            absentRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let invalidRouter = ChamberRouter(now: { self.fixtureNow })
        let invalid = await invalidRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(id: "missing-roundtrip-receipt.json"),
            correlationID: correlationID
        )
        XCTAssertFalse(invalid)
        XCTAssertEqual(
            invalidRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let expiredRouter = ChamberRouter(now: { self.fixtureNow })
        let expired = await expiredRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(
                issuedAt: fixtureNow.addingTimeInterval(-60),
                expiresAt: fixtureNow
            ),
            correlationID: correlationID
        )
        XCTAssertFalse(expired)
        XCTAssertEqual(
            expiredRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let uncorrelatedRouter = ChamberRouter(now: { self.fixtureNow })
        let uncorrelated = await uncorrelatedRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(),
            correlationID: UUID()
        )
        XCTAssertFalse(uncorrelated)
        XCTAssertEqual(
            uncorrelatedRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let liveRouter = ChamberRouter(
            admissionVerifier: KingsChamberRouteAdmissionVerifier(),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.fixtureNow }
        )
        let routeReceipt = receipt()
        let verifier = KingsChamberRouteAdmissionVerifier()
        guard await verifier.permits(
            routeReceipt,
            chamberKey: routeReceipt.chamberKey,
            correlationID: correlationID
        ) else {
            throw XCTSkip("HOLD.KingsChamberRouteAdmissionVerifierUnavailable")
        }
        let admitted = await liveRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: routeReceipt,
            correlationID: correlationID
        )
        XCTAssertTrue(admitted)
        XCTAssertEqual(
            liveRouter.routingDisposition(for: .arkadas),
            .receiptAdmittedSpecializedRoute
        )
        XCTAssertEqual(
            liveRouter.routingDisposition(for: .obiWan),
            .canonicalDOJOFallback
        )

        let client = liveRouter.client(for: .arkadas)
        let transportReceipt = try await client.callTool(
            name: "arkadas_status",
            effect: .readOnly,
            correlationID: correlationID
        )

        XCTAssertEqual(transportReceipt.correlationID, correlationID)
        XCTAssertEqual(transportReceipt.httpStatus, 200)
        let response = try XCTUnwrap(
            JSONSerialization.jsonObject(with: transportReceipt.responseBody) as? [String: Any]
        )
        XCTAssertEqual(response["correlation_id"] as? String, correlationID.uuidString)
        XCTAssertEqual(response["tool"] as? String, "arkadas_status")
        XCTAssertEqual(response["effect"] as? String, "readOnly")
        let responseReceipt = try XCTUnwrap(
            response["transport_receipt"] as? [String: Any]
        )
        XCTAssertEqual(
            responseReceipt["schema_id"] as? String,
            "ARKADAS_CORRELATED_READONLY_TRANSPORT_RECEIPT_V0"
        )
        XCTAssertEqual(responseReceipt["correlation_id"] as? String, correlationID.uuidString)

        let replayed = await liveRouter.admitSpecializedRoute(
            for: .arkadas,
            receipt: routeReceipt,
            correlationID: correlationID
        )
        XCTAssertFalse(replayed)
        XCTAssertEqual(
            liveRouter.routingDisposition(for: .arkadas),
            .canonicalDOJOFallback
        )

        let evidence = try JSONSerialization.data(
            withJSONObject: [
                "route_receipt_id": routeReceipt.receiptID,
                "route_scope": routeReceipt.authorityScope,
                "transport_http_status": transportReceipt.httpStatus,
                "response": response,
                "replay_rejected": true,
                "post_replay_disposition": "canonicalDOJOFallback"
            ],
            options: [.sortedKeys]
        )
        print("LIVE_SPECIALIZED_ROUTE_EVIDENCE \(String(decoding: evidence, as: UTF8.self))")
    }
}
