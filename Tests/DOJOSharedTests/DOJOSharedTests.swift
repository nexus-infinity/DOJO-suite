import XCTest
@testable import DOJOShared

// Stale tests — legacy DOJOShared class, AIService, TextInput, TextMessage, Communication, and
// DependencyInjector types were removed. DOJOShared is now a module name only (see commit 64929ed).
// Bodies replaced with XCTSkip; test names retained for history.
final class DOJOSharedTests: XCTestCase {

    func testDOJOSharedInitialization() throws {
        throw XCTSkip("Legacy DOJOShared class removed — module/class name collision resolved in 64929ed")
    }

    func testAIService() throws {
        throw XCTSkip("AIService, TextInput stub types removed")
    }

    @available(iOS 15.0, macOS 12.0, *)
    func testAIServiceAsync() async throws {
        throw XCTSkip("AIService async stub types removed")
    }

    func testCommunication() throws {
        throw XCTSkip("Communication, TextMessage stub types removed")
    }

    func testCommunicationEmptyQueue() throws {
        throw XCTSkip("Communication stub type removed")
    }

    func testDependencyInjector() throws {
        throw XCTSkip("DependencyInjector stub type removed")
    }

    func testDependencyInjectorTypeSafe() throws {
        throw XCTSkip("DependencyInjector stub type removed")
    }

    func testDependencyInjectorThreadSafety() throws {
        throw XCTSkip("DependencyInjector stub type removed")
    }
}
