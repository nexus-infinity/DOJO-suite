import XCTest
@testable import DOJOShared

final class SpatialAnchorTests: XCTestCase {
    func testValidSpatialAnchorConstruction() throws {
        let coordinate = try XCTUnwrap(SpatialCoordinate(latitude: -37.8136, longitude: 144.9631))
        let anchor = SpatialAnchor(
            anchorID: "spatial-anchor-melbourne",
            coordinate: coordinate,
            displayName: "Melbourne fixture",
            horizontalAccuracyMeters: 12,
            observedAt: Date(timeIntervalSince1970: 100),
            recordedAt: Date(timeIntervalSince1970: 120),
            evidenceAnchor: EvidenceAnchor(
                anchorID: "receipt-1",
                kind: .localCaptureReceipt,
                sourceID: "receipt-1",
                state: .sealed,
                claim: "Fixture receipt anchors this coordinate"
            )
        )

        XCTAssertEqual(anchor.coordinate, coordinate)
        XCTAssertEqual(anchor.displayName, "Melbourne fixture")
        XCTAssertEqual(anchor.horizontalAccuracyMeters, 12)
        XCTAssertTrue(anchor.mayRenderAsMapAnnotation)
    }

    func testInvalidCoordinateBehavior() throws {
        XCTAssertNil(SpatialCoordinate(latitude: -91, longitude: 144))
        XCTAssertNil(SpatialCoordinate(latitude: -37, longitude: 181))
        XCTAssertNil(SpatialCoordinate(latitude: .nan, longitude: 144))

        let invalidJSON = #"{"latitude":91,"longitude":144}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(SpatialCoordinate.self, from: invalidJSON))
    }

    func testReceiptToSpatialGroundingAttachmentProducesPermittedAnnotationCandidate() throws {
        let receipt = makeReceipt()
        let anchor = makeAnchor(receipt: receipt)
        let projection = SpatialEvidenceProjectionFactory.fromLocalCaptureReceipt(
            receipt,
            spatialAnchor: anchor,
            projectionIdentity: ProjectionIdentity(
                projectionID: "map-annotation-\(receipt.receiptID)",
                surface: .mac,
                representationKind: .mapAnnotation
            ),
            interactionContext: InteractionContext(activeDevice: .mac),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            projectionTime: Date(timeIntervalSince1970: 500)
        )

        XCTAssertTrue(projection.mayRenderAsOrdinaryMapAnnotation)
        XCTAssertEqual(projection.spatialAnchor.anchorID, "spatial-\(receipt.receiptID)")
        XCTAssertEqual(projection.projectionGrounding.representedObject.objectID, receipt.objectID)
        XCTAssertEqual(projection.projectionGrounding.evidenceAnchors.first?.sourceID, receipt.receiptID)
        XCTAssertEqual(projection.projectionGrounding.temporalValidity.recordingTime, receipt.issuedAt)
        XCTAssertEqual(projection.projectionGrounding.temporalValidity.projectionTime, Date(timeIntervalSince1970: 500))
        XCTAssertFalse(projection.projectionGrounding.hasUnknownSource)
        XCTAssertFalse(projection.projectionGrounding.hasAuthorityHold)
    }

    func testNilReceiptOrMissingAnchorPreservesUnknownAndEvidenceHold() {
        let projection = SpatialEvidenceProjectionFactory.fromLocalCaptureReceipt(
            nil,
            spatialAnchor: nil,
            projectionIdentity: ProjectionIdentity(
                projectionID: "map-annotation-missing",
                surface: .mac,
                representationKind: .mapAnnotation
            )
        )

        XCTAssertFalse(projection.mayRenderAsOrdinaryMapAnnotation)
        XCTAssertTrue(projection.requiresHoldPresentation)
        XCTAssertEqual(projection.spatialAnchor, .unknown)
        XCTAssertTrue(projection.projectionGrounding.unknownDimensions.contains(.identity))
        XCTAssertTrue(projection.projectionGrounding.unknownDimensions.contains(.source))
        XCTAssertTrue(projection.projectionGrounding.unknownDimensions.contains(.geometricReturn))
        XCTAssertTrue(projection.projectionGrounding.holdReasons.contains(.evidence))
    }

    func testAuthorityHeldEvidencePreservesReceiptAndWithholdsOrdinaryAnnotation() {
        let receipt = makeReceipt()
        let projection = SpatialEvidenceProjectionFactory.fromLocalCaptureReceipt(
            receipt,
            spatialAnchor: makeAnchor(receipt: receipt),
            projectionIdentity: ProjectionIdentity(
                projectionID: "map-annotation-held",
                surface: .mac,
                representationKind: .mapAnnotation
            ),
            authorityStatus: .authorityHold
        )

        XCTAssertFalse(projection.mayRenderAsOrdinaryMapAnnotation)
        XCTAssertTrue(projection.requiresHoldPresentation)
        XCTAssertEqual(projection.projectionGrounding.evidenceAnchors.first?.sourceID, receipt.receiptID)
        XCTAssertEqual(projection.projectionGrounding.authorityStatus.decision, .hold)
        XCTAssertTrue(projection.projectionGrounding.holdReasons.contains(.authority))
    }

    func testHistoricalTemporalStateDoesNotPresentAsCurrentPresence() {
        let receipt = makeReceipt(issuedAt: Date(timeIntervalSince1970: 100))
        let grounding = ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "historical-projection",
                surface: .mac,
                representationKind: .mapAnnotation
            ),
            representedObject: FieldObjectIdentity(
                objectID: receipt.objectID,
                ontologyKind: .capture,
                displayLabel: "Historical capture"
            ),
            evidenceAnchors: [
                EvidenceAnchor(
                    anchorID: receipt.receiptID,
                    kind: .localCaptureReceipt,
                    sourceID: receipt.receiptID,
                    state: .sealed,
                    claim: "Historical fixture receipt"
                )
            ],
            temporalValidity: TemporalValidity(
                recordingTime: receipt.issuedAt,
                projectionTime: Date(timeIntervalSince1970: 900),
                expiryTime: Date(timeIntervalSince1970: 300),
                freshness: .historical
            ),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            unknownDimensions: [],
            holdReasons: []
        )
        let projection = SpatialEvidenceProjection(
            spatialAnchor: makeAnchor(receipt: receipt),
            projectionGrounding: grounding
        )

        XCTAssertTrue(projection.mayRenderAsOrdinaryMapAnnotation)
        XCTAssertEqual(projection.projectionGrounding.temporalValidity.freshness, .historical)
        XCTAssertNotEqual(projection.projectionGrounding.temporalValidity.freshness, .current)
    }

    func testSpatialObjectAndProjectionIdentitiesRemainDistinct() throws {
        let receipt = makeReceipt(objectID: "object-identity")
        let projection = SpatialEvidenceProjectionFactory.fromLocalCaptureReceipt(
            receipt,
            spatialAnchor: makeAnchor(receipt: receipt, anchorID: "spatial-identity"),
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-identity",
                surface: .mac,
                representationKind: .mapAnnotation
            ),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass)
        )

        XCTAssertEqual(projection.spatialAnchor.anchorID, "spatial-identity")
        XCTAssertEqual(projection.projectionGrounding.representedObject.objectID, "object-identity")
        XCTAssertEqual(projection.projectionGrounding.projectionIdentity.projectionID, "projection-identity")
        XCTAssertNotEqual(projection.spatialAnchor.anchorID, projection.projectionGrounding.representedObject.objectID)
        XCTAssertNotEqual(projection.spatialAnchor.anchorID, projection.projectionGrounding.projectionIdentity.projectionID)
        XCTAssertNotEqual(
            projection.projectionGrounding.representedObject.objectID,
            projection.projectionGrounding.projectionIdentity.projectionID
        )
    }

    func testSpatialEvidenceProjectionRoundTripsThroughJSON() throws {
        let receipt = makeReceipt()
        let projection = SpatialEvidenceProjectionFactory.fromLocalCaptureReceipt(
            receipt,
            spatialAnchor: makeAnchor(receipt: receipt),
            projectionIdentity: ProjectionIdentity(
                projectionID: "codable-projection",
                surface: .mac,
                representationKind: .mapAnnotation
            ),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass)
        )

        let data = try JSONEncoder().encode(projection)
        let decoded = try JSONDecoder().decode(SpatialEvidenceProjection.self, from: data)

        XCTAssertEqual(decoded, projection)
    }

    private func makeReceipt(
        receiptID: String = "receipt-spatial-fixture",
        objectID: String = "object-spatial-fixture",
        issuedAt: Date = Date(timeIntervalSince1970: 400)
    ) -> LocalCaptureReceipt {
        LocalCaptureReceipt(
            receiptID: receiptID,
            objectID: objectID,
            surface: "DOJO Today · macOS",
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            issuedAt: issuedAt,
            contentSHA256: String(repeating: "b", count: 64),
            objectPath: "/tmp/generated_objects.json",
            receiptPath: "/tmp/local_capture_receipts.jsonl"
        )
    }

    private func makeAnchor(
        receipt: LocalCaptureReceipt,
        anchorID: String? = nil
    ) -> SpatialAnchor {
        SpatialAnchor(
            anchorID: anchorID ?? "spatial-\(receipt.receiptID)",
            coordinate: SpatialCoordinate(latitude: -37.8136, longitude: 144.9631),
            displayName: "FIXTURE / DEVELOPMENT PROOF — NOT LIVE LOCATION",
            horizontalAccuracyMeters: 18,
            observedAt: Date(timeIntervalSince1970: 350),
            recordedAt: receipt.issuedAt,
            evidenceAnchor: EvidenceAnchor(
                anchorID: receipt.receiptID,
                kind: .localCaptureReceipt,
                sourceID: receipt.receiptID,
                state: .sealed,
                claim: "Fixture spatial anchor attached to existing local capture receipt"
            )
        )
    }
}
