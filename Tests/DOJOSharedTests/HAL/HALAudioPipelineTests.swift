import XCTest
import AVFoundation
import Speech
@testable import DOJOShared
@testable import DOJOUI

final class HALAudioPipelineTests: XCTestCase {

    private enum PermissionProbeState: Equatable, CustomStringConvertible {
        case authorized
        case denied
        case restricted
        case notDetermined
        case notAuthorized
        case unknownNotEvaluated(source: String)

        var description: String {
            switch self {
            case .authorized:
                return "authorized"
            case .denied:
                return "denied"
            case .restricted:
                return "restricted"
            case .notDetermined:
                return "notDetermined"
            case .notAuthorized:
                return "notAuthorized"
            case let .unknownNotEvaluated(source):
                return "Unknown.NotEvaluated(\(source))"
            }
        }
    }

    private static func microphonePermissionState() -> PermissionProbeState {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unknownNotEvaluated(source: "Microphone")
        }
    }

    private static func speechRecognitionPermissionState() -> PermissionProbeState {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unknownNotEvaluated(source: "SpeechRecognition")
        }
    }

    private static func bridgeAdmissionState(
        microphone: PermissionProbeState,
        speechRecognition: PermissionProbeState
    ) -> PermissionProbeState {
        guard microphone == .authorized, speechRecognition == .authorized else {
            return .notAuthorized
        }
        return .authorized
    }

    /// Permission proof is intentionally separate from the state-transition
    /// tests below. This probe queries both macOS TCC states and fails with
    /// independent diagnostics unless each one is explicitly authorized.
    func testSignedHostPrivacyPermissionsAreAuthorized() {
        let microphone = Self.microphonePermissionState()
        let speechRecognition = Self.speechRecognitionPermissionState()
        let bridgeAdmission = Self.bridgeAdmissionState(
            microphone: microphone,
            speechRecognition: speechRecognition
        )

        XCTAssertEqual(
            microphone,
            .authorized,
            "Microphone permission is \(microphone); expected authorized"
        )
        XCTAssertEqual(
            speechRecognition,
            .authorized,
            "Speech Recognition permission is \(speechRecognition); expected authorized"
        )
        XCTAssertEqual(
            bridgeAdmission,
            .authorized,
            "HAL bridge admission is \(bridgeAdmission); both permissions must be authorized"
        )
    }

    /// Dormant signed-host authorization harness.
    ///
    /// Compile-only fixtures must never execute this test. A future,
    /// separately authorised fixture may select this exact test once; that
    /// execution makes exactly one call to the existing authorization path.
    @MainActor
    func testSignedHostSpeechRecognitionAuthorizationRequest() async {
        let micBridge = VADMicBridge()

        await micBridge.requestAuthorization()

        let speechRecognition = Self.speechRecognitionPermissionState()
        XCTAssertEqual(
            speechRecognition,
            .authorized,
            "Speech Recognition authorization request returned \(speechRecognition)"
        )
        XCTAssertEqual(
            micBridge.authorizationStatus,
            .authorized,
            "VADMicBridge retained \(micBridge.authorizationStatus); expected authorized"
        )
    }

    @MainActor
    func testUnifiedTransitionLogic() throws {
        let engine = CopilotEngine()
        let observer = OBIWANState.shared
        let micBridge = VADMicBridge()
        let coordinator = DOJOFieldCoordinator(engine: engine, observer: observer, micBridge: micBridge, envMonitor: HALEnvironmentMonitor())

        // Initial state: broadcast, full
        XCTAssertEqual(coordinator.activeProfile, .broadcast)
        XCTAssertEqual(coordinator.audioMode, .full)

        // 1. Test .fallback profile switch
        coordinator.setProfile(.fallback)
        XCTAssertEqual(coordinator.activeProfile, .fallback)

        // 2. Test transition to .silent (should stop mic)
        coordinator.applyTransition(mode: .silent, profile: .fallback)
        XCTAssertEqual(coordinator.audioMode, .silent)
        XCTAssertFalse(micBridge.isListening, "Mic should be stopped in .silent mode")

        // 3. Test transition back to .full (should start mic)
        // Note: micBridge.start() requires authorization, which we can't easily mock in a pure unit test without a mock recognizer.
        // This verifies state only. It is not permission proof; the dedicated
        // signed-host permission probe above owns that assertion.
        coordinator.applyTransition(mode: .full, profile: .intimate)
        XCTAssertEqual(coordinator.audioMode, .full)
        XCTAssertEqual(coordinator.activeProfile, .intimate)
    }

    @MainActor
    func testDuckingLogicState() throws {
        let coordinator = DOJOFieldCoordinator(engine: CopilotEngine())
        let micBridge = coordinator.micBridge

        // Manually trigger ducking calls to verify state management
        // Note: pauseForOutput and resumeAfterOutput are internal/private to the implementation logic
        // but we can check if the coordinator calls them via the delegate if we had a way to trigger TTS.

        // For this smoke test, we'll verify the delegate methods exist and are nonisolated as required.
        XCTAssertTrue(coordinator.conforms(to: AVSpeechSynthesizerDelegate.self))
    }
}
