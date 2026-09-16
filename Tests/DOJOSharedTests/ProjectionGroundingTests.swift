import XCTest
@testable import DOJOShared

final class ProjectionGroundingTests: XCTestCase {
    func testFullProjectionGroundingRoundTripsThroughJSON() throws {
        let grounding = ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-card-1",
                surface: .mac,
                representationKind: .card
            ),
            representedObject: FieldObjectIdentity(
                objectID: "object-capture-1",
                ontologyKind: .capture,
                displayLabel: "Local capture 1",
                sourceObjectID: "source-object-1"
            ),
            interactionContext: InteractionContext(
                inputMode: .text,
                preferredOutputMode: .visual,
                resolvedOutputMode: .visual,
                biometricState: .steady,
                environmentState: EnvironmentState(noiseLevel: 0.2, isPublic: false),
                activeDevice: .mac
            ),
            evidenceAnchors: [
                EvidenceAnchor(
                    anchorID: "receipt-1",
                    kind: .localCaptureReceipt,
                    sourceID: "local-receipt-1",
                    state: .sealed,
                    claim: "Local capture receipt exists"
                )
            ],
            temporalValidity: TemporalValidity(
                eventTime: Date(timeIntervalSince1970: 10),
                observationTime: Date(timeIntervalSince1970: 20),
                recordingTime: Date(timeIntervalSince1970: 30),
                resolutionTime: Date(timeIntervalSince1970: 40),
                projectionTime: Date(timeIntervalSince1970: 50),
                decisionTime: Date(timeIntervalSince1970: 60),
                expiryTime: Date(timeIntervalSince1970: 70),
                freshness: .current
            ),
            authorityStatus: ProjectionAuthorityStatus(
                decision: .pass,
                boundaryReference: "capability-boundary-1",
                nextEvidence: nil
            ),
            correctionRoute: CorrectionRoute(
                routeID: "correction-route-1",
                destination: "local-capture-journal",
                preservesHistory: true
            ),
            unknownDimensions: [],
            holdReasons: []
        )

        let data = try JSONEncoder().encode(grounding)
        let decoded = try JSONDecoder().decode(ProjectionGrounding.self, from: data)

        XCTAssertEqual(decoded, grounding)
        XCTAssertFalse(decoded.hasUnknownSource)
        XCTAssertFalse(decoded.hasAuthorityHold)
        XCTAssertEqual(decoded.inverseScopeNote, ProjectionGrounding.defaultInverseScopeNote)
    }

    func testMissingSourceIsRepresentedAsUnknownSource() {
        let grounding = ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-unknown-source",
                surface: .mac,
                representationKind: .diagnostic
            ),
            evidenceAnchors: [.unknownSource],
            unknownDimensions: [.source]
        )

        XCTAssertTrue(grounding.hasUnknownSource)
        XCTAssertEqual(grounding.evidenceAnchors.first, .unknownSource)
        XCTAssertTrue(grounding.unknownDimensions.contains(.source))
    }

    func testAuthorityHoldIsRepresentedAsHoldAuthority() {
        let grounding = ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-authority-hold",
                surface: .mac,
                representationKind: .card
            ),
            authorityStatus: .authorityHold,
            holdReasons: [.authority]
        )

        XCTAssertTrue(grounding.hasAuthorityHold)
        XCTAssertEqual(grounding.authorityStatus.decision, .hold)
        XCTAssertEqual(grounding.authorityStatus.boundaryReference, "HOLD.Authority")
        XCTAssertTrue(grounding.holdReasons.contains(.authority))
    }

    func testProjectionIdentityRemainsDistinctFromRepresentedObjectIdentity() {
        let grounding = ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "map-pin-1",
                surface: .iPhone,
                representationKind: .mapAnnotation
            ),
            representedObject: FieldObjectIdentity(
                objectID: "place-1",
                ontologyKind: .place,
                displayLabel: "Observed place"
            )
        )

        XCTAssertNotEqual(grounding.projectionIdentity.projectionID, grounding.representedObject.objectID)
        XCTAssertEqual(grounding.projectionIdentity.representationKind, .mapAnnotation)
        XCTAssertEqual(grounding.representedObject.ontologyKind, .place)
    }

    func testTemporalValidityDistinguishesIntertemporalDates() {
        let temporal = TemporalValidity(
            eventTime: Date(timeIntervalSince1970: 100),
            observationTime: Date(timeIntervalSince1970: 200),
            recordingTime: Date(timeIntervalSince1970: 300),
            resolutionTime: Date(timeIntervalSince1970: 400),
            projectionTime: Date(timeIntervalSince1970: 500),
            expiryTime: Date(timeIntervalSince1970: 600),
            freshness: .partial
        )

        XCTAssertEqual(temporal.eventTime, Date(timeIntervalSince1970: 100))
        XCTAssertEqual(temporal.observationTime, Date(timeIntervalSince1970: 200))
        XCTAssertEqual(temporal.recordingTime, Date(timeIntervalSince1970: 300))
        XCTAssertEqual(temporal.resolutionTime, Date(timeIntervalSince1970: 400))
        XCTAssertEqual(temporal.projectionTime, Date(timeIntervalSince1970: 500))
        XCTAssertEqual(temporal.expiryTime, Date(timeIntervalSince1970: 600))
        XCTAssertEqual(temporal.freshness, .partial)
    }

    func testLocalCaptureReceiptBuildsGroundedPermittedProjection() {
        let receipt = makeReceipt()
        let grounding = ProjectionGroundingFactory.fromLocalCaptureReceipt(
            receipt,
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-local-capture-1",
                surface: .mac,
                representationKind: .card
            ),
            interactionContext: InteractionContext(activeDevice: .mac),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            projectionTime: Date(timeIntervalSince1970: 700)
        )

        XCTAssertEqual(grounding.representedObject.objectID, receipt.objectID)
        XCTAssertEqual(grounding.representedObject.ontologyKind, .capture)
        XCTAssertEqual(grounding.evidenceAnchors.first?.anchorID, receipt.receiptID)
        XCTAssertEqual(grounding.evidenceAnchors.first?.sourceID, receipt.receiptID)
        XCTAssertEqual(grounding.evidenceAnchors.first?.kind, .localCaptureReceipt)
        XCTAssertEqual(grounding.evidenceAnchors.first?.state, .sealed)
        XCTAssertEqual(grounding.temporalValidity.recordingTime, receipt.issuedAt)
        XCTAssertEqual(grounding.temporalValidity.projectionTime, Date(timeIntervalSince1970: 700))
        XCTAssertEqual(grounding.temporalValidity.freshness, .current)
        XCTAssertEqual(grounding.authorityStatus.decision, .pass)
        XCTAssertTrue(grounding.unknownDimensions.isEmpty)
        XCTAssertTrue(grounding.holdReasons.isEmpty)
        XCTAssertFalse(grounding.hasUnknownSource)
        XCTAssertFalse(grounding.hasAuthorityHold)
    }

    func testNilLocalCaptureReceiptBuildsPartialProjectionWithUnknownSource() {
        let grounding = ProjectionGroundingFactory.fromLocalCaptureReceipt(
            nil,
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-missing-receipt",
                surface: .mac,
                representationKind: .diagnostic
            )
        )

        XCTAssertEqual(grounding.representedObject, .unknown)
        XCTAssertEqual(grounding.evidenceAnchors, [.unknownSource])
        XCTAssertTrue(grounding.unknownDimensions.contains(.identity))
        XCTAssertTrue(grounding.unknownDimensions.contains(.source))
        XCTAssertTrue(grounding.unknownDimensions.contains(.temporalValidity))
        XCTAssertTrue(grounding.holdReasons.contains(.evidence))
        XCTAssertTrue(grounding.hasUnknownSource)
    }

    func testLocalCaptureReceiptWithAuthorityHoldKeepsEvidenceAndHoldsProjection() {
        let receipt = makeReceipt()
        let grounding = ProjectionGroundingFactory.fromLocalCaptureReceipt(
            receipt,
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-held-capture",
                surface: .mac,
                representationKind: .card
            ),
            authorityStatus: .authorityHold
        )

        XCTAssertEqual(grounding.representedObject.objectID, receipt.objectID)
        XCTAssertEqual(grounding.evidenceAnchors.first?.sourceID, receipt.receiptID)
        XCTAssertEqual(grounding.authorityStatus.decision, .hold)
        XCTAssertTrue(grounding.holdReasons.contains(.authority))
        XCTAssertTrue(grounding.hasAuthorityHold)
        XCTAssertFalse(grounding.hasUnknownSource)
    }

    func testLocalCaptureReceiptProjectionIdentityStaysSeparateFromObjectIdentity() {
        let receipt = makeReceipt(objectID: "object-local-capture")
        let grounding = ProjectionGroundingFactory.fromLocalCaptureReceipt(
            receipt,
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-row-local-capture",
                surface: .mac,
                representationKind: .row
            ),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass)
        )

        XCTAssertEqual(grounding.representedObject.objectID, "object-local-capture")
        XCTAssertEqual(grounding.projectionIdentity.projectionID, "projection-row-local-capture")
        XCTAssertNotEqual(grounding.projectionIdentity.projectionID, grounding.representedObject.objectID)
    }

    private func makeReceipt(
        receiptID: String = "receipt-local-capture",
        objectID: String = "object-local-capture-1",
        issuedAt: Date = Date(timeIntervalSince1970: 600)
    ) -> LocalCaptureReceipt {
        LocalCaptureReceipt(
            receiptID: receiptID,
            objectID: objectID,
            surface: "DOJO Today · macOS",
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            issuedAt: issuedAt,
            contentSHA256: String(repeating: "a", count: 64),
            objectPath: "/tmp/generated_objects.json",
            receiptPath: "/tmp/local_capture_receipts.jsonl"
        )
    }
}
