import Foundation

/// User-selected or observed input lane for an interaction.
/// This is a data contract only; it does not activate capture hardware.
public enum InputMode: String, Codable, CaseIterable, Equatable, Sendable {
    case voice = "VOICE"
    case text = "TEXT"
    case visual = "VISUAL"
    case gesture = "GESTURE"
    case biometric = "BIOMETRIC"
    case unknown = "UNKNOWN"
}

/// User-visible output lane resolved by policy.
/// Input mode and output mode are deliberately independent.
public enum OutputMode: String, Codable, CaseIterable, Equatable, Sendable {
    case voice = "VOICE"
    case text = "TEXT"
    case visual = "VISUAL"
    case haptic = "HAPTIC"
    case silent = "SILENT"
    case unknown = "UNKNOWN"
}

/// Normalized body-state contract shared by surfaces.
/// Raw HealthKit samples stay in app targets; shared code sees only this state.
public enum BiometricState: String, Codable, CaseIterable, Equatable, Sendable {
    case unknown = "UNKNOWN"
    case steady = "STEADY"
    case discovery = "DISCOVERY"
    case deepWork = "DEEP_WORK"
    case stress = "STRESS"
}

/// Environmental hints that can shape output without claiming authority.
public struct EnvironmentState: Codable, Equatable, Sendable {
    public let noiseLevel: Double?
    public let isPublic: Bool
    public let isMotionActive: Bool

    public init(
        noiseLevel: Double? = nil,
        isPublic: Bool = false,
        isMotionActive: Bool = false
    ) {
        self.noiseLevel = noiseLevel.map { min(max($0, 0), 1) }
        self.isPublic = isPublic
        self.isMotionActive = isMotionActive
    }

    public static let unknown = EnvironmentState()
}

/// App-visible device surface. This is presence vocabulary, not live sync proof.
public enum DeviceSurface: String, Codable, CaseIterable, Equatable, Sendable {
    case mac = "MAC"
    case iPhone = "IPHONE"
    case iPad = "IPAD"
    case watch = "WATCH"
    case web = "WEB"
    case unknown = "UNKNOWN"
}

/// Shared interaction context binding modality, normalized biometrics,
/// environment, and active surface into one deterministic contract.
public struct InteractionContext: Codable, Equatable, Sendable {
    public var inputMode: InputMode
    public var preferredOutputMode: OutputMode?
    public var resolvedOutputMode: OutputMode
    public var biometricState: BiometricState
    public var environmentState: EnvironmentState
    public var activeDevice: DeviceSurface

    public init(
        inputMode: InputMode = .text,
        preferredOutputMode: OutputMode? = nil,
        resolvedOutputMode: OutputMode = .visual,
        biometricState: BiometricState = .unknown,
        environmentState: EnvironmentState = .unknown,
        activeDevice: DeviceSurface = .unknown
    ) {
        self.inputMode = inputMode
        self.preferredOutputMode = preferredOutputMode
        self.resolvedOutputMode = resolvedOutputMode
        self.biometricState = biometricState
        self.environmentState = environmentState
        self.activeDevice = activeDevice
    }

    public static let unknown = InteractionContext(
        inputMode: .unknown,
        preferredOutputMode: nil,
        resolvedOutputMode: .unknown,
        biometricState: .unknown,
        environmentState: .unknown,
        activeDevice: .unknown
    )
}
