import XCTest
@testable import DOJOShared

final class PyramidAtRestMapSnapshotTests: XCTestCase {
    func testPyramidAtRestMapV0KeepsDynamicTestInactiveAndAuthorityUnchanged() {
        let snapshot = PyramidAtRestMapSnapshot.v0

        XCTAssertFalse(snapshot.isDynamicTestActive)
        XCTAssertEqual(snapshot.authorityMutation, .none)
    }
}
