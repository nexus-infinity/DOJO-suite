import Foundation

public enum BluetoothTransportRole: String, Codable, Equatable, Sendable {
    case central
    case peripheral
    case systemManagedAudioRoute
    case pairedDeviceTransport
}

public enum BluetoothAvailability: String, Codable, Equatable, Sendable {
    case poweredOn
    case poweredOff
    case unauthorised
    case unsupported
    case resetting
    case unknown
}

public enum BLEOperation: String, Codable, CaseIterable, Equatable, Sendable {
    case scanRegisteredService
    case connect
    case discoverServices
    case discoverCharacteristics
    case read
    case writeWithResponse
    case subscribe
    case unsubscribe
    case disconnect
}

public enum BLESecurityRequirement: String, Codable, Equatable, Sendable {
    case platformDefault
    case knownPeripheralRequired
    case encryptedLinkRequired
    case explicitUserInitiationRequired
}

public enum BluetoothFallback: String, Codable, Equatable, Sendable {
    case hold
    case requestPairedIPhoneHandoff
    case deferToDeepSurface
    case continueWithoutPeripheral
}

public enum BLEDataClassification: String, Codable, Equatable, Sendable {
    case transportState
    case environmentalEvidence
    case explicitUserCommand
    case nonSensitiveControl
}

public enum FieldCapabilityAvailability: String, Codable, Equatable, Sendable {
    case available
    case notConfigured
    case authorisationRequired
    case modelUnavailable
    case regionRestricted
    case dependencyUnavailable
}

public struct FieldSurfaceSignalCapabilityID: RawRepresentable, Codable, Equatable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let bluetoothLowEnergyCentral = FieldSurfaceSignalCapabilityID(
        rawValue: "bluetooth_low_energy_central"
    )
}

public struct BLEPeripheralProfile: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let serviceID: UUID?
    public let allowedCharacteristicIDs: [UUID]
    public let permittedOperations: [BLEOperation]
    public let requiredSecurity: [BLESecurityRequirement]
    public let maximumPayloadBytes: Int
    public let minimumInterval: TimeInterval
    public let messageTTL: TimeInterval
    public let fallback: BluetoothFallback
    public let dataClassification: BLEDataClassification
    public let availability: FieldCapabilityAvailability
    public let permitsRawAudio: Bool
    public let permitsRawHealthData: Bool
    public let permitsAuthorityPackets: Bool
    public let permitsPulseOrSomaState: Bool

    public init(
        profileID: String,
        serviceID: UUID?,
        allowedCharacteristicIDs: [UUID],
        permittedOperations: [BLEOperation],
        requiredSecurity: [BLESecurityRequirement],
        maximumPayloadBytes: Int,
        minimumInterval: TimeInterval,
        messageTTL: TimeInterval,
        fallback: BluetoothFallback,
        dataClassification: BLEDataClassification,
        availability: FieldCapabilityAvailability,
        permitsRawAudio: Bool = false,
        permitsRawHealthData: Bool = false,
        permitsAuthorityPackets: Bool = false,
        permitsPulseOrSomaState: Bool = false
    ) {
        self.id = profileID
        self.serviceID = serviceID
        self.allowedCharacteristicIDs = allowedCharacteristicIDs
        self.permittedOperations = permittedOperations
        self.requiredSecurity = requiredSecurity
        self.maximumPayloadBytes = maximumPayloadBytes
        self.minimumInterval = minimumInterval
        self.messageTTL = messageTTL
        self.fallback = fallback
        self.dataClassification = dataClassification
        self.availability = availability
        self.permitsRawAudio = permitsRawAudio
        self.permitsRawHealthData = permitsRawHealthData
        self.permitsAuthorityPackets = permitsAuthorityPackets
        self.permitsPulseOrSomaState = permitsPulseOrSomaState
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("BLE profile ID is empty")
        }
        if maximumPayloadBytes <= 0 {
            violations.append("BLE maximum payload must be positive")
        }
        if minimumInterval < 0 || messageTTL <= 0 {
            violations.append("BLE timing limits are invalid")
        }
        if permittedOperations.isEmpty {
            violations.append("BLE profile has no permitted operations")
        }
        if availability == .available && serviceID == nil {
            violations.append("available BLE profile requires a registered service UUID")
        }
        if !allowedCharacteristicIDs.isEmpty && serviceID == nil {
            violations.append("BLE characteristics cannot be registered without a service")
        }
        if permitsRawAudio {
            violations.append("generic Arkadaş BLE profile cannot carry raw audio")
        }
        if permitsRawHealthData {
            violations.append("generic Arkadaş BLE profile cannot carry raw health data")
        }
        if permitsAuthorityPackets {
            violations.append("BLE profile cannot carry DOJO authority packets")
        }
        if permitsPulseOrSomaState {
            violations.append("BLE profile cannot define PULSE or SOMA state")
        }
        return violations
    }
}

public enum HALBluetoothRouteDecision: String, Codable, Equatable, Sendable {
    case admit
    case hold
    case requestHandoff
    case reject
}

public enum HALBluetoothHoldReason: String, Codable, Equatable, Sendable {
    case bluetoothUnavailable
    case bluetoothUnauthorised
    case peripheralNotRegistered
    case peripheralNotTrusted
    case serviceNotAllowed
    case characteristicNotAllowed
    case encryptionRequired
    case connectionUnavailable
    case staleRequest
    case expiredRequest
    case malformedPayload
    case unsupportedProtocolVersion
    case rateLimitExceeded
    case surfaceAttentionExceeded
    case murmurAuthorityExceeded
    case safetyContextRestricted
    case provenanceIncomplete
    case pairedIPhonePreferred
}

public enum HALRequestedBluetoothOutcome: String, Codable, Equatable, Sendable {
    case dampenHaptics
    case hold
    case requestHandoff
    case voiceInteraction
    case dojoAuthorityMutation
    case pulseEmission
    case somaStateMutation
}

public enum HALTransportPriority: String, Codable, Equatable, Sendable {
    case low
    case normal
    case safety
}

public struct HALBluetoothRouteRequest: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let fieldObjectID: String?
    public let origin: ChannelLineageRef
    public let intendedSurfaceID: String
    public let requestedCapability: FieldSurfaceSignalCapabilityID
    public let requestedOperation: BLEOperation
    public let requestedOutcome: HALRequestedBluetoothOutcome
    public let peripheralProfileID: String
    public let issuedAt: Date
    public let expiresAt: Date
    public let priority: HALTransportPriority
    public let policyVersion: String
    public let evidenceReference: String?

    public init(
        requestID: UUID,
        fieldObjectID: String?,
        origin: ChannelLineageRef,
        intendedSurfaceID: String,
        requestedCapability: FieldSurfaceSignalCapabilityID,
        requestedOperation: BLEOperation,
        requestedOutcome: HALRequestedBluetoothOutcome,
        peripheralProfileID: String,
        issuedAt: Date,
        expiresAt: Date,
        priority: HALTransportPriority,
        policyVersion: String,
        evidenceReference: String?
    ) {
        self.id = requestID
        self.fieldObjectID = fieldObjectID
        self.origin = origin
        self.intendedSurfaceID = intendedSurfaceID
        self.requestedCapability = requestedCapability
        self.requestedOperation = requestedOperation
        self.requestedOutcome = requestedOutcome
        self.peripheralProfileID = peripheralProfileID
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
        self.priority = priority
        self.policyVersion = policyVersion
        self.evidenceReference = evidenceReference
    }
}

public struct HALBluetoothRouteAdmission: Codable, Equatable, Sendable {
    public let decision: HALBluetoothRouteDecision
    public let holdReason: HALBluetoothHoldReason?
    public let admittedOperation: BLEOperation?
    public let admittedOutcome: HALRequestedBluetoothOutcome?
    public let fallback: BluetoothFallback
    public let authorityCeiling: String
    public let provenancePreserved: Bool

    public init(
        decision: HALBluetoothRouteDecision,
        holdReason: HALBluetoothHoldReason?,
        admittedOperation: BLEOperation?,
        admittedOutcome: HALRequestedBluetoothOutcome?,
        fallback: BluetoothFallback,
        authorityCeiling: String,
        provenancePreserved: Bool
    ) {
        self.decision = decision
        self.holdReason = holdReason
        self.admittedOperation = admittedOperation
        self.admittedOutcome = admittedOutcome
        self.fallback = fallback
        self.authorityCeiling = authorityCeiling
        self.provenancePreserved = provenancePreserved
    }
}

public struct HALBluetoothTransportReceipt: Codable, Equatable, Sendable {
    public let requestID: UUID
    public let routeDecision: HALBluetoothRouteDecision
    public let transportState: BluetoothAvailability
    public let peripheralProfileID: String?
    public let serviceID: UUID?
    public let characteristicID: UUID?
    public let startedAt: Date
    public let completedAt: Date?
    public let expiry: Date
    public let holdReason: HALBluetoothHoldReason?
    public let provenancePreserved: Bool
    public let rawPayloadRetained: Bool
    public let sealsDojoReceipt: Bool

    public init(
        requestID: UUID,
        routeDecision: HALBluetoothRouteDecision,
        transportState: BluetoothAvailability,
        peripheralProfileID: String?,
        serviceID: UUID?,
        characteristicID: UUID?,
        startedAt: Date,
        completedAt: Date?,
        expiry: Date,
        holdReason: HALBluetoothHoldReason?,
        provenancePreserved: Bool,
        rawPayloadRetained: Bool = false,
        sealsDojoReceipt: Bool = false
    ) {
        self.requestID = requestID
        self.routeDecision = routeDecision
        self.transportState = transportState
        self.peripheralProfileID = peripheralProfileID
        self.serviceID = serviceID
        self.characteristicID = characteristicID
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.expiry = expiry
        self.holdReason = holdReason
        self.provenancePreserved = provenancePreserved
        self.rawPayloadRetained = rawPayloadRetained
        self.sealsDojoReceipt = sealsDojoReceipt
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if expiry <= startedAt {
            violations.append("BLE receipt expiry must follow start")
        }
        if let completedAt, completedAt < startedAt || completedAt > expiry {
            violations.append("BLE receipt completion is outside its transport window")
        }
        if rawPayloadRetained {
            violations.append("HAL BLE receipt cannot retain raw payload")
        }
        if sealsDojoReceipt {
            violations.append("HAL BLE transport receipt cannot seal a DOJO receipt")
        }
        if !provenancePreserved {
            violations.append("HAL BLE transport receipt lost provenance")
        }
        return violations
    }
}

public enum HALBluetoothRoutePolicy {
    public static func evaluate(
        request: HALBluetoothRouteRequest,
        at evaluationTime: Date,
        bluetoothAvailability: BluetoothAvailability,
        profile: BLEPeripheralProfile?,
        murmurPolicy: FieldMurmurPolicy,
        watchSurface: FieldSurfaceNode
    ) -> HALBluetoothRouteAdmission {
        guard request.origin.channel == .arkadas,
              request.origin.invariantViolations().isEmpty,
              request.origin.coordinatorID == "hal",
              !request.peripheralProfileID.isEmpty
        else {
            return hold(.provenanceIncomplete, fallback: .hold)
        }
        guard request.issuedAt <= evaluationTime else {
            return hold(.staleRequest, fallback: .hold)
        }
        guard request.expiresAt > evaluationTime else {
            return hold(.expiredRequest, fallback: .hold)
        }
        guard request.intendedSurfaceID == "watch_ultra_murmur",
              watchSurface.id == request.intendedSurfaceID,
              murmurPolicy.surfaceID == request.intendedSurfaceID,
              watchSurface.configuration.authorityCeiling == "HAPTIC_CUE_ONLY",
              !watchSurface.configuration.globalFieldAuthority,
              !watchSurface.utilisation.consentInferred,
              murmurPolicy.invariantViolations(knownSurfaceIDs: [watchSurface.id]).isEmpty
        else {
            return hold(.murmurAuthorityExceeded, fallback: .hold)
        }

        switch bluetoothAvailability {
        case .poweredOn:
            break
        case .unauthorised:
            return hold(.bluetoothUnauthorised, fallback: .hold)
        case .poweredOff, .unsupported, .resetting, .unknown:
            let fallback = profile?.fallback ?? .hold
            return routeUnavailable(fallback: fallback)
        }

        guard let profile,
              profile.id == request.peripheralProfileID,
              profile.availability == .available,
              profile.serviceID != nil,
              profile.invariantViolations().isEmpty
        else {
            return hold(.peripheralNotRegistered, fallback: profile?.fallback ?? .hold)
        }
        guard request.requestedCapability == .bluetoothLowEnergyCentral,
              profile.permittedOperations.contains(request.requestedOperation)
        else {
            return hold(.serviceNotAllowed, fallback: profile.fallback)
        }

        switch request.requestedOutcome {
        case .dampenHaptics:
            guard murmurPolicy.correctionActions.contains(.dampenHaptics) else {
                return hold(.murmurAuthorityExceeded, fallback: profile.fallback)
            }
        case .hold:
            guard murmurPolicy.correctionActions.contains(.hold) else {
                return hold(.murmurAuthorityExceeded, fallback: profile.fallback)
            }
        case .requestHandoff:
            return HALBluetoothRouteAdmission(
                decision: .requestHandoff,
                holdReason: .pairedIPhonePreferred,
                admittedOperation: nil,
                admittedOutcome: .requestHandoff,
                fallback: .requestPairedIPhoneHandoff,
                authorityCeiling: "HAPTIC_CUE_ONLY",
                provenancePreserved: true
            )
        case .voiceInteraction, .dojoAuthorityMutation, .pulseEmission, .somaStateMutation:
            return HALBluetoothRouteAdmission(
                decision: .reject,
                holdReason: .murmurAuthorityExceeded,
                admittedOperation: nil,
                admittedOutcome: nil,
                fallback: profile.fallback,
                authorityCeiling: "HAPTIC_CUE_ONLY",
                provenancePreserved: true
            )
        }

        return HALBluetoothRouteAdmission(
            decision: .admit,
            holdReason: nil,
            admittedOperation: request.requestedOperation,
            admittedOutcome: request.requestedOutcome,
            fallback: profile.fallback,
            authorityCeiling: "HAPTIC_CUE_ONLY",
            provenancePreserved: true
        )
    }

    private static func routeUnavailable(fallback: BluetoothFallback) -> HALBluetoothRouteAdmission {
        if fallback == .requestPairedIPhoneHandoff {
            return HALBluetoothRouteAdmission(
                decision: .requestHandoff,
                holdReason: .bluetoothUnavailable,
                admittedOperation: nil,
                admittedOutcome: .requestHandoff,
                fallback: fallback,
                authorityCeiling: "HAPTIC_CUE_ONLY",
                provenancePreserved: true
            )
        }
        return hold(.bluetoothUnavailable, fallback: fallback)
    }

    private static func hold(
        _ reason: HALBluetoothHoldReason,
        fallback: BluetoothFallback
    ) -> HALBluetoothRouteAdmission {
        HALBluetoothRouteAdmission(
            decision: .hold,
            holdReason: reason,
            admittedOperation: nil,
            admittedOutcome: nil,
            fallback: fallback,
            authorityCeiling: "HAPTIC_CUE_ONLY",
            provenancePreserved: true
        )
    }
}

public enum ArkadasBluetoothContract {
    public static let coreBluetoothInverseSurfaceID = "core_bluetooth"
    public static let bluetoothAuthorisationInverseSurfaceID = "apple_bluetooth_authorisation"

    /// Deliberately unbound: no service or characteristic UUID is claimed until
    /// a real peripheral is selected, approved, and tested.
    public static let unboundEnvironmentalEvidenceProfile = BLEPeripheralProfile(
        profileID: "arkadas.environmental-evidence.unbound.v1",
        serviceID: nil,
        allowedCharacteristicIDs: [],
        permittedOperations: [.scanRegisteredService, .connect, .discoverServices, .subscribe, .disconnect],
        requiredSecurity: [.knownPeripheralRequired, .encryptedLinkRequired, .explicitUserInitiationRequired],
        maximumPayloadBytes: 128,
        minimumInterval: 5,
        messageTTL: 30,
        fallback: .hold,
        dataClassification: .environmentalEvidence,
        availability: .notConfigured
    )

    public static let watchTransportRole = BluetoothTransportRole.central
    public static let watchCanAdvertiseApplicationGATTService = false
    public static let pairedIPhonePreferredTransport = BluetoothTransportRole.pairedDeviceTransport
}

public enum BluetoothHandoffPhase: String, Codable, Equatable, Hashable, Sendable {
    case proposed
    case scanning
    case discovered
    case connecting
    case negotiating
    case active
    case draining
    case completed
    case held
    case failed
    case expired
}

public enum BluetoothHandoffPriority: Int, Codable, Comparable, Equatable, Sendable {
    case convenience = 0
    case continuity = 1
    case timeSensitive = 2
    case safety = 3

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Process-relative time used only for ordering and elapsed-duration decisions.
/// It is meaningful only within the runtime epoch identified by the request.
public struct MonotonicTimestamp: Codable, Equatable, Comparable, Sendable {
    public let nanoseconds: UInt64

    public init(nanoseconds: UInt64) {
        self.nanoseconds = nanoseconds
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.nanoseconds < rhs.nanoseconds
    }

    public func adding(nanoseconds delta: UInt64) -> Self {
        let result = nanoseconds.addingReportingOverflow(delta)
        return Self(nanoseconds: result.overflow ? .max : result.partialValue)
    }
}

public struct BluetoothHandoffLeasePolicy: Codable, Equatable, Sendable {
    public let proposalNanoseconds: UInt64
    public let connectionNanoseconds: UInt64
    public let negotiationNanoseconds: UInt64
    public let stabilityNanoseconds: UInt64
    public let maximumRetryCount: Int
    public let baseRetryNanoseconds: UInt64
    public let maximumRetryNanoseconds: UInt64

    public init(
        proposalNanoseconds: UInt64,
        connectionNanoseconds: UInt64,
        negotiationNanoseconds: UInt64,
        stabilityNanoseconds: UInt64,
        maximumRetryCount: Int,
        baseRetryNanoseconds: UInt64,
        maximumRetryNanoseconds: UInt64
    ) {
        self.proposalNanoseconds = proposalNanoseconds
        self.connectionNanoseconds = connectionNanoseconds
        self.negotiationNanoseconds = negotiationNanoseconds
        self.stabilityNanoseconds = stabilityNanoseconds
        self.maximumRetryCount = maximumRetryCount
        self.baseRetryNanoseconds = baseRetryNanoseconds
        self.maximumRetryNanoseconds = maximumRetryNanoseconds
    }

    public func retryDelayNanoseconds(for retryCount: Int, jitterNanoseconds: UInt64) -> UInt64 {
        let shift = min(max(retryCount - 1, 0), 20)
        let multiplied = baseRetryNanoseconds.multipliedReportingOverflow(by: UInt64(1) << shift)
        let boundedBase = multiplied.overflow ? maximumRetryNanoseconds : min(multiplied.partialValue, maximumRetryNanoseconds)
        let jittered = boundedBase.addingReportingOverflow(jitterNanoseconds)
        return jittered.overflow ? maximumRetryNanoseconds : min(jittered.partialValue, maximumRetryNanoseconds)
    }
}

public struct BluetoothHandoffRequest: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let sourceSurfaceID: String
    public let destinationSurfaceID: String
    public let channel: SovereignChannel
    public let requiredServiceIDs: [UUID]
    public let priority: BluetoothHandoffPriority
    public let createdAt: Date
    public let runtimeEpochID: UUID
    public let createdAtMonotonic: MonotonicTimestamp
    public let deadlineAtMonotonic: MonotonicTimestamp
    public let leasePolicy: BluetoothHandoffLeasePolicy
    public let authorityCeiling: String
    public let policyVersion: String
    public let evidenceReference: String?

    public init(
        handoffID: UUID,
        sourceSurfaceID: String,
        destinationSurfaceID: String,
        channel: SovereignChannel,
        requiredServiceIDs: [UUID],
        priority: BluetoothHandoffPriority,
        createdAt: Date,
        runtimeEpochID: UUID,
        createdAtMonotonic: MonotonicTimestamp,
        deadlineAtMonotonic: MonotonicTimestamp,
        leasePolicy: BluetoothHandoffLeasePolicy,
        authorityCeiling: String,
        policyVersion: String,
        evidenceReference: String?
    ) {
        self.id = handoffID
        self.sourceSurfaceID = sourceSurfaceID
        self.destinationSurfaceID = destinationSurfaceID
        self.channel = channel
        self.requiredServiceIDs = requiredServiceIDs
        self.priority = priority
        self.createdAt = createdAt
        self.runtimeEpochID = runtimeEpochID
        self.createdAtMonotonic = createdAtMonotonic
        self.deadlineAtMonotonic = deadlineAtMonotonic
        self.leasePolicy = leasePolicy
        self.authorityCeiling = authorityCeiling
        self.policyVersion = policyVersion
        self.evidenceReference = evidenceReference
    }
}

public struct BluetoothHandoffState: Codable, Equatable, Sendable {
    public let request: BluetoothHandoffRequest
    public var phase: BluetoothHandoffPhase
    public var peripheralID: UUID?
    public var discoveredServiceIDs: Set<UUID>
    public var firstValidPayloadAt: MonotonicTimestamp?
    public var stabilityStartedAt: MonotonicTimestamp?
    public var phaseDeadline: MonotonicTimestamp
    public var retryCount: Int
    public var sourceReleased: Bool
    public var holdReason: HALBluetoothHoldReason?

    public init(request: BluetoothHandoffRequest) {
        self.request = request
        phase = .proposed
        peripheralID = nil
        discoveredServiceIDs = []
        firstValidPayloadAt = nil
        stabilityStartedAt = nil
        phaseDeadline = request.createdAtMonotonic.adding(nanoseconds: request.leasePolicy.proposalNanoseconds)
        retryCount = 0
        sourceReleased = false
        holdReason = nil
    }
}

public struct BluetoothHandoffCoordinationReceipt: Codable, Equatable, Sendable {
    public let handoffID: UUID
    public let channelID: String
    public let channelDisplayName: String
    public let sourceSurfaceID: String
    public let destinationSurfaceID: String
    public let finalPhase: BluetoothHandoffPhase
    public let createdAt: Date
    public let recordedAt: Date
    public let elapsedMonotonicNanoseconds: UInt64
    public let retryCount: Int
    public let sourceReleased: Bool
    public let holdReason: HALBluetoothHoldReason?
    public let authorityCeiling: String
    public let policyVersion: String
    public let evidenceReference: String?
    public let rawBluetoothPayloadRetained: Bool
    public let sealsDojoReceipt: Bool
}

/// Serializes CoreBluetooth callbacks into a deterministic, lease-bound handoff.
/// The adapter supplies monotonic timestamps; this actor performs no Bluetooth I/O.
public actor HALBluetoothHandoffArbiter {
    private let runtimeEpochID: UUID
    private var handoffs: [UUID: BluetoothHandoffState] = [:]
    private var activeHandoffByChannel: [SovereignChannel: UUID] = [:]

    public init(runtimeEpochID: UUID) {
        self.runtimeEpochID = runtimeEpochID
    }

    public func submit(_ request: BluetoothHandoffRequest, now: MonotonicTimestamp) -> BluetoothHandoffState {
        var state = BluetoothHandoffState(request: request)
        guard request.runtimeEpochID == runtimeEpochID,
              request.createdAtMonotonic <= now,
              now < request.deadlineAtMonotonic,
              !request.requiredServiceIDs.isEmpty,
              request.authorityCeiling == "HAPTIC_CUE_ONLY"
        else {
            state.phase = request.runtimeEpochID == runtimeEpochID ? .held : .expired
            state.holdReason = request.runtimeEpochID == runtimeEpochID ? .provenanceIncomplete : .expiredRequest
            handoffs[request.id] = state
            return state
        }
        if let activeID = activeHandoffByChannel[request.channel],
           let active = handoffs[activeID],
           active.phase != .completed,
           active.phase != .failed,
           active.phase != .expired,
           active.phase != .held {
            state.phase = .held
            state.holdReason = .connectionUnavailable
            handoffs[request.id] = state
            return state
        }
        state.phase = .scanning
        state.phaseDeadline = boundedDeadline(
            now.adding(nanoseconds: request.leasePolicy.connectionNanoseconds),
            request.deadlineAtMonotonic
        )
        handoffs[request.id] = state
        activeHandoffByChannel[request.channel] = request.id
        return state
    }

    public func didDiscover(handoffID: UUID, peripheralID: UUID, now: MonotonicTimestamp) -> BluetoothHandoffState? {
        transition(handoffID: handoffID, now: now, allowed: [.scanning]) { state in
            state.phase = .connecting
            state.peripheralID = peripheralID
            state.phaseDeadline = boundedDeadline(
                now.adding(nanoseconds: state.request.leasePolicy.connectionNanoseconds),
                state.request.deadlineAtMonotonic
            )
        }
    }

    public func didConnect(handoffID: UUID, peripheralID: UUID, now: MonotonicTimestamp) -> BluetoothHandoffState? {
        transition(handoffID: handoffID, now: now, allowed: [.connecting], peripheralID: peripheralID) { state in
            state.phase = .negotiating
            state.phaseDeadline = boundedDeadline(
                now.adding(nanoseconds: state.request.leasePolicy.negotiationNanoseconds),
                state.request.deadlineAtMonotonic
            )
        }
    }

    public func didNegotiate(
        handoffID: UUID,
        peripheralID: UUID,
        discoveredServiceIDs: Set<UUID>,
        now: MonotonicTimestamp
    ) -> BluetoothHandoffState? {
        transition(handoffID: handoffID, now: now, allowed: [.negotiating], peripheralID: peripheralID) { state in
            guard Set(state.request.requiredServiceIDs).isSubset(of: discoveredServiceIDs) else {
                state.phase = .held
                state.holdReason = .serviceNotAllowed
                return
            }
            state.discoveredServiceIDs = discoveredServiceIDs
            state.phase = .discovered
        }
    }

    public func didReceiveFirstValidPayload(
        handoffID: UUID,
        peripheralID: UUID,
        now: MonotonicTimestamp
    ) -> BluetoothHandoffState? {
        transition(handoffID: handoffID, now: now, allowed: [.discovered], peripheralID: peripheralID) { state in
            state.firstValidPayloadAt = now
            state.stabilityStartedAt = now
            state.phaseDeadline = boundedDeadline(
                now.adding(nanoseconds: state.request.leasePolicy.stabilityNanoseconds),
                state.request.deadlineAtMonotonic
            )
        }
    }

    public func confirmStability(handoffID: UUID, now: MonotonicTimestamp) -> BluetoothHandoffState? {
        transition(handoffID: handoffID, now: now, allowed: [.discovered], enforcePhaseDeadline: false) { state in
            guard let stabilityStartedAt = state.stabilityStartedAt,
                  now.nanoseconds >= stabilityStartedAt.adding(
                    nanoseconds: state.request.leasePolicy.stabilityNanoseconds
                  ).nanoseconds,
                  now <= state.phaseDeadline
            else { return }
            state.phase = .active
            state.sourceReleased = true
        }
    }

    public func state(for handoffID: UUID) -> BluetoothHandoffState? {
        handoffs[handoffID]
    }

    public func expireOverdue(at now: MonotonicTimestamp) {
        for id in handoffs.keys {
            guard var state = handoffs[id], isPending(state.phase), now > state.phaseDeadline else { continue }
            state.phase = .expired
            state.holdReason = .expiredRequest
            state.sourceReleased = false
            handoffs[id] = state
            activeHandoffByChannel[state.request.channel] = nil
        }
    }

    private func transition(
        handoffID: UUID,
        now: MonotonicTimestamp,
        allowed: Set<BluetoothHandoffPhase>,
        peripheralID: UUID? = nil,
        enforcePhaseDeadline: Bool = true,
        update: (inout BluetoothHandoffState) -> Void
    ) -> BluetoothHandoffState? {
        guard var state = handoffs[handoffID],
              state.request.runtimeEpochID == runtimeEpochID,
              allowed.contains(state.phase),
              now <= state.request.deadlineAtMonotonic,
              (!enforcePhaseDeadline || now <= state.phaseDeadline),
              peripheralID == nil || peripheralID == state.peripheralID
        else { return handoffs[handoffID] }
        update(&state)
        handoffs[handoffID] = state
        if [.held, .failed, .expired, .completed].contains(state.phase) {
            activeHandoffByChannel[state.request.channel] = nil
        }
        return state
    }

    private func isPending(_ phase: BluetoothHandoffPhase) -> Bool {
        ![.active, .completed, .held, .failed, .expired].contains(phase)
    }
}

private func boundedDeadline(_ proposed: MonotonicTimestamp, _ absolute: MonotonicTimestamp) -> MonotonicTimestamp {
    min(proposed, absolute)
}
