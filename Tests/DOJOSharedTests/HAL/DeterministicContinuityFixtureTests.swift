import XCTest
@testable import DOJOShared

final class DeterministicContinuityFixtureTests: XCTestCase {
    private let package = CapabilityShapedPackage(
        packageID: UUID(uuidString: "85200000-7410-7170-9630-000000000001")!,
        payloadSHA256: String(repeating: "c", count: 64),
        semanticIntent: "maintain the same focused object across surfaces",
        authorityScope: "local deterministic continuity fixture only",
        provenance: "deterministic-continuity-zero-loss-fixture-v0",
        returnRoute: "dojo://continuity-return"
    )

    private var attention: TodayAttentionContract {
        TodayAttentionContract(
            objectID: "field.object.continuity-001",
            phase: .sustain,
            topology: .central,
            depth: .init(
                executive: "same focused object",
                strategic: "continuity handoff pending",
                foundation: "immutable package retained"
            ),
            authorityCeiling: "local deterministic continuity fixture only",
            recoveryPointer: "return to the same focused object"
        )
    }

    private func surface(
        _ id: String,
        available: Bool = true,
        objectOriented: Bool = true,
        gstAligned: Bool = true,
        priority: Int,
        profile: HALProfile
    ) -> ContinuitySurfaceCandidate {
        ContinuitySurfaceCandidate(
            surfaceID: id,
            expression: DeviceCapabilityExpression(package: package, profile: profile),
            availableNow: available,
            objectOriented: objectOriented,
            gstAlignedToObserver: gstAligned,
            selectionPriority: priority
        )
    }

    private func receipt(
        source: String = "surface.mac",
        destination: String = "surface.tablet",
        confirmed: Bool = true,
        package: CapabilityShapedPackage? = nil,
        focusedObjectID: String = "field.object.continuity-001"
    ) -> ContinuityHandoffReceipt {
        ContinuityHandoffReceipt(
            receiptID: "continuity-receipt-001",
            package: package ?? self.package,
            sourceSurfaceID: source,
            receivingSurfaceID: destination,
            focusedObjectID: focusedObjectID,
            receivingSurfaceConfirmed: confirmed
        )
    }

    func testLossTransfersWithZeroLossAndReleasesSourceLast() throws {
        let fullProfile = HALProfile(
            sense: .full,
            process: .full,
            store: .full,
            relay: .full,
            act: .full
        )
        let initial = surface("surface.mac", priority: 100, profile: fullProfile)
        let lost = surface("surface.mac", available: false, priority: 100, profile: fullProfile)
        let receiving = surface("surface.tablet", priority: 80, profile: fullProfile)
        var fixture = try DeterministicContinuityFixture(
            package: package,
            requiredLayers: [1, 2, 3],
            activeSurface: initial,
            attention: attention
        )

        let selected = try fixture.exposeLossAndPrepareHandoff(
            sourceAfterLoss: lost,
            candidates: [receiving]
        )

        XCTAssertEqual(selected, "surface.tablet")
        XCTAssertEqual(fixture.activeSurfaceID, "surface.mac")
        XCTAssertFalse(fixture.releasedSurfaceIDs.contains("surface.mac"))
        XCTAssertNil(fixture.returnedReceipt)

        try fixture.confirmHandoff(with: receipt())

        XCTAssertEqual(fixture.activeSurfaceID, "surface.tablet")
        XCTAssertTrue(fixture.releasedSurfaceIDs.contains("surface.mac"))
        XCTAssertEqual(fixture.returnedReceipt?.packageID, package.packageID)
        XCTAssertEqual(
            fixture.trace,
            [
                .sourceCapabilityLossExposed(surfaceID: "surface.mac"),
                .arkadasSelectedQualifiedSurface(surfaceID: "surface.tablet"),
                .receivingSurfaceConfirmed(surfaceID: "surface.tablet"),
                .receiptReturned(receiptID: "continuity-receipt-001"),
                .dojoReacquiredFocusedObject(
                    objectID: "field.object.continuity-001",
                    surfaceID: "surface.tablet"
                ),
                .priorSurfaceReleased(surfaceID: "surface.mac"),
            ]
        )
    }

    func testArkadasSelectionIsDeterministicAndRejectsUnqualifiedSurfaces() throws {
        let full = HALProfile(sense: .full, process: .full, relay: .full, act: .full)
        let insufficient = HALProfile(sense: .full, process: .minimal, relay: .full, act: .full)
        let initial = surface("surface.mac", priority: 100, profile: full)
        let lost = surface("surface.mac", available: false, priority: 100, profile: full)
        let untyped = surface(
            "surface.display",
            objectOriented: false,
            priority: 1000,
            profile: full
        )
        let missingLayer = surface("surface.watch", priority: 900, profile: insufficient)
        let tieB = surface("surface.b", priority: 50, profile: full)
        let tieA = surface("surface.a", priority: 50, profile: full)
        var fixture = try DeterministicContinuityFixture(
            package: package,
            requiredLayers: [1, 2, 3],
            activeSurface: initial,
            attention: attention
        )

        let selected = try fixture.exposeLossAndPrepareHandoff(
            sourceAfterLoss: lost,
            candidates: [untyped, missingLayer, tieB, tieA]
        )

        XCTAssertEqual(selected, "surface.a")
    }

    func testNoQualifiedSurfaceHoldsWithoutReleasingSource() throws {
        let full = HALProfile(sense: .full, process: .full, relay: .full, act: .full)
        let insufficient = HALProfile(sense: .full, process: .minimal, relay: .full, act: .full)
        let initial = surface("surface.mac", priority: 100, profile: full)
        let lost = surface("surface.mac", available: false, priority: 100, profile: full)
        let watch = surface("surface.watch", priority: 80, profile: insufficient)
        var fixture = try DeterministicContinuityFixture(
            package: package,
            requiredLayers: [1, 2, 3],
            activeSurface: initial,
            attention: attention
        )

        XCTAssertThrowsError(
            try fixture.exposeLossAndPrepareHandoff(
                sourceAfterLoss: lost,
                candidates: [watch]
            )
        ) { error in
            XCTAssertEqual(error as? ContinuityFixtureError, .noQualifiedContinuitySurface)
        }
        XCTAssertEqual(fixture.activeSurfaceID, "surface.mac")
        XCTAssertTrue(fixture.releasedSurfaceIDs.isEmpty)
    }

    func testUnconfirmedOrIdentityDriftedReceiptCannotReleaseSource() throws {
        let full = HALProfile(sense: .full, process: .full, relay: .full, act: .full)
        let initial = surface("surface.mac", priority: 100, profile: full)
        let lost = surface("surface.mac", available: false, priority: 100, profile: full)
        let receiving = surface("surface.tablet", priority: 80, profile: full)
        var fixture = try DeterministicContinuityFixture(
            package: package,
            requiredLayers: [1, 2, 3],
            activeSurface: initial,
            attention: attention
        )
        try fixture.exposeLossAndPrepareHandoff(
            sourceAfterLoss: lost,
            candidates: [receiving]
        )

        XCTAssertThrowsError(try fixture.confirmHandoff(with: receipt(confirmed: false))) { error in
            XCTAssertEqual(error as? ContinuityFixtureError, .receivingSurfaceNotConfirmed)
        }

        let driftedPackage = CapabilityShapedPackage(
            packageID: UUID(),
            payloadSHA256: package.payloadSHA256,
            semanticIntent: package.semanticIntent,
            authorityScope: package.authorityScope,
            provenance: package.provenance,
            returnRoute: package.returnRoute
        )
        XCTAssertThrowsError(
            try fixture.confirmHandoff(with: receipt(package: driftedPackage))
        ) { error in
            XCTAssertEqual(error as? ContinuityFixtureError, .receiptIdentityMismatch)
        }

        XCTAssertEqual(fixture.activeSurfaceID, "surface.mac")
        XCTAssertTrue(fixture.releasedSurfaceIDs.isEmpty)
        XCTAssertNil(fixture.returnedReceipt)
    }

    func testDOJOCannotReacquireDifferentFocusedObject() throws {
        let full = HALProfile(sense: .full, process: .full, relay: .full, act: .full)
        let initial = surface("surface.mac", priority: 100, profile: full)
        let lost = surface("surface.mac", available: false, priority: 100, profile: full)
        let receiving = surface("surface.tablet", priority: 80, profile: full)
        var fixture = try DeterministicContinuityFixture(
            package: package,
            requiredLayers: [1, 2, 3],
            activeSurface: initial,
            attention: attention
        )
        try fixture.exposeLossAndPrepareHandoff(
            sourceAfterLoss: lost,
            candidates: [receiving]
        )

        XCTAssertThrowsError(
            try fixture.confirmHandoff(
                with: receipt(focusedObjectID: "field.object.different")
            )
        ) { error in
            XCTAssertEqual(error as? ContinuityFixtureError, .focusedObjectMismatch)
        }
        XCTAssertEqual(fixture.activeSurfaceID, "surface.mac")
        XCTAssertTrue(fixture.releasedSurfaceIDs.isEmpty)
    }

    func testAuthorityOrReturnLineageDriftCannotReleaseSource() throws {
        let full = HALProfile(sense: .full, process: .full, relay: .full, act: .full)
        let initial = surface("surface.mac", priority: 100, profile: full)
        let lost = surface("surface.mac", available: false, priority: 100, profile: full)
        let receiving = surface("surface.tablet", priority: 80, profile: full)
        var fixture = try DeterministicContinuityFixture(
            package: package,
            requiredLayers: [1, 2, 3],
            activeSurface: initial,
            attention: attention
        )
        try fixture.exposeLossAndPrepareHandoff(
            sourceAfterLoss: lost,
            candidates: [receiving]
        )

        let expandedAuthority = CapabilityShapedPackage(
            packageID: package.packageID,
            payloadSHA256: package.payloadSHA256,
            semanticIntent: package.semanticIntent,
            authorityScope: "external execution permitted",
            provenance: package.provenance,
            returnRoute: package.returnRoute
        )
        XCTAssertThrowsError(
            try fixture.confirmHandoff(with: receipt(package: expandedAuthority))
        ) { error in
            XCTAssertEqual(error as? ContinuityFixtureError, .receiptAuthorityMismatch)
        }

        let brokenReturn = CapabilityShapedPackage(
            packageID: package.packageID,
            payloadSHA256: package.payloadSHA256,
            semanticIntent: package.semanticIntent,
            authorityScope: package.authorityScope,
            provenance: package.provenance,
            returnRoute: "unknown://return"
        )
        XCTAssertThrowsError(
            try fixture.confirmHandoff(with: receipt(package: brokenReturn))
        ) { error in
            XCTAssertEqual(error as? ContinuityFixtureError, .receiptReturnLineageMismatch)
        }

        XCTAssertEqual(fixture.activeSurfaceID, "surface.mac")
        XCTAssertTrue(fixture.releasedSurfaceIDs.isEmpty)
        XCTAssertNil(fixture.returnedReceipt)
    }
}
