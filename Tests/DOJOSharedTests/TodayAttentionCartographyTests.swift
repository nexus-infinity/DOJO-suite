import XCTest
@testable import DOJOShared

final class TodayAttentionCartographyTests: XCTestCase {
    func testCompleteProjectionCarriesAllDepthsAndRecovery() {
        let contract = TodayAttentionContract(
            objectID: "today.ready",
            phase: .orient,
            topology: .horizon,
            depth: .init(
                executive: "composer available",
                strategic: "ready state mapped",
                foundation: "no object selected"
            ),
            authorityCeiling: "presentation only",
            recoveryPointer: "return to composer"
        )

        XCTAssertTrue(contract.isProjectionComplete)
        XCTAssertTrue(contract.hasLawfulMotionPosture)
    }

    func testPartialDepthColumnFailsClosed() {
        let contract = TodayAttentionContract(
            objectID: "today.partial",
            phase: .engage,
            topology: .contextual,
            depth: .init(
                executive: "show object",
                strategic: "",
                foundation: "preserve source"
            ),
            authorityCeiling: "proposal only",
            recoveryPointer: "return to prior work"
        )

        XCTAssertFalse(contract.isProjectionComplete)
    }

    func testRepeatedMotionRequiresCentralTimeCriticalTopology() {
        let peripheral = TodayAttentionContract(
            objectID: "today.notice",
            phase: .sustain,
            topology: .peripheral,
            motion: .repeatedTimeCritical,
            depth: .init(executive: "cue", strategic: "defer", foundation: "witness"),
            authorityCeiling: "attention only",
            recoveryPointer: "remain on active object"
        )
        let central = TodayAttentionContract(
            objectID: "today.critical",
            phase: .engage,
            topology: .central,
            motion: .repeatedTimeCritical,
            depth: .init(executive: "interrupt", strategic: "critical", foundation: "witness"),
            authorityCeiling: "explicit time-critical presentation",
            recoveryPointer: "restore displaced object"
        )

        XCTAssertFalse(peripheral.hasLawfulMotionPosture)
        XCTAssertTrue(central.hasLawfulMotionPosture)
    }
}
