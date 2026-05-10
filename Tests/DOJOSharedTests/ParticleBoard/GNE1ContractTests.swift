import XCTest
@testable import DOJOShared
@testable import DOJOUI

final class GNE1ContractTests: XCTestCase {

    @MainActor
    func testForecastDoesNotMutateCommittedState() throws {
        let controller = ParticleBoardController()
        controller.load(DocumentPlan(title: "Test", sections: [], policyPins: []))

        let initialDoc = controller.committedDraft
        let initialImg = controller.committedImageDraft
        let initialState = controller.committedState

        controller.proposeEdit(row: 0, col: 0, payload: .route(intent: "Intent", action: "Draft"))

        XCTAssertEqual(controller.committedState, initialState, "Committed state MUST NOT mutate when a forecast is generated.")
        XCTAssertEqual(controller.committedDraft, initialDoc, "Committed DocumentDraft MUST NOT mutate when a forecast is generated.")
        XCTAssertEqual(controller.committedImageDraft, initialImg, "Committed ImageDraft MUST NOT mutate when a forecast is generated.")

        let forecast = try XCTUnwrap(controller.pendingForecast)
        XCTAssertNotEqual(forecast.proposedState, initialState, "Forecast must produce a distinct proposed state.")
    }

    @MainActor
    func testAcceptBlockedWhenValidationHold() throws {
        let controller = ParticleBoardController()
        controller.load(DocumentPlan(title: "Test", sections: [], policyPins: []))

        controller.proposeEdit(row: 0, col: 0, payload: .route(intent: "Intent", action: "Draft"))

        XCTAssertThrowsError(try controller.acceptForecast()) { error in
            guard let boardErr = error as? ParticleBoardError,
                  case .acceptBlockedByPolicy(let reasons) = boardErr else {
                XCTFail("Expected acceptBlockedByPolicy error")
                return
            }
            let holdAddress = GridAddress(row: 2, col: 2)!
            XCTAssertTrue(reasons.contains { $0.address == holdAddress }, "Must contain HOLD reason addressed specifically to [2,2]")
        }

        let current00 = controller.committedState?.cell(at: GridAddress(row: 0, col: 0)!)
        XCTAssertEqual(current00?.payload, .empty, "State must remain unchanged after a blocked accept")

        controller.proposeEdit(row: 2, col: 2, payload: .route(intent: "Policy", action: "Publish"))

        XCTAssertNoThrow(try controller.acceptForecast())

        let new22 = controller.committedState?.cell(at: GridAddress(row: 2, col: 2)!)
        XCTAssertEqual(new22?.payload, .route(intent: "Policy", action: "Publish"), "State must mutate after a successful accept")
    }

    @MainActor
    func testRejectForecastClearsPendingState() {
        let controller = ParticleBoardController()
        controller.load(DocumentPlan(title: "Test", sections: [], policyPins: []))

        controller.proposeEdit(row: 1, col: 1, payload: .route(intent: "Structure", action: "Validate"))
        XCTAssertNotNil(controller.pendingForecast, "Forecast must be set after proposeEdit.")

        controller.rejectForecast()
        XCTAssertNil(controller.pendingForecast, "pendingForecast must be nil after rejectForecast — UI forecast panel must disappear.")
    }

    @MainActor
    func testNoPendingForecastThrowsOnAccept() {
        let controller = ParticleBoardController()
        controller.load(DocumentPlan(title: "Test", sections: [], policyPins: []))

        XCTAssertThrowsError(try controller.acceptForecast()) { error in
            guard let boardErr = error as? ParticleBoardError,
                  case .noPendingForecast = boardErr else {
                XCTFail("Expected noPendingForecast error when no forecast is queued")
                return
            }
        }
    }
}
