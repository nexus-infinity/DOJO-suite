import XCTest
@testable import DOJOShared

final class DOJOSharedTests: XCTestCase {
    
    func testDOJOSharedInitialization() {
        let shared = DOJOShared()
        shared.initialize()
        XCTAssertEqual(DOJOShared.version, "1.0.0")
    }
    
    func testAIService() {
        let aiService = AIService()
        // Test that running model doesn't crash
        aiService.runModel(input: "test input")
    }
    
    func testCommunication() {
        // Test that sending/receiving messages doesn't crash
        Communication.sendMessage(to: "TestModule", message: "test")
        Communication.receiveMessage(from: "TestModule")
    }
    
    func testDependencyInjector() {
        let testService = "TestService"
        DependencyInjector.registerService(name: "test", service: testService)
        
        let retrieved = DependencyInjector.getService(name: "test") as? String
        XCTAssertEqual(retrieved, testService)
    }
}
