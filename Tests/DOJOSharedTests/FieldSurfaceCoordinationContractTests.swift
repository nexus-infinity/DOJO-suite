import XCTest
@testable import DOJOShared

final class FieldSurfaceCoordinationContractTests: XCTestCase {
    func testCatalogueUsesOneGenotypeWithDistinctSurfaceIdentities() {
        let entries = FieldSurfaceCoordinationCatalog.entries

        XCTAssertGreaterThanOrEqual(entries.count, 10)
        XCTAssertEqual(Set(entries.map(\.genotypeID)), [FieldSurfaceCoordinationCatalog.genotypeID])
        XCTAssertEqual(Set(entries.map(\.surfaceID)).count, entries.count)
        XCTAssertTrue(entries.allSatisfy { !$0.globalFieldAuthority })
        XCTAssertTrue(FieldSurfaceCoordinationCatalog.invariantViolations().isEmpty)
    }

    func testArchitectAndCoordinationRolesRemainDistinct() {
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "linear")?.role, .architectHandoff)
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "trello")?.role, .coordination)
        XCTAssertNotEqual(
            FieldSurfaceCoordinationCatalog.entry(for: "linear")?.role,
            FieldSurfaceCoordinationCatalog.entry(for: "trello")?.role
        )
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "linear")?.authorityCeiling, "HANDOFF_ONLY")
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "trello")?.authorityCeiling, "COORDINATION_ONLY")
    }

    func testAkronToInternalRouteIsPointerOnlyAndReceiptBound() {
        let decision = FieldSurfaceCoordinationCatalog.routeDecision(
            from: "akron",
            to: "obiwan",
            kind: .pointerOnly
        )

        XCTAssertEqual(decision.result, .pass)
        XCTAssertTrue(decision.isPermitted)
        XCTAssertTrue(FieldSurfaceCoordinationCatalog.routes.first(where: { $0.id == "akron-to-obiwan" })!.requiresReceipt)
        XCTAssertFalse(FieldSurfaceCoordinationCatalog.routes.first(where: { $0.id == "akron-to-obiwan" })!.contentCopyAllowed)
    }

    func testInternalObserverReturnIsSeparateFromExternalIntake() {
        let decision = FieldSurfaceCoordinationCatalog.routeDecision(
            from: "obiwan",
            to: "dojo",
            kind: .internalObservationReturn
        )

        XCTAssertEqual(decision.result, .pass)
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "akron")?.plane, .externalIntake)
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "obiwan")?.plane, .internalCirculation)
        XCTAssertEqual(FieldSurfaceCoordinationCatalog.entry(for: "dojo")?.plane, .internalCirculation)
    }

    func testUnregisteredCrossSurfaceExecutionRouteHolds() {
        let directProviderExecution = FieldSurfaceCoordinationCatalog.routeDecision(
            from: "notion",
            to: "vercel",
            kind: .hostedPhenotypePointer
        )
        let unknownSurface = FieldSurfaceCoordinationCatalog.routeDecision(
            from: "unknown",
            to: "dojo",
            kind: .pointerOnly
        )

        XCTAssertEqual(directProviderExecution.result, .hold)
        XCTAssertEqual(unknownSurface.result, .hold)
    }

    func testCodableRoundTripPreservesSurfaceAndRouteBoundaries() throws {
        let entry = try XCTUnwrap(FieldSurfaceCoordinationCatalog.entry(for: "linear"))
        let route = try XCTUnwrap(FieldSurfaceCoordinationCatalog.routes.first(where: { $0.id == "linear-to-github" }))

        XCTAssertEqual(try JSONDecoder().decode(FieldSurfaceCoordinationEntry.self, from: JSONEncoder().encode(entry)), entry)
        XCTAssertEqual(try JSONDecoder().decode(FieldSurfaceTransferRoute.self, from: JSONEncoder().encode(route)), route)
    }

    func testDojoTodayMacSurfaceNodeSeparatesConfigurationInfrastructureAndUtilisation() throws {
        let node = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))

        XCTAssertEqual(node.kind, .mac)
        XCTAssertEqual(node.configuration.permissionProfile, "LOCAL_OPERATOR_VISIBLE_ONLY")
        XCTAssertEqual(node.configuration.authorityCeiling, "EXPERIENCE_AND_LOCAL_CAPTURE_ONLY")
        XCTAssertFalse(node.configuration.globalFieldAuthority)
        XCTAssertEqual(node.infrastructure.state, .partial)
        XCTAssertEqual(node.infrastructure.networkBoundary, "No live Notion MCP from app")
        XCTAssertEqual(node.utilisation.context, .desktopWorking)
        XCTAssertEqual(node.utilisation.currentObserverID, "local-operator")
        XCTAssertFalse(node.utilisation.consentInferred)
        XCTAssertTrue(node.outputChannels.contains(.visual))
        XCTAssertTrue(node.outputChannels.contains(.evidential))
        XCTAssertTrue(node.inputChannels.contains(.keyboard))
        XCTAssertTrue(node.invariantViolations().isEmpty)
    }

    func testObjectContextSignalEdgeDoesNotMutateConfigurationInfrastructureAuthorityOrConsent() throws {
        let edge = try XCTUnwrap(FieldSurfaceCoordinationCatalog.signalEdge(for: "dojo_today_object_context_open"))

        XCTAssertEqual(edge.source, FieldSignalEndpoint(kind: .object, id: "selected-generated-object"))
        XCTAssertEqual(edge.receiver, FieldSignalEndpoint(kind: .observer, id: "local-operator"))
        XCTAssertEqual(edge.surfaceID, "dojo_today_mac")
        XCTAssertEqual(edge.channel, .visual)
        XCTAssertEqual(edge.lane, .evidential)
        XCTAssertEqual(edge.permissionProfile, "READ_ONLY_CONTEXT_PROJECTION")
        XCTAssertFalse(edge.configurationMutationAllowed)
        XCTAssertFalse(edge.infrastructureMutationAllowed)
        XCTAssertFalse(edge.runtimeAuthorityGranted)
        XCTAssertFalse(edge.consentInferred)
        XCTAssertTrue(edge.invariantViolations().isEmpty)
    }

    func testSurfaceNodeAndSignalEdgeCodableRoundTrip() throws {
        let node = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))
        let edge = try XCTUnwrap(FieldSurfaceCoordinationCatalog.signalEdge(for: "dojo_today_object_context_open"))

        XCTAssertEqual(try JSONDecoder().decode(FieldSurfaceNode.self, from: JSONEncoder().encode(node)), node)
        XCTAssertEqual(try JSONDecoder().decode(FieldSignalGraphEdge.self, from: JSONEncoder().encode(edge)), edge)
    }

    func testHostileSurfaceNodeAndSignalEdgeFailClosed() {
        let node = FieldSurfaceNode(
            id: "",
            displayName: "",
            kind: .unknown,
            outputChannels: [],
            inputChannels: [],
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: [],
                allowedActions: [],
                permissionProfile: "",
                authorityCeiling: "",
                globalFieldAuthority: true
            ),
            utilisation: FieldSurfaceUtilisationFacet(consentInferred: true)
        )
        XCTAssertFalse(node.invariantViolations().isEmpty)

        let edge = FieldSignalGraphEdge(
            id: "",
            source: FieldSignalEndpoint(kind: .unknown, id: ""),
            receiver: FieldSignalEndpoint(kind: .unknown, id: ""),
            channel: .unknown,
            lane: .permission,
            surfaceID: "",
            meaningPointer: "",
            permissionProfile: "",
            evidencePointer: "",
            feedbackPath: "",
            configurationMutationAllowed: true,
            infrastructureMutationAllowed: true,
            runtimeAuthorityGranted: true,
            consentInferred: true
        )
        XCTAssertFalse(edge.invariantViolations().isEmpty)
    }

    func testPermissionProfilesSeparateDesktopAndVehicleConstraints() throws {
        let desktop = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "READ_ONLY_CONTEXT_PROJECTION"))
        let vehicle = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "VEHICLE_SAFETY_RESTRICTED"))

        XCTAssertEqual(desktop.decision(for: .visual), .pass)
        XCTAssertEqual(desktop.decision(for: .voice), .hold)
        XCTAssertEqual(vehicle.decision(for: .audio), .pass)
        XCTAssertEqual(vehicle.decision(for: .visual), .hold)
        XCTAssertFalse(desktop.canMutateSource)
        XCTAssertFalse(desktop.canControlApplication)
        XCTAssertFalse(desktop.canSendOrPublish)
        XCTAssertFalse(desktop.consentInferred)
        XCTAssertFalse(vehicle.canMutateSource)
        XCTAssertFalse(vehicle.canControlApplication)
        XCTAssertFalse(vehicle.canSendOrPublish)
        XCTAssertFalse(vehicle.consentInferred)
        XCTAssertTrue(desktop.invariantViolations().isEmpty)
        XCTAssertTrue(vehicle.invariantViolations().isEmpty)
    }

    func testObserverContextKeepsConfigurationInfrastructureAndUtilisationSeparate() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))

        XCTAssertEqual(context.permissionProfileID, "READ_ONLY_CONTEXT_PROJECTION")
        XCTAssertEqual(context.continuityContractID, "DOJO.Today.LocalContinuity.V0")
        XCTAssertEqual(context.primaryDeviceID, "dojo_today_mac")
        XCTAssertTrue(context.availableSurfaceIDs.contains("dojo_today_mac"))
        XCTAssertTrue(context.availableSurfaceIDs.contains("vehicle_safety_simulator"))
        XCTAssertEqual(context.activity.kind, .deskWork)
        XCTAssertFalse(context.activity.safetyCritical)
        XCTAssertEqual(context.attention.level, .medium)
        XCTAssertEqual(context.attention.mode, .visualPrimary)
        XCTAssertEqual(context.location.semantic, .atDesk)
        XCTAssertEqual(context.activeObjects.first?.id, "selected-generated-object")
        XCTAssertEqual(context.continuityPromises.first?.status, .active)
        XCTAssertEqual(context.integrityStatus.code, .ok)
        XCTAssertTrue(context.invariantViolations(knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))).isEmpty)
    }

    func testVehicleSurfaceNodeAndContinuityEdgeRemainDeferredAndNonAuthoritative() throws {
        let node = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "vehicle_safety_simulator"))
        let edge = try XCTUnwrap(FieldSurfaceCoordinationCatalog.signalEdge(for: "dojo_today_vehicle_continuity_deferred"))

        XCTAssertEqual(node.kind, .vehicle)
        XCTAssertEqual(node.infrastructure.state, .held)
        XCTAssertEqual(node.infrastructure.networkBoundary, "No CarPlay or vehicle integration")
        XCTAssertEqual(node.utilisation.context, .safetyConstrained)
        XCTAssertFalse(node.configuration.globalFieldAuthority)
        XCTAssertFalse(node.utilisation.consentInferred)
        XCTAssertEqual(edge.surfaceID, "vehicle_safety_simulator")
        XCTAssertEqual(edge.permissionProfile, "VEHICLE_SAFETY_RESTRICTED")
        XCTAssertEqual(edge.evidencePointer, "HOLD.SimulatedVehicleSurfaceOnly")
        XCTAssertFalse(edge.configurationMutationAllowed)
        XCTAssertFalse(edge.infrastructureMutationAllowed)
        XCTAssertFalse(edge.runtimeAuthorityGranted)
        XCTAssertFalse(edge.consentInferred)
        XCTAssertTrue(node.invariantViolations().isEmpty)
        XCTAssertTrue(edge.invariantViolations().isEmpty)
    }

    func testPulseWebSurfaceStaysCarrierPointerOnly() throws {
        let node = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "vercel_pulse_web"))
        let edge = try XCTUnwrap(FieldSurfaceCoordinationCatalog.signalEdge(for: "dojo_today_to_pulse_coherence_intent"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "PULSE_TREATY_POINTER_ONLY"))

        XCTAssertEqual(node.displayName, "Field-PULSE Web Surface")
        XCTAssertEqual(node.infrastructure.state, .unknown)
        XCTAssertEqual(node.infrastructure.networkBoundary, "No Vercel call or PULSE runtime binding")
        XCTAssertEqual(node.configuration.authorityCeiling, "CARRIER_POINTER_ONLY")
        XCTAssertFalse(node.configuration.globalFieldAuthority)
        XCTAssertFalse(node.utilisation.consentInferred)
        XCTAssertEqual(edge.receiver, FieldSignalEndpoint(kind: .service, id: "field-pulse"))
        XCTAssertEqual(edge.surfaceID, "vercel_pulse_web")
        XCTAssertEqual(edge.permissionProfile, "PULSE_TREATY_POINTER_ONLY")
        XCTAssertFalse(edge.runtimeAuthorityGranted)
        XCTAssertFalse(edge.infrastructureMutationAllowed)
        XCTAssertEqual(profile.decision(for: .ambient), .pass)
        XCTAssertEqual(profile.decision(for: .visual), .hold)
        XCTAssertFalse(profile.canControlApplication)
        XCTAssertFalse(profile.canSendOrPublish)
    }

    func testPulseTreatyMessagesAreKernelOrderedAndNonCollapsing() {
        let intent = FieldSurfaceCoordinationCatalog.pulseTreatyIntent
        let snapshot = FieldSurfaceCoordinationCatalog.pulseTreatySnapshot
        let notice = FieldSurfaceCoordinationCatalog.pulseTreatyHoldExitNotice

        XCTAssertEqual(FieldPulseTreatyAdapter.kernelOrder, [.conservation, .symmetry, .resonance])
        XCTAssertEqual(intent.targetSurfaceID, "vercel_pulse_web")
        XCTAssertEqual(intent.permissionProfile, "PULSE_TREATY_POINTER_ONLY")
        XCTAssertFalse(intent.mayExecuteExternalAction)
        XCTAssertFalse(intent.mayMutateFieldOntology)
        XCTAssertEqual(snapshot.genotypeID, FieldPulseTreatyAdapter.genotypeID)
        XCTAssertEqual(snapshot.surfaceStates["vercel_pulse_web"], .holding)
        XCTAssertFalse(snapshot.ownsFieldOntology)
        XCTAssertFalse(snapshot.redefinesDojoReceipts)
        XCTAssertEqual(notice.holdReason, "HOLD.PulseRuntimeUnbound")
        XCTAssertTrue(notice.exitRequired)
        XCTAssertFalse(notice.claimsPulseExecution)
        XCTAssertTrue(intent.invariantViolations().isEmpty)
        XCTAssertTrue(snapshot.invariantViolations().isEmpty)
        XCTAssertTrue(notice.invariantViolations().isEmpty)
    }

    func testPulseTreatyIntentCanBecomeSignalEdgeWithoutGrantingRuntimeAuthority() {
        let edge = FieldPulseTreatyAdapter.signalEdge(from: FieldSurfaceCoordinationCatalog.pulseTreatyIntent)

        XCTAssertEqual(edge.source, FieldSignalEndpoint(kind: .object, id: "selected-generated-object"))
        XCTAssertEqual(edge.receiver, FieldSignalEndpoint(kind: .service, id: "vercel_pulse_web"))
        XCTAssertEqual(edge.channel, .ambient)
        XCTAssertEqual(edge.lane, .temporal)
        XCTAssertEqual(edge.permissionProfile, "PULSE_TREATY_POINTER_ONLY")
        XCTAssertFalse(edge.configurationMutationAllowed)
        XCTAssertFalse(edge.infrastructureMutationAllowed)
        XCTAssertFalse(edge.runtimeAuthorityGranted)
        XCTAssertFalse(edge.consentInferred)
        XCTAssertTrue(edge.invariantViolations().isEmpty)
    }

    func testPulseTreatyMessagesCodableRoundTrip() throws {
        let intent = FieldSurfaceCoordinationCatalog.pulseTreatyIntent
        let snapshot = FieldSurfaceCoordinationCatalog.pulseTreatySnapshot
        let notice = FieldSurfaceCoordinationCatalog.pulseTreatyHoldExitNotice
        let receipt = FieldPulseReceipt(
            id: "pulse_receipt_static_v0",
            intentID: intent.id,
            outcome: .held,
            emittedPulseID: nil,
            sourceSurfaceID: "vercel_pulse_web",
            targetSurfaceID: "dojo_today_mac",
            evidencePointer: "docs/DOJO_SUITE_FIELD_PULSE_HOMEFIELD_CARRY_BRIDGE_V0.md"
        )

        XCTAssertEqual(try JSONDecoder().decode(FieldPulseIntentDeclaration.self, from: JSONEncoder().encode(intent)), intent)
        XCTAssertEqual(try JSONDecoder().decode(FieldPulseStateSnapshot.self, from: JSONEncoder().encode(snapshot)), snapshot)
        XCTAssertEqual(try JSONDecoder().decode(FieldPulseHoldExitNotice.self, from: JSONEncoder().encode(notice)), notice)
        XCTAssertEqual(try JSONDecoder().decode(FieldPulseReceipt.self, from: JSONEncoder().encode(receipt)), receipt)
    }

    func testHostilePulseTreatyMessagesFailClosed() {
        let metric = FieldPulseCoherenceMetric(id: "", label: "", value: 2.0, evidencePointer: "")
        XCTAssertFalse(metric.invariantViolations().isEmpty)

        let snapshot = FieldPulseStateSnapshot(
            id: "",
            pulseRuntimeID: "",
            genotypeID: "OTHER",
            observedAt: "",
            activePulseIDs: [],
            surfaceStates: [:],
            coherenceMetrics: [metric],
            kernelOrder: [.resonance, .symmetry, .conservation],
            ownsFieldOntology: true,
            redefinesDojoReceipts: true
        )
        XCTAssertFalse(snapshot.invariantViolations().isEmpty)

        let intent = FieldPulseIntentDeclaration(
            id: "",
            sourceSurfaceID: "",
            targetSurfaceID: "",
            objectID: "",
            intentType: "",
            requestedLane: .operational,
            permissionProfile: "",
            evidencePointer: "",
            mayExecuteExternalAction: true,
            mayMutateFieldOntology: true
        )
        XCTAssertFalse(intent.invariantViolations().isEmpty)

        let notice = FieldPulseHoldExitNotice(
            id: "",
            intentID: "",
            blockedLaw: .conservation,
            holdReason: "",
            exitRequired: true,
            sourceSurfaceID: "",
            targetSurfaceID: "",
            evidencePointer: "",
            claimsPulseExecution: true
        )
        XCTAssertFalse(notice.invariantViolations().isEmpty)

        let receipt = FieldPulseReceipt(
            id: "",
            intentID: "",
            outcome: .emitted,
            emittedPulseID: nil,
            sourceSurfaceID: "",
            targetSurfaceID: "",
            evidencePointer: "",
            mutatesSource: true,
            promotesAuthority: true
        )
        XCTAssertFalse(receipt.invariantViolations().isEmpty)
    }

    func testCarPlayDecisionMetadataIsSafeByDefault() {
        let metadata = FieldSurfaceCoordinationCatalog.carPlayDecisionMetadata
        let knownSurfaces = Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))

        XCTAssertEqual(metadata.objectID, "decision:atlas:2026-09-14")
        XCTAssertEqual(metadata.carPlaySafeSummary, "Project Atlas decision due 3 PM.")
        XCTAssertEqual(metadata.allowedActions, [.deferToArrival, .hearSummary])
        XCTAssertEqual(metadata.desktopOnlyFields, ["fullContext", "attachments", "history"])
        XCTAssertEqual(metadata.continuationSurfaceID, "dojo_today_mac")
        XCTAssertEqual(metadata.authorityCeiling, "GLANCE_AND_DEFER_ONLY")
        XCTAssertFalse(metadata.permitsDeepWork)
        XCTAssertFalse(metadata.permitsVehicleControl)
        XCTAssertTrue(metadata.invariantViolations(knownSurfaceIDs: knownSurfaces).isEmpty)
    }

    func testCarPlayProjectionAdmissionAllowsSimulationButNotRuntimeForDrivingContext() throws {
        let metadata = FieldSurfaceCoordinationCatalog.carPlayDecisionMetadata
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator-driving-simulation"))
        let vehicle = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "vehicle_safety_simulator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "VEHICLE_SAFETY_RESTRICTED"))
        let knownSurfaces = Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))

        let admission = FieldCarPlayProjectionPolicy.admit(
            metadata: metadata,
            observerContext: context,
            vehicleSurface: vehicle,
            permissionProfile: profile,
            knownSurfaceIDs: knownSurfaces
        )

        XCTAssertEqual(admission.decision, .pass)
        XCTAssertNil(admission.blockedLaw)
        XCTAssertEqual(admission.reason, "PASS.CarPlay.SimulationOnly")
        XCTAssertEqual(admission.holdReasons, ["HOLD.CarPlayRuntimeNotImplemented"])
        XCTAssertEqual(admission.visibleSummary, "Project Atlas decision due 3 PM.")
        XCTAssertEqual(admission.allowedActions, [.deferToArrival, .hearSummary])
        XCTAssertEqual(admission.continuationSurfaceID, "dojo_today_mac")
        XCTAssertTrue(admission.simulationAllowed)
        XCTAssertFalse(admission.runtimeProjectionAllowed)
    }

    func testCarPlayProjectionAdmissionHoldsDeepWorkAndVehicleControl() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator-driving-simulation"))
        let vehicle = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "vehicle_safety_simulator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "VEHICLE_SAFETY_RESTRICTED"))
        let unsafe = FieldCarPlayObjectMetadata(
            objectID: "decision:atlas:2026-09-14",
            carPlaySafeSummary: "Project Atlas decision due 3 PM.",
            allowedActions: [.deferToArrival, .hearSummary],
            desktopOnlyFields: ["fullContext"],
            continuationSurfaceID: "dojo_today_mac",
            evidencePointer: "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md",
            authorityCeiling: "GLANCE_AND_DEFER_ONLY",
            permitsDeepWork: true,
            permitsVehicleControl: true
        )

        let admission = FieldCarPlayProjectionPolicy.admit(
            metadata: unsafe,
            observerContext: context,
            vehicleSurface: vehicle,
            permissionProfile: profile,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .hold)
        XCTAssertEqual(admission.blockedLaw, .conservation)
        XCTAssertFalse(admission.simulationAllowed)
        XCTAssertFalse(admission.runtimeProjectionAllowed)
        XCTAssertTrue(admission.holdReasons.contains("CarPlay metadata permits deep work"))
        XCTAssertTrue(admission.holdReasons.contains("CarPlay metadata permits vehicle control"))
    }

    func testCarPlayProjectionAdmissionHoldsVisualPrimarySafetyCriticalContext() throws {
        let metadata = FieldSurfaceCoordinationCatalog.carPlayDecisionMetadata
        let vehicle = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "vehicle_safety_simulator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "VEHICLE_SAFETY_RESTRICTED"))
        let visualDrivingContext = FieldObserverContext(
            observerID: "local-operator-driving-visual",
            version: "FIELD.ObserverContext.V0",
            asOfTime: "2026-09-14T00:00:00Z",
            timeZone: "Australia/Melbourne",
            permissionProfileID: "VEHICLE_SAFETY_RESTRICTED",
            continuityContractID: "DOJO.Today.VehicleContinuity.V0",
            primaryDeviceID: "vehicle_safety_simulator",
            availableSurfaceIDs: ["vehicle_safety_simulator", "dojo_today_mac"],
            activeChannels: [.audio, .voice, .temporal],
            activity: FieldObserverActivityState(kind: .driving, safetyCritical: true),
            attention: FieldObserverAttentionState(level: .medium, mode: .visualPrimary),
            location: FieldObserverLocationState(semantic: .inVehicle, primarySurfaceID: "vehicle_safety_simulator"),
            activeObjects: [],
            continuityPromises: [],
            evidenceRef: "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md",
            integrityStatus: FieldObserverIntegrityStatus(code: .degraded)
        )

        let admission = FieldCarPlayProjectionPolicy.admit(
            metadata: metadata,
            observerContext: visualDrivingContext,
            vehicleSurface: vehicle,
            permissionProfile: profile,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .hold)
        XCTAssertEqual(admission.blockedLaw, .resonance)
        XCTAssertEqual(admission.holdReasons, ["HOLD.DrivingMode.CognitiveLoad"])
        XCTAssertFalse(admission.simulationAllowed)
        XCTAssertFalse(admission.runtimeProjectionAllowed)
    }

    func testCarPlayMetadataAndAdmissionCodableRoundTrip() throws {
        let metadata = FieldSurfaceCoordinationCatalog.carPlayDecisionMetadata
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator-driving-simulation"))
        let vehicle = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "vehicle_safety_simulator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "VEHICLE_SAFETY_RESTRICTED"))
        let admission = FieldCarPlayProjectionPolicy.admit(
            metadata: metadata,
            observerContext: context,
            vehicleSurface: vehicle,
            permissionProfile: profile,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(try JSONDecoder().decode(FieldCarPlayObjectMetadata.self, from: JSONEncoder().encode(metadata)), metadata)
        XCTAssertEqual(try JSONDecoder().decode(FieldCarPlayProjectionAdmission.self, from: JSONEncoder().encode(admission)), admission)
    }

    func testCarPlayDecisionSignalEdgeIsTemporalAndNonAuthoritative() throws {
        let edge = try XCTUnwrap(FieldSurfaceCoordinationCatalog.signalEdge(for: "carplay_safe_decision_due_simulated"))

        XCTAssertEqual(edge.source, FieldSignalEndpoint(kind: .object, id: "decision:atlas:2026-09-14"))
        XCTAssertEqual(edge.receiver, FieldSignalEndpoint(kind: .observer, id: "local-operator"))
        XCTAssertEqual(edge.channel, .audio)
        XCTAssertEqual(edge.lane, .temporal)
        XCTAssertEqual(edge.surfaceID, "vehicle_safety_simulator")
        XCTAssertEqual(edge.permissionProfile, "VEHICLE_SAFETY_RESTRICTED")
        XCTAssertEqual(edge.evidencePointer, "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md")
        XCTAssertFalse(edge.configurationMutationAllowed)
        XCTAssertFalse(edge.infrastructureMutationAllowed)
        XCTAssertFalse(edge.runtimeAuthorityGranted)
        XCTAssertFalse(edge.consentInferred)
        XCTAssertTrue(edge.invariantViolations().isEmpty)
    }

    func testDojoTodayMurmurPolicyIsLocalHomeostasisOnly() {
        let policy = FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy
        let knownSurfaces = Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))

        XCTAssertEqual(policy.surfaceID, "dojo_today_mac")
        XCTAssertEqual(policy.setpoints.maxOpenMinutes, 10)
        XCTAssertEqual(policy.setpoints.maxRequestsPerMinute, 3)
        XCTAssertEqual(policy.toleranceBands.highAttentionOpenMinutes, 2)
        XCTAssertEqual(policy.toleranceBands.highAttentionRequestsPerMinute, 1)
        XCTAssertEqual(policy.correctionActions, [.fadeOpacity, .showPauseCue, .autoCollapse, .hold])
        XCTAssertTrue(policy.mirroredGeometryPointers.contains("DOJO spinning top"))
        XCTAssertFalse(policy.mayRedefineGeometry)
        XCTAssertFalse(policy.mayLockOutObserver)
        XCTAssertFalse(policy.mayIncreaseIrreversibleRisk)
        XCTAssertTrue(policy.invariantViolations(knownSurfaceIDs: knownSurfaces).isEmpty)
    }

    func testDojoTodayMurmurHomeostasisIsBalancedWithinSetpoints() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let surface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))

        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 9, requestsPerMinute: 2),
            observerContext: context,
            surfaceNode: surface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .balanced)
        XCTAssertNil(admission.blockedLaw)
        XCTAssertNil(admission.correctionAction)
        XCTAssertTrue(admission.holdReasons.isEmpty)
    }

    func testDojoTodayMurmurHomeostasisUsesHighAttentionTolerance() throws {
        let base = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let context = FieldObserverContext(
            observerID: base.id,
            version: base.version,
            asOfTime: base.asOfTime,
            timeZone: base.timeZone,
            permissionProfileID: base.permissionProfileID,
            continuityContractID: base.continuityContractID,
            primaryDeviceID: base.primaryDeviceID,
            availableSurfaceIDs: base.availableSurfaceIDs,
            activeChannels: base.activeChannels,
            activity: base.activity,
            attention: FieldObserverAttentionState(level: .high, mode: .visualPrimary, source: "unit test"),
            location: base.location,
            activeObjects: base.activeObjects,
            continuityPromises: base.continuityPromises,
            evidenceRef: base.evidenceRef,
            integrityStatus: base.integrityStatus
        )
        let surface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))

        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 11.5, requestsPerMinute: 3.5),
            observerContext: context,
            surfaceNode: surface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .balanced)
        XCTAssertNil(admission.correctionAction)
    }

    func testDojoTodayMurmurHomeostasisSelectsMinimumOpenCorrection() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let surface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))

        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 11, requestsPerMinute: 2),
            observerContext: context,
            surfaceNode: surface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .correct)
        XCTAssertNil(admission.blockedLaw)
        XCTAssertEqual(admission.correctionAction, .fadeOpacity)
        XCTAssertEqual(admission.reason, "PASS.MurmurHomeostasis.FadeOpacity")
    }

    func testDojoTodayMurmurHomeostasisCollapsesOnlyAfterLargerDrift() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let surface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))

        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 15, requestsPerMinute: 2),
            observerContext: context,
            surfaceNode: surface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .correct)
        XCTAssertEqual(admission.correctionAction, .autoCollapse)
        XCTAssertEqual(admission.reason, "PASS.MurmurHomeostasis.AutoCollapse")
    }

    func testDojoTodayMurmurHomeostasisHoldsWhenCorrectionWouldNeedSafetyMode() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator-driving-simulation"))
        let surface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))

        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 11, requestsPerMinute: 4),
            observerContext: context,
            surfaceNode: surface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .correct)
        XCTAssertEqual(admission.correctionAction, .hold)
        XCTAssertEqual(admission.reason, "PASS.MurmurHomeostasis.Hold")
    }

    func testHostileMurmurPolicyFailsClosed() {
        let unsafe = FieldMurmurPolicy(
            surfaceID: "",
            mirroredGeometryPointers: [],
            setpoints: FieldMurmurSetpoints(maxOpenMinutes: 0, maxRequestsPerMinute: 0),
            toleranceBands: FieldMurmurToleranceBands(highAttentionOpenMinutes: -1, highAttentionRequestsPerMinute: -1),
            correctionActions: [],
            evidencePointer: "",
            authorityCeiling: "",
            mayRedefineGeometry: true,
            mayLockOutObserver: true,
            mayIncreaseIrreversibleRisk: true
        )

        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: unsafe,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 99, requestsPerMinute: 99),
            observerContext: FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"),
            surfaceNode: FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"),
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .hold)
        XCTAssertEqual(admission.blockedLaw, .conservation)
        XCTAssertTrue(admission.holdReasons.contains("murmur policy increases irreversible risk"))
        XCTAssertTrue(admission.holdReasons.contains("murmur policy redefines geometry"))
    }

    func testMurmurPolicyAndAdmissionCodableRoundTrip() throws {
        let policy = FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let surface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))
        let admission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: policy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 11, requestsPerMinute: 2),
            observerContext: context,
            surfaceNode: surface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(try JSONDecoder().decode(FieldMurmurPolicy.self, from: JSONEncoder().encode(policy)), policy)
        XCTAssertEqual(try JSONDecoder().decode(FieldMurmurHomeostasisAdmission.self, from: JSONEncoder().encode(admission)), admission)
    }

    func testWatchUltraMurmurNodeAndPolicyAreHapticCueOnly() throws {
        let node = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "WATCH_GLANCE_HAPTIC_ONLY"))
        let policy = FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy
        let knownSurfaces = Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))

        XCTAssertEqual(node.kind, .watch)
        XCTAssertEqual(node.configuration.permissionProfile, "WATCH_GLANCE_HAPTIC_ONLY")
        XCTAssertEqual(node.configuration.authorityCeiling, "HAPTIC_CUE_ONLY")
        XCTAssertEqual(node.infrastructure.state, .held)
        XCTAssertEqual(node.infrastructure.networkBoundary, "No live WatchConnectivity binding")
        XCTAssertEqual(node.utilisation.context, .glanceable)
        XCTAssertEqual(profile.decision(for: .haptic), .pass)
        XCTAssertEqual(profile.decision(for: .visual), .hold)
        XCTAssertEqual(policy.surfaceID, "watch_ultra_murmur")
        XCTAssertEqual(policy.setpoints.maxOpenMinutes, 1)
        XCTAssertEqual(policy.setpoints.maxRequestsPerMinute, 1)
        XCTAssertEqual(policy.correctionActions, [.dampenHaptics, .hold])
        XCTAssertFalse(policy.mayRedefineGeometry)
        XCTAssertTrue(node.invariantViolations().isEmpty)
        XCTAssertTrue(profile.invariantViolations().isEmpty)
        XCTAssertTrue(policy.invariantViolations(knownSurfaceIDs: knownSurfaces).isEmpty)
    }

    func testIPhone14MurmurNodeAndPolicyAreMobileContinuityOnly() throws {
        let node = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "iphone14_murmur"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "IPHONE_MOBILE_CONTINUITY"))
        let policy = FieldSurfaceCoordinationCatalog.iPhone14MurmurPolicy
        let knownSurfaces = Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))

        XCTAssertEqual(node.kind, .iPhone)
        XCTAssertEqual(node.configuration.permissionProfile, "IPHONE_MOBILE_CONTINUITY")
        XCTAssertEqual(node.configuration.authorityCeiling, "MOBILE_CONTINUITY_ONLY")
        XCTAssertEqual(node.infrastructure.state, .held)
        XCTAssertEqual(node.infrastructure.networkBoundary, "No live iPhone relay binding")
        XCTAssertEqual(node.utilisation.context, .mobileContinuity)
        XCTAssertEqual(profile.decision(for: .semantic), .pass)
        XCTAssertEqual(profile.decision(for: .geometric), .hold)
        XCTAssertEqual(policy.surfaceID, "iphone14_murmur")
        XCTAssertEqual(policy.setpoints.maxOpenMinutes, 3)
        XCTAssertEqual(policy.setpoints.maxRequestsPerMinute, 2)
        XCTAssertEqual(policy.correctionActions, [.stageContinuation, .showPauseCue, .hold])
        XCTAssertFalse(policy.mayRedefineGeometry)
        XCTAssertFalse(profile.canControlApplication)
        XCTAssertTrue(node.invariantViolations().isEmpty)
        XCTAssertTrue(profile.invariantViolations().isEmpty)
        XCTAssertTrue(policy.invariantViolations(knownSurfaceIDs: knownSurfaces).isEmpty)
    }

    func testQuietModeMurmurationDampensWatchWhenDojoTodayHolds() throws {
        let sourceContext = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator-driving-simulation"))
        let sourceSurface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))
        let sourceAdmission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 11, requestsPerMinute: 4),
            observerContext: sourceContext,
            surfaceNode: sourceSurface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        let admission = FieldMurmurationPolicy.evaluateQuietModeDampening(
            cue: FieldSurfaceCoordinationCatalog.quietModeMurmurationCue,
            sourceAdmission: sourceAdmission,
            policies: [
                FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
                FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy
            ],
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(sourceAdmission.correctionAction, .hold)
        XCTAssertEqual(admission.decision, .correct)
        XCTAssertNil(admission.blockedLaw)
        XCTAssertEqual(admission.reason, "PASS.Murmuration.QuietModeDampening")
        XCTAssertEqual(admission.correctionActionsBySurfaceID["dojo_today_mac"], .hold)
        XCTAssertEqual(admission.correctionActionsBySurfaceID["watch_ultra_murmur"], .dampenHaptics)
        XCTAssertTrue(admission.holdReasons.isEmpty)
    }

    func testTravelModeMurmurationStagesIPhoneAndDampensWatchWhenDojoTodayHolds() throws {
        let sourceContext = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator-driving-simulation"))
        let sourceSurface = try XCTUnwrap(FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac"))
        let sourceAdmission = FieldMurmurHomeostasisPolicy.evaluate(
            policy: FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
            metrics: FieldMurmurRuntimeMetrics(openMinutes: 11, requestsPerMinute: 4),
            observerContext: sourceContext,
            surfaceNode: sourceSurface,
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        let admission = FieldMurmurationPolicy.evaluateTravelModeContinuity(
            cue: FieldSurfaceCoordinationCatalog.travelModeMurmurationCue,
            sourceAdmission: sourceAdmission,
            policies: [
                FieldSurfaceCoordinationCatalog.dojoTodayMurmurPolicy,
                FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy,
                FieldSurfaceCoordinationCatalog.iPhone14MurmurPolicy
            ],
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(sourceAdmission.correctionAction, .hold)
        XCTAssertEqual(admission.decision, .correct)
        XCTAssertNil(admission.blockedLaw)
        XCTAssertEqual(admission.reason, "PASS.Murmuration.TravelModeContinuity")
        XCTAssertEqual(admission.correctionActionsBySurfaceID["dojo_today_mac"], .hold)
        XCTAssertEqual(admission.correctionActionsBySurfaceID["watch_ultra_murmur"], .dampenHaptics)
        XCTAssertEqual(admission.correctionActionsBySurfaceID["iphone14_murmur"], .stageContinuation)
        XCTAssertTrue(admission.holdReasons.isEmpty)
    }

    func testTravelModeMurmurationFailsClosedWithoutIPhonePolicy() throws {
        let sourceAdmission = FieldMurmurHomeostasisAdmission(
            decision: .correct,
            blockedLaw: nil,
            reason: "fixture",
            holdReasons: [],
            correctionAction: .hold
        )

        let admission = FieldMurmurationPolicy.evaluateTravelModeContinuity(
            cue: FieldSurfaceCoordinationCatalog.travelModeMurmurationCue,
            sourceAdmission: sourceAdmission,
            policies: [FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy],
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(admission.decision, .hold)
        XCTAssertEqual(admission.blockedLaw, .symmetry)
        XCTAssertEqual(admission.holdReasons, ["HOLD.ReceivingMurmurPolicyUnavailable"])
        XCTAssertTrue(admission.correctionActionsBySurfaceID.isEmpty)
    }

    func testQuietModeMurmurationCueCodableRoundTrip() throws {
        let cue = FieldSurfaceCoordinationCatalog.quietModeMurmurationCue
        let admission = FieldMurmurationPolicy.evaluateQuietModeDampening(
            cue: cue,
            sourceAdmission: FieldMurmurHomeostasisAdmission(
                decision: .correct,
                blockedLaw: nil,
                reason: "fixture",
                holdReasons: [],
                correctionAction: .hold
            ),
            policies: [FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy],
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(try JSONDecoder().decode(FieldMurmurationCue.self, from: JSONEncoder().encode(cue)), cue)
        XCTAssertEqual(try JSONDecoder().decode(FieldMurmurationAdmission.self, from: JSONEncoder().encode(admission)), admission)
    }

    func testTravelModeMurmurationCueCodableRoundTrip() throws {
        let cue = FieldSurfaceCoordinationCatalog.travelModeMurmurationCue
        let admission = FieldMurmurationPolicy.evaluateTravelModeContinuity(
            cue: cue,
            sourceAdmission: FieldMurmurHomeostasisAdmission(
                decision: .correct,
                blockedLaw: nil,
                reason: "fixture",
                holdReasons: [],
                correctionAction: .hold
            ),
            policies: [
                FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy,
                FieldSurfaceCoordinationCatalog.iPhone14MurmurPolicy
            ],
            knownSurfaceIDs: Set(FieldSurfaceCoordinationCatalog.surfaceNodes.map(\.id))
        )

        XCTAssertEqual(try JSONDecoder().decode(FieldMurmurationCue.self, from: JSONEncoder().encode(cue)), cue)
        XCTAssertEqual(try JSONDecoder().decode(FieldMurmurationAdmission.self, from: JSONEncoder().encode(admission)), admission)
    }

    func testObserverContextAndPermissionProfileCodableRoundTrip() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: context.permissionProfileID))

        XCTAssertEqual(try JSONDecoder().decode(FieldObserverContext.self, from: JSONEncoder().encode(context)), context)
        XCTAssertEqual(try JSONDecoder().decode(FieldPermissionProfile.self, from: JSONEncoder().encode(profile)), profile)
    }

    func testSurfaceContextHeaderLineIsDeterministicAndReadOnly() {
        let full = FieldSurfaceCoordinationCatalog.surfaceContextHeaderLine(observerID: "local-operator")
        let compact = FieldSurfaceCoordinationCatalog.surfaceContextHeaderLine(observerID: "local-operator", compact: true)

        XCTAssertEqual(
            full,
            "Surface Context: DOJO Today on Mac · local-operator · DESK_WORK · MEDIUM · READ_ONLY_CONTEXT_PROJECTION"
        )
        XCTAssertEqual(
            compact,
            "DOJO Today on Mac · local-operator · DESK_WORK · MEDIUM"
        )
        XCTAssertFalse(full.contains("send"))
        XCTAssertFalse(full.contains("publish"))
        XCTAssertFalse(full.contains("control"))
    }

    func testSurfaceContextHeaderLineFailsClosedForUnknownObserver() {
        XCTAssertEqual(
            FieldSurfaceCoordinationCatalog.surfaceContextHeaderLine(observerID: "missing"),
            "Surface Context: Unknown · HOLD"
        )
    }

    func testHostileObserverContextAndPermissionProfileFailClosed() {
        let context = FieldObserverContext(
            observerID: "",
            version: "",
            asOfTime: "",
            timeZone: "",
            permissionProfileID: "",
            continuityContractID: "",
            primaryDeviceID: "missing",
            availableSurfaceIDs: [],
            activeChannels: [],
            activity: FieldObserverActivityState(kind: .driving, safetyCritical: true),
            attention: FieldObserverAttentionState(level: .high, mode: .visualPrimary),
            location: FieldObserverLocationState(semantic: .inVehicle, primarySurfaceID: "missing"),
            activeObjects: [],
            continuityPromises: [],
            evidenceRef: nil,
            integrityStatus: FieldObserverIntegrityStatus(code: .unknown)
        )
        XCTAssertFalse(context.invariantViolations(knownSurfaceIDs: ["dojo_today_mac"]).isEmpty)

        let profile = FieldPermissionProfile(
            id: "",
            displayName: "",
            allowedChannels: [],
            allowedActions: [],
            authorityCeiling: "",
            canMutateSource: true,
            canControlApplication: true,
            canSendOrPublish: true,
            consentInferred: true
        )
        XCTAssertFalse(profile.invariantViolations().isEmpty)
    }
}
