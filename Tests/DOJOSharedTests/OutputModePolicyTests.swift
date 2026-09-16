import XCTest
@testable import DOJOShared

final class OutputModePolicyTests: XCTestCase {
    func testPreferredOutputModeWinsWhenLawful() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: .voice,
            inputMode: .text,
            biometricState: .steady,
            environmentState: EnvironmentState(noiseLevel: 0.2, isPublic: false)
        )

        XCTAssertEqual(resolved, .voice)
    }

    func testExplicitNonVoicePreferenceWinsEvenInFocusedState() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: .text,
            inputMode: .voice,
            biometricState: .deepWork,
            environmentState: .unknown
        )

        XCTAssertEqual(resolved, .text)
    }

    func testDeepWorkResolvesSilentWithoutPreference() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: nil,
            inputMode: .voice,
            biometricState: .deepWork,
            environmentState: .unknown
        )

        XCTAssertEqual(resolved, .silent)
    }

    func testDeepWorkRemainsSilentInPublicNoisyEnvironmentWithoutPreference() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: nil,
            inputMode: .voice,
            biometricState: .deepWork,
            environmentState: EnvironmentState(noiseLevel: 0.95, isPublic: true)
        )

        XCTAssertEqual(resolved, .silent)
    }

    func testStressResolvesHapticWithoutPreference() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: nil,
            inputMode: .text,
            biometricState: .stress,
            environmentState: .unknown
        )

        XCTAssertEqual(resolved, .haptic)
    }

    func testPublicEnvironmentAvoidsVoiceWhenPreferenceIsVoice() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: .voice,
            inputMode: .voice,
            biometricState: .steady,
            environmentState: EnvironmentState(noiseLevel: 0.1, isPublic: true)
        )

        XCTAssertNotEqual(resolved, .voice)
        XCTAssertEqual(resolved, .haptic)
    }

    func testNoisyEnvironmentAvoidsVoiceWhenPreferenceIsVoice() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: .voice,
            inputMode: .voice,
            biometricState: .steady,
            environmentState: EnvironmentState(noiseLevel: 0.9, isPublic: false)
        )

        XCTAssertNotEqual(resolved, .voice)
        XCTAssertEqual(resolved, .visual)
    }

    func testVoiceOutputIsNotLawfulInPublicOrNoisyEnvironment() {
        XCTAssertFalse(
            OutputModePolicy.isLawful(
                .voice,
                environmentState: EnvironmentState(noiseLevel: 0.1, isPublic: true)
            )
        )
        XCTAssertFalse(
            OutputModePolicy.isLawful(
                .voice,
                environmentState: EnvironmentState(noiseLevel: 0.9, isPublic: false)
            )
        )
    }

    func testVoiceInputDoesNotForceVoiceOutput() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: nil,
            inputMode: .voice,
            biometricState: .steady,
            environmentState: .unknown
        )

        XCTAssertEqual(resolved, .visual)
    }

    func testUnknownStatesResolveConservativelyToVisual() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: nil,
            inputMode: .unknown,
            biometricState: .unknown,
            environmentState: .unknown
        )

        XCTAssertEqual(resolved, .visual)
    }

    func testNilPreferenceWithGestureInputResolvesNonDisruptiveHaptic() {
        let resolved = OutputModePolicy.resolve(
            preferredOutputMode: nil,
            inputMode: .gesture,
            biometricState: .unknown,
            environmentState: .unknown
        )

        XCTAssertEqual(resolved, .haptic)
    }
}
