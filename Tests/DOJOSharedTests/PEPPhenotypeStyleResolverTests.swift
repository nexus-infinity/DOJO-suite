import XCTest
import SwiftUI
#if os(macOS)
import AppKit
#endif
@testable import DOJOShared
@testable import DOJOUI

final class PEPPhenotypeStyleResolverTests: XCTestCase {
    func testEveryPEPStateResolvesDeterministically() {
        let states: [PEPPhenotypeResolutionState] = [.eligible, .held, .unknown, .forbidden]
        let first = states.map { PEPPhenotypeStyleResolver.style(for: makeResolution(state: $0)) }
        let second = states.map { PEPPhenotypeStyleResolver.style(for: makeResolution(state: $0)) }

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.map(\.state), states)
    }

    func testEligibleHeldUnknownForbiddenAreVisuallyDistinct() {
        let eligible = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .eligible))
        let held = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .held, holdReasons: [.authority]))
        let unknown = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .unknown, unknownDimensions: [.source]))
        let forbidden = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .forbidden))

        XCTAssertEqual(eligible.stateBadge.token, .pass)
        XCTAssertEqual(held.stateBadge.token, .hold)
        XCTAssertEqual(unknown.stateBadge.token, .unknown)
        XCTAssertEqual(forbidden.stateBadge.token, .forbidden)
        XCTAssertEqual(Set([eligible.stateBadge.symbolName, held.stateBadge.symbolName, unknown.stateBadge.symbolName, forbidden.stateBadge.symbolName]).count, 4)
        XCTAssertEqual(Set([eligible.stateBadge.label, held.stateBadge.label, unknown.stateBadge.label, forbidden.stateBadge.label]).count, 4)
    }

    func testHoldAndForbiddenProduceNoEnabledActionAffordance() {
        let held = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .held, holdReasons: [.authority]))
        let forbidden = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .forbidden))

        XCTAssertEqual(held.actionAffordance, .none)
        XCTAssertFalse(held.actionAffordanceEnabled)
        XCTAssertEqual(forbidden.actionAffordance, .none)
        XCTAssertFalse(forbidden.actionAffordanceEnabled)
    }

    func testColourIsReinforcedByLabelSymbolAndBoundary() {
        let style = PEPPhenotypeStyleResolver.style(for: makeResolution(state: .held, holdReasons: [.authority]))

        XCTAssertEqual(style.accentToken, .hold)
        XCTAssertTrue(style.reinforcesWithLabel)
        XCTAssertTrue(style.reinforcesWithSymbol)
        XCTAssertTrue(style.reinforcesWithBoundary)
        XCTAssertEqual(style.stateBadge.label, "HOLD")
        XCTAssertEqual(style.stateBadge.symbolName, "pause.circle")
        XCTAssertEqual(style.shapeToken, .heldBoundary)
    }

    func testLineageAndAuthorityAreNotAlteredDuringStyleResolution() {
        let resolution = makeResolution(state: .eligible)
        let style = PEPPhenotypeStyleResolver.style(for: resolution)

        XCTAssertEqual(resolution.projectionGrounding?.representedObject.objectID, "field-object-style-1")
        XCTAssertEqual(resolution.projectionGrounding?.projectionIdentity.projectionID, "projection-style-1")
        XCTAssertEqual(resolution.expressionBoundary.authorityStatus.decision, .pass)
        XCTAssertTrue(style.lineageSummary.contains("field-object-style-1"))
        XCTAssertTrue(style.lineageSummary.contains("projection-style-1"))
        XCTAssertEqual(style.authoritySummary, "Authority PASS")
    }

    func testHostileOrIncompleteValuesFailClosed() {
        let hostile = makeResolution(
            state: .eligible,
            boundary: PEPExpressionBoundary(
                authorityStatus: .authorityHold,
                allowedExpressionModes: [.visual],
                allowsInteractionAffordance: true,
                correctionRoute: makeCorrectionRoute()
            ),
            holdReasons: [.authority]
        )
        let style = PEPPhenotypeStyleResolver.style(for: hostile)

        XCTAssertEqual(style.actionAffordance, .none)
        XCTAssertFalse(style.actionAffordanceEnabled)
        XCTAssertEqual(style.accentToken, .hold)
        XCTAssertTrue(style.accessibilityLabel.contains("HOLD.Authority"))
    }

    func testResolverHasNoRuntimeEffect() {
        let resolution = makeResolution(state: .eligible)
        let style = PEPPhenotypeStyleResolver.style(for: resolution)

        XCTAssertFalse(resolution.isRendered)
        XCTAssertFalse(resolution.isDelivered)
        XCTAssertFalse(resolution.isEncountered)
        XCTAssertFalse(resolution.consentInferred)
        XCTAssertEqual(resolution.runtimeAuthority, "none")
        XCTAssertEqual(style.actionAffordance, .actionRepresentable)
    }

    func testResolverSourceHasNoRoutingDeliveryOrSensorDependency() throws {
        let source = try String(contentsOf: resolverSourceURL(), encoding: .utf8)
        let forbiddenTerms = [
            "CLLocationManager",
            "MapKit",
            "HealthKit",
            "AVCapture",
            "WatchConnectivity",
            "CloudKit",
            "URLSession",
            "send(",
            "deliver(",
            "route(",
            "writeReceipt"
        ]

        XCTAssertTrue(source.contains("import SwiftUI"))
        XCTAssertTrue(source.contains("import DOJOShared"))
        for term in forbiddenTerms {
            XCTAssertFalse(source.contains(term), "Unexpected runtime term: \(term)")
        }
    }

    @MainActor
    func testBadgeViewRendersVisualArtifact() throws {
        #if os(macOS)
        let styles = [
            PEPPhenotypeStyleResolver.style(for: makeResolution(state: .eligible)),
            PEPPhenotypeStyleResolver.style(for: makeResolution(state: .held, holdReasons: [.authority])),
            PEPPhenotypeStyleResolver.style(for: makeResolution(state: .unknown, unknownDimensions: [.source])),
            PEPPhenotypeStyleResolver.style(for: makeResolution(state: .forbidden))
        ]
        let view = HStack(spacing: 10) {
            ForEach(styles.indices, id: \.self) { index in
                PEPPhenotypeBadgeView(style: styles[index])
            }
        }
        .padding(14)
        .background(Color(hex: "#111318"))

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let nsImage = renderer.nsImage,
              let tiff = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            throw XCTSkip("SwiftUI ImageRenderer did not produce a macOS image in this environment.")
        }

        let outputURL = visualArtifactURL()
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try png.write(to: outputURL)

        XCTAssertGreaterThan(try Data(contentsOf: outputURL).count, 1_000)
        #else
        throw XCTSkip("Visual artifact rendering is macOS-only for this test target.")
        #endif
    }

    private func makeResolution(
        state: PEPPhenotypeResolutionState,
        boundary: PEPExpressionBoundary? = nil,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) -> PEPPhenotypeResolution {
        let grounding = makeGrounding(
            authorityStatus: state == .forbidden
                ? ProjectionAuthorityStatus(decision: .fail)
                : state == .held
                    ? .authorityHold
                    : ProjectionAuthorityStatus(decision: .pass),
            unknownDimensions: unknownDimensions,
            holdReasons: holdReasons
        )
        let expressionBoundary = boundary ?? PEPExpressionBoundary(
            authorityStatus: grounding.authorityStatus,
            allowedExpressionModes: [.visual, .textual],
            allowsInteractionAffordance: true,
            correctionRoute: makeCorrectionRoute(),
            unknownDimensions: unknownDimensions,
            holdReasons: holdReasons
        )
        let expression = PEPSurfaceExpression(
            surfaceClass: .desktop,
            semanticEmphasis: "Provider capability expression",
            attributes: [makeAttribute(authorityStatus: grounding.authorityStatus)],
            density: .compact,
            priority: state == .held ? .hold : .normal,
            legibilityRequirements: ["label", "symbol", "boundary"],
            availableCommunicationModes: [.visual, .textual],
            interactionAffordance: .actionRepresentable,
            isSelectedSurface: true
        )

        return PEPPhenotypeResolution(
            state: state,
            identity: PEPPhenotypeIdentity(
                phenotypeID: "pep-style-\(state.rawValue)",
                genotypeObject: grounding.representedObject,
                projectionIdentity: grounding.projectionIdentity,
                sourceExpression: expression.semanticEmphasis
            ),
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: expression,
            expressionBoundary: expressionBoundary,
            resolvedAttributes: expression.attributes,
            unknownDimensions: unknownDimensions,
            holdReasons: holdReasons,
            correctionRoute: makeCorrectionRoute()
        )
    }

    private func makeGrounding(
        authorityStatus: ProjectionAuthorityStatus,
        unknownDimensions: [UnknownDimension],
        holdReasons: [ProjectionHoldReason]
    ) -> ProjectionGrounding {
        ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "projection-style-1",
                surface: .mac,
                representationKind: .card
            ),
            representedObject: FieldObjectIdentity(
                objectID: "field-object-style-1",
                ontologyKind: .generatedObject,
                displayLabel: "Provider style fixture"
            ),
            interactionContext: InteractionContext(activeDevice: .mac),
            evidenceAnchors: [makeEvidenceAnchor()],
            temporalValidity: TemporalValidity(projectionTime: Date(timeIntervalSince1970: 100), freshness: .current),
            authorityStatus: authorityStatus,
            correctionRoute: makeCorrectionRoute(),
            unknownDimensions: unknownDimensions,
            holdReasons: holdReasons
        )
    }

    private func makeAttribute(authorityStatus: ProjectionAuthorityStatus) -> PEPAttribute {
        PEPAttribute(
            attributeID: "style-attribute-1",
            semanticRole: "Capability state",
            colorRole: .authority,
            geometryRole: .boundary,
            motionRole: .none,
            communicationMode: .visual,
            evidenceAnchor: makeEvidenceAnchor(),
            authorityStatus: authorityStatus,
            correctionRoute: makeCorrectionRoute()
        )
    }

    private func makeEvidenceAnchor() -> EvidenceAnchor {
        EvidenceAnchor(
            anchorID: "evidence-style-1",
            kind: .humanReport,
            sourceID: "fixture-style-1",
            state: .witnessed,
            claim: "Deterministic style fixture"
        )
    }

    private func makeCorrectionRoute() -> CorrectionRoute {
        CorrectionRoute(routeID: "correction-style-1", destination: "style-fixture", preservesHistory: true)
    }

    private func resolverSourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/DOJOUI/DesignSystem/PEPPhenotypeStyleResolver.swift")
    }

    private func visualArtifactURL() -> URL {
        URL(fileURLWithPath: "/private/tmp/dojo-pep-proof/pep-phenotype-badges.png")
    }
}
