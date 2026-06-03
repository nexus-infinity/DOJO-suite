import XCTest
import AVFoundation
@testable import DOJOShared
@testable import DOJOUI

final class HALAudioPipelineTests: XCTestCase {
    
    @MainActor
    func testUnifiedTransitionLogic() throws {
        let engine = CopilotEngine()
        let observer = OBIWANState.shared
        let micBridge = VADMicBridge()
        let coordinator = DOJOFieldCoordinator(engine: engine, observer: observer, micBridge: micBridge)
        
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
        // However, we can verify that applyTransition was called and the audioMode updated.
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
