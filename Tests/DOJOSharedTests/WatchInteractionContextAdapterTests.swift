import XCTest
@testable import DOJOShared

final class WatchInteractionContextAdapterTests: XCTestCase {
    func testNilSamplesResolveUnknownBiometricOnWatch() {
        let context = WatchInteractionContextAdapter.make(
            heartRateBPM: nil,
            heartRateVariabilityMS: nil
        )

        XCTAssertEqual(context.activeDevice, .watch)
        XCTAssertEqual(context.inputMode, .unknown)
        XCTAssertNil(context.preferredOutputMode)
        XCTAssertEqual(context.environmentState, .unknown)
        XCTAssertEqual(context.biometricState, .unknown)
        XCTAssertEqual(
            context.resolvedOutputMode,
            OutputModePolicy.resolve(
                preferredOutputMode: nil,
                inputMode: .unknown,
                biometricState: .unknown,
                environmentState: .unknown
            )
        )
        XCTAssertEqual(
            context.biometricState,
            BiometricStatePolicy.normalize(heartRateBPM: nil, heartRateVariabilityMS: nil)
        )
    }

    func testInvalidHeartRateResolvesUnknown() {
        let context = WatchInteractionContextAdapter.make(
            heartRateBPM: 0,
            heartRateVariabilityMS: 50
        )
        XCTAssertEqual(context.biometricState, .unknown)
        XCTAssertEqual(context.activeDevice, .watch)
    }

    func testWatchSamplesMatchFactoryAndNormalize() {
        let samples: [(Double?, Double?)] = [
            (104, 28),
            (72, 62),
            (96, 42),
            (120, 70)
        ]

        for (heartRateBPM, heartRateVariabilityMS) in samples {
            let context = WatchInteractionContextAdapter.make(
                heartRateBPM: heartRateBPM,
                heartRateVariabilityMS: heartRateVariabilityMS
            )
            let factory = InteractionContextFactory.make(
                inputMode: .unknown,
                preferredOutputMode: nil,
                heartRateBPM: heartRateBPM,
                heartRateVariabilityMS: heartRateVariabilityMS,
                environmentState: .unknown,
                activeDevice: .watch
            )
            XCTAssertEqual(context, factory)
            XCTAssertEqual(
                context.biometricState,
                BiometricStatePolicy.normalize(
                    heartRateBPM: heartRateBPM,
                    heartRateVariabilityMS: heartRateVariabilityMS
                )
            )
        }
    }
}
