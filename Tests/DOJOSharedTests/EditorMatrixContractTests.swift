import XCTest
@testable import DOJOShared

final class EditorMatrixContractTests: XCTestCase {
    func testMatrixAxesRemainIndependent() {
        let selection = EditorMatrixSelection(
            inputChannel: .microphone,
            spatialRelation: .ambient,
            augmentationChannel: .touch,
            projectionArchetype: .somatic,
            attentionLevel: .supportive,
            authorityState: .preview
        )

        XCTAssertEqual(selection.inputChannel, .microphone)
        XCTAssertEqual(selection.spatialRelation, .ambient)
        XCTAssertEqual(selection.augmentationChannel, .touch)
        XCTAssertEqual(selection.projectionArchetype, .somatic)
        XCTAssertEqual(selection.attentionLevel, .supportive)
        XCTAssertEqual(selection.authorityState, .preview)
    }

    func testDefaultSelectionFailsClosed() {
        let selection = EditorMatrixSelection()

        XCTAssertEqual(selection.inputChannel, .none)
        XCTAssertEqual(selection.authorityState, .hold)
    }

    func testCurrentMatrixDimensionsRemainExplicit() {
        XCTAssertEqual(InputChannel.allCases.count, 9)
        XCTAssertEqual(SpatialRelation.allCases.count, 4)
        XCTAssertEqual(AugmentationChannel.allCases.count, 3)
        XCTAssertEqual(ProjectionArchetype.allCases.count, 5)
        XCTAssertEqual(AttentionLevel.allCases.count, 5)
    }
}
