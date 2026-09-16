import Foundation
import DOJOShared

public struct DraftManifestationEnvelope: Codable, Equatable, Sendable {
    public let candidateID: String
    public let candidateType: DraftCandidateType
    public let sourceLabel: String
    public let evidenceAnchors: [EvidenceAnchor]
    public let projectionAuthorityStatus: ProjectionAuthorityStatus
    public let correctionRoute: CorrectionRoute
    public let requestedFidelity: ParticleBoardFidelity
    public let phenotype: PEPPhenotypeResolution
    public let artifactReference: String
    public let observerSurfaceAvailable: Bool
    public let saveEnabled: Bool
    public let sendEnabled: Bool
    public let publishEnabled: Bool
    public let applicationControlEnabled: Bool
    public let consentInferred: Bool

    private enum CodingKeys: String, CodingKey {
        case candidateID
        case candidateType
        case sourceLabel
        case evidenceAnchors
        case projectionAuthorityStatus
        case correctionRoute
        case requestedFidelity
        case phenotype
        case artifactReference
        case observerSurfaceAvailable
        case saveEnabled
        case sendEnabled
        case publishEnabled
        case applicationControlEnabled
        case consentInferred
    }

    public init(
        candidateID: String,
        candidateType: DraftCandidateType,
        sourceLabel: String,
        evidenceAnchors: [EvidenceAnchor],
        projectionAuthorityStatus: ProjectionAuthorityStatus,
        correctionRoute: CorrectionRoute,
        requestedFidelity: ParticleBoardFidelity,
        phenotype: PEPPhenotypeResolution,
        artifactReference: String = "fixture://particleboard/aikido-optics/sample-draft",
        observerSurfaceAvailable: Bool = true
    ) {
        self.candidateID = candidateID
        self.candidateType = candidateType
        self.sourceLabel = sourceLabel
        self.evidenceAnchors = evidenceAnchors
        self.projectionAuthorityStatus = projectionAuthorityStatus
        self.correctionRoute = correctionRoute
        self.requestedFidelity = requestedFidelity
        self.phenotype = phenotype
        self.artifactReference = artifactReference
        self.observerSurfaceAvailable = observerSurfaceAvailable
        self.saveEnabled = false
        self.sendEnabled = false
        self.publishEnabled = false
        self.applicationControlEnabled = false
        self.consentInferred = false
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            candidateID: try container.decodeIfPresent(String.self, forKey: .candidateID) ?? "",
            candidateType: try container.decodeIfPresent(DraftCandidateType.self, forKey: .candidateType) ?? .documentPreview,
            sourceLabel: try container.decodeIfPresent(String.self, forKey: .sourceLabel) ?? "Unknown",
            evidenceAnchors: try container.decodeIfPresent([EvidenceAnchor].self, forKey: .evidenceAnchors) ?? [.unknownSource],
            projectionAuthorityStatus: try container.decodeIfPresent(ProjectionAuthorityStatus.self, forKey: .projectionAuthorityStatus) ?? .unknown,
            correctionRoute: try container.decodeIfPresent(CorrectionRoute.self, forKey: .correctionRoute) ?? .unknown,
            requestedFidelity: try container.decodeIfPresent(ParticleBoardFidelity.self, forKey: .requestedFidelity) ?? .preview,
            phenotype: try container.decodeIfPresent(PEPPhenotypeResolution.self, forKey: .phenotype) ?? .unknown,
            artifactReference: try container.decodeIfPresent(String.self, forKey: .artifactReference) ?? "Unknown",
            observerSurfaceAvailable: try container.decodeIfPresent(Bool.self, forKey: .observerSurfaceAvailable) ?? false
        )
    }

    public var isPresentationEligible: Bool {
        !candidateID.isEmpty &&
            phenotype.state == .eligible &&
            phenotype.preservesRuntimeBoundary &&
            projectionAuthorityStatus.decision == .pass &&
            !evidenceAnchors.isEmpty &&
            !evidenceAnchors.contains(.unknownSource) &&
            correctionRoute != .unknown &&
            observerSurfaceAvailable &&
            sideEffectsRemainClosed
    }

    public var isHeld: Bool {
        projectionAuthorityStatus.decision == .hold ||
            phenotype.state == .held ||
            phenotype.holdReasons.contains(.authority)
    }

    public var isUnknown: Bool {
        candidateID.isEmpty ||
            phenotype.state == .unknown ||
            evidenceAnchors.contains(.unknownSource) ||
            correctionRoute == .unknown
    }

    public var sideEffectsRemainClosed: Bool {
        !saveEnabled &&
            !sendEnabled &&
            !publishEnabled &&
            !applicationControlEnabled &&
            !consentInferred
    }
}
