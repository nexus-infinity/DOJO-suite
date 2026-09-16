import XCTest
@testable import DOJOShared

final class TodayAttentionProductConstraintsTests: XCTestCase {
    func testDecorativeMotionForbidden() {
        XCTAssertFalse(TodayAttentionProductConstraints.isDecorativeMotionAllowed())
        XCTAssertTrue(TodayAttentionProductConstraints.stillnessByDefault)
    }

    func testLawfulMotionReasons() {
        XCTAssertTrue(TodayAttentionProductConstraints.isMotionLawful(.send))
        XCTAssertTrue(TodayAttentionProductConstraints.isMotionLawful(.loading))
        XCTAssertTrue(TodayAttentionProductConstraints.isMotionLawful(.result))
        XCTAssertTrue(TodayAttentionProductConstraints.isMotionLawful(.error))
        XCTAssertTrue(TodayAttentionProductConstraints.isMotionLawful(.boundaryPanelTransition))
        XCTAssertTrue(TodayAttentionProductConstraints.isMotionLawful(.explicitTimeCritical))
    }

    func testRightPanelOpenOnlyAtBoundaries() {
        XCTAssertTrue(TodayAttentionProductConstraints.isRightPanelOpenLawful(.objectSelected))
        XCTAssertTrue(TodayAttentionProductConstraints.isRightPanelOpenLawful(.resultGenerated))
        XCTAssertTrue(TodayAttentionProductConstraints.isRightPanelOpenLawful(.explicitReviewOrDetails))
        XCTAssertTrue(TodayAttentionProductConstraints.isRightPanelOpenLawful(.userManualToggle))
    }

    func testAnswerRecoveryCueIsMinimallyComplete() {
        let cue = ObjectRecoveryCue.forAnswer(
            title: "Answer · hello",
            sourcePrompt: "hello",
            providerDisplayName: "OpenAI",
            modelID: "gpt-4o-mini"
        )
        XCTAssertTrue(cue.isMinimallyComplete)
        XCTAssertEqual(cue.lastStablePoint, "answer_received")
        XCTAssertEqual(cue.changedWhileAway, "none")
        XCTAssertTrue(cue.nextAvailableAction.contains("Save"))
        XCTAssertEqual(cue.providerModel, "OpenAI · gpt-4o-mini")
    }
}
