import Foundation

/// Runtime identity for Aikido Optics as a first-class project inside DOJO Suite.
///
/// This registers project containment and authority boundaries. It does not claim
/// that optical hardware, physical registration, or the observer loop is proven.
public enum AikidoOpticsProjectClass: String, Codable, Sendable {
    case autonomousSubProject = "AutonomousSubProject"
}

public enum AikidoOpticsRuntimeStatus: String, Codable, Sendable {
    case designRegisteredRuntimeUnproven = "DESIGN_REGISTERED_RUNTIME_UNPROVEN"
}

public enum AikidoOpticsAuthorityCeiling: String, Codable, Sendable {
    case projectRegistrationOnly = "PROJECT_REGISTRATION_ONLY"
}

public struct AikidoOpticsProjectBoundary: Codable, Equatable, Sendable {
    public let owns: [String]
    public let inherits: [String]
    public let doesNotOwn: [String]

    public init(owns: [String], inherits: [String], doesNotOwn: [String]) {
        self.owns = owns
        self.inherits = inherits
        self.doesNotOwn = doesNotOwn
    }

    public func owns(_ objectID: String) -> Bool {
        owns.contains(objectID)
    }

    public func doesNotOwn(_ objectID: String) -> Bool {
        doesNotOwn.contains(objectID)
    }
}

public struct AikidoOpticsMirrorPortalRegistration: Codable, Equatable, Sendable {
    public let portalID: String
    public let capability: String
    public let sourceOfTruth: Bool
    public let writesThroughDirectly: Bool

    public init(
        portalID: String,
        capability: String,
        sourceOfTruth: Bool,
        writesThroughDirectly: Bool
    ) {
        self.portalID = portalID
        self.capability = capability
        self.sourceOfTruth = sourceOfTruth
        self.writesThroughDirectly = writesThroughDirectly
    }
}

public struct AikidoOpticsProjectRegistration: Codable, Equatable, Sendable {
    public let objectID: String
    public let objectClass: AikidoOpticsProjectClass
    public let displayName: String
    public let parentProjectID: String
    public let runtimeStatus: AikidoOpticsRuntimeStatus
    public let lawfulHome: String
    public let boundary: AikidoOpticsProjectBoundary
    public let mirrorPortal: AikidoOpticsMirrorPortalRegistration
    public let authorityCeiling: AikidoOpticsAuthorityCeiling
    public let registeredAt: String

    public init(
        objectID: String,
        objectClass: AikidoOpticsProjectClass,
        displayName: String,
        parentProjectID: String,
        runtimeStatus: AikidoOpticsRuntimeStatus,
        lawfulHome: String,
        boundary: AikidoOpticsProjectBoundary,
        mirrorPortal: AikidoOpticsMirrorPortalRegistration,
        authorityCeiling: AikidoOpticsAuthorityCeiling,
        registeredAt: String
    ) {
        self.objectID = objectID
        self.objectClass = objectClass
        self.displayName = displayName
        self.parentProjectID = parentProjectID
        self.runtimeStatus = runtimeStatus
        self.lawfulHome = lawfulHome
        self.boundary = boundary
        self.mirrorPortal = mirrorPortal
        self.authorityCeiling = authorityCeiling
        self.registeredAt = registeredAt
    }

    /// True only when project containment and non-collapse boundaries are intact.
    public var isValidFractalRegistration: Bool {
        objectID == "project.aikido-optics" &&
        objectClass == .autonomousSubProject &&
        parentProjectID == "project.dojo-suite" &&
        boundary.doesNotOwn("dojo.source-ontology") &&
        boundary.doesNotOwn("dojo.manifestation-authority") &&
        !mirrorPortal.sourceOfTruth &&
        !mirrorPortal.writesThroughDirectly
    }

    /// The current runtime may expose identity and routing metadata only.
    public var canExecuteOpticalAction: Bool {
        false
    }

    /// Presentation-only projection for the Particle Board project card.
    ///
    /// The card reads the registered relationship and boundaries; it does not
    /// become a second registration surface or acquire execution authority.
    public var particleBoardCard: AikidoOpticsProjectCardProjection {
        AikidoOpticsProjectCardProjection(
            projectID: objectID,
            title: displayName,
            parentProjectID: parentProjectID,
            parentLabel: "DOJO Suite",
            relationshipLabel: "Autonomous sub-project · contained, not collapsed",
            scopeLabel: "Independent project scope",
            ownedScope: boundary.owns,
            nonOwnershipLabel: "Does not own",
            nonOwnedScope: boundary.doesNotOwn,
            statusLabel: runtimeStatus.rawValue,
            authorityLabel: authorityCeiling.rawValue
        )
    }

    /// Canonical local registration for the DOJO Suite runtime.
    public static let current = AikidoOpticsProjectRegistration(
        objectID: "project.aikido-optics",
        objectClass: .autonomousSubProject,
        displayName: "Aikido Optics",
        parentProjectID: "project.dojo-suite",
        runtimeStatus: .designRegisteredRuntimeUnproven,
        lawfulHome: "/Users/field/DOJO-suite",
        boundary: AikidoOpticsProjectBoundary(
            owns: [
                "aikido_optics_ontology",
                "optical_research",
                "prototype_generations",
                "manufacturing_relationships",
                "experimental_receipts",
                "project_specific_ip",
                "project_roadmap",
                "project_risks",
                "project_completion_criteria"
            ],
            inherits: [
                "dojo_suite_mirror_portal_contract",
                "field_observer_model",
                "dojo_ontology_interface",
                "field_provenance_and_receipt_discipline"
            ],
            doesNotOwn: [
                "dojo.source-ontology",
                "dojo.manifestation-authority",
                "kings_chamber_arbiter_authority",
                "physical_geometry_truth",
                "observer_intention"
            ]
        ),
        mirrorPortal: AikidoOpticsMirrorPortalRegistration(
            portalID: "portal.dojo-suite.aikido-optics",
            capability: "MirrorPortal",
            sourceOfTruth: false,
            writesThroughDirectly: false
        ),
        authorityCeiling: .projectRegistrationOnly,
        registeredAt: "2026-08-26T03:05:15+10:00"
    )
}

public struct AikidoOpticsProjectCardProjection: Equatable, Sendable {
    public let projectID: String
    public let title: String
    public let parentProjectID: String
    public let parentLabel: String
    public let relationshipLabel: String
    public let scopeLabel: String
    public let ownedScope: [String]
    public let nonOwnershipLabel: String
    public let nonOwnedScope: [String]
    public let statusLabel: String
    public let authorityLabel: String

    public init(
        projectID: String,
        title: String,
        parentProjectID: String,
        parentLabel: String,
        relationshipLabel: String,
        scopeLabel: String,
        ownedScope: [String],
        nonOwnershipLabel: String,
        nonOwnedScope: [String],
        statusLabel: String,
        authorityLabel: String
    ) {
        self.projectID = projectID
        self.title = title
        self.parentProjectID = parentProjectID
        self.parentLabel = parentLabel
        self.relationshipLabel = relationshipLabel
        self.scopeLabel = scopeLabel
        self.ownedScope = ownedScope
        self.nonOwnershipLabel = nonOwnershipLabel
        self.nonOwnedScope = nonOwnedScope
        self.statusLabel = statusLabel
        self.authorityLabel = authorityLabel
    }
}
