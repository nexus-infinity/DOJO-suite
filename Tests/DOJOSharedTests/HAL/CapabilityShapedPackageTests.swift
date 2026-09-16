import XCTest
@testable import DOJOShared

final class CapabilityShapedPackageTests: XCTestCase {
    private let package = CapabilityShapedPackage(
        packageID: UUID(uuidString: "85200000-7410-4320-9630-000000000001")!,
        payloadSHA256: String(repeating: "a", count: 64),
        semanticIntent: "render the same bounded instruction",
        authorityScope: "local deterministic expression only",
        provenance: "same-package-two-device-specimen-v0",
        returnRoute: "dojo://specimen-return"
    )

    func testSamePackageProducesCoherentDifferentPhenotypes() {
        let baseDevice = HALProfile(
            sense: .minimal,
            process: .minimal,
            store: .none,
            relay: .minimal,
            act: .minimal
        )
        let expandedDevice = HALProfile(
            sense: .full,
            process: .full,
            store: .full,
            relay: .full,
            act: .full
        )

        let baseExpression = DeviceCapabilityExpression(package: package, profile: baseDevice)
        let expandedExpression = DeviceCapabilityExpression(package: package, profile: expandedDevice)

        XCTAssertEqual(baseExpression.package, expandedExpression.package)
        XCTAssertEqual(baseExpression.layers.map(\.availability), [.available, .unavailable, .available])
        XCTAssertEqual(expandedExpression.layers.map(\.availability), [.available, .available, .available])
        XCTAssertEqual(
            CapabilityCoherenceEvaluator.compare(baseExpression, expandedExpression),
            .coherentDifferentPhenotypes
        )
    }

    func testEveryLayerRemainsRepresentedWhenCapabilityIsUnavailable() {
        let minimalDevice = HALProfile(relay: .minimal)
        let expression = DeviceCapabilityExpression(package: package, profile: minimalDevice)

        XCTAssertEqual(expression.layers.map(\.layer), [1, 2, 3])
        XCTAssertEqual(expression.layers.map(\.availability), [.unavailable, .unavailable, .unavailable])
    }

    func testAuthorityExpansionHolds() {
        let profile = HALProfile(sense: .minimal, act: .minimal)
        let first = DeviceCapabilityExpression(package: package, profile: profile)
        let expandedAuthority = CapabilityShapedPackage(
            packageID: package.packageID,
            payloadSHA256: package.payloadSHA256,
            semanticIntent: package.semanticIntent,
            authorityScope: "external execution permitted",
            provenance: package.provenance,
            returnRoute: package.returnRoute
        )
        let second = DeviceCapabilityExpression(package: expandedAuthority, profile: .init(process: .full))

        XCTAssertEqual(CapabilityCoherenceEvaluator.compare(first, second), .holdAuthorityExpansion)
    }

    func testBrokenReturnLineageHolds() {
        let profile = HALProfile(sense: .minimal, act: .minimal)
        let first = DeviceCapabilityExpression(package: package, profile: profile)
        let brokenReturn = CapabilityShapedPackage(
            packageID: package.packageID,
            payloadSHA256: package.payloadSHA256,
            semanticIntent: package.semanticIntent,
            authorityScope: package.authorityScope,
            provenance: package.provenance,
            returnRoute: "unknown://return"
        )
        let second = DeviceCapabilityExpression(package: brokenReturn, profile: .init(process: .full))

        XCTAssertEqual(CapabilityCoherenceEvaluator.compare(first, second), .holdReturnLineageBroken)
    }
}
