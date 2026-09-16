import XCTest
@testable import DOJOShared

final class SpinningTopClientTests: XCTestCase {
    func testChatResponseMarksExplicitlyUnavailableInferenceAsHold() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "response": "transport reached",
            "model": "gemma3:latest",
            "status": "degraded",
            "inference_available": false
        ])

        let response = try JSONDecoder().decode(SpinningTopClient.ChatResponse.self, from: data)

        XCTAssertFalse(response.inferenceAvailable)
        XCTAssertEqual(response.model_used, "gemma3:latest")
    }

    func testChatResponseUsesResponseCompatibilityFallbackWhenAvailabilityIsOmitted() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "response": "inference result",
            "model": "gemma3:latest"
        ])

        let response = try JSONDecoder().decode(SpinningTopClient.ChatResponse.self, from: data)

        XCTAssertTrue(response.inferenceAvailable)
    }

    func testChatResponseRecognisesLegacyInferenceUnavailableMarker() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "response": "[DOJO 7410 ✓ — inference unavailable] model is not ready"
        ])

        let response = try JSONDecoder().decode(SpinningTopClient.ChatResponse.self, from: data)

        XCTAssertFalse(response.inferenceAvailable)
    }
}
