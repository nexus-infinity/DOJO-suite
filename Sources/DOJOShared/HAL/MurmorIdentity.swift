import Foundation

// MARK: - Murmor Identity

/// Every murmor in the field has a unique, stable identity.
/// This is how the field knows who you are across disconnections.
public struct MurmorIdentity: Codable {
    /// Persistent UUID — survives reboots, reconnections.
    public let id: UUID

    /// Human-readable name (e.g., "JB's Mac", "Kitchen Sensor", "Wrist Pulse")
    public let name: String

    /// Device class — what kind of hardware this is
    public let deviceClass: DeviceClass

    /// The HAL profile — what this device can do
    public let profile: HALProfile

    /// When this device last successfully synced with the field
    public var lastSyncTimestamp: Date

    /// Current operational state
    public var state: MurmorState

    public init(
        id: UUID = UUID(),
        name: String,
        deviceClass: DeviceClass,
        profile: HALProfile,
        state: MurmorState = .offline
    ) {
        self.id = id
        self.name = name
        self.deviceClass = deviceClass
        self.profile = profile
        self.lastSyncTimestamp = .distantPast
        self.state = state
    }
}

// Identity equality is purely by UUID — profile and state can change.
extension MurmorIdentity: Hashable {
    public static func == (lhs: MurmorIdentity, rhs: MurmorIdentity) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Device Class

public enum DeviceClass: String, Codable {
    // Apple ecosystem
    case mac
    case iPhone
    case watch
    case homePod
    case appleTV

    // IoT nodes
    case roomSensor        // PIR, temp, humidity, light
    case doorContact       // Binary open/close
    case smartSpeaker      // Non-Apple voice output
    case lightStrip        // Ambient indicator
    case irBlaster         // Infrared relay hub
    case edgeCompute       // Raspberry Pi, Jetson, etc.
    case smartGlasses      // AR sentinel
    case biometricBand     // Heart rate, skin conductance

    // Unknown — answers HAL questions to self-classify
    case custom
}

// MARK: - Murmor State

public enum MurmorState: String, Codable {
    case active            // Online, synced, contributing to field
    case autonomous        // Online but disconnected — running on last known state (Rule 2)
    case buffering         // Collecting data locally, waiting to sync (Rule 3)
    case sleeping          // Low-power, will wake on trigger
    case offline           // Not responding
}
