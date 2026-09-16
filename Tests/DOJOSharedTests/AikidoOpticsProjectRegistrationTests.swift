import XCTest
@testable import DOJOShared

final class AikidoOpticsProjectRegistrationTests: XCTestCase {
    func testRegistersAikidoAsAutonomousSubProjectOfDojoSuite() {
        let registration = AikidoOpticsProjectRegistration.current

        XCTAssertEqual(registration.objectID, "project.aikido-optics")
        XCTAssertEqual(registration.objectClass, .autonomousSubProject)
        XCTAssertEqual(registration.parentProjectID, "project.dojo-suite")
        XCTAssertTrue(registration.isValidFractalRegistration)
    }

    func testProjectOwnsItsDevelopmentConcerns() {
        let boundary = AikidoOpticsProjectRegistration.current.boundary

        XCTAssertTrue(boundary.owns("optical_research"))
        XCTAssertTrue(boundary.owns("manufacturing_relationships"))
        XCTAssertTrue(boundary.owns("project_specific_ip"))
        XCTAssertTrue(boundary.owns("project_roadmap"))
    }

    func testProjectDoesNotOwnDojoOntologyOrManifestationAuthority() {
        let boundary = AikidoOpticsProjectRegistration.current.boundary

        XCTAssertTrue(boundary.doesNotOwn("dojo.source-ontology"))
        XCTAssertTrue(boundary.doesNotOwn("dojo.manifestation-authority"))
        XCTAssertFalse(boundary.owns("dojo.source-ontology"))
        XCTAssertFalse(boundary.owns("dojo.manifestation-authority"))
    }

    func testMirrorPortalIsNotSourceOfTruthOrDirectExecutionRoute() {
        let mirrorPortal = AikidoOpticsProjectRegistration.current.mirrorPortal

        XCTAssertEqual(mirrorPortal.portalID, "portal.dojo-suite.aikido-optics")
        XCTAssertEqual(mirrorPortal.capability, "MirrorPortal")
        XCTAssertFalse(mirrorPortal.sourceOfTruth)
        XCTAssertFalse(mirrorPortal.writesThroughDirectly)
        XCTAssertFalse(AikidoOpticsProjectRegistration.current.canExecuteOpticalAction)
    }

    func testRuntimeStatusKeepsOpticalPhenotypeUnproven() {
        let registration = AikidoOpticsProjectRegistration.current

        XCTAssertEqual(registration.runtimeStatus, .designRegisteredRuntimeUnproven)
        XCTAssertEqual(registration.authorityCeiling, .projectRegistrationOnly)
    }

    func testParticleBoardCardProjectsParentAndIndependentScope() {
        let card = AikidoOpticsProjectRegistration.current.particleBoardCard

        XCTAssertEqual(card.projectID, "project.aikido-optics")
        XCTAssertEqual(card.parentProjectID, "project.dojo-suite")
        XCTAssertEqual(card.parentLabel, "DOJO Suite")
        XCTAssertEqual(card.relationshipLabel, "Autonomous sub-project · contained, not collapsed")
        XCTAssertEqual(card.scopeLabel, "Independent project scope")
        XCTAssertTrue(card.ownedScope.contains("optical_research"))
        XCTAssertTrue(card.ownedScope.contains("manufacturing_relationships"))
        XCTAssertTrue(card.ownedScope.contains("experimental_receipts"))
        XCTAssertTrue(card.ownedScope.contains("project_specific_ip"))
        XCTAssertTrue(card.ownedScope.contains("project_roadmap"))
    }

    func testParticleBoardCardProjectsNonOwnershipAndAuthorityCeiling() {
        let card = AikidoOpticsProjectRegistration.current.particleBoardCard

        XCTAssertEqual(card.nonOwnershipLabel, "Does not own")
        XCTAssertTrue(card.nonOwnedScope.contains("dojo.source-ontology"))
        XCTAssertTrue(card.nonOwnedScope.contains("dojo.manifestation-authority"))
        XCTAssertTrue(card.nonOwnedScope.contains("kings_chamber_arbiter_authority"))
        XCTAssertTrue(card.nonOwnedScope.contains("physical_geometry_truth"))
        XCTAssertTrue(card.nonOwnedScope.contains("observer_intention"))
        XCTAssertEqual(card.statusLabel, "DESIGN_REGISTERED_RUNTIME_UNPROVEN")
        XCTAssertEqual(card.authorityLabel, "PROJECT_REGISTRATION_ONLY")
        XCTAssertTrue(Set(card.ownedScope).isDisjoint(with: Set(card.nonOwnedScope)))
    }

    func testRegistrationRoundTripsThroughCodable() throws {
        let registration = AikidoOpticsProjectRegistration.current
        let data = try JSONEncoder().encode(registration)
        let decoded = try JSONDecoder().decode(AikidoOpticsProjectRegistration.self, from: data)

        XCTAssertEqual(decoded, registration)
    }
}
