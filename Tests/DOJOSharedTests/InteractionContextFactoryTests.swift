import XCTest
@testable import DOJOShared

final class InteractionContextFactoryTests: XCTestCase {
    func testFactoryBiometricStateMatchesExistingNormalizeCases() {
        let samples: [(Double?, Double?)] = [
            (nil, nil),
            (104, 28),
            (72, 62),
            (96, 42),
            (120, 70),
            (0, 50)
        ]

        for (heartRateBPM, heartRateVariabilityMS) in samples {
            let expected = BiometricStatePolicy.normalize(
                heartRateBPM: heartRateBPM,
                heartRateVariabilityMS: heartRateVariabilityMS
            )
            let context = InteractionContextFactory.make(
                inputMode: .text,
                heartRateBPM: heartRateBPM,
                heartRateVariabilityMS: heartRateVariabilityMS,
                environmentState: .unknown,
                activeDevice: .unknown
            )
            XCTAssertEqual(
                context.biometricState,
                expected,
                "HR \(String(describing: heartRateBPM)) HRV \(String(describing: heartRateVariabilityMS))"
            )
        }
    }

    func testNilAndUnknownHeartRateResolveBiometricUnknown() {
        let nilSamples = InteractionContextFactory.make(
            inputMode: .text,
            heartRateBPM: nil,
            heartRateVariabilityMS: nil,
            environmentState: .unknown,
            activeDevice: .mac
        )
        XCTAssertEqual(nilSamples.biometricState, .unknown)

        let invalidRate = InteractionContextFactory.make(
            inputMode: .text,
            heartRateBPM: 0,
            heartRateVariabilityMS: 50,
            environmentState: .unknown,
            activeDevice: .mac
        )
        XCTAssertEqual(invalidRate.biometricState, .unknown)
        XCTAssertEqual(
            BiometricStatePolicy.normalize(heartRateBPM: 0, heartRateVariabilityMS: 50),
            .unknown
        )
    }

    func testFactoryResolvedOutputMatchesExistingPolicyForSameInputs() {
        let cases: [(
            preferred: OutputMode?,
            input: InputMode,
            heartRateBPM: Double?,
            heartRateVariabilityMS: Double?,
            environment: EnvironmentState
        )] = [
            (.voice, .text, 72, 62, EnvironmentState(noiseLevel: 0.2, isPublic: false)),
            (.text, .voice, nil, nil, .unknown),
            (nil, .voice, nil, nil, .unknown),
            (nil, .text, 104, 28, .unknown),
            (.voice, .voice, 72, 62, EnvironmentState(noiseLevel: 0.1, isPublic: true)),
            (.voice, .voice, 72, 62, EnvironmentState(noiseLevel: 0.9, isPublic: false)),
            (nil, .voice, 72, 62, .unknown),
            (nil, .unknown, nil, nil, .unknown),
            (nil, .gesture, nil, nil, .unknown)
        ]

        for item in cases {
            let biometricState = BiometricStatePolicy.normalize(
                heartRateBPM: item.heartRateBPM,
                heartRateVariabilityMS: item.heartRateVariabilityMS
            )
            let expectedOutput = OutputModePolicy.resolve(
                preferredOutputMode: item.preferred,
                inputMode: item.input,
                biometricState: biometricState,
                environmentState: item.environment
            )
            let context = InteractionContextFactory.make(
                inputMode: item.input,
                preferredOutputMode: item.preferred,
                heartRateBPM: item.heartRateBPM,
                heartRateVariabilityMS: item.heartRateVariabilityMS,
                environmentState: item.environment,
                activeDevice: .iPhone
            )

            XCTAssertEqual(context.inputMode, item.input)
            XCTAssertEqual(context.preferredOutputMode, item.preferred)
            XCTAssertEqual(context.environmentState, item.environment)
            XCTAssertEqual(context.activeDevice, .iPhone)
            XCTAssertEqual(context.biometricState, biometricState)
            XCTAssertEqual(context.resolvedOutputMode, expectedOutput)
        }
    }

    func testTodayShapedCallKeepsUnknownBiometricsAndMacPresence() {
        let context = InteractionContextFactory.make(
            inputMode: .text,
            preferredOutputMode: nil,
            heartRateBPM: nil,
            heartRateVariabilityMS: nil,
            environmentState: .unknown,
            activeDevice: .mac
        )

        XCTAssertEqual(context.inputMode, .text)
        XCTAssertNil(context.preferredOutputMode)
        XCTAssertEqual(context.biometricState, .unknown)
        XCTAssertEqual(context.environmentState, .unknown)
        XCTAssertEqual(context.activeDevice, .mac)
        XCTAssertEqual(
            context.resolvedOutputMode,
            OutputModePolicy.resolve(
                preferredOutputMode: nil,
                inputMode: .text,
                biometricState: .unknown,
                environmentState: .unknown
            )
        )
    }

    func testFactoryDoesNotInventDeepWorkFromHeartRate() {
        let context = InteractionContextFactory.make(
            inputMode: .voice,
            preferredOutputMode: nil,
            heartRateBPM: 72,
            heartRateVariabilityMS: 62,
            environmentState: .unknown,
            activeDevice: .watch
        )
        XCTAssertNotEqual(context.biometricState, .deepWork)
        XCTAssertEqual(
            context.biometricState,
            BiometricStatePolicy.normalize(heartRateBPM: 72, heartRateVariabilityMS: 62)
        )
    }
}
