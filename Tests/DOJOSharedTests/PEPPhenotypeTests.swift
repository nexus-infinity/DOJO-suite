import XCTest
@testable import DOJOShared

final class PEPPhenotypeTests: XCTestCase {
    func testGroundedPassProducesEligibleExpressionNotVisibilityOrDelivery() {
        let resolution = makeEligibleResolution()

        XCTAssertEqual(resolution.state, .eligible)
        XCTAssertTrue(resolution.preservesLineage)
        XCTAssertTrue(resolution.preservesRuntimeBoundary)
        XCTAssertFalse(resolution.isVisible)
        XCTAssertFalse(resolution.isRendered)
        XCTAssertFalse(resolution.isDelivered)
        XCTAssertFalse(resolution.isEncountered)
        XCTAssertFalse(resolution.consentInferred)
        XCTAssertEqual(resolution.runtimeAuthority, "none")
    }

    func testHoldAuthorityProducesHeldPhenotypeWithNoActionAffordance() {
        let grounding = makeProjectionGrounding(authorityStatus: .authorityHold, holdReasons: [.authority])
        let boundary = PEPExpressionBoundary(
            authorityStatus: .authorityHold,
            allowedExpressionModes: [.visual],
            allowsInteractionAffordance: true,
            correctionRoute: makeCorrectionRoute()
        )
        let expression = makeSurfaceExpression(interactionAffordance: .actionRepresentable)
        let resolution = PEPPhenotypeResolution.resolve(
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: expression,
            expressionBoundary: boundary,
            attributes: [makeAttribute(authorityStatus: .authorityHold, holdReasons: [.authority])]
        )

        XCTAssertEqual(resolution.state, .held)
        XCTAssertTrue(resolution.holdReasons.contains(.authority))
        XCTAssertFalse(resolution.mayRepresentInteractionAffordance)
        XCTAssertFalse(resolution.expressionBoundary.deliveryAllowed)
        XCTAssertEqual(resolution.expressionBoundary.runtimeAuthority, "none")
    }

    func testUnknownEvidencePreservesUnknownHoldAndCorrectionRoute() {
        let grounding = ProjectionGrounding(
            projectionIdentity: makeProjectionIdentity(),
            representedObject: makeObjectIdentity(),
            evidenceAnchors: [.unknownSource],
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            correctionRoute: makeCorrectionRoute(),
            unknownDimensions: [.source],
            holdReasons: [.evidence]
        )
        let resolution = PEPPhenotypeResolution.resolve(
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: makeSurfaceExpression(),
            expressionBoundary: makeBoundary(),
            attributes: [makeAttribute(evidenceAnchor: .unknownSource, unknownDimensions: [.source], holdReasons: [.evidence])]
        )

        XCTAssertEqual(resolution.state, .unknown)
        XCTAssertTrue(resolution.unknownDimensions.contains(.source))
        XCTAssertTrue(resolution.holdReasons.contains(.evidence))
        XCTAssertEqual(resolution.correctionRoute, makeCorrectionRoute())
        XCTAssertTrue(resolution.preservesRuntimeBoundary)
    }

    func testSameGenotypeProducesDistinctLawfulSurfacePhenotypes() {
        let desktop = makeSurfaceExpression(surfaceClass: .desktop, semanticEmphasis: "Evidence inspector")
        let handheld = makeSurfaceExpression(surfaceClass: .handheld, semanticEmphasis: "Capture state")
        let wearable = makeSurfaceExpression(surfaceClass: .wearable, semanticEmphasis: "Haptic witness", modes: [.haptic])
        let grounding = makeProjectionGrounding()
        let variants = [desktop, handheld, wearable]
        let resolution = PEPPhenotypeResolution.resolve(
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: desktop,
            expressionBoundary: PEPExpressionBoundary(
                authorityStatus: ProjectionAuthorityStatus(decision: .pass),
                allowedExpressionModes: [.visual, .textual, .haptic],
                correctionRoute: makeCorrectionRoute()
            ),
            attributes: [makeAttribute()],
            surfaceVariants: variants
        )

        XCTAssertEqual(Set(resolution.surfaceVariants.map(\.surfaceClass)), Set([.desktop, .handheld, .wearable]))
        XCTAssertTrue(resolution.surfaceVariants.allSatisfy { !$0.isRendered && !$0.isDelivered })
        XCTAssertEqual(resolution.identity.genotypeObject, grounding.representedObject)
        XCTAssertEqual(resolution.identity.projectionIdentity, grounding.projectionIdentity)
    }

    func testPhenotypePreservesObjectProjectionEvidenceAuthorityAndCorrection() {
        let grounding = makeProjectionGrounding()
        let attribute = makeAttribute()
        let resolution = PEPPhenotypeResolution.resolve(
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: makeSurfaceExpression(attributes: [attribute]),
            expressionBoundary: makeBoundary(),
            attributes: [attribute]
        )

        XCTAssertEqual(resolution.identity.genotypeObject, grounding.representedObject)
        XCTAssertEqual(resolution.identity.projectionIdentity, grounding.projectionIdentity)
        XCTAssertEqual(resolution.projectionGrounding?.evidenceAnchors, grounding.evidenceAnchors)
        XCTAssertEqual(resolution.expressionBoundary.authorityStatus, grounding.authorityStatus)
        XCTAssertEqual(resolution.correctionRoute, grounding.correctionRoute)
        XCTAssertTrue(resolution.preservesLineage)
    }

    func testColourSymbolAndGeometryCannotIndependentlyConferAuthority() {
        let attribute = PEPAttribute(
            attributeID: "attribute-symbolic",
            semanticRole: "Symbolic caution",
            colorRole: .authority,
            geometryRole: .boundary,
            motionRole: .pulse,
            communicationMode: .visual,
            evidenceAnchor: makeEvidenceAnchor(),
            authorityStatus: .unknown,
            correctionRoute: makeCorrectionRoute()
        )
        let boundary = PEPExpressionBoundary(
            authorityStatus: .unknown,
            allowedExpressionModes: [.visual],
            correctionRoute: makeCorrectionRoute()
        )

        XCTAssertFalse(attribute.independentlyCompletesMeaning)
        XCTAssertFalse(attribute.independentlyConfersAuthority)
        XCTAssertFalse(attribute.independentlyGrantsPermission)
        XCTAssertFalse(boundary.permits(.visual))
    }

    func testAddressabilityCannotBecomeSelectionRenderingOrDelivery() {
        let addressability = makeAddressabilityResult()
        let expression = makeSurfaceExpression(isSelectedSurface: false)
        let resolution = PEPPhenotypeResolution.resolve(
            projectionGrounding: makeProjectionGrounding(),
            addressabilityResult: addressability,
            selectedSurfaceClass: .desktop,
            surfaceExpression: expression,
            expressionBoundary: makeBoundary(),
            attributes: [makeAttribute()]
        )

        XCTAssertTrue(addressability.mayAddressObserverField)
        XCTAssertFalse(resolution.surfaceExpression.isSelectedSurface)
        XCTAssertFalse(resolution.isVisible)
        XCTAssertFalse(resolution.isRendered)
        XCTAssertFalse(resolution.isDelivered)
        XCTAssertFalse(resolution.isEncountered)
        XCTAssertFalse(resolution.consentInferred)
    }

    func testDefaultsAreDeterministicAndFailClosed() {
        XCTAssertEqual(PEPPhenotypeIdentity(), PEPPhenotypeIdentity())
        XCTAssertEqual(PEPAttribute(), PEPAttribute())
        XCTAssertEqual(PEPExpressionBoundary(), PEPExpressionBoundary())
        XCTAssertEqual(PEPSurfaceExpression(), PEPSurfaceExpression())
        XCTAssertEqual(PEPPhenotypeResolution(), PEPPhenotypeResolution())

        let resolution = PEPPhenotypeResolution()
        XCTAssertEqual(resolution.state, .unknown)
        XCTAssertTrue(resolution.unknownDimensions.contains(.source))
        XCTAssertTrue(resolution.holdReasons.contains(.evidence))
        XCTAssertFalse(resolution.preservesLineage)
        XCTAssertTrue(resolution.preservesRuntimeBoundary)
    }

    func testCodableRoundTripPreservesBoundaries() throws {
        let resolution = makeEligibleResolution()

        let data = try JSONEncoder().encode(resolution)
        let decoded = try JSONDecoder().decode(PEPPhenotypeResolution.self, from: data)

        XCTAssertEqual(decoded, resolution)
        XCTAssertTrue(decoded.preservesLineage)
        XCTAssertTrue(decoded.preservesRuntimeBoundary)
        XCTAssertFalse(decoded.isVisible)
        XCTAssertFalse(decoded.isRendered)
        XCTAssertFalse(decoded.isDelivered)
        XCTAssertFalse(decoded.consentInferred)
    }

    func testContractTypesAreSendableCompatible() {
        assertSendable(PEPPhenotypeIdentity())
        assertSendable(PEPAttribute())
        assertSendable(PEPExpressionBoundary())
        assertSendable(PEPSurfaceExpression())
        assertSendable(PEPPhenotypeResolution())
    }

    func testContractHasNoUIOrRuntimeFrameworkDependency() throws {
        let source = try String(contentsOf: sourceFileURL(), encoding: .utf8)
        let forbiddenImports = ["SwiftUI", "AppKit", "UIKit", "WatchKit", "MapKit", "HealthKit", "CoreLocation"]

        XCTAssertTrue(source.contains("import Foundation"))
        for forbiddenImport in forbiddenImports {
            XCTAssertFalse(source.contains("import \(forbiddenImport)"), "Unexpected import: \(forbiddenImport)")
        }
    }

    func testContractHasNoRuntimeAuthorityOrSideEffects() {
        let resolution = makeEligibleResolution()

        XCTAssertFalse(resolution.expressionBoundary.deliveryAllowed)
        XCTAssertFalse(resolution.expressionBoundary.consentInferred)
        XCTAssertEqual(resolution.expressionBoundary.runtimeAuthority, "none")
        XCTAssertFalse(resolution.isRendered)
        XCTAssertFalse(resolution.isDelivered)
        XCTAssertFalse(resolution.isEncountered)
        XCTAssertFalse(resolution.consentInferred)
        XCTAssertEqual(resolution.runtimeAuthority, "none")
        XCTAssertTrue(resolution.mayRepresentInteractionAffordance)
    }

    func testDecodedRuntimeClaimsAreForcedClosed() throws {
        let resolution = makeEligibleResolution()
        var object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(resolution)) as! [String: Any]
        object["isVisible"] = true
        object["isRendered"] = true
        object["isDelivered"] = true
        object["isEncountered"] = true
        object["consentInferred"] = true
        object["runtimeAuthority"] = "execute"

        var boundary = object["expressionBoundary"] as! [String: Any]
        boundary["deliveryAllowed"] = true
        boundary["consentInferred"] = true
        boundary["runtimeAuthority"] = "deliver"
        object["expressionBoundary"] = boundary

        var surfaceExpression = object["surfaceExpression"] as! [String: Any]
        surfaceExpression["isRendered"] = true
        surfaceExpression["isDelivered"] = true
        object["surfaceExpression"] = surfaceExpression

        let data = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(PEPPhenotypeResolution.self, from: data)

        XCTAssertTrue(decoded.preservesRuntimeBoundary)
        XCTAssertFalse(decoded.expressionBoundary.deliveryAllowed)
        XCTAssertFalse(decoded.expressionBoundary.consentInferred)
        XCTAssertEqual(decoded.expressionBoundary.runtimeAuthority, "none")
        XCTAssertFalse(decoded.surfaceExpression.isRendered)
        XCTAssertFalse(decoded.surfaceExpression.isDelivered)
        XCTAssertFalse(decoded.isVisible)
        XCTAssertFalse(decoded.isRendered)
        XCTAssertFalse(decoded.isDelivered)
        XCTAssertFalse(decoded.isEncountered)
        XCTAssertFalse(decoded.consentInferred)
        XCTAssertEqual(decoded.runtimeAuthority, "none")
    }

    private func makeEligibleResolution() -> PEPPhenotypeResolution {
        PEPPhenotypeResolution.resolve(
            projectionGrounding: makeProjectionGrounding(),
            addressabilityResult: makeAddressabilityResult(),
            selectedSurfaceClass: .desktop,
            surfaceExpression: makeSurfaceExpression(isSelectedSurface: true),
            expressionBoundary: makeBoundary(allowsInteractionAffordance: true),
            attributes: [makeAttribute()]
        )
    }

    private func makeProjectionGrounding(
        authorityStatus: ProjectionAuthorityStatus = ProjectionAuthorityStatus(
            decision: .pass,
            boundaryReference: "boundary.pep.fixture"
        ),
        holdReasons: [ProjectionHoldReason] = []
    ) -> ProjectionGrounding {
        ProjectionGrounding(
            projectionIdentity: makeProjectionIdentity(),
            representedObject: makeObjectIdentity(),
            interactionContext: InteractionContext(
                inputMode: .text,
                preferredOutputMode: .visual,
                resolvedOutputMode: .visual,
                biometricState: .steady,
                environmentState: EnvironmentState(noiseLevel: 0.1, isPublic: false),
                activeDevice: .mac
            ),
            evidenceAnchors: [makeEvidenceAnchor()],
            temporalValidity: TemporalValidity(
                eventTime: Date(timeIntervalSince1970: 10),
                observationTime: Date(timeIntervalSince1970: 20),
                recordingTime: Date(timeIntervalSince1970: 30),
                projectionTime: Date(timeIntervalSince1970: 40),
                freshness: .current
            ),
            authorityStatus: authorityStatus,
            correctionRoute: makeCorrectionRoute(),
            unknownDimensions: [],
            holdReasons: holdReasons
        )
    }

    private func makeAddressabilityResult() -> ArkadasAddressabilityResult {
        let grounding = makeProjectionGrounding()
        let selectedSurface = SurfaceAvailability(
            surface: .mac,
            outputMode: .visual,
            isAvailable: true,
            boundaryReference: "surface.mac.visual"
        )
        let coordinate = SpatialCoordinate(latitude: -37.8136, longitude: 144.9631)!
        let spatialAnchor = SpatialAnchor(
            anchorID: "observer-anchor-1",
            coordinate: coordinate,
            displayName: "Fixture observer frame",
            observedAt: Date(timeIntervalSince1970: 20),
            recordedAt: Date(timeIntervalSince1970: 30),
            evidenceAnchor: makeEvidenceAnchor()
        )

        return ArkadasAddressabilityResult(
            identity: ArkadasAddressabilityIdentity(addressabilityID: "addressability-1"),
            intention: ArkadasIntentionReference(
                intentionID: "intention-1",
                sourceObject: makeObjectIdentity(),
                boundedSummary: "Describe grounded evidence quietly"
            ),
            projectionGrounding: grounding,
            cohabitationFrame: ObserverCohabitationFrame(
                observerID: "observer-1",
                interactionContext: grounding.interactionContext,
                spatialAnchor: spatialAnchor,
                orientationLabel: "seated",
                observedAt: Date(timeIntervalSince1970: 20)
            ),
            availableSurfaces: [selectedSurface],
            selectedSurface: selectedSurface,
            temporalValidity: grounding.temporalValidity,
            correspondenceState: .addressable,
            authorityStatus: ProjectionAuthorityStatus(decision: .pass)
        )
    }

    private func makeSurfaceExpression(
        surfaceClass: PEPSurfaceClass = .desktop,
        semanticEmphasis: String = "Evidence with inverse return",
        attributes: [PEPAttribute] = [PEPAttribute(
            attributeID: "attribute-evidence",
            semanticRole: "Evidence state",
            colorRole: .evidence,
            geometryRole: .anchor,
            motionRole: .none,
            communicationMode: .visual,
            evidenceAnchor: EvidenceAnchor(
                anchorID: "evidence-1",
                kind: .localCaptureReceipt,
                sourceID: "receipt-1",
                state: .sealed,
                claim: "Fixture receipt exists"
            ),
            authorityStatus: ProjectionAuthorityStatus(decision: .pass),
            correctionRoute: CorrectionRoute(
                routeID: "correction-1",
                destination: "fixture-receipt",
                preservesHistory: true
            )
        )],
        modes: [PEPCommunicationMode] = [.visual, .textual],
        interactionAffordance: PEPInteractionAffordanceState = .inspectable,
        isSelectedSurface: Bool = false
    ) -> PEPSurfaceExpression {
        PEPSurfaceExpression(
            surfaceClass: surfaceClass,
            semanticEmphasis: semanticEmphasis,
            attributes: attributes,
            density: .standard,
            priority: .normal,
            legibilityRequirements: ["Preserve evidence and correction labels"],
            availableCommunicationModes: modes,
            interactionAffordance: interactionAffordance,
            isSelectedSurface: isSelectedSurface
        )
    }

    private func makeAttribute(
        evidenceAnchor: EvidenceAnchor = EvidenceAnchor(
            anchorID: "evidence-1",
            kind: .localCaptureReceipt,
            sourceID: "receipt-1",
            state: .sealed,
            claim: "Fixture receipt exists"
        ),
        authorityStatus: ProjectionAuthorityStatus = ProjectionAuthorityStatus(decision: .pass),
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) -> PEPAttribute {
        PEPAttribute(
            attributeID: "attribute-evidence",
            semanticRole: "Evidence state",
            colorRole: .evidence,
            geometryRole: .anchor,
            motionRole: .none,
            communicationMode: .visual,
            evidenceAnchor: evidenceAnchor,
            authorityStatus: authorityStatus,
            confidence: 0.9,
            unknownDimensions: unknownDimensions,
            holdReasons: holdReasons,
            correctionRoute: makeCorrectionRoute()
        )
    }

    private func makeBoundary(allowsInteractionAffordance: Bool = true) -> PEPExpressionBoundary {
        PEPExpressionBoundary(
            authorityStatus: ProjectionAuthorityStatus(decision: .pass, boundaryReference: "boundary.pep.fixture"),
            allowedExpressionModes: [.visual, .textual],
            forbiddenExpressionModes: [.auditory],
            allowsInteractionAffordance: allowsInteractionAffordance,
            correctionRoute: makeCorrectionRoute()
        )
    }

    private func makeObjectIdentity() -> FieldObjectIdentity {
        FieldObjectIdentity(
            objectID: "field-object-1",
            ontologyKind: .capture,
            displayLabel: "Fixture capture",
            sourceObjectID: "receipt-1"
        )
    }

    private func makeProjectionIdentity() -> ProjectionIdentity {
        ProjectionIdentity(
            projectionID: "projection-1",
            surface: .mac,
            representationKind: .card
        )
    }

    private func makeEvidenceAnchor() -> EvidenceAnchor {
        EvidenceAnchor(
            anchorID: "evidence-1",
            kind: .localCaptureReceipt,
            sourceID: "receipt-1",
            state: .sealed,
            claim: "Fixture receipt exists"
        )
    }

    private func makeCorrectionRoute() -> CorrectionRoute {
        CorrectionRoute(
            routeID: "correction-1",
            destination: "fixture-receipt",
            preservesHistory: true
        )
    }

    private func sourceFileURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/DOJOShared/Contracts/PEPPhenotype.swift")
    }
}

private func assertSendable<T: Sendable>(_ value: T) {}
