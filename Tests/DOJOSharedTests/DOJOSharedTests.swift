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
        let input = TextInput(data: "test input")
        let result = aiService.runModel(input: input)
        
        // Verify result is returned
        XCTAssertFalse(result.output.isEmpty)
        XCTAssertTrue(result.output.contains("test input"))
        XCTAssertGreaterThan(result.confidence, 0.0)
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    func testAIServiceAsync() async {
        let aiService = AIService()
        let input = TextInput(data: "async test")
        let result = await aiService.runModelAsync(input: input)
        
        // Verify async result is returned
        XCTAssertFalse(result.output.isEmpty)
        XCTAssertTrue(result.output.contains("async test"))
        XCTAssertGreaterThan(result.confidence, 0.0)
    }
    
    func testCommunication() {
        // Test message sending and receiving
        let message = TextMessage(payload: "test message")
        Communication.sendMessage(to: "TestModule", message: message)
        
        let received = Communication.receiveMessage(from: "TestModule")
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first?.payload, "test message")
    }
    
    func testCommunicationEmptyQueue() {
        // Test receiving when no messages are available
        let received = Communication.receiveMessage(from: "EmptyModule")
        XCTAssertEqual(received.count, 0)
    }
    
    func testDependencyInjector() {
        let testService = "TestService"
        DependencyInjector.registerService(name: "test", service: testService)
        
        let retrieved = DependencyInjector.getService(name: "test") as? String
        XCTAssertEqual(retrieved, testService)
    }
    
    func testDependencyInjectorTypeSafe() {
        // Test type-safe API
        let testService = AIService()
        DependencyInjector.register(AIService.self, service: testService)
        
        let retrieved = DependencyInjector.get(AIService.self)
        XCTAssertNotNil(retrieved)
    }
    
    func testDependencyInjectorThreadSafety() {
        // Test concurrent access
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                DependencyInjector.registerService(name: "service\(i)", service: "value\(i)")
                let _ = DependencyInjector.getService(name: "service\(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
