import XCTest
@testable import DOJOShared

final class FieldManifestationCapabilityTests: XCTestCase {
    func testExternalMirrorsRemainDistinctWhileSharingSignalAndReceiverRole() {
        let mirrors = FieldManifestationCapabilityCatalog.entries.filter { $0.family == .externalMirror }

        XCTAssertEqual(Set(mirrors.map(\.surfaceID)), ["notion", "google_drive", "vercel", "canva"])
        XCTAssertTrue(mirrors.allSatisfy { $0.signalDirection == .signalAndReceiver })
        XCTAssertEqual(Set(mirrors.map(\.nativeResidence)).count, mirrors.count)
        XCTAssertTrue(FieldManifestationCapabilityCatalog.invariantViolations().isEmpty)
    }

    func testAkronRemainsExternalIntakeAndDoesNotBecomeInternalCirculation() throws {
        let akron = try XCTUnwrap(FieldManifestationCapabilityCatalog.entry(for: "akron"))

        XCTAssertEqual(akron.family, .externalIntake)
        XCTAssertEqual(akron.observerRelationship, .externalSourceBoundary)
        XCTAssertEqual(akron.authorityCeiling, "POINTER_ONLY")
        XCTAssertTrue(akron.heldFunctions.contains("direct external content into internal circulation"))
        XCTAssertNotEqual(akron.family, FieldManifestationCapabilityCatalog.entry(for: "obiwan")?.family)
    }

    func testDojoSuiteAndTodayHaveDifferentLiveExperienceEnvelopes() throws {
        let suite = try XCTUnwrap(FieldManifestationCapabilityCatalog.entry(for: "dojo_suite"))
        let today = try XCTUnwrap(FieldManifestationCapabilityCatalog.entry(for: "dojo_today"))

        XCTAssertEqual(suite.observerRelationship, .cohabitationalSovereignDigitalObserver)
        XCTAssertEqual(today.observerRelationship, .cohabitationalSovereignDigitalObserver)
        XCTAssertEqual(suite.liveExperience, .partial)
        XCTAssertEqual(today.liveExperience, .witnessedBounded)
        XCTAssertNotEqual(suite.nativeResidence, today.nativeResidence)
        XCTAssertTrue(suite.heldFunctions.contains("claim full live device sensing"))
        XCTAssertTrue(today.heldFunctions.contains("produce the full Today processing packet at runtime"))
    }

    func testUnknownDeviceFeedbackDoesNotAcquireCapability() throws {
        let breathing = try XCTUnwrap(FieldManifestationCapabilityCatalog.entry(for: "computer_breathing"))

        XCTAssertEqual(breathing.signalDirection, .unknown)
        XCTAssertEqual(breathing.liveExperience, .unknown)
        XCTAssertEqual(breathing.evidenceState, .unknown)
        XCTAssertEqual(breathing.authorityCeiling, "HOLD_UNKNOWN")
        XCTAssertTrue(breathing.availableFunctions.isEmpty)
    }

    func testCapabilityEntryCodableRoundTripPreservesBoundaries() throws {
        let entry = try XCTUnwrap(FieldManifestationCapabilityCatalog.entry(for: "dojo_today"))

        XCTAssertEqual(
            try JSONDecoder().decode(
                FieldManifestationCapabilityEntry.self,
                from: JSONEncoder().encode(entry)
            ),
            entry
        )
    }
}
