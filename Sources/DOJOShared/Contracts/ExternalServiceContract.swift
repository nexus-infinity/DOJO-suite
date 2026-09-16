import Foundation

// MARK: - ExternalServiceState
// Lifecycle state of an external service connection.
// A service that is available is not necessarily allowed, active, or correctly configured.

public enum ExternalServiceState: String, Codable, Sendable, Equatable, CaseIterable {
    case available      = "AVAILABLE"       // Connected, idle
    case connected      = "CONNECTED"       // Authenticated, not yet active
    case authenticated  = "AUTHENTICATED"   // Token valid, ready
    case enabled        = "ENABLED"         // Configured and allowed in principle
    case allowed        = "ALLOWED"         // Permitted in current context
    case active         = "ACTIVE"          // Currently executing a call
    case blocked        = "BLOCKED"         // Context or policy prevents use
    case misconfigured  = "MISCONFIGURED"   // Invalid configuration
    case expired        = "EXPIRED"         // Token or auth expired
    case revoked        = "REVOKED"         // Access explicitly removed
    case unknown        = "UNKNOWN"         // State cannot be determined
}

// MARK: - ServiceAccessType
// The kind of access being requested or granted.
// Read and search are distinct; write and execute require stronger approval gates.

public enum ServiceAccessType: String, Codable, Sendable, Equatable, CaseIterable {
    case read       = "READ"
    case search     = "SEARCH"
    case write      = "WRITE"
    case create     = "CREATE"
    case delete     = "DELETE"
    case archive    = "ARCHIVE"
    case execute    = "EXECUTE"
    case stream     = "STREAM"
    case monitor    = "MONITOR"
    case trigger    = "TRIGGER"
    case sync       = "SYNC"
}

// MARK: - ExternalServiceCategory
// The class of external service.

public enum ExternalServiceCategory: String, Codable, Sendable, Equatable, CaseIterable {
    case knowledge      = "KNOWLEDGE"       // Web search, workspace search, docs
    case workspace      = "WORKSPACE"       // Notion, Drive, SharePoint, local files
    case communication  = "COMMUNICATION"   // Email, Slack, telephony, notifications
    case codeAndDeploy  = "CODE_AND_DEPLOY" // GitHub, CI/CD, package registries
    case dataAnalytics  = "DATA_ANALYTICS"  // Databases, analytics, CRM
    case device         = "DEVICE"          // Camera, mic, location, sensors, Bluetooth
    case model          = "MODEL"           // Cloud LLM, local LLM, STT/TTS, embeddings
    case unknown        = "UNKNOWN"
}

// MARK: - ServiceCallTrigger
// What initiated the external call.

public enum ServiceCallTrigger: String, Codable, Sendable, Equatable, CaseIterable {
    case userTriggered  = "USER_TRIGGERED"  // Explicit user action
    case modelRequested = "MODEL_REQUESTED" // Agent or model made the request
    case systemEvent    = "SYSTEM_EVENT"    // App lifecycle or network event
    case backgroundJob  = "BACKGROUND_JOB" // Scheduled or queued background work
    case contextual     = "CONTEXTUAL"      // Context policy drove the call
}

// MARK: - ExternalCallVisualState
// The display state for a service or call in the boundary capacity view.

public enum ExternalCallVisualState: String, Codable, Sendable, Equatable, CaseIterable {
    case available  = "AVAILABLE"   // Idle, can be used
    case active     = "ACTIVE"      // Call currently running
    case waiting    = "WAITING"     // Queued or pending approval
    case complete   = "COMPLETE"    // Finished with receipt
    case failed     = "FAILED"      // Errored
    case held       = "HELD"        // Blocked by policy or context
    case cancelled  = "CANCELLED"   // Stopped intentionally
    case unknown    = "UNKNOWN"
}

// MARK: - ExternalServiceCapabilitySnapshot
// Per-service snapshot answering: what is this service, what can it do, and what is it doing now?
// This is a contract type only — no transport, no runtime services.

public struct ExternalServiceCapabilitySnapshot: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let serviceID: String
    public let serviceName: String
    public let provider: String
    public let category: ExternalServiceCategory
    public let brandIconName: String?       // SF Symbol or asset catalog name — no runtime resolution here
    public let authIdentity: String?        // Display-safe label only; no credentials stored

    public let state: ExternalServiceState
    public let isAvailable: Bool
    public let isEnabled: Bool
    public let isAllowedInContext: Bool
    public let isActive: Bool

    public let accessTypes: [ServiceAccessType]
    public let allowedActions: [ServiceAccessType]
    public let resourceScope: String?
    public let currentAction: ServiceAccessType?
    public let currentTrigger: ServiceCallTrigger?

    public let backgroundAllowed: Bool
    public let writeAllowed: Bool
    public let executeAllowed: Bool
    public let streamingAllowed: Bool
    public let approvalRequired: Bool

    public let timeoutSeconds: Double?
    public let rateLimitPerMinute: Int?

    public let lastCallID: String?
    public let lastReceiptID: String?
    public let holdReasons: [SemanticHoldReason]
    public let visualState: ExternalCallVisualState
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        serviceID: String,
        serviceName: String,
        provider: String,
        category: ExternalServiceCategory,
        brandIconName: String? = nil,
        authIdentity: String? = nil,
        state: ExternalServiceState,
        isAvailable: Bool,
        isEnabled: Bool,
        isAllowedInContext: Bool,
        isActive: Bool,
        accessTypes: [ServiceAccessType],
        allowedActions: [ServiceAccessType],
        resourceScope: String? = nil,
        currentAction: ServiceAccessType? = nil,
        currentTrigger: ServiceCallTrigger? = nil,
        backgroundAllowed: Bool = false,
        writeAllowed: Bool = false,
        executeAllowed: Bool = false,
        streamingAllowed: Bool = false,
        approvalRequired: Bool = true,
        timeoutSeconds: Double? = nil,
        rateLimitPerMinute: Int? = nil,
        lastCallID: String? = nil,
        lastReceiptID: String? = nil,
        holdReasons: [SemanticHoldReason] = [],
        visualState: ExternalCallVisualState,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.serviceID = serviceID
        self.serviceName = serviceName
        self.provider = provider
        self.category = category
        self.brandIconName = brandIconName
        self.authIdentity = authIdentity
        self.state = state
        self.isAvailable = isAvailable
        self.isEnabled = isEnabled
        self.isAllowedInContext = isAllowedInContext
        self.isActive = isActive
        self.accessTypes = accessTypes
        self.allowedActions = allowedActions
        self.resourceScope = resourceScope
        self.currentAction = currentAction
        self.currentTrigger = currentTrigger
        self.backgroundAllowed = backgroundAllowed
        self.writeAllowed = writeAllowed
        self.executeAllowed = executeAllowed
        self.streamingAllowed = streamingAllowed
        self.approvalRequired = approvalRequired
        self.timeoutSeconds = timeoutSeconds
        self.rateLimitPerMinute = rateLimitPerMinute
        self.lastCallID = lastCallID
        self.lastReceiptID = lastReceiptID
        self.holdReasons = holdReasons
        self.visualState = visualState
        self.timestamp = timestamp
    }
}
