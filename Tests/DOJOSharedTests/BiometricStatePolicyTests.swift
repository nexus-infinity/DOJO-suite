import XCTest
@testable import DOJOShared

final class BiometricStatePolicyTests: XCTestCase {
    func testMissingSamplesResolveUnknown() {
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: nil, heartRateVariabilityMS: nil),
            .unknown
        )
    }

    func testElevatedHeartRateWithLowHRVResolvesStress() {
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: 104, heartRateVariabilityMS: 28),
            .stress
        )
    }

    func testStableModerateSignalsResolveSteady() {
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: 72, heartRateVariabilityMS: 62),
            .steady
        )
    }

    func testModeratelyElevatedSignalsResolveDiscovery() {
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: 96, heartRateVariabilityMS: 42),
            .discovery
        )
    }

    func testAmbiguousSignalsDoNotEscalate() {
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: 120, heartRateVariabilityMS: 70),
            .unknown
        )
    }

    func testInvalidHeartRateResolvesUnknown() {
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: 0, heartRateVariabilityMS: 50),
            .unknown
        )
    }
}
