import XCTest
@testable import DOJOShared

final class FieldOperationV0Tests: XCTestCase {
    private let issuedAt = Date(timeIntervalSince1970: 1_740_000_000)

    private func object(
        id: String = "field-object-1",
        authority: String = "compose",
        version: Int = 0
    ) -> FieldObjectV0 {
        FieldObjectV0(
            id: id,
            geometry: "pyramid",
            chamber: "dojo",
            role: "structure",
            evidence: "HOLD",
            authority: authority,
            primeState: "HOLD · not embodied",
            version: version,
            source: "local-fixture",
            provenance: "/tmp/field-object-1.json",
            next: "Choose one bounded next move."
        )
    }

    private func request(
        objectID: String = "field-object-1",
        value: String = "Choose one bounded next-evidence sentence.",
        expectedVersion: Int = 0,
        authority: String = "compose"
    ) -> FieldOperationRequestV0 {
        FieldOperationRequestV0(
            id: "operation-1",
            requestedBy: "human-observer",
            sourceSurface: "DOJO canvas",
            targetObjectID: objectID,
            value: value,
            expectedVersion: expectedVersion,
            authority: authority,
            requestedAt: issuedAt
        )
    }

    func testAcceptedSetNextCommitsReceiptAndRendersUpdatedObject() {
        var store = DeterministicFieldStoreV0(objects: [object()])

        let result = store.apply(request(), issuedAt: issuedAt)

        XCTAssertEqual(result.receipt.decision, .accepted)
        XCTAssertTrue(result.receipt.mutationApplied)
        XCTAssertEqual(result.receipt.priorVersion, 0)
        XCTAssertEqual(result.receipt.resultingVersion, 1)
        XCTAssertEqual(result.receipt.governanceStatus, "LOCAL_FIXTURE_ONLY")
        XCTAssertEqual(result.object?.next, "Choose one bounded next-evidence sentence.")
        XCTAssertEqual(result.object?.version, 1)
        XCTAssertEqual(result.projection.tuples.count, 1)
        XCTAssertEqual(result.projection.tuples[0].next, "Choose one bounded next-evidence sentence.")
        XCTAssertEqual(store.objects["field-object-1"]?.version, 1)
    }

    func testVersionMismatchHoldsWithoutMutation() {
        var store = DeterministicFieldStoreV0(objects: [object(version: 2)])

        let result = store.apply(request(expectedVersion: 0), issuedAt: issuedAt)

        XCTAssertEqual(result.receipt.decision, .hold)
        XCTAssertEqual(result.receipt.reason, "HOLD.ExpectedVersionMismatch")
        XCTAssertFalse(result.receipt.mutationApplied)
        XCTAssertEqual(store.objects["field-object-1"]?.version, 2)
        XCTAssertEqual(result.projection.tuples[0].next, "Choose one bounded next move.")
    }

    func testInsufficientAuthorityHoldsWithoutMutation() {
        var store = DeterministicFieldStoreV0(objects: [object(authority: "observe")])

        let result = store.apply(request(), issuedAt: issuedAt)

        XCTAssertEqual(result.receipt.decision, .hold)
        XCTAssertEqual(result.receipt.reason, "HOLD.ObjectAuthorityInsufficient")
        XCTAssertFalse(result.receipt.mutationApplied)
        XCTAssertEqual(store.objects["field-object-1"]?.next, "Choose one bounded next move.")
    }

    func testFormattedNextTextHoldsInsteadOfBeingSilentlyChanged() {
        var store = DeterministicFieldStoreV0(objects: [object()])

        let result = store.apply(
            request(value: "**Choose** one next move."),
            issuedAt: issuedAt
        )

        XCTAssertEqual(result.receipt.decision, .hold)
        XCTAssertEqual(result.receipt.reason, "HOLD.NextMustBePlainSentence")
        XCTAssertFalse(result.receipt.mutationApplied)
    }

    func testMissingTargetHoldsAndProducesEmptyProjection() {
        var store = DeterministicFieldStoreV0(objects: [object()])

        let result = store.apply(
            request(objectID: "missing-object"),
            issuedAt: issuedAt
        )

        XCTAssertEqual(result.receipt.decision, .hold)
        XCTAssertEqual(result.receipt.reason, "HOLD.TargetObjectMissing")
        XCTAssertFalse(result.receipt.mutationApplied)
        XCTAssertNil(result.object)
        XCTAssertEqual(result.projection.tuples, [])
    }

    func testRequestAndReceiptRoundTripAsJSON() throws {
        let request = request()
        let receipt = FieldOperationReceiptV0(
            receiptID: "FIELD-OP-RECEIPT-V0-operation-1",
            operationID: request.id,
            objectID: request.targetObjectID,
            decision: .accepted,
            reason: "accepted",
            issuedAt: issuedAt,
            priorVersion: 0,
            resultingVersion: 1,
            mutationApplied: true,
            authorityCeiling: "compose"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let requestData = try encoder.encode(request)
        let receiptData = try encoder.encode(receipt)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        XCTAssertEqual(try decoder.decode(FieldOperationRequestV0.self, from: requestData), request)
        XCTAssertEqual(try decoder.decode(FieldOperationReceiptV0.self, from: receiptData), receipt)
    }
}
