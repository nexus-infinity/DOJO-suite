import Foundation

/// The coordination plane in which a surface participates. A plane is a
/// routing distinction, not a claim that the surface owns FIELD authority.
public enum FieldSurfacePlane: String, Codable, CaseIterable, Equatable, Sendable {
    case developmentConfiguration = "DEVELOPMENT_CONFIGURATION"
    case sovereignMirror = "SOVEREIGN_MIRROR"
    case externalIntake = "EXTERNAL_INTAKE"
    case internalCirculation = "INTERNAL_CIRCULATION"
    case hostedPhenotype = "HOSTED_PHENOTYPE"
    case visualPhenotype = "VISUAL_PHENOTYPE"
    case deviceFeedback = "DEVICE_FEEDBACK"
}

public struct FieldInfrastructureNode: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let capabilities: [String: String]
    public let role: String
    public let permissionProfile: String
    public let reliabilityClass: String
    public let sovereigntyClass: String

    public init(
        id: String,
        type: String,
        capabilities: [String: String],
        role: String,
        permissionProfile: String,
        reliabilityClass: String,
        sovereigntyClass: String
    ) {
        self.id = id
        self.type = type
        self.capabilities = capabilities
        self.role = role
        self.permissionProfile = permissionProfile
        self.reliabilityClass = reliabilityClass
        self.sovereigntyClass = sovereigntyClass
    }
}

/// Native responsibility of one named surface. The responsibility is scoped
/// to the surface; it is never a global authority claim.
public enum FieldSurfaceRole: String, Codable, CaseIterable, Equatable, Sendable {
    case intentionCanon = "INTENTION_CANON"
    case coordination = "COORDINATION"
    case architectHandoff = "ARCHITECT_HANDOFF"
    case implementationLineage = "IMPLEMENTATION_LINEAGE"
    case sovereignMirror = "SOVEREIGN_MIRROR"
    case externalIntake = "EXTERNAL_INTAKE"
    case internalObserver = "INTERNAL_OBSERVER"
    case internalConductor = "INTERNAL_CONDUCTOR"
    case hostedPhenotype = "HOSTED_PHENOTYPE"
    case visualPhenotype = "VISUAL_PHENOTYPE"
    case deviceFeedback = "DEVICE_FEEDBACK"
}

public enum FieldSurfaceEvidenceState: String, Codable, CaseIterable, Equatable, Sendable {
    case witnessed = "WITNESSED"
    case partial = "PARTIAL"
    case unknown = "UNKNOWN"
    case held = "HELD"
}

/// A surface's transfer vocabulary is deliberately narrower than arbitrary
/// copying or execution. All registered transfers carry pointers and/or
/// handoff meaning; none grants the receiving surface authority.
public enum FieldSurfaceTransferKind: String, Codable, CaseIterable, Equatable, Sendable {
    case pointerOnly = "POINTER_ONLY"
    case coordinationPointer = "COORDINATION_POINTER"
    case refinedArchitectHandoff = "REFINED_ARCHITECT_HANDOFF"
    case implementationHandoff = "IMPLEMENTATION_HANDOFF"
    case internalObservationReturn = "INTERNAL_OBSERVATION_RETURN"
    case hostedPhenotypePointer = "HOSTED_PHENOTYPE_POINTER"
    case visualPhenotypePointer = "VISUAL_PHENOTYPE_POINTER"
}

public enum FieldSurfaceNodeKind: String, Codable, CaseIterable, Equatable, Sendable {
    case mac = "MAC"
    case iPhone = "IPHONE"
    case iPad = "IPAD"
    case watch = "WATCH"
    case earbuds = "EARBUDS"
    case flatscreen = "FLATSCREEN"
    case vehicle = "VEHICLE"
    case ambient = "AMBIENT"
    case unknown = "UNKNOWN"
}

public enum FieldSurfaceChannel: String, Codable, CaseIterable, Equatable, Sendable {
    case visual = "VISUAL"
    case audio = "AUDIO"
    case haptic = "HAPTIC"
    case spatial = "SPATIAL"
    case ambient = "AMBIENT"
    case touch = "TOUCH"
    case keyboard = "KEYBOARD"
    case voice = "VOICE"
    case motion = "MOTION"
    case biometric = "BIOMETRIC"
    case location = "LOCATION"
    case time = "TIME"
    case semantic = "SEMANTIC"
    case geometric = "GEOMETRIC"
    case temporal = "TEMPORAL"
    case evidential = "EVIDENTIAL"
    case permission = "PERMISSION"
    case unknown = "UNKNOWN"
}

public enum FieldSurfaceOperationalLayer: String, Codable, CaseIterable, Equatable, Sendable {
    case configuration = "CONFIGURATION"
    case infrastructure = "INFRASTRUCTURE"
    case utilisation = "UTILISATION"
}

public enum FieldSurfaceInfrastructureState: String, Codable, CaseIterable, Equatable, Sendable {
    case witnessedAvailable = "WITNESSED_AVAILABLE"
    case partial = "PARTIAL"
    case held = "HELD"
    case unknown = "UNKNOWN"
}

public enum FieldSurfaceUtilisationContext: String, Codable, CaseIterable, Equatable, Sendable {
    case desktopWorking = "DESKTOP_WORKING"
    case mobileContinuity = "MOBILE_CONTINUITY"
    case glanceable = "GLANCEABLE"
    case sharedAmbient = "SHARED_AMBIENT"
    case safetyConstrained = "SAFETY_CONSTRAINED"
    case unknown = "UNKNOWN"
}

public struct FieldSurfaceConfigurationFacet: Codable, Equatable, Sendable {
    public let allowedProjections: [String]
    public let allowedActions: [String]
    public let permissionProfile: String
    public let authorityCeiling: String
    public let globalFieldAuthority: Bool

    public init(
        allowedProjections: [String],
        allowedActions: [String],
        permissionProfile: String,
        authorityCeiling: String,
        globalFieldAuthority: Bool = false
    ) {
        self.allowedProjections = allowedProjections
        self.allowedActions = allowedActions
        self.permissionProfile = permissionProfile
        self.authorityCeiling = authorityCeiling
        self.globalFieldAuthority = globalFieldAuthority
    }
}

public struct FieldSurfaceInfrastructureFacet: Codable, Equatable, Sendable {
    public let state: FieldSurfaceInfrastructureState
    public let healthPointer: String
    public let latencyClass: String
    public let networkBoundary: String

    public init(
        state: FieldSurfaceInfrastructureState = .unknown,
        healthPointer: String = "Unknown",
        latencyClass: String = "Unknown",
        networkBoundary: String = "Unknown"
    ) {
        self.state = state
        self.healthPointer = healthPointer
        self.latencyClass = latencyClass
        self.networkBoundary = networkBoundary
    }
}

public struct FieldSurfaceUtilisationFacet: Codable, Equatable, Sendable {
    public let context: FieldSurfaceUtilisationContext
    public let activeSignalsIn: [FieldSurfaceChannel]
    public let activeSignalsOut: [FieldSurfaceChannel]
    public let currentObserverID: String
    public let consentInferred: Bool

    public init(
        context: FieldSurfaceUtilisationContext = .unknown,
        activeSignalsIn: [FieldSurfaceChannel] = [],
        activeSignalsOut: [FieldSurfaceChannel] = [],
        currentObserverID: String = "Unknown.Observer",
        consentInferred: Bool = false
    ) {
        self.context = context
        self.activeSignalsIn = activeSignalsIn
        self.activeSignalsOut = activeSignalsOut
        self.currentObserverID = currentObserverID
        self.consentInferred = consentInferred
    }
}

public struct FieldSurfaceNode: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let displayName: String
    public let kind: FieldSurfaceNodeKind
    public let outputChannels: [FieldSurfaceChannel]
    public let inputChannels: [FieldSurfaceChannel]
    public let configuration: FieldSurfaceConfigurationFacet
    public let infrastructure: FieldSurfaceInfrastructureFacet
    public let utilisation: FieldSurfaceUtilisationFacet

    public init(
        id: String,
        displayName: String,
        kind: FieldSurfaceNodeKind,
        outputChannels: [FieldSurfaceChannel],
        inputChannels: [FieldSurfaceChannel],
        configuration: FieldSurfaceConfigurationFacet,
        infrastructure: FieldSurfaceInfrastructureFacet = FieldSurfaceInfrastructureFacet(),
        utilisation: FieldSurfaceUtilisationFacet = FieldSurfaceUtilisationFacet()
    ) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
        self.outputChannels = outputChannels
        self.inputChannels = inputChannels
        self.configuration = configuration
        self.infrastructure = infrastructure
        self.utilisation = utilisation
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("surface node ID is empty")
        }
        if displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("surface node display name is empty")
        }
        if outputChannels.isEmpty && inputChannels.isEmpty {
            violations.append("surface node has no channels")
        }
        if configuration.globalFieldAuthority {
            violations.append("surface node configuration claims global FIELD authority")
        }
        if utilisation.consentInferred {
            violations.append("surface node utilisation infers consent")
        }
        return violations
    }
}

public enum FieldSignalEndpointKind: String, Codable, CaseIterable, Equatable, Sendable {
    case observer = "OBSERVER"
    case device = "DEVICE"
    case service = "SERVICE"
    case environment = "ENVIRONMENT"
    case object = "OBJECT"
    case unknown = "UNKNOWN"
}

public struct FieldSignalEndpoint: Codable, Equatable, Sendable {
    public let kind: FieldSignalEndpointKind
    public let id: String

    public init(kind: FieldSignalEndpointKind, id: String) {
        self.kind = kind
        self.id = id
    }
}

public enum FieldSignalLane: String, Codable, CaseIterable, Equatable, Sendable {
    case conceptual = "CONCEPTUAL"
    case semantic = "SEMANTIC"
    case geometric = "GEOMETRIC"
    case temporal = "TEMPORAL"
    case experiential = "EXPERIENTIAL"
    case operational = "OPERATIONAL"
    case evidential = "EVIDENTIAL"
    case permission = "PERMISSION"
}

public struct FieldSignalGraphEdge: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let source: FieldSignalEndpoint
    public let receiver: FieldSignalEndpoint
    public let channel: FieldSurfaceChannel
    public let lane: FieldSignalLane
    public let surfaceID: String
    public let meaningPointer: String
    public let permissionProfile: String
    public let evidencePointer: String
    public let feedbackPath: String
    public let configurationMutationAllowed: Bool
    public let infrastructureMutationAllowed: Bool
    public let runtimeAuthorityGranted: Bool
    public let consentInferred: Bool

    public init(
        id: String,
        source: FieldSignalEndpoint,
        receiver: FieldSignalEndpoint,
        channel: FieldSurfaceChannel,
        lane: FieldSignalLane,
        surfaceID: String,
        meaningPointer: String,
        permissionProfile: String,
        evidencePointer: String,
        feedbackPath: String,
        configurationMutationAllowed: Bool = false,
        infrastructureMutationAllowed: Bool = false,
        runtimeAuthorityGranted: Bool = false,
        consentInferred: Bool = false
    ) {
        self.id = id
        self.source = source
        self.receiver = receiver
        self.channel = channel
        self.lane = lane
        self.surfaceID = surfaceID
        self.meaningPointer = meaningPointer
        self.permissionProfile = permissionProfile
        self.evidencePointer = evidencePointer
        self.feedbackPath = feedbackPath
        self.configurationMutationAllowed = configurationMutationAllowed
        self.infrastructureMutationAllowed = infrastructureMutationAllowed
        self.runtimeAuthorityGranted = runtimeAuthorityGranted
        self.consentInferred = consentInferred
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal edge ID is empty")
        }
        if source.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal source ID is empty")
        }
        if receiver.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal receiver ID is empty")
        }
        if surfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal surface ID is empty")
        }
        if meaningPointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal meaning pointer is empty")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal evidence pointer is empty")
        }
        if feedbackPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("signal feedback path is empty")
        }
        if configurationMutationAllowed {
            violations.append("signal edge mutates configuration")
        }
        if infrastructureMutationAllowed {
            violations.append("signal edge mutates infrastructure")
        }
        if runtimeAuthorityGranted {
            violations.append("signal edge grants runtime authority")
        }
        if consentInferred {
            violations.append("signal edge infers consent")
        }
        return violations
    }
}

public enum FieldPermissionDecision: String, Codable, CaseIterable, Equatable, Sendable {
    case pass = "PASS"
    case hold = "HOLD"
    case forbidden = "FORBIDDEN"
}

public struct FieldPermissionProfile: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let displayName: String
    public let allowedChannels: [FieldSurfaceChannel]
    public let allowedActions: [String]
    public let authorityCeiling: String
    public let canSelectSurface: Bool
    public let canMutateSource: Bool
    public let canControlApplication: Bool
    public let canSendOrPublish: Bool
    public let consentInferred: Bool

    public init(
        id: String,
        displayName: String,
        allowedChannels: [FieldSurfaceChannel],
        allowedActions: [String],
        authorityCeiling: String,
        canSelectSurface: Bool = false,
        canMutateSource: Bool = false,
        canControlApplication: Bool = false,
        canSendOrPublish: Bool = false,
        consentInferred: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.allowedChannels = allowedChannels
        self.allowedActions = allowedActions
        self.authorityCeiling = authorityCeiling
        self.canSelectSurface = canSelectSurface
        self.canMutateSource = canMutateSource
        self.canControlApplication = canControlApplication
        self.canSendOrPublish = canSendOrPublish
        self.consentInferred = consentInferred
    }

    public func decision(for channel: FieldSurfaceChannel) -> FieldPermissionDecision {
        allowedChannels.contains(channel) ? .pass : .hold
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("permission profile ID is empty")
        }
        if displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("permission profile display name is empty")
        }
        if allowedChannels.isEmpty {
            violations.append("permission profile has no allowed channels")
        }
        if authorityCeiling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("permission profile authority ceiling is empty")
        }
        if canMutateSource {
            violations.append("permission profile mutates source")
        }
        if canControlApplication {
            violations.append("permission profile controls applications")
        }
        if canSendOrPublish {
            violations.append("permission profile sends or publishes")
        }
        if consentInferred {
            violations.append("permission profile infers observer consent")
        }
        return violations
    }
}

public enum FieldObserverActivityKind: String, Codable, CaseIterable, Equatable, Sendable {
    case deskWork = "DESK_WORK"
    case mobile = "MOBILE"
    case walking = "WALKING"
    case driving = "DRIVING"
    case meeting = "MEETING"
    case ritual = "RITUAL"
    case offline = "OFFLINE"
    case unknown = "UNKNOWN"
}

public enum FieldObserverAttentionLevel: String, Codable, CaseIterable, Equatable, Sendable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    case unavailable = "UNAVAILABLE"
    case unknown = "UNKNOWN"
}

public enum FieldObserverAttentionMode: String, Codable, CaseIterable, Equatable, Sendable {
    case visualPrimary = "VISUAL_PRIMARY"
    case audioPrimary = "AUDIO_PRIMARY"
    case hapticPrimary = "HAPTIC_PRIMARY"
    case mixed = "MIXED"
    case none = "NONE"
    case unknown = "UNKNOWN"
}

public enum FieldObserverLocationSemantic: String, Codable, CaseIterable, Equatable, Sendable {
    case atDesk = "AT_DESK"
    case inVehicle = "IN_VEHICLE"
    case mobile = "MOBILE"
    case inMeetingRoom = "IN_MEETING_ROOM"
    case unknown = "UNKNOWN"
}

public enum FieldObserverUrgency: String, Codable, CaseIterable, Equatable, Sendable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"
}

public enum FieldContinuityPromiseStatus: String, Codable, CaseIterable, Equatable, Sendable {
    case active = "ACTIVE"
    case suspended = "SUSPENDED"
    case completed = "COMPLETED"
    case broken = "BROKEN"
    case unknown = "UNKNOWN"
}

public struct FieldObserverActivityState: Codable, Equatable, Sendable {
    public let kind: FieldObserverActivityKind
    public let detail: String
    public let safetyCritical: Bool

    public init(kind: FieldObserverActivityKind, detail: String = "", safetyCritical: Bool = false) {
        self.kind = kind
        self.detail = detail
        self.safetyCritical = safetyCritical
    }
}

public struct FieldObserverAttentionState: Codable, Equatable, Sendable {
    public let level: FieldObserverAttentionLevel
    public let mode: FieldObserverAttentionMode
    public let source: String

    public init(
        level: FieldObserverAttentionLevel,
        mode: FieldObserverAttentionMode,
        source: String = "manual fixture"
    ) {
        self.level = level
        self.mode = mode
        self.source = source
    }
}

public struct FieldObserverLocationState: Codable, Equatable, Sendable {
    public let semantic: FieldObserverLocationSemantic
    public let primarySurfaceID: String?
    public let nearbySurfaceIDs: [String]

    public init(
        semantic: FieldObserverLocationSemantic,
        primarySurfaceID: String?,
        nearbySurfaceIDs: [String] = []
    ) {
        self.semantic = semantic
        self.primarySurfaceID = primarySurfaceID
        self.nearbySurfaceIDs = nearbySurfaceIDs
    }
}

public struct FieldObserverActiveObjectSummary: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let role: String
    public let lanesActive: [FieldSignalLane]
    public let urgency: FieldObserverUrgency

    public init(
        objectID: String,
        role: String,
        lanesActive: [FieldSignalLane],
        urgency: FieldObserverUrgency
    ) {
        self.id = objectID
        self.role = role
        self.lanesActive = lanesActive
        self.urgency = urgency
    }
}

public struct FieldContinuityPromise: Codable, Equatable, Sendable {
    public let objectID: String
    public let startedOnSurfaceID: String
    public let canResumeOnSurfaceIDs: [String]
    public let requiredStateRefs: [String]
    public let status: FieldContinuityPromiseStatus

    public init(
        objectID: String,
        startedOnSurfaceID: String,
        canResumeOnSurfaceIDs: [String],
        requiredStateRefs: [String] = [],
        status: FieldContinuityPromiseStatus
    ) {
        self.objectID = objectID
        self.startedOnSurfaceID = startedOnSurfaceID
        self.canResumeOnSurfaceIDs = canResumeOnSurfaceIDs
        self.requiredStateRefs = requiredStateRefs
        self.status = status
    }
}

public enum FieldObserverIntegrityCode: String, Codable, CaseIterable, Equatable, Sendable {
    case ok = "OK"
    case degraded = "DEGRADED"
    case unknown = "UNKNOWN"
}

public struct FieldObserverIntegrityStatus: Codable, Equatable, Sendable {
    public let code: FieldObserverIntegrityCode
    public let note: String

    public init(code: FieldObserverIntegrityCode, note: String = "") {
        self.code = code
        self.note = note
    }
}

public struct FieldObserverContext: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let version: String
    public let asOfTime: String
    public let timeZone: String
    public let permissionProfileID: String
    public let continuityContractID: String
    public let primaryDeviceID: String?
    public let availableSurfaceIDs: [String]
    public let activeChannels: [FieldSurfaceChannel]
    public let activity: FieldObserverActivityState
    public let attention: FieldObserverAttentionState
    public let location: FieldObserverLocationState
    public let activeObjects: [FieldObserverActiveObjectSummary]
    public let continuityPromises: [FieldContinuityPromise]
    public let evidenceRef: String?
    public let integrityStatus: FieldObserverIntegrityStatus

    public init(
        observerID: String,
        version: String,
        asOfTime: String,
        timeZone: String,
        permissionProfileID: String,
        continuityContractID: String,
        primaryDeviceID: String?,
        availableSurfaceIDs: [String],
        activeChannels: [FieldSurfaceChannel],
        activity: FieldObserverActivityState,
        attention: FieldObserverAttentionState,
        location: FieldObserverLocationState,
        activeObjects: [FieldObserverActiveObjectSummary],
        continuityPromises: [FieldContinuityPromise],
        evidenceRef: String?,
        integrityStatus: FieldObserverIntegrityStatus
    ) {
        self.id = observerID
        self.version = version
        self.asOfTime = asOfTime
        self.timeZone = timeZone
        self.permissionProfileID = permissionProfileID
        self.continuityContractID = continuityContractID
        self.primaryDeviceID = primaryDeviceID
        self.availableSurfaceIDs = availableSurfaceIDs
        self.activeChannels = activeChannels
        self.activity = activity
        self.attention = attention
        self.location = location
        self.activeObjects = activeObjects
        self.continuityPromises = continuityPromises
        self.evidenceRef = evidenceRef
        self.integrityStatus = integrityStatus
    }

    public func invariantViolations(knownSurfaceIDs: Set<String> = []) -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observer context ID is empty")
        }
        if version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observer context version is empty")
        }
        if asOfTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observer context timestamp is empty")
        }
        if permissionProfileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observer context permission profile is empty")
        }
        if availableSurfaceIDs.isEmpty {
            violations.append("observer context has no available surfaces")
        }
        if activeChannels.isEmpty {
            violations.append("observer context has no active channels")
        }
        if activity.safetyCritical && attention.mode == .visualPrimary {
            violations.append("safety critical context cannot be visual-primary")
        }
        if let primaryDeviceID, !availableSurfaceIDs.contains(primaryDeviceID) {
            violations.append("primary device is not available")
        }
        if !knownSurfaceIDs.isEmpty {
            let missing = availableSurfaceIDs.filter { !knownSurfaceIDs.contains($0) }
            if !missing.isEmpty {
                violations.append("observer context references unknown surface")
            }
        }
        return violations
    }
}

public enum FieldCarPlayAction: String, Codable, CaseIterable, Equatable, Sendable {
    case hearSummary = "hearSummary"
    case deferToArrival = "deferToArrival"
    case acknowledgeHold = "acknowledgeHold"
}

public enum FieldCarPlayProjectionDecision: String, Codable, CaseIterable, Equatable, Sendable {
    case pass = "PASS"
    case hold = "HOLD"
}

public struct FieldCarPlayObjectMetadata: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let objectID: String
    public let carPlaySafeSummary: String
    public let allowedActions: [FieldCarPlayAction]
    public let desktopOnlyFields: [String]
    public let continuationSurfaceID: String
    public let evidencePointer: String
    public let authorityCeiling: String
    public let permitsDeepWork: Bool
    public let permitsVehicleControl: Bool

    public init(
        objectID: String,
        carPlaySafeSummary: String,
        allowedActions: [FieldCarPlayAction],
        desktopOnlyFields: [String],
        continuationSurfaceID: String,
        evidencePointer: String,
        authorityCeiling: String,
        permitsDeepWork: Bool = false,
        permitsVehicleControl: Bool = false
    ) {
        self.id = objectID
        self.objectID = objectID
        self.carPlaySafeSummary = carPlaySafeSummary
        self.allowedActions = allowedActions
        self.desktopOnlyFields = desktopOnlyFields
        self.continuationSurfaceID = continuationSurfaceID
        self.evidencePointer = evidencePointer
        self.authorityCeiling = authorityCeiling
        self.permitsDeepWork = permitsDeepWork
        self.permitsVehicleControl = permitsVehicleControl
    }

    public func invariantViolations(knownSurfaceIDs: Set<String> = []) -> [String] {
        var violations: [String] = []
        if objectID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("CarPlay object ID is empty")
        }
        let trimmedSummary = carPlaySafeSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedSummary.isEmpty {
            violations.append("CarPlay safe summary is empty")
        }
        if trimmedSummary.count > 120 {
            violations.append("CarPlay safe summary is too long")
        }
        if allowedActions.isEmpty {
            violations.append("CarPlay metadata has no allowed actions")
        }
        if !allowedActions.contains(.deferToArrival) {
            violations.append("CarPlay metadata lacks defer-to-arrival action")
        }
        if desktopOnlyFields.isEmpty {
            violations.append("CarPlay metadata has no desktop-only fields")
        }
        if continuationSurfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("CarPlay continuation surface is empty")
        }
        if !knownSurfaceIDs.isEmpty && !knownSurfaceIDs.contains(continuationSurfaceID) {
            violations.append("CarPlay continuation surface is unknown")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("CarPlay evidence pointer is empty")
        }
        if authorityCeiling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("CarPlay authority ceiling is empty")
        }
        if permitsDeepWork {
            violations.append("CarPlay metadata permits deep work")
        }
        if permitsVehicleControl {
            violations.append("CarPlay metadata permits vehicle control")
        }
        return violations
    }
}

public struct FieldCarPlayProjectionAdmission: Codable, Equatable, Sendable {
    public let decision: FieldCarPlayProjectionDecision
    public let blockedLaw: HarmonicKernelLaw?
    public let reason: String
    public let holdReasons: [String]
    public let visibleSummary: String?
    public let allowedActions: [FieldCarPlayAction]
    public let continuationSurfaceID: String?
    public let simulationAllowed: Bool
    public let runtimeProjectionAllowed: Bool

    public init(
        decision: FieldCarPlayProjectionDecision,
        blockedLaw: HarmonicKernelLaw?,
        reason: String,
        holdReasons: [String],
        visibleSummary: String?,
        allowedActions: [FieldCarPlayAction],
        continuationSurfaceID: String?,
        simulationAllowed: Bool,
        runtimeProjectionAllowed: Bool
    ) {
        self.decision = decision
        self.blockedLaw = blockedLaw
        self.reason = reason
        self.holdReasons = holdReasons
        self.visibleSummary = visibleSummary
        self.allowedActions = allowedActions
        self.continuationSurfaceID = continuationSurfaceID
        self.simulationAllowed = simulationAllowed
        self.runtimeProjectionAllowed = runtimeProjectionAllowed
    }
}

public enum FieldCarPlayProjectionPolicy {
    public static func admit(
        metadata: FieldCarPlayObjectMetadata?,
        observerContext: FieldObserverContext?,
        vehicleSurface: FieldSurfaceNode?,
        permissionProfile: FieldPermissionProfile?,
        knownSurfaceIDs: Set<String> = []
    ) -> FieldCarPlayProjectionAdmission {
        guard let metadata else {
            return hold(.conservation, "HOLD.CarPlayMetadataUnavailable", "CarPlay-safe metadata is required.")
        }
        let metadataViolations = metadata.invariantViolations(knownSurfaceIDs: knownSurfaceIDs)
        guard metadataViolations.isEmpty else {
            return hold(.conservation, metadataViolations, "CarPlay metadata violates the safe object contract.")
        }
        guard let observerContext else {
            return hold(.conservation, "HOLD.ObserverContextUnavailable", "Observer context is required.")
        }
        guard let vehicleSurface, vehicleSurface.kind == .vehicle else {
            return hold(.conservation, "HOLD.VehicleSurfaceUnavailable", "Vehicle surface must be present and typed as vehicle.")
        }
        guard let permissionProfile else {
            return hold(.symmetry, "HOLD.VehiclePermissionProfileUnavailable", "Vehicle permission profile is required.")
        }
        guard vehicleSurface.configuration.permissionProfile == permissionProfile.id else {
            return hold(.symmetry, "HOLD.VehiclePermissionProfileMismatch", "Vehicle surface and permission profile do not match.")
        }
        guard !permissionProfile.canMutateSource,
              !permissionProfile.canControlApplication,
              !permissionProfile.canSendOrPublish,
              !permissionProfile.consentInferred
        else {
            return hold(.symmetry, "HOLD.VehiclePermissionOverreach", "Vehicle projection cannot mutate, control, send, publish, or infer consent.")
        }
        let permittedActions = Set(permissionProfile.allowedActions)
        guard metadata.allowedActions.allSatisfy({ permittedActions.contains($0.rawValue) }) else {
            return hold(.symmetry, "HOLD.CarPlayActionOutsidePermission", "CarPlay action is outside the vehicle permission profile.")
        }
        guard permissionProfile.decision(for: .audio) == .pass,
              permissionProfile.decision(for: .temporal) == .pass,
              permissionProfile.decision(for: .visual) != .pass
        else {
            return hold(.symmetry, "HOLD.VehicleChannelEnvelopeMismatch", "Vehicle projection must be audio/temporal and not dense visual.")
        }
        guard vehicleSurface.outputChannels.contains(.audio),
              vehicleSurface.outputChannels.contains(.temporal),
              vehicleSurface.inputChannels.contains(.voice)
        else {
            return hold(.symmetry, "HOLD.VehicleSurfaceChannelMismatch", "Vehicle surface lacks the required voice-first channel envelope.")
        }
        guard observerContext.activity.kind == .driving,
              observerContext.location.semantic == .inVehicle,
              observerContext.activity.safetyCritical
        else {
            return hold(.resonance, "HOLD.NotInDrivingContext", "Vehicle projection is only admitted in a safety-critical driving context.")
        }
        guard observerContext.attention.mode != .visualPrimary,
              observerContext.attention.level != .low,
              observerContext.attention.level != .unavailable,
              observerContext.attention.level != .unknown
        else {
            return hold(.resonance, "HOLD.DrivingMode.CognitiveLoad", "Vehicle projection requires non-visual attention above low/unavailable.")
        }

        let runtimeAllowed = vehicleSurface.infrastructure.state == .witnessedAvailable
        return FieldCarPlayProjectionAdmission(
            decision: .pass,
            blockedLaw: nil,
            reason: runtimeAllowed ? "PASS.CarPlay.RuntimeEnvelope" : "PASS.CarPlay.SimulationOnly",
            holdReasons: runtimeAllowed ? [] : ["HOLD.CarPlayRuntimeNotImplemented"],
            visibleSummary: metadata.carPlaySafeSummary,
            allowedActions: metadata.allowedActions,
            continuationSurfaceID: metadata.continuationSurfaceID,
            simulationAllowed: true,
            runtimeProjectionAllowed: runtimeAllowed
        )
    }

    private static func hold(
        _ law: HarmonicKernelLaw,
        _ holdReason: String,
        _ reason: String
    ) -> FieldCarPlayProjectionAdmission {
        hold(law, [holdReason], reason)
    }

    private static func hold(
        _ law: HarmonicKernelLaw,
        _ holdReasons: [String],
        _ reason: String
    ) -> FieldCarPlayProjectionAdmission {
        FieldCarPlayProjectionAdmission(
            decision: .hold,
            blockedLaw: law,
            reason: reason,
            holdReasons: holdReasons,
            visibleSummary: nil,
            allowedActions: [],
            continuationSurfaceID: nil,
            simulationAllowed: false,
            runtimeProjectionAllowed: false
        )
    }
}

public enum FieldMurmurCorrectionAction: String, Codable, CaseIterable, Equatable, Sendable {
    case fadeOpacity = "fadeOpacity"
    case showPauseCue = "showPauseCue"
    case autoCollapse = "autoCollapse"
    case dampenHaptics = "dampenHaptics"
    case stageContinuation = "stageContinuation"
    case hold = "hold"
    case requestHumanReview = "requestHumanReview"
}

public enum FieldMurmurHomeostasisDecision: String, Codable, CaseIterable, Equatable, Sendable {
    case balanced = "BALANCED"
    case correct = "CORRECT"
    case hold = "HOLD"
}

public struct FieldMurmurSetpoints: Codable, Equatable, Sendable {
    public let maxOpenMinutes: Double
    public let maxRequestsPerMinute: Double

    public init(maxOpenMinutes: Double, maxRequestsPerMinute: Double) {
        self.maxOpenMinutes = maxOpenMinutes
        self.maxRequestsPerMinute = maxRequestsPerMinute
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if maxOpenMinutes <= 0 {
            violations.append("murmur max open minutes must be positive")
        }
        if maxRequestsPerMinute <= 0 {
            violations.append("murmur max requests per minute must be positive")
        }
        return violations
    }
}

public struct FieldMurmurToleranceBands: Codable, Equatable, Sendable {
    public let highAttentionOpenMinutes: Double
    public let highAttentionRequestsPerMinute: Double

    public init(highAttentionOpenMinutes: Double, highAttentionRequestsPerMinute: Double) {
        self.highAttentionOpenMinutes = highAttentionOpenMinutes
        self.highAttentionRequestsPerMinute = highAttentionRequestsPerMinute
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if highAttentionOpenMinutes < 0 {
            violations.append("murmur open tolerance cannot be negative")
        }
        if highAttentionRequestsPerMinute < 0 {
            violations.append("murmur request tolerance cannot be negative")
        }
        return violations
    }
}

public enum ReadinessLevel: String, Codable, CaseIterable, Equatable, Sendable {
    case high
    case medium
    case low
    case unknown
}

public enum ReadinessDataQuality: String, Codable, CaseIterable, Equatable, Sendable {
    case valid
    case insufficientSamples
    case stale
    case missing
    case nonpositive
    case unreliable
}

public struct ReadinessMetricSample: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let value: Double
    public let date: Date
    public let isReliable: Bool

    public init(id: String, value: Double, date: Date, isReliable: Bool = true) {
        self.id = id
        self.value = value
        self.date = date
        self.isReliable = isReliable
    }
}

public struct ReadinessCue: Codable, Equatable, Sendable {
    public let level: ReadinessLevel
    public let hrvRatio: Double?
    public let rhrRatio: Double?
    public let hrvSDNNMilliseconds: Double?
    public let restingHeartRateBPM: Double?
    public let baselineHRVMilliseconds: Double?
    public let baselineRestingHeartRateBPM: Double?
    public let evaluatedAt: Date
    public let sourceSampleDate: Date?
    public let sourceSampleIDs: [String]
    public let baselineStartDate: Date?
    public let baselineEndDate: Date?
    public let baselineSampleCount: Int
    public let consecutiveLowEvaluations: Int
    public let quality: ReadinessDataQuality

    public init(
        level: ReadinessLevel,
        hrvRatio: Double?,
        rhrRatio: Double?,
        hrvSDNNMilliseconds: Double?,
        restingHeartRateBPM: Double?,
        baselineHRVMilliseconds: Double?,
        baselineRestingHeartRateBPM: Double?,
        evaluatedAt: Date,
        sourceSampleDate: Date?,
        sourceSampleIDs: [String],
        baselineStartDate: Date?,
        baselineEndDate: Date?,
        baselineSampleCount: Int,
        consecutiveLowEvaluations: Int,
        quality: ReadinessDataQuality
    ) {
        self.level = level
        self.hrvRatio = hrvRatio
        self.rhrRatio = rhrRatio
        self.hrvSDNNMilliseconds = hrvSDNNMilliseconds
        self.restingHeartRateBPM = restingHeartRateBPM
        self.baselineHRVMilliseconds = baselineHRVMilliseconds
        self.baselineRestingHeartRateBPM = baselineRestingHeartRateBPM
        self.evaluatedAt = evaluatedAt
        self.sourceSampleDate = sourceSampleDate
        self.sourceSampleIDs = sourceSampleIDs
        self.baselineStartDate = baselineStartDate
        self.baselineEndDate = baselineEndDate
        self.baselineSampleCount = baselineSampleCount
        self.consecutiveLowEvaluations = consecutiveLowEvaluations
        self.quality = quality
    }
}

public enum ReadinessDerivation {
    public static let minimumBaselineSampleCount = 14
    public static let baselineWindowDays = 30
    public static let maximumHRVAge: TimeInterval = 36 * 60 * 60

    public static func derive(
        hrvSample: ReadinessMetricSample?,
        restingHeartRateSample: ReadinessMetricSample?,
        hrvBaselineSamples: [ReadinessMetricSample],
        restingHeartRateBaselineSamples: [ReadinessMetricSample],
        evaluatedAt: Date,
        previousConsecutiveLowEvaluations: Int = 0,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> ReadinessCue {
        guard let hrvSample, let restingHeartRateSample else {
            return unknown(
                quality: .missing,
                hrvSample: hrvSample,
                restingHeartRateSample: restingHeartRateSample,
                evaluatedAt: evaluatedAt
            )
        }
        guard hrvSample.isReliable, restingHeartRateSample.isReliable else {
            return unknown(
                quality: .unreliable,
                hrvSample: hrvSample,
                restingHeartRateSample: restingHeartRateSample,
                evaluatedAt: evaluatedAt
            )
        }
        guard hrvSample.value > 0, restingHeartRateSample.value > 0 else {
            return unknown(
                quality: .nonpositive,
                hrvSample: hrvSample,
                restingHeartRateSample: restingHeartRateSample,
                evaluatedAt: evaluatedAt
            )
        }

        let startOfEvaluationDay = calendar.startOfDay(for: evaluatedAt)
        guard
            let baselineStart = calendar.date(byAdding: .day, value: -baselineWindowDays, to: startOfEvaluationDay),
            let previousDayStart = calendar.date(byAdding: .day, value: -1, to: startOfEvaluationDay)
        else {
            return unknown(
                quality: .stale,
                hrvSample: hrvSample,
                restingHeartRateSample: restingHeartRateSample,
                evaluatedAt: evaluatedAt
            )
        }

        let hrvIsFresh = hrvSample.date <= evaluatedAt
            && evaluatedAt.timeIntervalSince(hrvSample.date) <= maximumHRVAge
        let restingHeartRateIsFromPreviousCompletedDay =
            restingHeartRateSample.date >= previousDayStart
            && restingHeartRateSample.date < startOfEvaluationDay
        guard hrvIsFresh, restingHeartRateIsFromPreviousCompletedDay else {
            return unknown(
                quality: .stale,
                hrvSample: hrvSample,
                restingHeartRateSample: restingHeartRateSample,
                evaluatedAt: evaluatedAt
            )
        }

        let validHRVBaseline = validBaselineSamples(
            hrvBaselineSamples,
            from: baselineStart,
            before: startOfEvaluationDay
        )
        let validRHRBaseline = validBaselineSamples(
            restingHeartRateBaselineSamples,
            from: baselineStart,
            before: startOfEvaluationDay
        )
        let baselineSampleCount = min(validHRVBaseline.count, validRHRBaseline.count)
        guard
            baselineSampleCount >= minimumBaselineSampleCount,
            let baselineHRV = median(validHRVBaseline.map(\.value)),
            let baselineRHR = median(validRHRBaseline.map(\.value)),
            baselineHRV > 0,
            baselineRHR > 0
        else {
            return unknown(
                quality: .insufficientSamples,
                hrvSample: hrvSample,
                restingHeartRateSample: restingHeartRateSample,
                evaluatedAt: evaluatedAt,
                baselineStartDate: baselineStart,
                baselineEndDate: previousDayStart,
                baselineSampleCount: baselineSampleCount
            )
        }

        let hrvRatio = hrvSample.value / baselineHRV
        let rhrRatio = restingHeartRateSample.value / baselineRHR
        let level: ReadinessLevel
        if hrvRatio < 0.80 || rhrRatio > 1.10 {
            level = .low
        } else if hrvRatio >= 1.10 && rhrRatio <= 1.00 {
            level = .high
        } else {
            level = .medium
        }
        let consecutiveLowEvaluations = level == .low
            ? max(previousConsecutiveLowEvaluations, 0) + 1
            : 0

        return ReadinessCue(
            level: level,
            hrvRatio: hrvRatio,
            rhrRatio: rhrRatio,
            hrvSDNNMilliseconds: hrvSample.value,
            restingHeartRateBPM: restingHeartRateSample.value,
            baselineHRVMilliseconds: baselineHRV,
            baselineRestingHeartRateBPM: baselineRHR,
            evaluatedAt: evaluatedAt,
            sourceSampleDate: min(hrvSample.date, restingHeartRateSample.date),
            sourceSampleIDs: [hrvSample.id, restingHeartRateSample.id],
            baselineStartDate: baselineStart,
            baselineEndDate: previousDayStart,
            baselineSampleCount: baselineSampleCount,
            consecutiveLowEvaluations: consecutiveLowEvaluations,
            quality: .valid
        )
    }

    private static func validBaselineSamples(
        _ samples: [ReadinessMetricSample],
        from startDate: Date,
        before endDate: Date
    ) -> [ReadinessMetricSample] {
        samples.filter {
            $0.isReliable && $0.value > 0 && $0.date >= startDate && $0.date < endDate
        }
    }

    private static func median(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    private static func unknown(
        quality: ReadinessDataQuality,
        hrvSample: ReadinessMetricSample?,
        restingHeartRateSample: ReadinessMetricSample?,
        evaluatedAt: Date,
        baselineStartDate: Date? = nil,
        baselineEndDate: Date? = nil,
        baselineSampleCount: Int = 0
    ) -> ReadinessCue {
        ReadinessCue(
            level: .unknown,
            hrvRatio: nil,
            rhrRatio: nil,
            hrvSDNNMilliseconds: hrvSample?.value,
            restingHeartRateBPM: restingHeartRateSample?.value,
            baselineHRVMilliseconds: nil,
            baselineRestingHeartRateBPM: nil,
            evaluatedAt: evaluatedAt,
            sourceSampleDate: [hrvSample?.date, restingHeartRateSample?.date].compactMap { $0 }.min(),
            sourceSampleIDs: [hrvSample?.id, restingHeartRateSample?.id].compactMap { $0 },
            baselineStartDate: baselineStartDate,
            baselineEndDate: baselineEndDate,
            baselineSampleCount: baselineSampleCount,
            consecutiveLowEvaluations: 0,
            quality: quality
        )
    }
}

public struct FieldMurmurPolicy: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let surfaceID: String
    public let mirroredGeometryPointers: [String]
    public let setpoints: FieldMurmurSetpoints
    public let toleranceBands: FieldMurmurToleranceBands
    public let correctionActions: [FieldMurmurCorrectionAction]
    public let evidencePointer: String
    public let authorityCeiling: String
    public let mayRedefineGeometry: Bool
    public let mayLockOutObserver: Bool
    public let mayIncreaseIrreversibleRisk: Bool

    public init(
        surfaceID: String,
        mirroredGeometryPointers: [String],
        setpoints: FieldMurmurSetpoints,
        toleranceBands: FieldMurmurToleranceBands,
        correctionActions: [FieldMurmurCorrectionAction],
        evidencePointer: String,
        authorityCeiling: String,
        mayRedefineGeometry: Bool = false,
        mayLockOutObserver: Bool = false,
        mayIncreaseIrreversibleRisk: Bool = false
    ) {
        self.id = surfaceID
        self.surfaceID = surfaceID
        self.mirroredGeometryPointers = mirroredGeometryPointers
        self.setpoints = setpoints
        self.toleranceBands = toleranceBands
        self.correctionActions = correctionActions
        self.evidencePointer = evidencePointer
        self.authorityCeiling = authorityCeiling
        self.mayRedefineGeometry = mayRedefineGeometry
        self.mayLockOutObserver = mayLockOutObserver
        self.mayIncreaseIrreversibleRisk = mayIncreaseIrreversibleRisk
    }

    public func adjustedSetpoints(for readiness: ReadinessLevel) -> FieldMurmurSetpoints {
        switch readiness {
        case .high, .unknown:
            return setpoints
        case .medium:
            return FieldMurmurSetpoints(
                maxOpenMinutes: setpoints.maxOpenMinutes * 0.9,
                maxRequestsPerMinute: setpoints.maxRequestsPerMinute
            )
        case .low:
            return FieldMurmurSetpoints(
                maxOpenMinutes: setpoints.maxOpenMinutes * 0.7,
                maxRequestsPerMinute: setpoints.maxRequestsPerMinute * 0.5
            )
        }
    }

    public func invariantViolations(knownSurfaceIDs: Set<String> = []) -> [String] {
        var violations: [String] = []
        if surfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("murmur surface ID is empty")
        }
        if !knownSurfaceIDs.isEmpty && !knownSurfaceIDs.contains(surfaceID) {
            violations.append("murmur policy references unknown surface")
        }
        if mirroredGeometryPointers.isEmpty {
            violations.append("murmur policy has no mirrored geometry pointers")
        }
        if correctionActions.isEmpty {
            violations.append("murmur policy has no correction actions")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("murmur evidence pointer is empty")
        }
        if authorityCeiling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("murmur authority ceiling is empty")
        }
        if mayIncreaseIrreversibleRisk {
            violations.append("murmur policy increases irreversible risk")
        }
        if mayLockOutObserver {
            violations.append("murmur policy locks out observer")
        }
        if mayRedefineGeometry {
            violations.append("murmur policy redefines geometry")
        }
        violations.append(contentsOf: setpoints.invariantViolations())
        violations.append(contentsOf: toleranceBands.invariantViolations())
        return violations
    }
}

public enum FieldReadinessMurmurDecision: String, Codable, Equatable, Sendable {
    case normal
    case dampened
    case held
}

public struct FieldReadinessEvidenceReceipt: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let sourceSurfaceID: String
    public let targetSurfaceID: String
    public let readinessLevel: ReadinessLevel
    public let quality: ReadinessDataQuality
    public let hrvRatio: Double?
    public let rhrRatio: Double?
    public let baselineSampleCount: Int
    public let baselineStartDate: Date?
    public let baselineEndDate: Date?
    public let sourceSampleIDs: [String]
    public let consecutiveLowEvaluations: Int
    public let decision: FieldReadinessMurmurDecision
    public let appliedAction: FieldMurmurCorrectionAction?
    public let evaluatedAt: Date
    public let policyVersion: String
    public let contractVersion: String
    public let interpretation: String

    public init(
        id: String,
        sourceSurfaceID: String,
        targetSurfaceID: String,
        cue: ReadinessCue,
        decision: FieldReadinessMurmurDecision,
        appliedAction: FieldMurmurCorrectionAction?,
        policyVersion: String,
        contractVersion: String
    ) {
        self.id = id
        self.sourceSurfaceID = sourceSurfaceID
        self.targetSurfaceID = targetSurfaceID
        self.readinessLevel = cue.level
        self.quality = cue.quality
        self.hrvRatio = cue.hrvRatio
        self.rhrRatio = cue.rhrRatio
        self.baselineSampleCount = cue.baselineSampleCount
        self.baselineStartDate = cue.baselineStartDate
        self.baselineEndDate = cue.baselineEndDate
        self.sourceSampleIDs = cue.sourceSampleIDs
        self.consecutiveLowEvaluations = cue.consecutiveLowEvaluations
        self.decision = decision
        self.appliedAction = appliedAction
        self.evaluatedAt = cue.evaluatedAt
        self.policyVersion = policyVersion
        self.contractVersion = contractVersion
        self.interpretation = "Interface-capacity evidence only; not a medical diagnosis or identity claim."
    }
}

public struct FieldReadinessMurmurAdmission: Codable, Equatable, Sendable {
    public let decision: FieldReadinessMurmurDecision
    public let blockedLaw: HarmonicKernelLaw?
    public let reason: String
    public let holdReasons: [String]
    public let correctionAction: FieldMurmurCorrectionAction?
    public let adjustedSetpoints: FieldMurmurSetpoints
    public let receipt: FieldReadinessEvidenceReceipt

    public init(
        decision: FieldReadinessMurmurDecision,
        blockedLaw: HarmonicKernelLaw?,
        reason: String,
        holdReasons: [String],
        correctionAction: FieldMurmurCorrectionAction?,
        adjustedSetpoints: FieldMurmurSetpoints,
        receipt: FieldReadinessEvidenceReceipt
    ) {
        self.decision = decision
        self.blockedLaw = blockedLaw
        self.reason = reason
        self.holdReasons = holdReasons
        self.correctionAction = correctionAction
        self.adjustedSetpoints = adjustedSetpoints
        self.receipt = receipt
    }
}

public enum FieldReadinessMurmurPolicy {
    public static let sourceSurfaceID = "apple_watch_biometric"
    public static let targetSurfaceID = "watch_ultra_murmur"
    public static let requiredAuthorityCeiling = "HAPTIC_CUE_ONLY"
    public static let policyVersion = "FIELD.ReadinessMurmurPolicy.V1"
    public static let contractVersion = "FIELD.AppleWatchReadiness.V1"

    public static func evaluate(
        cue: ReadinessCue,
        policy: FieldMurmurPolicy,
        sourceSurface: FieldSurfaceNode,
        targetSurface: FieldSurfaceNode
    ) -> FieldReadinessMurmurAdmission {
        let knownSurfaceIDs = Set([sourceSurface.id, targetSurface.id])
        let policyViolations = policy.invariantViolations(knownSurfaceIDs: knownSurfaceIDs)

        guard sourceSurface.id == sourceSurfaceID,
              sourceSurface.configuration.permissionProfile == "health_biometric_read_only",
              sourceSurface.configuration.authorityCeiling == "READ_ONLY",
              !sourceSurface.configuration.globalFieldAuthority,
              !sourceSurface.utilisation.consentInferred
        else {
            return hold(cue: cue, policy: policy, reason: "HOLD.ReadinessSourceAuthorityMismatch")
        }

        guard targetSurface.id == targetSurfaceID,
              policy.surfaceID == targetSurfaceID,
              targetSurface.configuration.authorityCeiling == requiredAuthorityCeiling,
              targetSurface.outputChannels.contains(.haptic),
              targetSurface.configuration.allowedActions.contains(FieldMurmurCorrectionAction.dampenHaptics.rawValue),
              targetSurface.configuration.allowedActions.contains(FieldMurmurCorrectionAction.hold.rawValue),
              policy.correctionActions.contains(.dampenHaptics),
              policy.correctionActions.contains(.hold),
              policyViolations.isEmpty,
              !targetSurface.configuration.globalFieldAuthority,
              !targetSurface.utilisation.consentInferred
        else {
            return hold(cue: cue, policy: policy, reason: "HOLD.ReadinessTargetAuthorityMismatch")
        }

        guard cue.quality == .valid, cue.level != .unknown else {
            return hold(cue: cue, policy: policy, reason: "HOLD.ReadinessEvidenceUnavailable")
        }

        switch cue.level {
        case .high:
            return admission(
                cue: cue,
                policy: policy,
                decision: .normal,
                reason: "PASS.Readiness.NormalHaptics",
                correctionAction: nil
            )
        case .medium:
            return admission(
                cue: cue,
                policy: policy,
                decision: .dampened,
                reason: "PASS.Readiness.SlightHapticDampening",
                correctionAction: .dampenHaptics
            )
        case .low where cue.consecutiveLowEvaluations >= 2:
            return admission(
                cue: cue,
                policy: policy,
                decision: .dampened,
                reason: "PASS.Readiness.PersistentLowDampenHaptics",
                correctionAction: .dampenHaptics
            )
        case .low:
            return admission(
                cue: cue,
                policy: policy,
                decision: .normal,
                reason: "PASS.Readiness.LowObservedAwaitingConfirmation",
                correctionAction: nil
            )
        case .unknown:
            return hold(cue: cue, policy: policy, reason: "HOLD.ReadinessEvidenceUnavailable")
        }
    }

    private static func admission(
        cue: ReadinessCue,
        policy: FieldMurmurPolicy,
        decision: FieldReadinessMurmurDecision,
        reason: String,
        correctionAction: FieldMurmurCorrectionAction?
    ) -> FieldReadinessMurmurAdmission {
        makeAdmission(
            cue: cue,
            policy: policy,
            decision: decision,
            blockedLaw: nil,
            reason: reason,
            holdReasons: [],
            correctionAction: correctionAction,
            adjustedSetpoints: policy.adjustedSetpoints(for: cue.level)
        )
    }

    private static func hold(
        cue: ReadinessCue,
        policy: FieldMurmurPolicy,
        reason: String
    ) -> FieldReadinessMurmurAdmission {
        makeAdmission(
            cue: cue,
            policy: policy,
            decision: .held,
            blockedLaw: .conservation,
            reason: reason,
            holdReasons: [reason],
            correctionAction: .hold,
            adjustedSetpoints: policy.setpoints
        )
    }

    private static func makeAdmission(
        cue: ReadinessCue,
        policy: FieldMurmurPolicy,
        decision: FieldReadinessMurmurDecision,
        blockedLaw: HarmonicKernelLaw?,
        reason: String,
        holdReasons: [String],
        correctionAction: FieldMurmurCorrectionAction?,
        adjustedSetpoints: FieldMurmurSetpoints
    ) -> FieldReadinessMurmurAdmission {
        let receipt = FieldReadinessEvidenceReceipt(
            id: "readiness_\(Int(cue.evaluatedAt.timeIntervalSince1970))_\(targetSurfaceID)",
            sourceSurfaceID: sourceSurfaceID,
            targetSurfaceID: targetSurfaceID,
            cue: cue,
            decision: decision,
            appliedAction: correctionAction,
            policyVersion: policyVersion,
            contractVersion: contractVersion
        )
        return FieldReadinessMurmurAdmission(
            decision: decision,
            blockedLaw: blockedLaw,
            reason: reason,
            holdReasons: holdReasons,
            correctionAction: correctionAction,
            adjustedSetpoints: adjustedSetpoints,
            receipt: receipt
        )
    }
}

public enum NonVerbalFeedbackKind: String, Codable, Equatable, Sendable {
    case readinessCapacity
}

public enum FeedbackConfidence: String, Codable, Equatable, Sendable {
    case sufficient
    case limited
    case unavailable
}

public enum DojoFeedbackOperationMode: String, Codable, Equatable, Sendable {
    case observeOnly
    case shadow
    case live
}

public enum ObserverCapacityReflection: String, Codable, Equatable, Sendable {
    case aligned
    case notAligned
    case noReflection
}

public struct DojoNonVerbalFeedbackSignal: Codable, Equatable, Sendable, Identifiable {
    public static let permittedReadinessInterpretation =
        "Temporary interface-capacity context for nonessential murmur modulation."
    public static let prohibitedReadinessInterpretations = [
        "medical diagnosis",
        "health condition inference",
        "observer identity classification",
        "authority escalation",
        "decision validity judgment",
        "PULSE coherence state",
        "SOMA phase determination"
    ]

    public let id: String
    public let sourceSystem: String
    public let receivingSystem: String
    public let targetMurmurID: String
    public let kind: NonVerbalFeedbackKind
    public let observedAt: Date
    public let receivedAt: Date
    public let readinessLevel: ReadinessLevel
    public let dataQuality: ReadinessDataQuality
    public let confidence: FeedbackConfidence
    public let permittedInterpretation: String
    public let prohibitedInterpretations: [String]
    public let sourceEvidenceRefs: [String]
    public let expiryAt: Date

    public init(
        id: String,
        sourceSystem: String,
        receivingSystem: String,
        targetMurmurID: String,
        kind: NonVerbalFeedbackKind,
        observedAt: Date,
        receivedAt: Date,
        readinessLevel: ReadinessLevel,
        dataQuality: ReadinessDataQuality,
        confidence: FeedbackConfidence,
        permittedInterpretation: String,
        prohibitedInterpretations: [String],
        sourceEvidenceRefs: [String],
        expiryAt: Date
    ) {
        self.id = id
        self.sourceSystem = sourceSystem
        self.receivingSystem = receivingSystem
        self.targetMurmurID = targetMurmurID
        self.kind = kind
        self.observedAt = observedAt
        self.receivedAt = receivedAt
        self.readinessLevel = readinessLevel
        self.dataQuality = dataQuality
        self.confidence = confidence
        self.permittedInterpretation = permittedInterpretation
        self.prohibitedInterpretations = prohibitedInterpretations
        self.sourceEvidenceRefs = sourceEvidenceRefs
        self.expiryAt = expiryAt
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if sourceSystem != FieldReadinessMurmurPolicy.sourceSurfaceID {
            violations.append("feedback source must be the read-only Apple Watch biometric surface")
        }
        if receivingSystem != "DOJO" {
            violations.append("feedback receiver must be DOJO")
        }
        if targetMurmurID != FieldReadinessMurmurPolicy.targetSurfaceID {
            violations.append("feedback target must be the Watch Ultra murmur")
        }
        if kind != .readinessCapacity {
            violations.append("feedback kind is outside the readiness contract")
        }
        if permittedInterpretation != Self.permittedReadinessInterpretation {
            violations.append("feedback permitted interpretation was changed")
        }
        if Set(prohibitedInterpretations) != Set(Self.prohibitedReadinessInterpretations) {
            violations.append("feedback prohibited interpretations were changed")
        }
        if expiryAt <= receivedAt {
            violations.append("feedback signal must expire after receipt")
        }
        return violations
    }
}

public struct MurmurUtilisationSnapshot: Codable, Equatable, Sendable {
    public let capturedAt: Date
    public let openMinutes: Double
    public let requestsPerMinute: Double
    public let setpoints: FieldMurmurSetpoints

    public init(
        capturedAt: Date,
        openMinutes: Double,
        requestsPerMinute: Double,
        setpoints: FieldMurmurSetpoints
    ) {
        self.capturedAt = capturedAt
        self.openMinutes = max(openMinutes, 0)
        self.requestsPerMinute = max(requestsPerMinute, 0)
        self.setpoints = setpoints
    }
}

public enum FeedbackOutcome: String, Codable, Equatable, Sendable {
    case noAdjustmentRequired
    case observedOnly
    case temporaryDampeningApplied
    case heldForInsufficientEvidence
    case correctionReverted
    case observerOverrode
    case incomplete
}

public enum DojoFeedbackOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noAdjustmentRequired
    case adjustmentApplied
    case adjustmentExpiredNormally
    case adjustmentReverted
    case observerConfirmedUseful
    case observerReportedTooQuiet
    case observerReportedTooActive
    case observerOverrode
    case essentialCueProtected
    case policyHeldForUnknownInput
    case policyRejectedByAuthority
    case observationIncomplete
}

public enum ObserverMurmurFeedback: String, Codable, Equatable, Sendable {
    case useful
    case tooQuiet
    case tooActive
    case resumeNormalCues
    case keepQuiet
    case noResponse
}

public struct DojoObservedOutcome: Codable, Equatable, Sendable, Identifiable {
    public static let interpretationLimit =
        "Interface-policy outcome only; no medical, identity, intent, consent, or causal inference."

    public let id: String
    public let feedbackSignalID: String
    public let receiptID: String
    public let targetMurmurID: String
    public let observationStartedAt: Date
    public let observationEndedAt: Date
    public let signalExpiresAt: Date
    public let policyVersion: String
    public let primaryOutcome: DojoFeedbackOutcome
    public let supportingOutcomes: Set<DojoFeedbackOutcome>
    public let nonessentialHapticsSuppressed: Int
    public let essentialHapticsDelivered: Int
    public let essentialHapticsLost: Int
    public let blockedEscalationCount: Int
    public let authorityBoundaryEncountered: Bool
    public let permissionBoundaryEncountered: Bool
    public let observerResponse: ObserverMurmurFeedback?
    public let revertedAt: Date?
    public let notes: String?
    public let interpretationBoundary: String

    public init(
        id: String,
        feedbackSignalID: String,
        receiptID: String,
        targetMurmurID: String,
        observationStartedAt: Date,
        observationEndedAt: Date,
        signalExpiresAt: Date,
        policyVersion: String,
        primaryOutcome: DojoFeedbackOutcome,
        supportingOutcomes: Set<DojoFeedbackOutcome> = [],
        nonessentialHapticsSuppressed: Int = 0,
        essentialHapticsDelivered: Int = 0,
        essentialHapticsLost: Int = 0,
        blockedEscalationCount: Int = 0,
        authorityBoundaryEncountered: Bool = false,
        permissionBoundaryEncountered: Bool = false,
        observerResponse: ObserverMurmurFeedback? = nil,
        revertedAt: Date? = nil,
        notes: String? = nil,
        interpretationBoundary: String = DojoObservedOutcome.interpretationLimit
    ) {
        self.id = id
        self.feedbackSignalID = feedbackSignalID
        self.receiptID = receiptID
        self.targetMurmurID = targetMurmurID
        self.observationStartedAt = observationStartedAt
        self.observationEndedAt = observationEndedAt
        self.signalExpiresAt = signalExpiresAt
        self.policyVersion = policyVersion
        self.primaryOutcome = primaryOutcome
        self.supportingOutcomes = supportingOutcomes
        self.nonessentialHapticsSuppressed = nonessentialHapticsSuppressed
        self.essentialHapticsDelivered = essentialHapticsDelivered
        self.essentialHapticsLost = essentialHapticsLost
        self.blockedEscalationCount = blockedEscalationCount
        self.authorityBoundaryEncountered = authorityBoundaryEncountered
        self.permissionBoundaryEncountered = permissionBoundaryEncountered
        self.observerResponse = observerResponse
        self.revertedAt = revertedAt
        self.notes = notes
        self.interpretationBoundary = interpretationBoundary
    }

    public static func record(
        observation: DojoMurmurFeedbackObservation,
        endedAt: Date,
        primaryOutcome: DojoFeedbackOutcome,
        supportingOutcomes: Set<DojoFeedbackOutcome> = [],
        nonessentialHapticsSuppressed: Int = 0,
        essentialHapticsDelivered: Int = 0,
        essentialHapticsLost: Int = 0,
        blockedEscalationCount: Int = 0,
        authorityBoundaryEncountered: Bool = false,
        permissionBoundaryEncountered: Bool = false,
        observerResponse: ObserverMurmurFeedback? = nil,
        revertedAt: Date? = nil,
        notes: String? = nil
    ) -> DojoObservedOutcome {
        DojoObservedOutcome(
            id: "outcome_\(observation.id)_\(Int(endedAt.timeIntervalSince1970))",
            feedbackSignalID: observation.feedbackSignal.id,
            receiptID: observation.evidenceReceipt.id,
            targetMurmurID: observation.feedbackSignal.targetMurmurID,
            observationStartedAt: observation.feedbackSignal.receivedAt,
            observationEndedAt: endedAt,
            signalExpiresAt: observation.feedbackSignal.expiryAt,
            policyVersion: observation.policyVersion,
            primaryOutcome: primaryOutcome,
            supportingOutcomes: supportingOutcomes,
            nonessentialHapticsSuppressed: nonessentialHapticsSuppressed,
            essentialHapticsDelivered: essentialHapticsDelivered,
            essentialHapticsLost: essentialHapticsLost,
            blockedEscalationCount: blockedEscalationCount,
            authorityBoundaryEncountered: authorityBoundaryEncountered,
            permissionBoundaryEncountered: permissionBoundaryEncountered,
            observerResponse: observerResponse,
            revertedAt: revertedAt,
            notes: notes
        )
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observed outcome ID is empty")
        }
        if feedbackSignalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observed outcome signal attribution is empty")
        }
        if receiptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observed outcome receipt attribution is empty")
        }
        if targetMurmurID != FieldReadinessMurmurPolicy.targetSurfaceID {
            violations.append("observed outcome target is outside the Watch readiness contract")
        }
        if observationEndedAt < observationStartedAt {
            violations.append("observed outcome ends before its observation window starts")
        }
        if let revertedAt, revertedAt < observationStartedAt || revertedAt > observationEndedAt {
            violations.append("observed outcome reversion is outside its observation window")
        }
        if nonessentialHapticsSuppressed < 0
            || essentialHapticsDelivered < 0
            || essentialHapticsLost < 0
            || blockedEscalationCount < 0 {
            violations.append("observed outcome counters cannot be negative")
        }
        if interpretationBoundary != Self.interpretationLimit {
            violations.append("observed outcome interpretation boundary was changed")
        }
        if supportingOutcomes.contains(.essentialCueProtected) && essentialHapticsLost > 0 {
            violations.append("essential-cue protection cannot be claimed when a cue was lost")
        }
        return violations
    }
}

public struct DojoMurmurFeedbackObservation: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let feedbackSignal: DojoNonVerbalFeedbackSignal
    public let policyVersion: String
    public let operationMode: DojoFeedbackOperationMode
    public let readinessLevel: ReadinessLevel
    public let proposedAction: FieldMurmurCorrectionAction?
    public let appliedAction: FieldMurmurCorrectionAction?
    public let wasPersistentDampening: Bool
    public let preAdjustmentState: MurmurUtilisationSnapshot
    public let postAdjustmentState: MurmurUtilisationSnapshot
    public let observerReflection: ObserverCapacityReflection
    public let correctionReversedAt: Date?
    public let outcome: FeedbackOutcome
    public let holdReasons: [String]
    public let evidenceReceipt: FieldReadinessEvidenceReceipt

    public init(
        id: String,
        feedbackSignal: DojoNonVerbalFeedbackSignal,
        policyVersion: String,
        operationMode: DojoFeedbackOperationMode,
        readinessLevel: ReadinessLevel,
        proposedAction: FieldMurmurCorrectionAction?,
        appliedAction: FieldMurmurCorrectionAction?,
        wasPersistentDampening: Bool,
        preAdjustmentState: MurmurUtilisationSnapshot,
        postAdjustmentState: MurmurUtilisationSnapshot,
        observerReflection: ObserverCapacityReflection,
        correctionReversedAt: Date?,
        outcome: FeedbackOutcome,
        holdReasons: [String],
        evidenceReceipt: FieldReadinessEvidenceReceipt
    ) {
        self.id = id
        self.feedbackSignal = feedbackSignal
        self.policyVersion = policyVersion
        self.operationMode = operationMode
        self.readinessLevel = readinessLevel
        self.proposedAction = proposedAction
        self.appliedAction = appliedAction
        self.wasPersistentDampening = wasPersistentDampening
        self.preAdjustmentState = preAdjustmentState
        self.postAdjustmentState = postAdjustmentState
        self.observerReflection = observerReflection
        self.correctionReversedAt = correctionReversedAt
        self.outcome = outcome
        self.holdReasons = holdReasons
        self.evidenceReceipt = evidenceReceipt
    }
}

public enum DojoNonVerbalFeedbackChannel {
    public static let signalLifetime: TimeInterval = 6 * 60 * 60

    public static func receive(
        readinessCue: ReadinessCue,
        receivedAt: Date,
        preAdjustmentState: MurmurUtilisationSnapshot,
        policy: FieldMurmurPolicy,
        sourceSurface: FieldSurfaceNode,
        targetSurface: FieldSurfaceNode,
        operationMode: DojoFeedbackOperationMode = .observeOnly,
        observerReflection: ObserverCapacityReflection = .noReflection
    ) -> DojoMurmurFeedbackObservation {
        let admission = FieldReadinessMurmurPolicy.evaluate(
            cue: readinessCue,
            policy: policy,
            sourceSurface: sourceSurface,
            targetSurface: targetSurface
        )
        let confidence = confidence(for: readinessCue)
        let signal = DojoNonVerbalFeedbackSignal(
            id: "nonverbal_\(Int(receivedAt.timeIntervalSince1970))_\(FieldReadinessMurmurPolicy.targetSurfaceID)",
            sourceSystem: FieldReadinessMurmurPolicy.sourceSurfaceID,
            receivingSystem: "DOJO",
            targetMurmurID: FieldReadinessMurmurPolicy.targetSurfaceID,
            kind: .readinessCapacity,
            observedAt: readinessCue.evaluatedAt,
            receivedAt: receivedAt,
            readinessLevel: readinessCue.level,
            dataQuality: readinessCue.quality,
            confidence: confidence,
            permittedInterpretation: DojoNonVerbalFeedbackSignal.permittedReadinessInterpretation,
            prohibitedInterpretations: DojoNonVerbalFeedbackSignal.prohibitedReadinessInterpretations,
            sourceEvidenceRefs: readinessCue.sourceSampleIDs,
            expiryAt: readinessCue.evaluatedAt.addingTimeInterval(signalLifetime)
        )

        let modeIsPromoted = operationMode == .observeOnly
        let evidenceIsCurrent = receivedAt >= readinessCue.evaluatedAt
            && receivedAt < signal.expiryAt
        let signalViolations = signal.invariantViolations()
        let channelHoldReasons: [String]
        if !modeIsPromoted {
            channelHoldReasons = ["HOLD.FeedbackModeNotPromoted"]
        } else if !evidenceIsCurrent {
            channelHoldReasons = ["HOLD.FeedbackSignalExpired"]
        } else {
            channelHoldReasons = signalViolations
        }

        let outcome: FeedbackOutcome
        if !channelHoldReasons.isEmpty || admission.decision == .held {
            outcome = .heldForInsufficientEvidence
        } else if admission.correctionAction == nil {
            outcome = .noAdjustmentRequired
        } else {
            outcome = .observedOnly
        }

        // Observe-only is the sole promoted mode in this slice. No action reaches hardware.
        let postAdjustmentState = MurmurUtilisationSnapshot(
            capturedAt: receivedAt,
            openMinutes: preAdjustmentState.openMinutes,
            requestsPerMinute: preAdjustmentState.requestsPerMinute,
            setpoints: preAdjustmentState.setpoints
        )
        let combinedHoldReasons = channelHoldReasons + admission.holdReasons

        return DojoMurmurFeedbackObservation(
            id: "observation_\(Int(receivedAt.timeIntervalSince1970))_\(FieldReadinessMurmurPolicy.targetSurfaceID)",
            feedbackSignal: signal,
            policyVersion: FieldReadinessMurmurPolicy.policyVersion,
            operationMode: operationMode,
            readinessLevel: readinessCue.level,
            proposedAction: admission.correctionAction,
            appliedAction: nil,
            wasPersistentDampening: false,
            preAdjustmentState: preAdjustmentState,
            postAdjustmentState: postAdjustmentState,
            observerReflection: observerReflection,
            correctionReversedAt: nil,
            outcome: outcome,
            holdReasons: combinedHoldReasons,
            evidenceReceipt: admission.receipt
        )
    }

    private static func confidence(for cue: ReadinessCue) -> FeedbackConfidence {
        guard cue.quality == .valid else {
            return cue.quality == .missing ? .unavailable : .limited
        }
        return .sufficient
    }
}

public struct FieldMurmurRuntimeMetrics: Codable, Equatable, Sendable {
    public let openMinutes: Double
    public let requestsPerMinute: Double

    public init(openMinutes: Double, requestsPerMinute: Double) {
        self.openMinutes = max(openMinutes, 0)
        self.requestsPerMinute = max(requestsPerMinute, 0)
    }
}

public struct FieldMurmurHomeostasisAdmission: Codable, Equatable, Sendable {
    public let decision: FieldMurmurHomeostasisDecision
    public let blockedLaw: HarmonicKernelLaw?
    public let reason: String
    public let holdReasons: [String]
    public let correctionAction: FieldMurmurCorrectionAction?

    public init(
        decision: FieldMurmurHomeostasisDecision,
        blockedLaw: HarmonicKernelLaw?,
        reason: String,
        holdReasons: [String],
        correctionAction: FieldMurmurCorrectionAction?
    ) {
        self.decision = decision
        self.blockedLaw = blockedLaw
        self.reason = reason
        self.holdReasons = holdReasons
        self.correctionAction = correctionAction
    }
}

public enum FieldMurmurHomeostasisPolicy {
    public static func evaluate(
        policy: FieldMurmurPolicy?,
        metrics: FieldMurmurRuntimeMetrics,
        observerContext: FieldObserverContext?,
        surfaceNode: FieldSurfaceNode?,
        knownSurfaceIDs: Set<String> = []
    ) -> FieldMurmurHomeostasisAdmission {
        guard let policy else {
            return result(.hold, .conservation, "Murmur homeostasis policy is required.", ["HOLD.MurmurPolicyUnavailable"])
        }
        let policyViolations = policy.invariantViolations(knownSurfaceIDs: knownSurfaceIDs)
        guard policyViolations.isEmpty else {
            return result(.hold, .conservation, "Murmur policy violates the homeostasis contract.", policyViolations)
        }
        guard let observerContext else {
            return result(.hold, .conservation, "Observer context is required for murmur homeostasis.", ["HOLD.ObserverContextUnavailable"])
        }
        guard let surfaceNode, surfaceNode.id == policy.surfaceID else {
            return result(.hold, .symmetry, "Murmur policy must match the evaluated surface node.", ["HOLD.MurmurSurfaceMismatch"])
        }
        guard !surfaceNode.configuration.globalFieldAuthority, !surfaceNode.utilisation.consentInferred else {
            return result(.hold, .symmetry, "Murmur surface cannot claim global authority or infer consent.", ["HOLD.MurmurSurfaceAuthorityOverreach"])
        }

        let tolerance = tolerance(for: observerContext, policy: policy)
        let openLimit = policy.setpoints.maxOpenMinutes + tolerance.openMinutes
        let requestLimit = policy.setpoints.maxRequestsPerMinute + tolerance.requestsPerMinute
        let openDrift = metrics.openMinutes - openLimit
        let requestDrift = metrics.requestsPerMinute - requestLimit

        guard openDrift > 0 || requestDrift > 0 else {
            return result(.balanced, nil, "PASS.MurmurHomeostasis.Balanced", [])
        }

        if observerContext.activity.safetyCritical || observerContext.attention.level == .low || observerContext.attention.level == .unavailable {
            return correction(.resonance, "PASS.MurmurHomeostasis.Hold", policy: policy, preferred: .hold)
        }
        if openDrift >= 5 {
            return correction(.resonance, "PASS.MurmurHomeostasis.AutoCollapse", policy: policy, preferred: .autoCollapse)
        }
        if requestDrift > 0 {
            return correction(.resonance, "PASS.MurmurHomeostasis.PauseCue", policy: policy, preferred: .showPauseCue)
        }
        return correction(.resonance, "PASS.MurmurHomeostasis.FadeOpacity", policy: policy, preferred: .fadeOpacity)
    }

    private static func tolerance(
        for observerContext: FieldObserverContext,
        policy: FieldMurmurPolicy
    ) -> (openMinutes: Double, requestsPerMinute: Double) {
        guard observerContext.attention.level == .high, !observerContext.activity.safetyCritical else {
            return (0, 0)
        }
        return (
            policy.toleranceBands.highAttentionOpenMinutes,
            policy.toleranceBands.highAttentionRequestsPerMinute
        )
    }

    private static func correction(
        _ law: HarmonicKernelLaw,
        _ reason: String,
        policy: FieldMurmurPolicy,
        preferred: FieldMurmurCorrectionAction
    ) -> FieldMurmurHomeostasisAdmission {
        guard policy.correctionActions.contains(preferred) else {
            return result(.hold, law, "Murmur policy lacks the minimum-intensity correction.", ["HOLD.MurmurCorrectionUnavailable"])
        }
        return result(.correct, nil, reason, [], preferred)
    }

    private static func result(
        _ decision: FieldMurmurHomeostasisDecision,
        _ blockedLaw: HarmonicKernelLaw?,
        _ reason: String,
        _ holdReasons: [String],
        _ correctionAction: FieldMurmurCorrectionAction? = nil
    ) -> FieldMurmurHomeostasisAdmission {
        FieldMurmurHomeostasisAdmission(
            decision: decision,
            blockedLaw: blockedLaw,
            reason: reason,
            holdReasons: holdReasons,
            correctionAction: correctionAction
        )
    }
}

public enum FieldMurmurationMode: String, Codable, CaseIterable, Equatable, Sendable {
    case working = "WORKING"
    case quiet = "QUIET"
    case travel = "TRAVEL"
    case driving = "DRIVING"
    case unknown = "UNKNOWN"
}

public struct FieldMurmurationCue: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let mode: FieldMurmurationMode
    public let sourceSurfaceID: String
    public let receivingSurfaceIDs: [String]
    public let fieldAttentionBudget: Double
    public let evidencePointer: String

    public init(
        id: String,
        mode: FieldMurmurationMode,
        sourceSurfaceID: String,
        receivingSurfaceIDs: [String],
        fieldAttentionBudget: Double,
        evidencePointer: String
    ) {
        self.id = id
        self.mode = mode
        self.sourceSurfaceID = sourceSurfaceID
        self.receivingSurfaceIDs = receivingSurfaceIDs
        self.fieldAttentionBudget = min(max(fieldAttentionBudget, 0), 1)
        self.evidencePointer = evidencePointer
    }

    public func invariantViolations(knownSurfaceIDs: Set<String> = []) -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("murmuration cue ID is empty")
        }
        if sourceSurfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("murmuration cue source surface is empty")
        }
        if receivingSurfaceIDs.isEmpty {
            violations.append("murmuration cue has no receiving surfaces")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("murmuration cue evidence pointer is empty")
        }
        if !knownSurfaceIDs.isEmpty {
            let referenced = Set([sourceSurfaceID] + receivingSurfaceIDs)
            if !referenced.isSubset(of: knownSurfaceIDs) {
                violations.append("murmuration cue references unknown surface")
            }
        }
        return violations
    }
}

public struct FieldMurmurationAdmission: Codable, Equatable, Sendable {
    public let decision: FieldMurmurHomeostasisDecision
    public let blockedLaw: HarmonicKernelLaw?
    public let reason: String
    public let holdReasons: [String]
    public let correctionActionsBySurfaceID: [String: FieldMurmurCorrectionAction]

    public init(
        decision: FieldMurmurHomeostasisDecision,
        blockedLaw: HarmonicKernelLaw?,
        reason: String,
        holdReasons: [String],
        correctionActionsBySurfaceID: [String: FieldMurmurCorrectionAction]
    ) {
        self.decision = decision
        self.blockedLaw = blockedLaw
        self.reason = reason
        self.holdReasons = holdReasons
        self.correctionActionsBySurfaceID = correctionActionsBySurfaceID
    }
}

public enum FieldMurmurationPolicy {
    public static func evaluateQuietModeDampening(
        cue: FieldMurmurationCue?,
        sourceAdmission: FieldMurmurHomeostasisAdmission?,
        policies: [FieldMurmurPolicy],
        knownSurfaceIDs: Set<String> = []
    ) -> FieldMurmurationAdmission {
        guard let cue else {
            return admission(.hold, .conservation, "Murmuration cue is required.", ["HOLD.MurmurationCueUnavailable"])
        }
        let cueViolations = cue.invariantViolations(knownSurfaceIDs: knownSurfaceIDs)
        guard cueViolations.isEmpty else {
            return admission(.hold, .conservation, "Murmuration cue violates the coherence contract.", cueViolations)
        }
        guard cue.mode == .quiet else {
            return admission(.balanced, nil, "PASS.Murmuration.NoQuietDampeningNeeded", [])
        }
        guard cue.fieldAttentionBudget <= 0.35 else {
            return admission(.balanced, nil, "PASS.Murmuration.AttentionBudgetAvailable", [])
        }
        guard let sourceAdmission else {
            return admission(.hold, .conservation, "Source murmur admission is required.", ["HOLD.SourceMurmurAdmissionUnavailable"])
        }
        guard sourceAdmission.correctionAction == .hold else {
            return admission(.balanced, nil, "PASS.Murmuration.SourceNotHolding", [])
        }

        var actions: [String: FieldMurmurCorrectionAction] = [cue.sourceSurfaceID: .hold]
        for surfaceID in cue.receivingSurfaceIDs {
            guard let policy = policies.first(where: { $0.surfaceID == surfaceID }) else {
                return admission(.hold, .symmetry, "Every receiving murmur needs a policy.", ["HOLD.ReceivingMurmurPolicyUnavailable"])
            }
            let action: FieldMurmurCorrectionAction = policy.correctionActions.contains(.dampenHaptics) ? .dampenHaptics : .hold
            actions[surfaceID] = action
        }
        return admission(.correct, nil, "PASS.Murmuration.QuietModeDampening", [], actions)
    }

    public static func evaluateTravelModeContinuity(
        cue: FieldMurmurationCue?,
        sourceAdmission: FieldMurmurHomeostasisAdmission?,
        policies: [FieldMurmurPolicy],
        knownSurfaceIDs: Set<String> = []
    ) -> FieldMurmurationAdmission {
        guard let cue else {
            return admission(.hold, .conservation, "Murmuration cue is required.", ["HOLD.MurmurationCueUnavailable"])
        }
        let cueViolations = cue.invariantViolations(knownSurfaceIDs: knownSurfaceIDs)
        guard cueViolations.isEmpty else {
            return admission(.hold, .conservation, "Murmuration cue violates the coherence contract.", cueViolations)
        }
        guard cue.mode == .travel else {
            return admission(.balanced, nil, "PASS.Murmuration.NoTravelContinuityNeeded", [])
        }
        guard cue.fieldAttentionBudget <= 0.6 else {
            return admission(.balanced, nil, "PASS.Murmuration.AttentionBudgetAvailable", [])
        }
        guard let sourceAdmission else {
            return admission(.hold, .conservation, "Source murmur admission is required.", ["HOLD.SourceMurmurAdmissionUnavailable"])
        }
        guard sourceAdmission.correctionAction == .hold else {
            return admission(.balanced, nil, "PASS.Murmuration.SourceNotHolding", [])
        }

        var actions: [String: FieldMurmurCorrectionAction] = [cue.sourceSurfaceID: .hold]
        for surfaceID in cue.receivingSurfaceIDs {
            guard let policy = policies.first(where: { $0.surfaceID == surfaceID }) else {
                return admission(.hold, .symmetry, "Every receiving murmur needs a policy.", ["HOLD.ReceivingMurmurPolicyUnavailable"])
            }
            if policy.correctionActions.contains(.stageContinuation) {
                actions[surfaceID] = .stageContinuation
            } else if policy.correctionActions.contains(.dampenHaptics) {
                actions[surfaceID] = .dampenHaptics
            } else {
                actions[surfaceID] = .hold
            }
        }
        return admission(.correct, nil, "PASS.Murmuration.TravelModeContinuity", [], actions)
    }

    private static func admission(
        _ decision: FieldMurmurHomeostasisDecision,
        _ blockedLaw: HarmonicKernelLaw?,
        _ reason: String,
        _ holdReasons: [String],
        _ actions: [String: FieldMurmurCorrectionAction] = [:]
    ) -> FieldMurmurationAdmission {
        FieldMurmurationAdmission(
            decision: decision,
            blockedLaw: blockedLaw,
            reason: reason,
            holdReasons: holdReasons,
            correctionActionsBySurfaceID: actions
        )
    }
}

public enum FieldPulseSurfaceState: String, Codable, CaseIterable, Equatable, Sendable {
    case quiet = "QUIET"
    case emitting = "EMITTING"
    case holding = "HOLDING"
    case exited = "EXITED"
    case unknown = "UNKNOWN"
}

public enum FieldPulseReceiptOutcome: String, Codable, CaseIterable, Equatable, Sendable {
    case emitted = "EMITTED"
    case held = "HELD"
    case exited = "EXITED"
    case acknowledged = "ACKNOWLEDGED"
}

public struct FieldPulseCoherenceMetric: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let value: Double
    public let evidencePointer: String

    public init(id: String, label: String, value: Double, evidencePointer: String) {
        self.id = id
        self.label = label
        self.value = value
        self.evidencePointer = evidencePointer
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse metric ID is empty")
        }
        if !(0.0...1.0).contains(value) {
            violations.append("pulse metric value is outside 0...1")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse metric evidence pointer is empty")
        }
        return violations
    }
}

public struct FieldPulseStateSnapshot: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let pulseRuntimeID: String
    public let genotypeID: String
    public let observedAt: String
    public let activePulseIDs: [String]
    public let surfaceStates: [String: FieldPulseSurfaceState]
    public let coherenceMetrics: [FieldPulseCoherenceMetric]
    public let kernelOrder: [HarmonicKernelLaw]
    public let ownsFieldOntology: Bool
    public let redefinesDojoReceipts: Bool

    public init(
        id: String,
        pulseRuntimeID: String,
        genotypeID: String = FieldPulseTreatyAdapter.genotypeID,
        observedAt: String,
        activePulseIDs: [String],
        surfaceStates: [String: FieldPulseSurfaceState],
        coherenceMetrics: [FieldPulseCoherenceMetric],
        kernelOrder: [HarmonicKernelLaw] = FieldPulseTreatyAdapter.kernelOrder,
        ownsFieldOntology: Bool = false,
        redefinesDojoReceipts: Bool = false
    ) {
        self.id = id
        self.pulseRuntimeID = pulseRuntimeID
        self.genotypeID = genotypeID
        self.observedAt = observedAt
        self.activePulseIDs = activePulseIDs
        self.surfaceStates = surfaceStates
        self.coherenceMetrics = coherenceMetrics
        self.kernelOrder = kernelOrder
        self.ownsFieldOntology = ownsFieldOntology
        self.redefinesDojoReceipts = redefinesDojoReceipts
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse snapshot ID is empty")
        }
        if pulseRuntimeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse runtime ID is empty")
        }
        if genotypeID != FieldPulseTreatyAdapter.genotypeID {
            violations.append("pulse genotype drift")
        }
        if observedAt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse observed time is empty")
        }
        if kernelOrder != FieldPulseTreatyAdapter.kernelOrder {
            violations.append("pulse kernel order drift")
        }
        if ownsFieldOntology {
            violations.append("pulse snapshot claims FIELD ontology ownership")
        }
        if redefinesDojoReceipts {
            violations.append("pulse snapshot redefines DOJO receipts")
        }
        if coherenceMetrics.flatMap({ $0.invariantViolations() }).isEmpty == false {
            violations.append("pulse metric invariant violation")
        }
        return violations
    }
}

public struct FieldPulseIntentDeclaration: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let sourceSurfaceID: String
    public let targetSurfaceID: String
    public let objectID: String
    public let intentType: String
    public let requestedLane: FieldSignalLane
    public let permissionProfile: String
    public let evidencePointer: String
    public let mayExecuteExternalAction: Bool
    public let mayMutateFieldOntology: Bool

    public init(
        id: String,
        sourceSurfaceID: String,
        targetSurfaceID: String,
        objectID: String,
        intentType: String,
        requestedLane: FieldSignalLane,
        permissionProfile: String,
        evidencePointer: String,
        mayExecuteExternalAction: Bool = false,
        mayMutateFieldOntology: Bool = false
    ) {
        self.id = id
        self.sourceSurfaceID = sourceSurfaceID
        self.targetSurfaceID = targetSurfaceID
        self.objectID = objectID
        self.intentType = intentType
        self.requestedLane = requestedLane
        self.permissionProfile = permissionProfile
        self.evidencePointer = evidencePointer
        self.mayExecuteExternalAction = mayExecuteExternalAction
        self.mayMutateFieldOntology = mayMutateFieldOntology
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse intent ID is empty")
        }
        if sourceSurfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse intent source surface is empty")
        }
        if targetSurfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse intent target surface is empty")
        }
        if objectID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse intent object ID is empty")
        }
        if permissionProfile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse intent permission profile is empty")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse intent evidence pointer is empty")
        }
        if mayExecuteExternalAction {
            violations.append("pulse intent executes external action")
        }
        if mayMutateFieldOntology {
            violations.append("pulse intent mutates FIELD ontology")
        }
        return violations
    }
}

public struct FieldPulseHoldExitNotice: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let intentID: String
    public let blockedLaw: HarmonicKernelLaw
    public let holdReason: String
    public let exitRequired: Bool
    public let sourceSurfaceID: String
    public let targetSurfaceID: String
    public let evidencePointer: String
    public let claimsPulseExecution: Bool

    public init(
        id: String,
        intentID: String,
        blockedLaw: HarmonicKernelLaw,
        holdReason: String,
        exitRequired: Bool,
        sourceSurfaceID: String,
        targetSurfaceID: String,
        evidencePointer: String,
        claimsPulseExecution: Bool = false
    ) {
        self.id = id
        self.intentID = intentID
        self.blockedLaw = blockedLaw
        self.holdReason = holdReason
        self.exitRequired = exitRequired
        self.sourceSurfaceID = sourceSurfaceID
        self.targetSurfaceID = targetSurfaceID
        self.evidencePointer = evidencePointer
        self.claimsPulseExecution = claimsPulseExecution
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse hold/exit notice ID is empty")
        }
        if intentID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse hold/exit intent ID is empty")
        }
        if holdReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse hold/exit reason is empty")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse hold/exit evidence pointer is empty")
        }
        if claimsPulseExecution {
            violations.append("pulse hold/exit notice claims execution")
        }
        return violations
    }
}

public struct FieldPulseReceipt: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let intentID: String
    public let outcome: FieldPulseReceiptOutcome
    public let emittedPulseID: String?
    public let sourceSurfaceID: String
    public let targetSurfaceID: String
    public let evidencePointer: String
    public let mutatesSource: Bool
    public let promotesAuthority: Bool

    public init(
        id: String,
        intentID: String,
        outcome: FieldPulseReceiptOutcome,
        emittedPulseID: String?,
        sourceSurfaceID: String,
        targetSurfaceID: String,
        evidencePointer: String,
        mutatesSource: Bool = false,
        promotesAuthority: Bool = false
    ) {
        self.id = id
        self.intentID = intentID
        self.outcome = outcome
        self.emittedPulseID = emittedPulseID
        self.sourceSurfaceID = sourceSurfaceID
        self.targetSurfaceID = targetSurfaceID
        self.evidencePointer = evidencePointer
        self.mutatesSource = mutatesSource
        self.promotesAuthority = promotesAuthority
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse receipt ID is empty")
        }
        if intentID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse receipt intent ID is empty")
        }
        if evidencePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("pulse receipt evidence pointer is empty")
        }
        if outcome == .emitted && (emittedPulseID ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("emitted pulse receipt lacks pulse ID")
        }
        if mutatesSource {
            violations.append("pulse receipt mutates source")
        }
        if promotesAuthority {
            violations.append("pulse receipt promotes authority")
        }
        return violations
    }
}

public enum FieldPulseTreatyAdapter {
    public static let genotypeID = "FIELD.PULSE.Treaty.Genotype.V0"
    public static let kernelOrder: [HarmonicKernelLaw] = [.conservation, .symmetry, .resonance]

    public static func signalEdge(from intent: FieldPulseIntentDeclaration) -> FieldSignalGraphEdge {
        FieldSignalGraphEdge(
            id: "\(intent.id).signal",
            source: FieldSignalEndpoint(kind: .object, id: intent.objectID),
            receiver: FieldSignalEndpoint(kind: .service, id: intent.targetSurfaceID),
            channel: .ambient,
            lane: intent.requestedLane,
            surfaceID: intent.targetSurfaceID,
            meaningPointer: intent.intentType,
            permissionProfile: intent.permissionProfile,
            evidencePointer: intent.evidencePointer,
            feedbackPath: "PULSE may return FieldPulseReceipt or FieldPulseHoldExitNotice only"
        )
    }
}

public struct FieldSurfaceCoordinationEntry: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let genotypeID: String
    public let surfaceID: String
    public let displayName: String
    public let plane: FieldSurfacePlane
    public let role: FieldSurfaceRole
    public let nativeOwner: String
    public let nativeResidence: String
    public let nativeAuthorityScope: String
    public let evidenceState: FieldSurfaceEvidenceState
    public let phenotype: String
    public let authorityCeiling: String
    public let globalFieldAuthority: Bool

    public init(
        genotypeID: String = FieldSurfaceCoordinationCatalog.genotypeID,
        surfaceID: String,
        displayName: String,
        plane: FieldSurfacePlane,
        role: FieldSurfaceRole,
        nativeOwner: String,
        nativeResidence: String,
        nativeAuthorityScope: String,
        evidenceState: FieldSurfaceEvidenceState,
        phenotype: String,
        authorityCeiling: String,
        globalFieldAuthority: Bool = false
    ) {
        self.id = surfaceID
        self.genotypeID = genotypeID
        self.surfaceID = surfaceID
        self.displayName = displayName
        self.plane = plane
        self.role = role
        self.nativeOwner = nativeOwner
        self.nativeResidence = nativeResidence
        self.nativeAuthorityScope = nativeAuthorityScope
        self.evidenceState = evidenceState
        self.phenotype = phenotype
        self.authorityCeiling = authorityCeiling
        self.globalFieldAuthority = globalFieldAuthority
    }
}

public struct FieldSurfaceTransferRoute: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let fromSurfaceID: String
    public let toSurfaceID: String
    public let kind: FieldSurfaceTransferKind
    public let preservesNativeResidence: Bool
    public let requiresReceipt: Bool
    public let contentCopyAllowed: Bool

    public init(
        id: String,
        fromSurfaceID: String,
        toSurfaceID: String,
        kind: FieldSurfaceTransferKind,
        preservesNativeResidence: Bool = true,
        requiresReceipt: Bool = true,
        contentCopyAllowed: Bool = false
    ) {
        self.id = id
        self.fromSurfaceID = fromSurfaceID
        self.toSurfaceID = toSurfaceID
        self.kind = kind
        self.preservesNativeResidence = preservesNativeResidence
        self.requiresReceipt = requiresReceipt
        self.contentCopyAllowed = contentCopyAllowed
    }
}

public struct FieldSurfaceTransferDecision: Codable, Equatable, Sendable {
    public enum Result: String, Codable, CaseIterable, Equatable, Sendable {
        case pass = "PASS"
        case hold = "HOLD"
    }

    public let result: Result
    public let reason: String

    public init(result: Result, reason: String) {
        self.result = result
        self.reason = reason
    }

    public var isPermitted: Bool { result == .pass }
}

/// Typed surface catalogue for the Philharmonic coordination field.
///
/// This is a deterministic contract and reporting catalogue. It does not
/// connect to a provider, write to a board, run a deployment, ingest device
/// data, or promote authority. It gives each surface one native role while
/// preserving a common genotype and distinct phenotype.
public enum FieldSurfaceCoordinationCatalog {
    public static let genotypeID = "FIELD.SurfaceCoordination.Genotype.V0"

    public static let entries: [FieldSurfaceCoordinationEntry] = [
        .init(
            surfaceID: "notion",
            displayName: "Notion",
            plane: .sovereignMirror,
            role: .intentionCanon,
            nativeOwner: "Notion / Notorious",
            nativeResidence: "Notion architecture and intention pages",
            nativeAuthorityScope: "planning and narrative canon only",
            evidenceState: .witnessed,
            phenotype: "editable architecture and intention mirror",
            authorityCeiling: "REFERENCE_ONLY"
        ),
        .init(
            surfaceID: "trello",
            displayName: "Trello",
            plane: .developmentConfiguration,
            role: .coordination,
            nativeOwner: "Trello Philharmonic board",
            nativeResidence: "lists, cards, and coordination pointers",
            nativeAuthorityScope: "cross-surface coordination only",
            evidenceState: .witnessed,
            phenotype: "visual orchestration board",
            authorityCeiling: "COORDINATION_ONLY"
        ),
        .init(
            surfaceID: "linear",
            displayName: "Linear",
            plane: .developmentConfiguration,
            role: .architectHandoff,
            nativeOwner: "Linear Field-MacOS-DOJO document and issues",
            nativeResidence: "refined architectural handoff and execution status",
            nativeAuthorityScope: "Architect preparation and Weaver handoff only",
            evidenceState: .witnessed,
            phenotype: "refined inverse/shadow-cast specification",
            authorityCeiling: "HANDOFF_ONLY"
        ),
        .init(
            surfaceID: "github",
            displayName: "GitHub",
            plane: .developmentConfiguration,
            role: .implementationLineage,
            nativeOwner: "versioned repository",
            nativeResidence: "commits, branches, issues, and review lineage",
            nativeAuthorityScope: "implementation lineage only",
            evidenceState: .partial,
            phenotype: "versioned implementation expression",
            authorityCeiling: "IMPLEMENTATION_EVIDENCE_ONLY"
        ),
        .init(
            surfaceID: "google_drive",
            displayName: "Google Drive",
            plane: .sovereignMirror,
            role: .sovereignMirror,
            nativeOwner: "Google Workspace",
            nativeResidence: "native documents, sheets, and evidence files",
            nativeAuthorityScope: "document and evidence residence only",
            evidenceState: .witnessed,
            phenotype: "editable document and ledger mirror",
            authorityCeiling: "MIRROR_ONLY"
        ),
        .init(
            surfaceID: "akron",
            displayName: "Akron",
            plane: .externalIntake,
            role: .externalIntake,
            nativeOwner: "Akron gateway",
            nativeResidence: "external source custody and intake boundary",
            nativeAuthorityScope: "external intake and source pointer custody",
            evidenceState: .partial,
            phenotype: "external source gateway",
            authorityCeiling: "POINTER_ONLY"
        ),
        .init(
            surfaceID: "obiwan",
            displayName: "OBI-WAN",
            plane: .internalCirculation,
            role: .internalObserver,
            nativeOwner: "OBI-WAN chamber",
            nativeResidence: "observer state and observation records",
            nativeAuthorityScope: "observation only",
            evidenceState: .witnessed,
            phenotype: "internal observer return",
            authorityCeiling: "OBSERVATION_ONLY"
        ),
        .init(
            surfaceID: "dojo",
            displayName: "DOJO",
            plane: .internalCirculation,
            role: .internalConductor,
            nativeOwner: "DOJO chamber",
            nativeResidence: "accepted chamber streams and orchestration state",
            nativeAuthorityScope: "conduction of accepted streams only",
            evidenceState: .witnessed,
            phenotype: "internal conductor",
            authorityCeiling: "OBSERVATION_ONLY"
        ),
        .init(
            surfaceID: "vercel",
            displayName: "Vercel / v0",
            plane: .hostedPhenotype,
            role: .hostedPhenotype,
            nativeOwner: "Vercel account and project surfaces",
            nativeResidence: "hosted projects, deployments, and provider billing surface",
            nativeAuthorityScope: "hosted phenotype and provider witness only",
            evidenceState: .partial,
            phenotype: "hosted deployment expression",
            authorityCeiling: "PROVIDER_WITNESS_ONLY"
        ),
        .init(
            surfaceID: "canva",
            displayName: "Canva",
            plane: .visualPhenotype,
            role: .visualPhenotype,
            nativeOwner: "Canva design workspace",
            nativeResidence: "visual designs and presentation artifacts",
            nativeAuthorityScope: "visual expression only",
            evidenceState: .partial,
            phenotype: "visual design expression",
            authorityCeiling: "VISUAL_WITNESS_ONLY"
        ),
        .init(
            surfaceID: "computer_breathing",
            displayName: "Computer Breathing",
            plane: .deviceFeedback,
            role: .deviceFeedback,
            nativeOwner: "consent-bound device feedback lane",
            nativeResidence: "device and environmental feedback boundary",
            nativeAuthorityScope: "device feedback only",
            evidenceState: .unknown,
            phenotype: "unwitnessed embodied feedback expression",
            authorityCeiling: "HOLD_UNKNOWN"
        )
    ]

    public static let routes: [FieldSurfaceTransferRoute] = [
        .init(id: "notion-to-trello", fromSurfaceID: "notion", toSurfaceID: "trello", kind: .coordinationPointer),
        .init(id: "notion-to-linear", fromSurfaceID: "notion", toSurfaceID: "linear", kind: .refinedArchitectHandoff),
        .init(id: "trello-to-linear", fromSurfaceID: "trello", toSurfaceID: "linear", kind: .refinedArchitectHandoff),
        .init(id: "linear-to-github", fromSurfaceID: "linear", toSurfaceID: "github", kind: .implementationHandoff),
        .init(id: "drive-to-trello", fromSurfaceID: "google_drive", toSurfaceID: "trello", kind: .coordinationPointer),
        .init(id: "akron-to-obiwan", fromSurfaceID: "akron", toSurfaceID: "obiwan", kind: .pointerOnly),
        .init(id: "obiwan-to-dojo", fromSurfaceID: "obiwan", toSurfaceID: "dojo", kind: .internalObservationReturn),
        .init(id: "github-to-vercel", fromSurfaceID: "github", toSurfaceID: "vercel", kind: .hostedPhenotypePointer),
        .init(id: "vercel-to-trello", fromSurfaceID: "vercel", toSurfaceID: "trello", kind: .hostedPhenotypePointer),
        .init(id: "canva-to-trello", fromSurfaceID: "canva", toSurfaceID: "trello", kind: .visualPhenotypePointer)
    ]

    public static let surfaceNodes: [FieldSurfaceNode] = [
        FieldSurfaceNode(
            id: "dojo_today_mac",
            displayName: "DOJO Today on Mac",
            kind: .mac,
            outputChannels: [.visual, .semantic, .geometric, .temporal, .evidential, .permission],
            inputChannels: [.keyboard, .touch],
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: ["selected object page", "foldable object context", "local evidence/HOLD summary"],
                allowedActions: ["local capture", "continue locally", "open proof", "copy metadata"],
                permissionProfile: "LOCAL_OPERATOR_VISIBLE_ONLY",
                authorityCeiling: "EXPERIENCE_AND_LOCAL_CAPTURE_ONLY"
            ),
            infrastructure: FieldSurfaceInfrastructureFacet(
                state: .partial,
                healthPointer: "SystemInspectorView",
                latencyClass: "Unknown",
                networkBoundary: "No live Notion MCP from app"
            ),
            utilisation: FieldSurfaceUtilisationFacet(
                context: .desktopWorking,
                activeSignalsIn: [.keyboard, .touch],
                activeSignalsOut: [.visual, .semantic, .evidential],
                currentObserverID: "local-operator",
                consentInferred: false
            )
        ),
        FieldSurfaceNode(
            id: "vehicle_safety_simulator",
            displayName: "Vehicle Safety Simulator",
            kind: .vehicle,
            outputChannels: [.audio, .haptic, .temporal, .permission],
            inputChannels: [.voice],
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: ["driving summary", "voice-first alert", "single decision", "defer to arrival"],
                allowedActions: ["deferToArrival", "hearSummary", "acknowledgeHold"],
                permissionProfile: "VEHICLE_SAFETY_RESTRICTED",
                authorityCeiling: "GLANCE_AND_DEFER_ONLY"
            ),
            infrastructure: FieldSurfaceInfrastructureFacet(
                state: .held,
                healthPointer: "simulated only",
                latencyClass: "not measured",
                networkBoundary: "No CarPlay or vehicle integration"
            ),
            utilisation: FieldSurfaceUtilisationFacet(
                context: .safetyConstrained,
                activeSignalsIn: [],
                activeSignalsOut: [],
                currentObserverID: "local-operator",
                consentInferred: false
            )
        ),
        FieldSurfaceNode(
            id: "iphone14_murmur",
            displayName: "iPhone 14 Murmur",
            kind: .iPhone,
            outputChannels: [.visual, .audio, .haptic, .temporal, .semantic, .permission],
            inputChannels: [.touch, .voice],
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: ["mobile continuity summary", "arrival staging", "deferred object pointer"],
                allowedActions: ["stageContinuation", "showPauseCue", "hold"],
                permissionProfile: "IPHONE_MOBILE_CONTINUITY",
                authorityCeiling: "MOBILE_CONTINUITY_ONLY"
            ),
            infrastructure: FieldSurfaceInfrastructureFacet(
                state: .held,
                healthPointer: "iPhoneMurmor",
                latencyClass: "not measured",
                networkBoundary: "No live iPhone relay binding"
            ),
            utilisation: FieldSurfaceUtilisationFacet(
                context: .mobileContinuity,
                activeSignalsIn: [],
                activeSignalsOut: [],
                currentObserverID: "local-operator",
                consentInferred: false
            )
        ),
        FieldSurfaceNode(
            id: "watch_ultra_murmur",
            displayName: "Watch Ultra Murmur",
            kind: .watch,
            outputChannels: [.haptic, .temporal, .permission],
            inputChannels: [],
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: ["quiet haptic cue", "deferred attention cue", "hold status"],
                allowedActions: ["dampenHaptics", "hold"],
                permissionProfile: "WATCH_GLANCE_HAPTIC_ONLY",
                authorityCeiling: "HAPTIC_CUE_ONLY"
            ),
            infrastructure: FieldSurfaceInfrastructureFacet(
                state: .held,
                healthPointer: "WatchMurmor",
                latencyClass: "not measured",
                networkBoundary: "No live WatchConnectivity binding"
            ),
            utilisation: FieldSurfaceUtilisationFacet(
                context: .glanceable,
                activeSignalsIn: [],
                activeSignalsOut: [],
                currentObserverID: "local-operator",
                consentInferred: false
            )
        ),
        FieldSurfaceNode(
            id: "vercel_pulse_web",
            displayName: "Field-PULSE Web Surface",
            kind: .ambient,
            outputChannels: [.visual, .ambient, .temporal, .permission],
            inputChannels: [],
            configuration: FieldSurfaceConfigurationFacet(
                allowedProjections: ["coherence pulse pointer", "ambient HOLD/EXIT status"],
                allowedActions: ["return receipt", "return hold/exit notice"],
                permissionProfile: "PULSE_TREATY_POINTER_ONLY",
                authorityCeiling: "CARRIER_POINTER_ONLY"
            ),
            infrastructure: FieldSurfaceInfrastructureFacet(
                state: .unknown,
                healthPointer: "docs/DOJO_SUITE_FIELD_PULSE_HOMEFIELD_CARRY_BRIDGE_V0.md",
                latencyClass: "not measured",
                networkBoundary: "No Vercel call or PULSE runtime binding"
            ),
            utilisation: FieldSurfaceUtilisationFacet(
                context: .sharedAmbient,
                activeSignalsIn: [],
                activeSignalsOut: [],
                currentObserverID: "local-operator",
                consentInferred: false
            )
        )
    ]

    public static let signalEdges: [FieldSignalGraphEdge] = [
        FieldSignalGraphEdge(
            id: "dojo_today_object_context_open",
            source: FieldSignalEndpoint(kind: .object, id: "selected-generated-object"),
            receiver: FieldSignalEndpoint(kind: .observer, id: "local-operator"),
            channel: .visual,
            lane: .evidential,
            surfaceID: "dojo_today_mac",
            meaningPointer: "Object Context foldover exposes source/home/evidence/authority/time/next move",
            permissionProfile: "READ_ONLY_CONTEXT_PROJECTION",
            evidencePointer: "GeneratedObjectShell.localReceipt | GeneratedObjectShell.processingPacket | HOLD",
            feedbackPath: "Observer may continue, capture, open proof, copy metadata, or close"
        ),
        FieldSignalGraphEdge(
            id: "dojo_today_vehicle_continuity_deferred",
            source: FieldSignalEndpoint(kind: .object, id: "selected-generated-object"),
            receiver: FieldSignalEndpoint(kind: .observer, id: "local-operator"),
            channel: .audio,
            lane: .experiential,
            surfaceID: "vehicle_safety_simulator",
            meaningPointer: "Deferred continuity cue only; object detail returns to DOJO Today on Mac",
            permissionProfile: "VEHICLE_SAFETY_RESTRICTED",
            evidencePointer: "HOLD.SimulatedVehicleSurfaceOnly",
            feedbackPath: "Observer may defer; no live vehicle action is performed"
        ),
        FieldSignalGraphEdge(
            id: "carplay_safe_decision_due_simulated",
            source: FieldSignalEndpoint(kind: .object, id: "decision:atlas:2026-09-14"),
            receiver: FieldSignalEndpoint(kind: .observer, id: "local-operator"),
            channel: .audio,
            lane: .temporal,
            surfaceID: "vehicle_safety_simulator",
            meaningPointer: "Project Atlas decision due 3 PM; hear summary or defer to arrival only",
            permissionProfile: "VEHICLE_SAFETY_RESTRICTED",
            evidencePointer: "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md",
            feedbackPath: "Observer may hearSummary or deferToArrival; full context resumes on dojo_today_mac"
        ),
        FieldSignalGraphEdge(
            id: "dojo_today_to_pulse_coherence_intent",
            source: FieldSignalEndpoint(kind: .object, id: "selected-generated-object"),
            receiver: FieldSignalEndpoint(kind: .service, id: "field-pulse"),
            channel: .ambient,
            lane: .temporal,
            surfaceID: "vercel_pulse_web",
            meaningPointer: "Treaty intent pointer for coherence pulse aligned to the selected object",
            permissionProfile: "PULSE_TREATY_POINTER_ONLY",
            evidencePointer: "docs/DOJO_SUITE_FIELD_PULSE_HOMEFIELD_CARRY_BRIDGE_V0.md",
            feedbackPath: "PULSE may return FieldPulseReceipt or FieldPulseHoldExitNotice only"
        )
    ]

    public static let permissionProfiles: [FieldPermissionProfile] = [
        FieldPermissionProfile(
            id: "READ_ONLY_CONTEXT_PROJECTION",
            displayName: "Read-only Context Projection",
            allowedChannels: [.visual, .semantic, .geometric, .temporal, .evidential, .permission],
            allowedActions: ["continue locally", "local capture", "open proof", "copy metadata", "fold context"],
            authorityCeiling: "EXPERIENCE_AND_LOCAL_CAPTURE_ONLY"
        ),
        FieldPermissionProfile(
            id: "VEHICLE_SAFETY_RESTRICTED",
            displayName: "Vehicle Safety Restricted",
            allowedChannels: [.audio, .haptic, .temporal, .permission],
            allowedActions: ["deferToArrival", "hearSummary", "acknowledgeHold"],
            authorityCeiling: "GLANCE_AND_DEFER_ONLY"
        ),
        FieldPermissionProfile(
            id: "WATCH_GLANCE_HAPTIC_ONLY",
            displayName: "Watch Glance Haptic Only",
            allowedChannels: [.haptic, .temporal, .permission],
            allowedActions: ["dampenHaptics", "hold"],
            authorityCeiling: "HAPTIC_CUE_ONLY"
        ),
        FieldPermissionProfile(
            id: "IPHONE_MOBILE_CONTINUITY",
            displayName: "iPhone Mobile Continuity",
            allowedChannels: [.visual, .audio, .haptic, .temporal, .semantic, .permission],
            allowedActions: ["stageContinuation", "showPauseCue", "hold"],
            authorityCeiling: "MOBILE_CONTINUITY_ONLY"
        ),
        FieldPermissionProfile(
            id: "PULSE_TREATY_POINTER_ONLY",
            displayName: "PULSE Treaty Pointer Only",
            allowedChannels: [.ambient, .temporal, .permission],
            allowedActions: ["return receipt", "return hold/exit notice"],
            authorityCeiling: "CARRIER_POINTER_ONLY"
        )
    ]

    public static let observerContexts: [FieldObserverContext] = [
        FieldObserverContext(
            observerID: "local-operator",
            version: "FIELD.ObserverContext.V0",
            asOfTime: "2026-09-14T00:00:00Z",
            timeZone: "Australia/Melbourne",
            permissionProfileID: "READ_ONLY_CONTEXT_PROJECTION",
            continuityContractID: "DOJO.Today.LocalContinuity.V0",
            primaryDeviceID: "dojo_today_mac",
            availableSurfaceIDs: ["dojo_today_mac", "vehicle_safety_simulator"],
            activeChannels: [.visual, .keyboard, .touch, .semantic, .evidential],
            activity: FieldObserverActivityState(kind: .deskWork, detail: "ordinary DOJO Today return", safetyCritical: false),
            attention: FieldObserverAttentionState(level: .medium, mode: .visualPrimary, source: "local deterministic fixture"),
            location: FieldObserverLocationState(
                semantic: .atDesk,
                primarySurfaceID: "dojo_today_mac",
                nearbySurfaceIDs: ["vehicle_safety_simulator"]
            ),
            activeObjects: [
                FieldObserverActiveObjectSummary(
                    objectID: "selected-generated-object",
                    role: "current object context",
                    lanesActive: [.semantic, .temporal, .evidential, .permission],
                    urgency: .medium
                )
            ],
            continuityPromises: [
                FieldContinuityPromise(
                    objectID: "selected-generated-object",
                    startedOnSurfaceID: "dojo_today_mac",
                    canResumeOnSurfaceIDs: ["dojo_today_mac"],
                    requiredStateRefs: ["source", "home", "evidence", "authority", "nextAvailableAction"],
                    status: .active
                ),
                FieldContinuityPromise(
                    objectID: "selected-generated-object",
                    startedOnSurfaceID: "vehicle_safety_simulator",
                    canResumeOnSurfaceIDs: ["dojo_today_mac"],
                    requiredStateRefs: ["nextAvailableAction"],
                    status: .suspended
                )
            ],
            evidenceRef: "GeneratedObjectShell.localReceipt | HOLD",
            integrityStatus: FieldObserverIntegrityStatus(code: .ok, note: "static local fixture; no live sensor claim")
        ),
        FieldObserverContext(
            observerID: "local-operator-driving-simulation",
            version: "FIELD.ObserverContext.V0",
            asOfTime: "2026-09-14T00:00:00Z",
            timeZone: "Australia/Melbourne",
            permissionProfileID: "VEHICLE_SAFETY_RESTRICTED",
            continuityContractID: "DOJO.Today.VehicleContinuity.V0",
            primaryDeviceID: "vehicle_safety_simulator",
            availableSurfaceIDs: ["vehicle_safety_simulator", "dojo_today_mac"],
            activeChannels: [.audio, .voice, .haptic, .temporal, .permission],
            activity: FieldObserverActivityState(kind: .driving, detail: "simulated CarPlay-safe driving context", safetyCritical: true),
            attention: FieldObserverAttentionState(level: .medium, mode: .audioPrimary, source: "contract fixture only"),
            location: FieldObserverLocationState(
                semantic: .inVehicle,
                primarySurfaceID: "vehicle_safety_simulator",
                nearbySurfaceIDs: ["dojo_today_mac"]
            ),
            activeObjects: [
                FieldObserverActiveObjectSummary(
                    objectID: "decision:atlas:2026-09-14",
                    role: "time-bound decision summary",
                    lanesActive: [.temporal, .operational, .permission],
                    urgency: .high
                )
            ],
            continuityPromises: [
                FieldContinuityPromise(
                    objectID: "decision:atlas:2026-09-14",
                    startedOnSurfaceID: "vehicle_safety_simulator",
                    canResumeOnSurfaceIDs: ["dojo_today_mac"],
                    requiredStateRefs: ["carPlaySafeSummary", "deferToArrival", "fullContext"],
                    status: .suspended
                )
            ],
            evidenceRef: "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md",
            integrityStatus: FieldObserverIntegrityStatus(code: .ok, note: "simulation only; no live CarPlay runtime")
        )
    ]

    public static let carPlayDecisionMetadata = FieldCarPlayObjectMetadata(
        objectID: "decision:atlas:2026-09-14",
        carPlaySafeSummary: "Project Atlas decision due 3 PM.",
        allowedActions: [.deferToArrival, .hearSummary],
        desktopOnlyFields: ["fullContext", "attachments", "history"],
        continuationSurfaceID: "dojo_today_mac",
        evidencePointer: "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md",
        authorityCeiling: "GLANCE_AND_DEFER_ONLY"
    )

    public static let dojoTodayMurmurPolicy = FieldMurmurPolicy(
        surfaceID: "dojo_today_mac",
        mirroredGeometryPointers: [
            "DOJO spinning top",
            "chamber rail",
            "object context foldover",
            "local evidence/HOLD summary"
        ],
        setpoints: FieldMurmurSetpoints(
            maxOpenMinutes: 10,
            maxRequestsPerMinute: 3
        ),
        toleranceBands: FieldMurmurToleranceBands(
            highAttentionOpenMinutes: 2,
            highAttentionRequestsPerMinute: 1
        ),
        correctionActions: [.fadeOpacity, .showPauseCue, .autoCollapse, .hold],
        evidencePointer: "DOJO_TODAY_ATTENTION_PRODUCT_CONSTRAINTS_V0",
        authorityCeiling: "EXPERIENCE_AND_LOCAL_CAPTURE_ONLY"
    )

    public static let watchUltraMurmurPolicy = FieldMurmurPolicy(
        surfaceID: "watch_ultra_murmur",
        mirroredGeometryPointers: [
            "wrist pulse node",
            "deferred attention cue",
            "HOLD status"
        ],
        setpoints: FieldMurmurSetpoints(
            maxOpenMinutes: 1,
            maxRequestsPerMinute: 1
        ),
        toleranceBands: FieldMurmurToleranceBands(
            highAttentionOpenMinutes: 0,
            highAttentionRequestsPerMinute: 0
        ),
        correctionActions: [.dampenHaptics, .hold],
        evidencePointer: "WatchMurmor",
        authorityCeiling: "HAPTIC_CUE_ONLY"
    )

    public static let iPhone14MurmurPolicy = FieldMurmurPolicy(
        surfaceID: "iphone14_murmur",
        mirroredGeometryPointers: [
            "mobile relay bridge",
            "arrival staging",
            "deferred object pointer"
        ],
        setpoints: FieldMurmurSetpoints(
            maxOpenMinutes: 3,
            maxRequestsPerMinute: 2
        ),
        toleranceBands: FieldMurmurToleranceBands(
            highAttentionOpenMinutes: 1,
            highAttentionRequestsPerMinute: 1
        ),
        correctionActions: [.stageContinuation, .showPauseCue, .hold],
        evidencePointer: "iPhoneMurmor",
        authorityCeiling: "MOBILE_CONTINUITY_ONLY"
    )

    public static let quietModeMurmurationCue = FieldMurmurationCue(
        id: "dojo_today_hold_to_watch_quiet_dampening",
        mode: .quiet,
        sourceSurfaceID: "dojo_today_mac",
        receivingSurfaceIDs: ["watch_ultra_murmur"],
        fieldAttentionBudget: 0.2,
        evidencePointer: "DOJO_TODAY_ATTENTION_PRODUCT_CONSTRAINTS_V0"
    )

    public static let travelModeMurmurationCue = FieldMurmurationCue(
        id: "dojo_today_hold_to_mobile_travel_continuity",
        mode: .travel,
        sourceSurfaceID: "dojo_today_mac",
        receivingSurfaceIDs: ["watch_ultra_murmur", "iphone14_murmur"],
        fieldAttentionBudget: 0.45,
        evidencePointer: "DOJO_TODAY_ATTENTION_PRODUCT_CONSTRAINTS_V0"
    )

    public static let pulseTreatyIntent = FieldPulseIntentDeclaration(
        id: "dojo_today_pulse_coherence_intent",
        sourceSurfaceID: "dojo_today_mac",
        targetSurfaceID: "vercel_pulse_web",
        objectID: "selected-generated-object",
        intentType: "emitCoherencePulsePointer",
        requestedLane: .temporal,
        permissionProfile: "PULSE_TREATY_POINTER_ONLY",
        evidencePointer: "docs/DOJO_SUITE_FIELD_PULSE_HOMEFIELD_CARRY_BRIDGE_V0.md"
    )

    public static let pulseTreatySnapshot = FieldPulseStateSnapshot(
        id: "pulse_snapshot_static_v0",
        pulseRuntimeID: "field-pulse-unbound",
        observedAt: "2026-09-14T00:00:00Z",
        activePulseIDs: [],
        surfaceStates: ["vercel_pulse_web": .holding],
        coherenceMetrics: [
            FieldPulseCoherenceMetric(
                id: "treaty_alignment",
                label: "Treaty alignment",
                value: 1.0,
                evidencePointer: "docs/DOJO_SUITE_FIELD_PULSE_HOMEFIELD_CARRY_BRIDGE_V0.md"
            )
        ]
    )

    public static let pulseTreatyHoldExitNotice = FieldPulseHoldExitNotice(
        id: "pulse_hold_exit_static_v0",
        intentID: pulseTreatyIntent.id,
        blockedLaw: .conservation,
        holdReason: "HOLD.PulseRuntimeUnbound",
        exitRequired: true,
        sourceSurfaceID: "vercel_pulse_web",
        targetSurfaceID: "dojo_today_mac",
        evidencePointer: "docs/DOJO_SUITE_FIELD_PULSE_HOMEFIELD_CARRY_BRIDGE_V0.md"
    )

    public static func entry(for surfaceID: String) -> FieldSurfaceCoordinationEntry? {
        entries.first { $0.surfaceID == surfaceID }
    }

    public static func surfaceNode(for id: String) -> FieldSurfaceNode? {
        surfaceNodes.first { $0.id == id }
    }

    public static func signalEdge(for id: String) -> FieldSignalGraphEdge? {
        signalEdges.first { $0.id == id }
    }

    public static func permissionProfile(for id: String) -> FieldPermissionProfile? {
        permissionProfiles.first { $0.id == id }
    }

    public static func observerContext(for id: String) -> FieldObserverContext? {
        observerContexts.first { $0.id == id }
    }

    public static func surfaceContextHeaderLine(
        observerID: String,
        compact: Bool = false
    ) -> String {
        guard
            let context = observerContext(for: observerID),
            let primaryDeviceID = context.primaryDeviceID,
            let surface = surfaceNode(for: primaryDeviceID),
            let profile = permissionProfile(for: context.permissionProfileID)
        else {
            return "Surface Context: Unknown · HOLD"
        }

        if context.activity.safetyCritical || context.attention.level == .low || context.attention.level == .unavailable {
            return compact
                ? "\(surface.displayName) · \(context.activity.kind.rawValue) · HOLD"
                : "Surface Context: \(surface.displayName) · \(context.id) · \(context.activity.kind.rawValue) · \(context.attention.level.rawValue) · HOLD.StressModeRequiresExit"
        }

        if compact {
            return "\(surface.displayName) · \(context.id) · \(context.activity.kind.rawValue) · \(context.attention.level.rawValue)"
        }

        return "Surface Context: \(surface.displayName) · \(context.id) · \(context.activity.kind.rawValue) · \(context.attention.level.rawValue) · \(profile.id)"
    }

    public static func routeDecision(
        from sourceSurfaceID: String,
        to destinationSurfaceID: String,
        kind: FieldSurfaceTransferKind
    ) -> FieldSurfaceTransferDecision {
        guard entry(for: sourceSurfaceID) != nil, entry(for: destinationSurfaceID) != nil else {
            return .init(result: .hold, reason: "source or destination surface is unknown")
        }

        guard let route = routes.first(where: {
            $0.fromSurfaceID == sourceSurfaceID &&
            $0.toSurfaceID == destinationSurfaceID &&
            $0.kind == kind
        }) else {
            return .init(result: .hold, reason: "route is not registered in the coordination contract")
        }

        guard route.preservesNativeResidence, route.requiresReceipt, !route.contentCopyAllowed else {
            return .init(result: .hold, reason: "route violates native residence, receipt, or content-copy boundary")
        }

        return .init(result: .pass, reason: "registered pointer or handoff route with native residence preserved")
    }

    /// A catalogue invariant check suitable for a preflight or unit test.
    public static func invariantViolations() -> [String] {
        var violations: [String] = []
        let ids = entries.map(\.surfaceID)
        if Set(ids).count != ids.count { violations.append("duplicate surface ID") }
        if entries.contains(where: { $0.genotypeID != genotypeID }) {
            violations.append("surface genotype drift")
        }
        if entries.contains(where: { $0.globalFieldAuthority }) {
            violations.append("external surface claims global FIELD authority")
        }
        if routes.contains(where: { !$0.preservesNativeResidence || !$0.requiresReceipt || $0.contentCopyAllowed }) {
            violations.append("route violates preservation or receipt invariant")
        }
        if surfaceNodes.flatMap({ $0.invariantViolations() }).isEmpty == false {
            violations.append("surface node invariant violation")
        }
        if signalEdges.flatMap({ $0.invariantViolations() }).isEmpty == false {
            violations.append("signal edge invariant violation")
        }
        if permissionProfiles.flatMap({ $0.invariantViolations() }).isEmpty == false {
            violations.append("permission profile invariant violation")
        }
        let knownSurfaceIDs = Set(surfaceNodes.map(\.id))
        if observerContexts.flatMap({ $0.invariantViolations(knownSurfaceIDs: knownSurfaceIDs) }).isEmpty == false {
            violations.append("observer context invariant violation")
        }
        let knownProfileIDs = Set(permissionProfiles.map(\.id))
        if signalEdges.contains(where: { !knownProfileIDs.contains($0.permissionProfile) }) {
            violations.append("signal edge references unknown permission profile")
        }
        if observerContexts.contains(where: { !knownProfileIDs.contains($0.permissionProfileID) }) {
            violations.append("observer context references unknown permission profile")
        }
        if pulseTreatyIntent.invariantViolations().isEmpty == false {
            violations.append("PULSE treaty intent invariant violation")
        }
        if pulseTreatySnapshot.invariantViolations().isEmpty == false {
            violations.append("PULSE treaty snapshot invariant violation")
        }
        if pulseTreatyHoldExitNotice.invariantViolations().isEmpty == false {
            violations.append("PULSE treaty hold/exit invariant violation")
        }
        if carPlayDecisionMetadata.invariantViolations(knownSurfaceIDs: knownSurfaceIDs).isEmpty == false {
            violations.append("CarPlay decision metadata invariant violation")
        }
        if dojoTodayMurmurPolicy.invariantViolations(knownSurfaceIDs: knownSurfaceIDs).isEmpty == false {
            violations.append("DOJO Today murmur policy invariant violation")
        }
        if watchUltraMurmurPolicy.invariantViolations(knownSurfaceIDs: knownSurfaceIDs).isEmpty == false {
            violations.append("Watch Ultra murmur policy invariant violation")
        }
        if iPhone14MurmurPolicy.invariantViolations(knownSurfaceIDs: knownSurfaceIDs).isEmpty == false {
            violations.append("iPhone 14 murmur policy invariant violation")
        }
        if quietModeMurmurationCue.invariantViolations(knownSurfaceIDs: knownSurfaceIDs).isEmpty == false {
            violations.append("quiet mode murmuration cue invariant violation")
        }
        if travelModeMurmurationCue.invariantViolations(knownSurfaceIDs: knownSurfaceIDs).isEmpty == false {
            violations.append("travel mode murmuration cue invariant violation")
        }
        return violations
    }
}

// MARK: - DOJO Render Projection V1

/// DOJO Rendering Rule v1 — typed consume path.
///
/// DOJO consumes only `{geometry, chamber, role, evidence, authority, next, prime_state}`.
/// Live Notion MCP is not invoked from the app. The witnessed snapshot is the lawful local feed.
public enum DojoRenderProjectionV1 {
    public static let schema = "DOJO.RenderProjection.V1"
    public static let dataSourceID = "61eb4b55-e283-454b-a628-5656c228dfc6"
    public static let chamberScope = "dojo"
    public static let writePolicy = "read_only"
    public static let preservedHolds: [String] = [
        "HOLD.LocalDojoNotConsumingLiveNotionMCP",
        "HOLD.RoleColourRetinting",
        "HOLD.SomaPrimeNotEmbodied",
        "HOLD.TrekInTrash"
    ]

    /// Witnessed one-chamber MCP query (2026-08-25). Not a live fetch.
    public static let witnessedDojoSnapshot: [DojoRenderRawRow] = [
        DojoRenderRawRow(
            url: "https://app.notion.com/3c704c15e4f1812290c1ee4b48a92a86",
            geometry: "pyramid",
            chamber: "dojo",
            role: "structure",
            evidence: "HOLD",
            authority: "observe",
            next: "Feed one chamber row and watch the quiet projection.",
            primeState: "HOLD · not embodied",
            name: "Sovereign chamber OS",
            workplace: "field-dojo-hub"
        ),
        DojoRenderRawRow(
            url: "https://app.notion.com/3c704c15e4f18133835ee0aed4895065",
            geometry: "octagon",
            chamber: "dojo",
            role: "flow",
            evidence: "HOLD",
            authority: "compose",
            next: "Choose one rail and write one next-evidence sentence.",
            primeState: "HOLD · not embodied",
            name: "Octagon narrative room",
            workplace: "stories-matter"
        )
    ]

    public static func project(
        rows: [DojoRenderRawRow] = witnessedDojoSnapshot,
        chamber: String = chamberScope
    ) -> DojoRenderProjectionResult {
        var tuples: [DojoRenderTuple] = []
        var dropped: [String] = []
        for row in rows {
            switch admit(row, chamber: chamber) {
            case .admitted(let tuple):
                tuples.append(tuple)
            case .rejected(let reason):
                dropped.append(reason)
            }
        }
        return DojoRenderProjectionResult(
            tuples: tuples,
            droppedReasons: dropped,
            writePolicy: writePolicy,
            chamberScope: chamber,
            holds: preservedHolds
        )
    }

    public static func admit(_ row: DojoRenderRawRow, chamber: String = chamberScope) -> DojoRenderAdmission {
        guard row.chamber == chamber else {
            return .rejected("dropped.chamber_out_of_scope:\(row.chamber)")
        }
        guard let geometry = DojoRenderGeometry(rawValue: row.geometry) else {
            return .rejected("hold.empty_or_unknown:geometry")
        }
        if geometry == .walkOn {
            return .rejected("hold.trek_in_trash")
        }
        guard let role = DojoRenderRole(rawValue: row.role) else {
            return .rejected("hold.empty_or_unknown:role")
        }
        guard let evidence = DojoRenderEvidence(rawValue: row.evidence) else {
            return .rejected("hold.empty_or_unknown:evidence")
        }
        guard let authority = DojoRenderAuthority(rawValue: row.authority) else {
            return .rejected("hold.empty_or_unknown:authority")
        }
        guard let prime = DojoRenderPrimeState(rawValue: row.primeState) else {
            return .rejected("hold.empty_or_unknown:prime_state")
        }
        guard let next = stripNext(row.next) else {
            return .rejected("hold.empty_or_unknown:next")
        }
        let identity = row.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identity.isEmpty else {
            return .rejected("hold.empty_or_unknown:url")
        }
        return .admitted(
            DojoRenderTuple(
                id: identity,
                geometry: geometry,
                chamber: chamber,
                role: role,
                evidence: evidence,
                authority: authority,
                next: next,
                primeState: prime
            )
        )
    }

    public static func stripNext(_ raw: String) -> String? {
        var text = raw
        text = text.replacingOccurrences(of: #"https?://\S+"#, with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: #"collection://\S+"#, with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: #"[@<][^\s>]+>"#, with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: #"^\s*[-*•]\s+"#, with: "", options: .regularExpression)
        for marker in ["**", "__", "*", "_", "`", "#"] {
            text = text.replacingOccurrences(of: marker, with: "")
        }
        text = String(text.unicodeScalars.filter { scalar in
            let value = scalar.value
            let isEmoji = (0x1F300...0x1FAFF).contains(value)
                || (0x2600...0x27BF).contains(value)
                || value == 0xFE0F
            return !isEmoji
        })
        text = text.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}

public enum DojoRenderAdmission: Equatable, Sendable {
    case admitted(DojoRenderTuple)
    case rejected(String)
}

public struct DojoRenderRawRow: Equatable, Sendable {
    public var url: String
    public var geometry: String
    public var chamber: String
    public var role: String
    public var evidence: String
    public var authority: String
    public var next: String
    public var primeState: String
    public var name: String?
    public var workplace: String?

    public init(
        url: String,
        geometry: String,
        chamber: String,
        role: String,
        evidence: String,
        authority: String,
        next: String,
        primeState: String,
        name: String? = nil,
        workplace: String? = nil
    ) {
        self.url = url
        self.geometry = geometry
        self.chamber = chamber
        self.role = role
        self.evidence = evidence
        self.authority = authority
        self.next = next
        self.primeState = primeState
        self.name = name
        self.workplace = workplace
    }
}

public struct DojoRenderTuple: Equatable, Sendable, Identifiable {
    public let id: String
    public let geometry: DojoRenderGeometry
    public let chamber: String
    public let role: DojoRenderRole
    public let evidence: DojoRenderEvidence
    public let authority: DojoRenderAuthority
    public let next: String
    public let primeState: DojoRenderPrimeState

    public var consumeKeys: [String] {
        ["geometry", "chamber", "role", "evidence", "authority", "next", "prime_state"]
    }
}

public struct DojoRenderProjectionResult: Equatable, Sendable {
    public let tuples: [DojoRenderTuple]
    public let droppedReasons: [String]
    public let writePolicy: String
    public let chamberScope: String
    public let holds: [String]
}

/// Smallest lawful Local DOJO Today bridge.
///
/// It consumes the already witnessed read-only feed and emits receipt facts for the UI/tests.
/// It does not invoke live Notion MCP, retint role colours, embody SOMA, or restore Trek.
public enum LocalDojoTodayRenderBridge {
    public static let relationshipEvidenceBoundary = "Relationship pattern only: interaction may reveal a relationship between distinct signals; interpretation remains subject to evidence. Resonance does not create authority or Prime Fractal State."

    public static func consumeVerifiedFeed(
        rows: [DojoRenderRawRow] = DojoRenderProjectionV1.witnessedDojoSnapshot
    ) -> LocalDojoTodayRenderReceipt {
        let projection = DojoRenderProjectionV1.project(rows: rows)
        return LocalDojoTodayRenderReceipt(
            schema: DojoRenderProjectionV1.schema,
            dataSourceID: DojoRenderProjectionV1.dataSourceID,
            projection: projection,
            consumedVerifiedReadOnlyFeed: true,
            liveNotionMCPInvoked: false,
            roleColourRetintingApplied: false,
            somaEmbodied: false,
            trekRestored: false
        )
    }
}

public struct LocalDojoTodayRenderReceipt: Equatable, Sendable {
    public let schema: String
    public let dataSourceID: String
    public let projection: DojoRenderProjectionResult
    public let consumedVerifiedReadOnlyFeed: Bool
    public let liveNotionMCPInvoked: Bool
    public let roleColourRetintingApplied: Bool
    public let somaEmbodied: Bool
    public let trekRestored: Bool

    public var receiptLine: String {
        [
            schema,
            dataSourceID,
            projection.writePolicy,
            projection.chamberScope,
            "tuples:\(projection.tuples.count)",
            "dropped:\(projection.droppedReasons.count)",
            "live_notion_mcp:false",
            "role_retint:false",
            "soma:false",
            "trek:false"
        ].joined(separator: " · ")
    }
}

public enum DojoRenderGeometry: String, Equatable, Sendable {
    case pyramid, octagon, spiral, neural
    case walkOn = "walk-on"
}

public enum DojoRenderRole: String, Equatable, Sendable {
    case structure, flow, interface, observer, validation

    /// Derived in DOJO. Never stored as Notion option colour. Green reserved.
    public var dojoHex: String {
        switch self {
        case .structure: return "#2563EB"
        case .flow: return "#14B8A6"
        case .interface: return "#22D3EE"
        case .observer: return "#4F46E5"
        case .validation: return "#EAB308"
        }
    }
}

public enum DojoRenderEvidence: String, Equatable, Sendable {
    case sealed = "SEALED"
    case hold = "HOLD"
    case promote = "PROMOTE"
}

public enum DojoRenderAuthority: String, Equatable, Sendable {
    case observe, compose, record, none
}

public enum DojoRenderPrimeState: String, Equatable, Sendable {
    case holdNotEmbodied = "HOLD · not embodied"
    case unknown = "Unknown"
}

public enum AppleWatchContract {
    public static let appleWatchBiometric = FieldSurfaceNode(
        id: "apple_watch_biometric",
        displayName: "Apple Watch Biometric",
        kind: .watch,
        outputChannels: [.visual, .haptic, .audio],
        inputChannels: [.biometric],
        configuration: FieldSurfaceConfigurationFacet(
            allowedProjections: ["readinessCue", "autonomicStateBrief", "anomalyAlert"],
            allowedActions: [],
            permissionProfile: "health_biometric_read_only",
            authorityCeiling: "READ_ONLY"
        )
    )

    public static let appleHealthKit = FieldInfrastructureNode(
        id: "appleHealthKit",
        type: "healthDataStore",
        capabilities: [
            "metricCount": "190",
            "dataTypes": "[quantity, category, workout, correlation, clinical]",
            "privacyModel": "onDevice_only"
        ],
        role: "centralHealthDataRepository",
        permissionProfile: "health_biometric_read_only",
        reliabilityClass: "high",
        sovereigntyClass: "external_vendor"
    )

    public static let appleWatchSensors = FieldInfrastructureNode(
        id: "appleWatchSensors",
        type: "biometricSensorSuite",
        capabilities: [
            "sensors": "[opticalHeart, electricalHeart_ECG, bloodOxygen_SpO2, wristTemperature, accelerometer, gyroscope, altimeter, compass, ambientLight, depthGauge, waterTemperature]"
        ],
        role: "rawBiometricDataAcquisition",
        permissionProfile: "health_biometric_read_only",
        reliabilityClass: "high",
        sovereigntyClass: "external_vendor"
    )
}
