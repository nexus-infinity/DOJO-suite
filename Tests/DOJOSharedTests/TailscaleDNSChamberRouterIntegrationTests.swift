import XCTest
@testable import DOJOShared

private struct TailscaleIntegrationVerifier: ChamberRouteAdmissionVerifying {
    let acceptedReceiptID: String

    func permits(
        _ receipt: ChamberRouteAdmissionReceipt,
        chamberKey: String,
        correlationID: UUID
    ) async -> Bool {
        receipt.receiptID == acceptedReceiptID
            && receipt.chamberKey == chamberKey
            && receipt.correlationID == correlationID
    }
}

@MainActor
final class TailscaleDNSChamberRouterIntegrationTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func receipt(
        endpoint: String,
        correlationID: UUID,
        id: String = "tailscale-integration-001"
    ) -> ChamberRouteAdmissionReceipt {
        ChamberRouteAdmissionReceipt(
            receiptID: id,
            chamberKey: "arkadas",
            endpoint: endpoint,
            correlationID: correlationID,
            issuedAt: now.addingTimeInterval(-30),
            expiresAt: now.addingTimeInterval(30)
        )
    }

    private func attribute(
        observerContext: FieldNetworkContext,
        targetScope: FieldTargetScope,
        serviceBindContext: FieldServiceBindContext,
        dnsAuthority: FieldDNSAuthority,
        addressKind: FieldAddressKind,
        targetAddress: String,
        witnessID: String = "integration-witness"
    ) -> TailscaleDNSManagementAttribute {
        TailscaleDNSManagementAttribute(
            observerContext: observerContext,
            targetScope: targetScope,
            serviceBindContext: serviceBindContext,
            dnsAuthority: dnsAuthority,
            addressKind: addressKind,
            targetAddress: targetAddress,
            witnessID: witnessID,
            witnessedAt: now
        )
    }

    func testWitnessedLoopbackAttributeGatesExistingAdmission() async {
        let correlationID = UUID()
        let endpoint = "http://127.0.0.1:7170"
        let router = ChamberRouter(
            admissionVerifier: TailscaleIntegrationVerifier(acceptedReceiptID: "tailscale-integration-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.now }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(endpoint: endpoint, correlationID: correlationID),
            correlationID: correlationID,
            networkAttribute: attribute(
                observerContext: .hostLoopback,
                targetScope: .localHost,
                serviceBindContext: .hostLoopback,
                dnsAuthority: .hostResolver,
                addressKind: .loopback,
                targetAddress: endpoint
            )
        )

        XCTAssertTrue(admitted)
        XCTAssertTrue(router.isPreferredChamberLive(for: .arkadas))
    }

    func testWitnessedTailnetAttributeGatesExistingAdmission() async {
        let correlationID = UUID()
        let endpoint = "http://100.79.35.36:7170"
        let router = ChamberRouter(
            admissionVerifier: TailscaleIntegrationVerifier(acceptedReceiptID: "tailscale-integration-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.now }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(endpoint: endpoint, correlationID: correlationID),
            correlationID: correlationID,
            networkAttribute: attribute(
                observerContext: .tailnet,
                targetScope: .tailnetPeer,
                serviceBindContext: .tailnet,
                dnsAuthority: .tailscaleControlPlane,
                addressKind: .tailnetIPv4,
                targetAddress: endpoint
            )
        )

        XCTAssertTrue(admitted)
        XCTAssertTrue(router.isPreferredChamberLive(for: .arkadas))
    }

    func testRemoteLocalhostMismatchCannotReachExistingAdmission() async {
        let correlationID = UUID()
        let endpoint = "http://localhost:7170"
        let router = ChamberRouter(
            admissionVerifier: TailscaleIntegrationVerifier(acceptedReceiptID: "tailscale-integration-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.now }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(endpoint: endpoint, correlationID: correlationID),
            correlationID: correlationID,
            networkAttribute: attribute(
                observerContext: .tailnet,
                targetScope: .localHost,
                serviceBindContext: .hostLoopback,
                dnsAuthority: .hostResolver,
                addressKind: .loopback,
                targetAddress: endpoint
            )
        )

        XCTAssertFalse(admitted)
        XCTAssertFalse(router.isPreferredChamberLive(for: .arkadas))
    }

    func testPublicDNSCannotBePromotedAsChamberRoute() async {
        let correlationID = UUID()
        let endpoint = "https://example.com"
        let router = ChamberRouter(
            admissionVerifier: TailscaleIntegrationVerifier(acceptedReceiptID: "tailscale-integration-001"),
            replayLedger: InMemoryRouteAdmissionReplayLedger(),
            now: { self.now }
        )

        let admitted = await router.admitSpecializedRoute(
            for: .arkadas,
            receipt: receipt(endpoint: endpoint, correlationID: correlationID),
            correlationID: correlationID,
            networkAttribute: attribute(
                observerContext: .external,
                targetScope: .publicInternet,
                serviceBindContext: .external,
                dnsAuthority: .publicDNS,
                addressKind: .publicDNS,
                targetAddress: endpoint
            )
        )

        XCTAssertFalse(admitted)
        XCTAssertFalse(router.isPreferredChamberLive(for: .arkadas))
    }
}
