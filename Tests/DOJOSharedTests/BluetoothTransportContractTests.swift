import Foundation
import Testing
@testable import DOJOShared

@Suite("Arkadaş and HAL BLE transport boundary")
struct BluetoothTransportContractTests {
    private let now = Date(timeIntervalSince1970: 1_789_473_600)

    @Test("Watch is central-only and unbound profile claims no UUID")
    func watchBoundaryIsCentralOnly() {
        let profile = ArkadasBluetoothContract.unboundEnvironmentalEvidenceProfile

        #expect(ArkadasBluetoothContract.watchTransportRole == .central)
        #expect(!ArkadasBluetoothContract.watchCanAdvertiseApplicationGATTService)
        #expect(ArkadasBluetoothContract.pairedIPhonePreferredTransport == .pairedDeviceTransport)
        #expect(profile.availability == .notConfigured)
        #expect(profile.serviceID == nil)
        #expect(profile.allowedCharacteristicIDs.isEmpty)
        #expect(profile.invariantViolations().isEmpty)
    }

    @Test("Unbound peripheral profile holds before transport")
    func unboundProfileHolds() throws {
        let admission = try evaluate(
            request: request(outcome: .dampenHaptics),
            profile: ArkadasBluetoothContract.unboundEnvironmentalEvidenceProfile
        )

        #expect(admission.decision == .hold)
        #expect(admission.holdReason == .peripheralNotRegistered)
        #expect(admission.admittedOperation == nil)
        #expect(admission.admittedOutcome == nil)
    }

    @Test("Registered least-privilege profile can admit bounded dampening")
    func registeredProfileAdmitsBoundedOutcome() throws {
        let profile = configuredProfile()
        let admission = try evaluate(
            request: request(outcome: .dampenHaptics, profileID: profile.id),
            profile: profile
        )

        #expect(admission.decision == .admit)
        #expect(admission.admittedOperation == .subscribe)
        #expect(admission.admittedOutcome == .dampenHaptics)
        #expect(admission.authorityCeiling == "HAPTIC_CUE_ONLY")
        #expect(admission.provenancePreserved)
    }

    @Test("Unavailable BLE requests paired-iPhone handoff when configured")
    func unavailableRequestsHandoff() throws {
        let profile = configuredProfile(fallback: .requestPairedIPhoneHandoff)
        let admission = try evaluate(
            request: request(outcome: .dampenHaptics, profileID: profile.id),
            availability: .poweredOff,
            profile: profile
        )

        #expect(admission.decision == .requestHandoff)
        #expect(admission.holdReason == .bluetoothUnavailable)
        #expect(admission.fallback == .requestPairedIPhoneHandoff)
        #expect(admission.admittedOperation == nil)
    }

    @Test("Expired request holds without initiating transport")
    func expiredRequestHolds() throws {
        let profile = configuredProfile()
        let expired = request(
            outcome: .dampenHaptics,
            profileID: profile.id,
            expiresAt: now.addingTimeInterval(-1)
        )
        let admission = try evaluate(request: expired, profile: profile)

        #expect(admission.decision == .hold)
        #expect(admission.holdReason == .expiredRequest)
        #expect(admission.admittedOperation == nil)
    }

    @Test("Outcomes beyond Watch murmur authority are rejected")
    func authorityExpansionIsRejected() throws {
        let profile = configuredProfile()
        for outcome in [
            HALRequestedBluetoothOutcome.voiceInteraction,
            .dojoAuthorityMutation,
            .pulseEmission,
            .somaStateMutation
        ] {
            let admission = try evaluate(
                request: request(outcome: outcome, profileID: profile.id),
                profile: profile
            )

            #expect(admission.decision == .reject)
            #expect(admission.holdReason == .murmurAuthorityExceeded)
            #expect(admission.admittedOutcome == nil)
        }
    }

    @Test("Non-Arkadaş or owner-claiming provenance holds")
    func invalidLineageHolds() throws {
        let profile = configuredProfile()
        let hostileOrigin = ChannelLineageRef(
            channel: .hal,
            geometricRole: "transport",
            sourceSurfaceID: "hal",
            capabilityUsed: "bluetooth",
            coordinatorID: "hal",
            mappedCapabilityOwnsChannelIdentity: true,
            coordinatorOwnsSourceSignal: true,
            authorityEscalationAllowed: true
        )
        let admission = try evaluate(
            request: request(
                outcome: .dampenHaptics,
                profileID: profile.id,
                origin: hostileOrigin
            ),
            profile: profile
        )

        #expect(admission.decision == .hold)
        #expect(admission.holdReason == .provenanceIncomplete)
    }

    @Test("Generic BLE profile rejects sensitive and sovereign payload classes")
    func hostileProfileFailsClosed() {
        let hostile = BLEPeripheralProfile(
            profileID: "hostile",
            serviceID: UUID(),
            allowedCharacteristicIDs: [UUID()],
            permittedOperations: [.read],
            requiredSecurity: [.platformDefault],
            maximumPayloadBytes: 128,
            minimumInterval: 0,
            messageTTL: 30,
            fallback: .hold,
            dataClassification: .environmentalEvidence,
            availability: .available,
            permitsRawAudio: true,
            permitsRawHealthData: true,
            permitsAuthorityPackets: true,
            permitsPulseOrSomaState: true
        )

        #expect(hostile.invariantViolations().contains("generic Arkadaş BLE profile cannot carry raw audio"))
        #expect(hostile.invariantViolations().contains("generic Arkadaş BLE profile cannot carry raw health data"))
        #expect(hostile.invariantViolations().contains("BLE profile cannot carry DOJO authority packets"))
        #expect(hostile.invariantViolations().contains("BLE profile cannot define PULSE or SOMA state"))
    }

    @Test("Transport receipt is reference-only and time bounded")
    func transportReceiptBoundary() {
        let receipt = HALBluetoothTransportReceipt(
            requestID: UUID(),
            routeDecision: .admit,
            transportState: .poweredOn,
            peripheralProfileID: "approved",
            serviceID: UUID(),
            characteristicID: UUID(),
            startedAt: now,
            completedAt: now.addingTimeInterval(1),
            expiry: now.addingTimeInterval(30),
            holdReason: nil,
            provenancePreserved: true
        )

        #expect(!receipt.rawPayloadRetained)
        #expect(!receipt.sealsDojoReceipt)
        #expect(receipt.invariantViolations().isEmpty)
    }

    @Test("BLE request, admission, profile, and receipt round trip through Codable")
    func codableRoundTrip() throws {
        let profile = configuredProfile()
        let routeRequest = request(outcome: .dampenHaptics, profileID: profile.id)
        let admission = try evaluate(request: routeRequest, profile: profile)
        let receipt = HALBluetoothTransportReceipt(
            requestID: routeRequest.id,
            routeDecision: admission.decision,
            transportState: .poweredOn,
            peripheralProfileID: profile.id,
            serviceID: profile.serviceID,
            characteristicID: profile.allowedCharacteristicIDs.first,
            startedAt: now,
            completedAt: now.addingTimeInterval(1),
            expiry: routeRequest.expiresAt,
            holdReason: admission.holdReason,
            provenancePreserved: admission.provenancePreserved
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        #expect(try decoder.decode(BLEPeripheralProfile.self, from: encoder.encode(profile)) == profile)
        #expect(try decoder.decode(HALBluetoothRouteRequest.self, from: encoder.encode(routeRequest)) == routeRequest)
        #expect(try decoder.decode(HALBluetoothRouteAdmission.self, from: encoder.encode(admission)) == admission)
        #expect(try decoder.decode(HALBluetoothTransportReceipt.self, from: encoder.encode(receipt)) == receipt)
    }

    @Test("Handoff uses make-before-break and monotonic stability")
    func makeBeforeBreakHandoff() async throws {
        let epoch = UUID()
        let serviceID = UUID()
        let peripheralID = UUID()
        let request = handoffRequest(epoch: epoch, serviceID: serviceID)
        let arbiter = HALBluetoothHandoffArbiter(runtimeEpochID: epoch)

        var state = await arbiter.submit(request, now: .init(nanoseconds: 100))
        #expect(state.phase == .scanning)
        #expect(!state.sourceReleased)

        state = try #require(await arbiter.didDiscover(
            handoffID: request.id,
            peripheralID: peripheralID,
            now: .init(nanoseconds: 110)
        ))
        state = try #require(await arbiter.didConnect(
            handoffID: request.id,
            peripheralID: peripheralID,
            now: .init(nanoseconds: 120)
        ))
        state = try #require(await arbiter.didNegotiate(
            handoffID: request.id,
            peripheralID: peripheralID,
            discoveredServiceIDs: [serviceID],
            now: .init(nanoseconds: 130)
        ))
        state = try #require(await arbiter.didReceiveFirstValidPayload(
            handoffID: request.id,
            peripheralID: peripheralID,
            now: .init(nanoseconds: 140)
        ))
        #expect(state.phase == .discovered)
        #expect(!state.sourceReleased)

        state = try #require(await arbiter.confirmStability(
            handoffID: request.id,
            now: .init(nanoseconds: 190)
        ))
        #expect(state.phase == .active)
        #expect(state.sourceReleased)
    }

    @Test("Late callback cannot resurrect an expired handoff")
    func expiredCallbackIsIgnored() async throws {
        let epoch = UUID()
        let request = handoffRequest(epoch: epoch, serviceID: UUID(), deadline: 150)
        let arbiter = HALBluetoothHandoffArbiter(runtimeEpochID: epoch)
        _ = await arbiter.submit(request, now: .init(nanoseconds: 100))
        await arbiter.expireOverdue(at: .init(nanoseconds: 151))

        let state = try #require(await arbiter.didDiscover(
            handoffID: request.id,
            peripheralID: UUID(),
            now: .init(nanoseconds: 152)
        ))
        #expect(state.phase == .expired)
        #expect(!state.sourceReleased)
    }

    @Test("One active handoff per sovereign channel prevents radio monopoly")
    func oneActiveHandoffPerChannel() async {
        let epoch = UUID()
        let arbiter = HALBluetoothHandoffArbiter(runtimeEpochID: epoch)
        let first = handoffRequest(epoch: epoch, serviceID: UUID())
        let second = handoffRequest(epoch: epoch, serviceID: UUID())
        _ = await arbiter.submit(first, now: .init(nanoseconds: 100))

        let held = await arbiter.submit(second, now: .init(nanoseconds: 101))
        #expect(held.phase == .held)
        #expect(held.holdReason == .connectionUnavailable)
        #expect(!held.sourceReleased)
    }

    @Test("Canonical channel names retain Unicode lineage and ASCII aliases")
    func canonicalChannelNames() throws {
        #expect(SovereignChannel.aikidoOptics.canonicalDisplayName == "Aikidō Optics")
        #expect(SovereignChannel.arkadas.canonicalDisplayName == "Arkadaş")
        #expect(SovereignChannel.aikidoOptics.transportAlias == "aikido-optics")
        #expect(SovereignChannel.arkadas.transportAlias == "arkadas")

        let data = try JSONEncoder().encode(SovereignChannel.aikidoOptics)
        #expect(try JSONDecoder().decode(SovereignChannel.self, from: data) == .aikidoOptics)
    }

    private func handoffRequest(
        epoch: UUID,
        serviceID: UUID,
        deadline: UInt64 = 1_000
    ) -> BluetoothHandoffRequest {
        BluetoothHandoffRequest(
            handoffID: UUID(),
            sourceSurfaceID: "watch_haptic_actuation",
            destinationSurfaceID: "paired_iphone_14",
            channel: .arkadas,
            requiredServiceIDs: [serviceID],
            priority: .continuity,
            createdAt: now,
            runtimeEpochID: epoch,
            createdAtMonotonic: .init(nanoseconds: 100),
            deadlineAtMonotonic: .init(nanoseconds: deadline),
            leasePolicy: .init(
                proposalNanoseconds: 20,
                connectionNanoseconds: 100,
                negotiationNanoseconds: 100,
                stabilityNanoseconds: 50,
                maximumRetryCount: 2,
                baseRetryNanoseconds: 10,
                maximumRetryNanoseconds: 100
            ),
            authorityCeiling: "HAPTIC_CUE_ONLY",
            policyVersion: FieldReadinessMurmurPolicy.policyVersion,
            evidenceReference: "readiness-evidence-reference"
        )
    }

    private func evaluate(
        request: HALBluetoothRouteRequest,
        availability: BluetoothAvailability = .poweredOn,
        profile: BLEPeripheralProfile?
    ) throws -> HALBluetoothRouteAdmission {
        HALBluetoothRoutePolicy.evaluate(
            request: request,
            at: now,
            bluetoothAvailability: availability,
            profile: profile,
            murmurPolicy: FieldSurfaceCoordinationCatalog.watchUltraMurmurPolicy,
            watchSurface: try #require(FieldSurfaceCoordinationCatalog.surfaceNode(for: "watch_ultra_murmur"))
        )
    }

    private func request(
        outcome: HALRequestedBluetoothOutcome,
        profileID: String = ArkadasBluetoothContract.unboundEnvironmentalEvidenceProfile.id,
        expiresAt: Date? = nil,
        origin: ChannelLineageRef = SovereignChannelLineageContract.arkadasAcousticLineage
    ) -> HALBluetoothRouteRequest {
        HALBluetoothRouteRequest(
            requestID: UUID(),
            fieldObjectID: "field-object-reference",
            origin: origin,
            intendedSurfaceID: "watch_ultra_murmur",
            requestedCapability: .bluetoothLowEnergyCentral,
            requestedOperation: .subscribe,
            requestedOutcome: outcome,
            peripheralProfileID: profileID,
            issuedAt: now.addingTimeInterval(-1),
            expiresAt: expiresAt ?? now.addingTimeInterval(30),
            priority: .normal,
            policyVersion: FieldReadinessMurmurPolicy.policyVersion,
            evidenceReference: "ble-evidence-reference"
        )
    }

    private func configuredProfile(
        fallback: BluetoothFallback = .hold
    ) -> BLEPeripheralProfile {
        BLEPeripheralProfile(
            profileID: "arkadas.environmental-evidence.test.v1",
            serviceID: UUID(),
            allowedCharacteristicIDs: [UUID()],
            permittedOperations: [.scanRegisteredService, .connect, .discoverServices, .discoverCharacteristics, .subscribe, .disconnect],
            requiredSecurity: [.knownPeripheralRequired, .encryptedLinkRequired, .explicitUserInitiationRequired],
            maximumPayloadBytes: 128,
            minimumInterval: 5,
            messageTTL: 30,
            fallback: fallback,
            dataClassification: .environmentalEvidence,
            availability: .available
        )
    }
}
