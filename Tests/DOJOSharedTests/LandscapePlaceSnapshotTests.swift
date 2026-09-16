import XCTest
@testable import DOJOShared

final class LandscapePlaceSnapshotTests: XCTestCase {
    func testV0HeldPinDoesNotClaimMapRuntimeOrCollapseCarPlay() {
        let pin = LandscapePlaceSnapshot.v0Held

        XCTAssertFalse(pin.placeKnown)
        XCTAssertFalse(pin.mapRuntime)
        XCTAssertFalse(pin.carPlayCollapsed)
        XCTAssertEqual(pin.hold, "HOLD.LandscapeMappingUnseated")
        XCTAssertEqual(pin.state, "HOLD.LandscapeMappingUnseated")
    }
}
