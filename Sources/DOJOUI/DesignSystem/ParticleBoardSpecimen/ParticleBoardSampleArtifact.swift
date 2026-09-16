import Foundation
import DOJOShared

public enum ParticleBoardSampleArtifact {
    public static let evidence = EvidenceAnchor(
        anchorID: "fixture-evidence-aikido-optics-1",
        kind: .generatedObject,
        sourceID: "fixture-draft-source-1",
        state: .witnessed,
        claim: "Development-only screenshot draft fixture for Aikido Optics reveal."
    )

    public static let correctionRoute = CorrectionRoute(
        routeID: "fixture-correction-aikido-optics-1",
        destination: "in-memory://particleboard/aikido-optics/correction",
        preservesHistory: true
    )

    public static func eligibleEnvelope() -> DraftManifestationEnvelope {
        DraftManifestationEnvelope(
            candidateID: "fixture-draft-candidate-eligible-1",
            candidateType: .screenshot,
            sourceLabel: "FIXTURE / DEVELOPMENT PROOF - NOT LIVE LOCATION",
            evidenceAnchors: [evidence],
            projectionAuthorityStatus: ProjectionAuthorityStatus(
                decision: .pass,
                boundaryReference: "Fixture.ParticleBoard.VisualMatter.Presentation",
                nextEvidence: nil
            ),
            correctionRoute: correctionRoute,
            requestedFidelity: .photographic,
            phenotype: phenotype(state: .eligible, authority: .pass)
        )
    }

    public static func heldEnvelope() -> DraftManifestationEnvelope {
        DraftManifestationEnvelope(
            candidateID: "fixture-draft-candidate-held-1",
            candidateType: .image,
            sourceLabel: "FIXTURE / DEVELOPMENT PROOF - AUTHORITY HOLD",
            evidenceAnchors: [evidence],
            projectionAuthorityStatus: .authorityHold,
            correctionRoute: correctionRoute,
            requestedFidelity: .readable,
            phenotype: phenotype(state: .held, authority: .hold, holds: [.authority])
        )
    }

    public static func unknownEnvelope() -> DraftManifestationEnvelope {
        DraftManifestationEnvelope(
            candidateID: "",
            candidateType: .documentPreview,
            sourceLabel: "FIXTURE / DEVELOPMENT PROOF - UNKNOWN SOURCE",
            evidenceAnchors: [.unknownSource],
            projectionAuthorityStatus: .unknown,
            correctionRoute: .unknown,
            requestedFidelity: .preview,
            phenotype: phenotype(state: .unknown, authority: .unknown, unknowns: [.identity, .source, .correctionRoute], holds: [.evidence]),
            observerSurfaceAvailable: false
        )
    }

    public static func particles(count: Int = ParticleBoardFidelity.photographic.particleCount) -> [VisualParticle] {
        AikidoOpticsProjection.seedParticles(count: count, seed: 717)
    }

    private static func phenotype(
        state: PEPPhenotypeResolutionState,
        authority: ProjectionAuthorityStatus.Decision,
        unknowns: [UnknownDimension] = [],
        holds: [ProjectionHoldReason] = []
    ) -> PEPPhenotypeResolution {
        let object = FieldObjectIdentity(
            objectID: "field-object-aikido-optics-fixture-1",
            ontologyKind: .generatedObject,
            displayLabel: "Aikido Optics draft artifact",
            sourceObjectID: "fixture-draft-source-1"
        )
        let projection = ProjectionIdentity(
            projectionID: "projection-aikido-optics-fixture-1",
            surface: .mac,
            representationKind: .overlay
        )
        let authorityStatus = ProjectionAuthorityStatus(
            decision: authority,
            boundaryReference: authority == .pass ? "Fixture.Authority.Pass" : "Fixture.Authority.\(authority.rawValue)",
            nextEvidence: authority == .pass ? nil : "Recover presentation authority before revealing content."
        )
        let grounding = ProjectionGrounding(
            projectionIdentity: projection,
            representedObject: object,
            interactionContext: InteractionContext(activeDevice: .mac),
            evidenceAnchors: unknowns.contains(.source) ? [.unknownSource] : [evidence],
            temporalValidity: TemporalValidity(
                eventTime: Date(timeIntervalSince1970: 1_789_000_000),
                observationTime: Date(timeIntervalSince1970: 1_789_000_030),
                recordingTime: Date(timeIntervalSince1970: 1_789_000_060),
                projectionTime: Date(timeIntervalSince1970: 1_789_000_120),
                freshness: state == .eligible ? .current : .partial
            ),
            authorityStatus: authorityStatus,
            correctionRoute: unknowns.contains(.correctionRoute) ? .unknown : correctionRoute,
            unknownDimensions: unknowns,
            holdReasons: holds
        )
        let attribute = PEPAttribute(
            attributeID: "pep-attribute-aikido-optics-fixture-1",
            semanticRole: "Draft reveal visual matter",
            colorRole: state == .held ? .hold : .evidence,
            geometryRole: .correspondence,
            motionRole: .transition,
            communicationMode: .visual,
            evidenceAnchor: unknowns.contains(.source) ? .unknownSource : evidence,
            authorityStatus: authorityStatus,
            confidence: state == .eligible ? 0.84 : nil,
            unknownDimensions: unknowns,
            holdReasons: holds,
            correctionRoute: unknowns.contains(.correctionRoute) ? .unknown : correctionRoute
        )
        let boundary = PEPExpressionBoundary(
            authorityStatus: authorityStatus,
            allowedExpressionModes: [.visual, .textual],
            forbiddenExpressionModes: [.auditory, .haptic, .multimodal],
            allowsInteractionAffordance: state == .eligible,
            correctionRoute: unknowns.contains(.correctionRoute) ? .unknown : correctionRoute,
            unknownDimensions: unknowns,
            holdReasons: holds
        )
        let expression = PEPSurfaceExpression(
            surfaceClass: .desktop,
            semanticEmphasis: "Development-only draft reveal",
            attributes: [attribute],
            density: .expanded,
            priority: state == .held ? .hold : .normal,
            legibilityRequirements: ["Readable artifact", "Non-colour state label", "No delivery claim"],
            availableCommunicationModes: [.visual, .textual],
            interactionAffordance: state == .eligible ? .correctable : .inspectable,
            isSelectedSurface: true
        )
        let resolved = PEPPhenotypeResolution.resolve(
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: expression,
            expressionBoundary: boundary,
            attributes: [attribute]
        )
        if resolved.state == state {
            return resolved
        }
        return PEPPhenotypeResolution(
            state: state,
            identity: resolved.identity,
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: expression,
            expressionBoundary: boundary,
            resolvedAttributes: [attribute],
            unknownDimensions: unknowns,
            holdReasons: holds,
            correctionRoute: unknowns.contains(.correctionRoute) ? .unknown : correctionRoute
        )
    }
}
