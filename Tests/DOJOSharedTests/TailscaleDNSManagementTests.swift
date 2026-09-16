import XCTest
@testable import DOJOShared

final class TailscaleDNSManagementTests: XCTestCase {
    private let witnessDate = Date(timeIntervalSince1970: 1_757_811_000)

    func testSameHostLoopbackSelectsLoopback() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .hostLoopback,
            targetScope: .localHost,
            serviceBindContext: .hostLoopback,
            dnsAuthority: .hostResolver,
            addressKind: .loopback,
            targetAddress: "http://127.0.0.1:7410",
            witnessID: "witness-loopback",
            witnessedAt: witnessDate
        )

        XCTAssertEqual(attribute.selectRoute().route, .hostLoopback)
        XCTAssertFalse(attribute.selectRoute().isHeld)
    }

    func testRemoteTailnetSelectsTailnet() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .tailnet,
            targetScope: .tailnetPeer,
            serviceBindContext: .tailnet,
            dnsAuthority: .tailscaleControlPlane,
            addressKind: .magicDNS,
            targetAddress: "http://mac-studio.tail504c30.ts.net:7410",
            witnessID: "witness-tailnet",
            witnessedAt: witnessDate
        )

        XCTAssertEqual(attribute.selectRoute().route, .tailnet)
    }

    func testPublicTargetSelectsExternal() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .external,
            targetScope: .publicInternet,
            serviceBindContext: .external,
            dnsAuthority: .publicDNS,
            addressKind: .publicDNS,
            targetAddress: "https://example.com",
            witnessID: "witness-public",
            witnessedAt: witnessDate
        )

        XCTAssertEqual(attribute.selectRoute().route, .external)
    }

    func testRemoteObserverCannotUseLocalHostRoute() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .tailnet,
            targetScope: .localHost,
            serviceBindContext: .hostLoopback,
            dnsAuthority: .hostResolver,
            addressKind: .loopback,
            targetAddress: "http://localhost:7410",
            witnessID: "witness-mismatch",
            witnessedAt: witnessDate
        )

        let decision = attribute.selectRoute()
        XCTAssertEqual(decision.route, .hold)
        XCTAssertTrue(decision.reason.contains("loopback"))
    }

    func testSameHostCannotPreferTailnetAddressForLoopbackService() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .hostLoopback,
            targetScope: .tailnetPeer,
            serviceBindContext: .hostLoopback,
            dnsAuthority: .tailscaleControlPlane,
            addressKind: .tailnetIPv4,
            targetAddress: "http://100.79.35.36:7410",
            witnessID: "witness-bind-mismatch",
            witnessedAt: witnessDate
        )

        XCTAssertEqual(attribute.selectRoute().route, .hold)
    }

    func testMagicDNSCannotBeClaimedAsPublicDNS() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .external,
            targetScope: .publicInternet,
            serviceBindContext: .external,
            dnsAuthority: .publicDNS,
            addressKind: .magicDNS,
            targetAddress: "https://mac-studio.tail504c30.ts.net",
            witnessID: "witness-authority-mismatch",
            witnessedAt: witnessDate
        )

        XCTAssertEqual(attribute.selectRoute().route, .hold)
    }

    func testMissingWitnessHolds() {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .tailnet,
            targetScope: .tailnetPeer,
            serviceBindContext: .tailnet,
            dnsAuthority: .tailscaleControlPlane,
            addressKind: .tailnetIPv4,
            targetAddress: "http://100.79.35.36:7410"
        )

        XCTAssertEqual(attribute.selectRoute().route, .hold)
        XCTAssertTrue(attribute.selectRoute().reason.contains("witness"))
    }

    func testAttributeRoundTripsThroughCodable() throws {
        let attribute = TailscaleDNSManagementAttribute(
            observerContext: .tailnet,
            targetScope: .tailnetPeer,
            serviceBindContext: .tailnet,
            dnsAuthority: .tailscaleControlPlane,
            addressKind: .tailnetIPv4,
            targetAddress: "http://100.79.35.36:7410",
            witnessID: "witness-codable",
            witnessedAt: witnessDate
        )
        let data = try JSONEncoder().encode(attribute)
        let decoded = try JSONDecoder().decode(TailscaleDNSManagementAttribute.self, from: data)

        XCTAssertEqual(decoded, attribute)
        XCTAssertEqual(decoded.selectRoute().route, .tailnet)
    }
}
