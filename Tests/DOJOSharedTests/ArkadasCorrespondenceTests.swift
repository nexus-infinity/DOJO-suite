import XCTest
@testable import DOJOShared

final class ArkadasCorrespondenceTests: XCTestCase {
    func testDefaultAddressabilityAndReturnAreDeterministic() {
        XCTAssertEqual(ArkadasAddressabilityResult(), ArkadasAddressabilityResult())
        XCTAssertEqual(ExternalGeometryReturn(), ExternalGeometryReturn())
        XCTAssertFalse(ArkadasAddressabilityResult().mayAddressObserverField)
        XCTAssertTrue(ArkadasAddressabilityResult().unknownDimensions.contains(.observerRelation))
        XCTAssertTrue(ArkadasAddressabilityResult().unknownDimensions.contains(.geometricReturn))
    }

    func testContractTypesAreSendableCompatible() {
        assertSendable(ArkadasAddressabilityResult())
        assertSendable(ExternalGeometryReturn())
        assertSendable(ObserverCohabitationFrame())
        assertSendable(SurfaceAvailability())
    }

    func testAddressableResultRoundTripsThroughJSON() throws {
        let result = makeAddressableResult()

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(ArkadasAddressabilityResult.self, from: data)

        XCTAssertEqual(decoded, result)
        XCTAssertTrue(decoded.mayAddressObserverField)
        XCTAssertTrue(decoded.preservesNonInferenceBoundary)
    }

    func testArkadasCanSaySurfacePlaceAndTimeAreAddressable() throws {
        let result = makeAddressableResult()

        XCTAssertEqual(result.correspondenceState, .addressable)
        XCTAssertEqual(result.authorityStatus.decision, .pass)
        XCTAssertEqual(result.selectedSurface?.surface, .iPhone)
        XCTAssertEqual(result.selectedSurface?.outputMode, .visual)
        XCTAssertEqual(result.temporalValidity.freshness, .current)
        XCTAssertEqual(result.cohabitationFrame.spatialAnchor?.anchorID, "observer-spatial-anchor-1")
        XCTAssertTrue(result.mayAddressObserverField)
    }

    func testUnknownCohabitationFramePreventsAddressabilityWithoutInventingGeometry() {
        let result = ArkadasAddressabilityResult(
            identity: ArkadasAddressabilityIdentity(addressabilityID: "addressability-unknown-frame"),
            intention: makeIntention(),
            projectionCandidate: makeProjectionIdentity(),
            cohabitationFrame: .unknown,
            availableSurfaces: [.unknown],
            selectedSurface: .unknown,
            correspondenceState: .unknown,
            authorityStatus: .unknown
        )

        XCTAssertFalse(result.mayAddressObserverField)
        XCTAssertTrue(result.unknownDimensions.contains(.observerRelation))
        XCTAssertTrue(result.unknownDimensions.contains(.geometricReturn))
        XCTAssertTrue(result.unknownDimensions.contains(.observerRelation))
        XCTAssertTrue(result.holdReasons.contains(.authority))
        XCTAssertTrue(result.preservesNonInferenceBoundary)
    }

    func testAuthorityHoldPreventsAddressabilityButDoesNotEraseCandidateOrSurface() {
        let selectedSurface = SurfaceAvailability(
            surface: .mac,
            outputMode: .visual,
            isAvailable: true,
            boundaryReference: "HAL.Surface.Mac.Visual"
        )
        let result = ArkadasAddressabilityResult(
            identity: ArkadasAddressabilityIdentity(addressabilityID: "addressability-held"),
            intention: makeIntention(),
            projectionGrounding: makeProjectionGrounding(),
            cohabitationFrame: makeCohabitationFrame(),
            availableSurfaces: [selectedSurface],
            selectedSurface: selectedSurface,
            temporalValidity: makeTemporalValidity(),
            correspondenceState: .held,
            authorityStatus: .authorityHold,
            holdReasons: [.authority]
        )

        XCTAssertFalse(result.mayAddressObserverField)
        XCTAssertEqual(result.projectionCandidate?.projectionID, "projection-candidate-1")
        XCTAssertEqual(result.selectedSurface?.surface, .mac)
        XCTAssertEqual(result.authorityStatus.decision, .hold)
        XCTAssertTrue(result.holdReasons.contains(.authority))
    }

    func testArkadasDoesNotInferConsentFulfillmentCorrectnessMeaningObserverIntentionOrRuntimeAuthority() {
        let result = makeAddressableResult()
        let returnedGeometry = ExternalGeometryReturn(
            returnID: "return-encountered-1",
            addressabilityIdentity: result.identity,
            observedAt: Date(timeIntervalSince1970: 1_000),
            surface: .iPhone,
            outcome: .encountered,
            changedSpatialAnchor: makeSpatialAnchor(anchorID: "changed-anchor-1"),
            evidenceAnchors: [makeEvidence()]
        )

        XCTAssertEqual(Set(result.withheldInferences), Set(ArkadasWithheldInference.allCases))
        XCTAssertEqual(Set(returnedGeometry.withheldInferences), Set(ArkadasWithheldInference.allCases))
        XCTAssertTrue(result.preservesNonInferenceBoundary)
        XCTAssertTrue(returnedGeometry.preservesNonInferenceBoundary)
        XCTAssertTrue(result.withheldInferences.contains(.consent))
        XCTAssertTrue(result.withheldInferences.contains(.semanticMeaning))
        XCTAssertTrue(result.withheldInferences.contains(.fulfillment))
        XCTAssertTrue(result.withheldInferences.contains(.correctness))
        XCTAssertTrue(result.withheldInferences.contains(.observerIntention))
        XCTAssertTrue(result.withheldInferences.contains(.runtimeAuthority))
    }

    func testExternalGeometryReturnReportsOutcomeWithoutSemanticConclusion() throws {
        let returnPacket = ExternalGeometryReturn(
            returnID: "return-delayed-1",
            addressabilityIdentity: ArkadasAddressabilityIdentity(addressabilityID: "addressability-1"),
            observedAt: Date(timeIntervalSince1970: 1_200),
            surface: .watch,
            outcome: .delayed,
            changedSpatialAnchor: makeSpatialAnchor(anchorID: "changed-watch-anchor"),
            evidenceAnchors: [makeEvidence(anchorID: "watch-return-evidence")]
        )

        let data = try JSONEncoder().encode(returnPacket)
        let decoded = try JSONDecoder().decode(ExternalGeometryReturn.self, from: data)

        XCTAssertEqual(decoded, returnPacket)
        XCTAssertEqual(decoded.outcome, .delayed)
        XCTAssertEqual(decoded.surface, .watch)
        XCTAssertTrue(decoded.unknownDimensions.isEmpty)
        XCTAssertTrue(decoded.holdReasons.isEmpty)
        XCTAssertTrue(decoded.preservesNonInferenceBoundary)
    }

    func testExternalGeometryReturnDefaultsUnknownSourceAndTemporalValidity() {
        let returnPacket = ExternalGeometryReturn()

        XCTAssertEqual(returnPacket.returnID, "Unknown.ExternalGeometryReturn")
        XCTAssertEqual(returnPacket.evidenceAnchors, [.unknownSource])
        XCTAssertTrue(returnPacket.unknownDimensions.contains(.source))
        XCTAssertTrue(returnPacket.unknownDimensions.contains(.temporalValidity))
        XCTAssertTrue(returnPacket.preservesNonInferenceBoundary)
    }

    func testIntentionAddressabilityProjectionAndFieldObjectIdentitiesRemainSeparate() {
        let result = makeAddressableResult()

        XCTAssertEqual(result.identity.addressabilityID, "addressability-1")
        XCTAssertEqual(result.intention.intentionID, "dojo-intention-1")
        XCTAssertEqual(result.intention.sourceObject.objectID, "field-object-1")
        XCTAssertEqual(result.projectionCandidate?.projectionID, "projection-candidate-1")
        XCTAssertNotEqual(result.identity.addressabilityID, result.intention.intentionID)
        XCTAssertNotEqual(result.identity.addressabilityID, result.projectionCandidate?.projectionID)
        XCTAssertNotEqual(result.intention.sourceObject.objectID, result.projectionCandidate?.projectionID)
    }

    func testSurfaceAvailabilityRequiresKnownAvailableSurfaceAndChannel() {
        let available = SurfaceAvailability(
            surface: .iPhone,
            outputMode: .visual,
            isAvailable: true,
            boundaryReference: "HAL.Surface.iPhone.Visual"
        )
        let unknown = SurfaceAvailability.unknown
        let unavailable = SurfaceAvailability(surface: .watch, outputMode: .haptic, isAvailable: false)

        XCTAssertTrue(available.mayBeSelectedForAddressability)
        XCTAssertFalse(unknown.mayBeSelectedForAddressability)
        XCTAssertFalse(unavailable.mayBeSelectedForAddressability)
        XCTAssertTrue(unknown.unknownDimensions.contains(.observerRelation))
        XCTAssertTrue(unknown.holdReasons.contains(.authority))
    }

    func testAmbiguousGroundingPreservesUncertaintyAndCorrectionRoute() {
        let ambiguousGrounding = ProjectionGrounding(
            projectionIdentity: makeProjectionIdentity(),
            representedObject: FieldObjectIdentity(
                objectID: "field-object-ambiguous",
                ontologyKind: .capture,
                displayLabel: "Ambiguous fixture capture"
            ),
            evidenceAnchors: [makeEvidence(anchorID: "ambiguous-evidence")],
            temporalValidity: makeTemporalValidity(),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            correctionRoute: CorrectionRoute(
                routeID: "correction-ambiguous",
                destination: "/tmp/dojo-fixture/corrections.jsonl",
                preservesHistory: true
            ),
            unknownDimensions: [.semanticClaim],
            holdReasons: [.evidence]
        )
        let selectedSurface = SurfaceAvailability(
            surface: .mac,
            outputMode: .visual,
            isAvailable: true,
            boundaryReference: "HAL.Surface.Mac.Visual"
        )
        let result = ArkadasAddressabilityResult(
            identity: ArkadasAddressabilityIdentity(addressabilityID: "addressability-ambiguous"),
            intention: makeIntention(),
            projectionGrounding: ambiguousGrounding,
            cohabitationFrame: makeCohabitationFrame(),
            availableSurfaces: [selectedSurface],
            selectedSurface: selectedSurface,
            temporalValidity: makeTemporalValidity(),
            correspondenceState: .partial,
            authorityStatus: ProjectionAuthorityStatus(decision: .pass)
        )

        XCTAssertFalse(result.mayAddressObserverField)
        XCTAssertEqual(result.projectionGrounding?.correctionRoute.destination, "/tmp/dojo-fixture/corrections.jsonl")
        XCTAssertTrue(result.unknownDimensions.contains(.semanticClaim))
        XCTAssertTrue(result.holdReasons.contains(.evidence))
    }

    private func makeAddressableResult() -> ArkadasAddressabilityResult {
        let selectedSurface = SurfaceAvailability(
            surface: .iPhone,
            outputMode: .visual,
            isAvailable: true,
            boundaryReference: "HAL.Surface.iPhone.Visual"
        )

        return ArkadasAddressabilityResult(
            identity: ArkadasAddressabilityIdentity(addressabilityID: "addressability-1"),
            intention: makeIntention(),
            projectionGrounding: makeProjectionGrounding(),
            cohabitationFrame: makeCohabitationFrame(),
            availableSurfaces: [selectedSurface],
            selectedSurface: selectedSurface,
            temporalValidity: makeTemporalValidity(),
            correspondenceState: .addressable,
            authorityStatus: ProjectionAuthorityStatus(
                decision: .pass,
                boundaryReference: "Arkadas.Correspondence.Fixture.Pass"
            )
        )
    }

    private func makeIntention() -> ArkadasIntentionReference {
        ArkadasIntentionReference(
            intentionID: "dojo-intention-1",
            sourceObject: FieldObjectIdentity(
                objectID: "field-object-1",
                ontologyKind: .capture,
                displayLabel: "Fixture capture"
            ),
            boundedSummary: "Make one existing projection candidate addressable in the observer field."
        )
    }

    private func makeProjectionIdentity() -> ProjectionIdentity {
        ProjectionIdentity(
            projectionID: "projection-candidate-1",
            surface: .mac,
            representationKind: .card
        )
    }

    private func makeProjectionGrounding() -> ProjectionGrounding {
        ProjectionGrounding(
            projectionIdentity: makeProjectionIdentity(),
            representedObject: FieldObjectIdentity(
                objectID: "field-object-1",
                ontologyKind: .capture,
                displayLabel: "Fixture capture"
            ),
            interactionContext: InteractionContext(
                inputMode: .text,
                resolvedOutputMode: .visual,
                biometricState: .unknown,
                environmentState: .unknown,
                activeDevice: .mac
            ),
            evidenceAnchors: [makeEvidence()],
            temporalValidity: makeTemporalValidity(),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            correctionRoute: CorrectionRoute(
                routeID: "correction-projection-candidate-1",
                destination: "/tmp/dojo-fixture/projection-corrections.jsonl",
                preservesHistory: true
            ),
            unknownDimensions: [],
            holdReasons: []
        )
    }

    private func makeCohabitationFrame() -> ObserverCohabitationFrame {
        ObserverCohabitationFrame(
            observerID: "observer-1",
            interactionContext: InteractionContext(
                inputMode: .text,
                preferredOutputMode: nil,
                resolvedOutputMode: .visual,
                biometricState: .unknown,
                environmentState: .unknown,
                activeDevice: .iPhone
            ),
            spatialAnchor: makeSpatialAnchor(anchorID: "observer-spatial-anchor-1"),
            orientationLabel: "fixture-facing-work-surface",
            observedAt: Date(timeIntervalSince1970: 900)
        )
    }

    private func makeSpatialAnchor(anchorID: String) -> SpatialAnchor {
        SpatialAnchor(
            anchorID: anchorID,
            coordinate: SpatialCoordinate(latitude: -37.8136, longitude: 144.9631),
            displayName: "Fixture cohabitation anchor",
            horizontalAccuracyMeters: 20,
            observedAt: Date(timeIntervalSince1970: 875),
            recordedAt: Date(timeIntervalSince1970: 900),
            evidenceAnchor: makeEvidence()
        )
    }

    private func makeTemporalValidity() -> TemporalValidity {
        TemporalValidity(
            observationTime: Date(timeIntervalSince1970: 900),
            projectionTime: Date(timeIntervalSince1970: 930),
            decisionTime: Date(timeIntervalSince1970: 940),
            freshness: .current
        )
    }

    private func makeEvidence(anchorID: String = "fixture-evidence-1") -> EvidenceAnchor {
        EvidenceAnchor(
            anchorID: anchorID,
            kind: .localCaptureReceipt,
            sourceID: anchorID,
            state: .sealed,
            claim: "Fixture evidence only"
        )
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
