import Foundation

/// A Room Sensor — Environmental Sentinel.
/// The cheapest murmor that still meaningfully deepens field reliability.
/// Layer 1 sensing murmor — eyes in the space.
public final class RoomSensorMurmor: DOJOMurmor {

    public let identity: MurmorIdentity

    public var profile: HALProfile {
        HALProfile(
            sense:   .moderate,  // PIR motion, temp, humidity, light
            process: .minimal,   // ESP32-class — threshold logic only
            store:   .minimal,   // 24-hour rolling buffer
            relay:   .moderate,  // Thread mesh — always-on, low-power
            act:     .minimal    // LED indicator, optional IR blaster
        )
    }

    public var localBuffer = EventBuffer(capacity: 200)
    public var lastKnownFieldState: FieldStateSnapshot = .defaultSnapshot

    public init(name: String) {
        self.identity = MurmorIdentity(
            name: name,
            deviceClass: .roomSensor,
            profile: HALProfile(sense: .moderate, process: .minimal, store: .minimal, relay: .moderate, act: .minimal),
            state: .offline
        )
    }

    public func observeLocal() -> SenseEvent? {
        // PIR triggered → presenceChange, urgency: .notable
        // Temperature threshold crossed → temperature, urgency: .routine
        // Light level shifted significantly → light, urgency: .routine
        // ALL LOCAL. Only publishes delta. Rule 1.
        return nil
    }

    /// Rule 2: LED reflects last known coherence. The field's eyes don't close.
    public func operateAutonomously() {
        // Continues logging to local buffer
        // LED reflects lastKnownFieldState.coherenceLevel
    }

    public func rejoinField(via relay: any DOJORelay) async throws -> SyncResult {
        // Rule 3: rejoin without ceremony
        // Dumps 24hr buffer to nearest cognitive murmor
        // Receives current FieldStateSnapshot, updates LED to match
        let snapshot = localBuffer
        let result = try await relay.syncBuffer(snapshot)
        localBuffer = EventBuffer(capacity: 200)
        return result
    }
}
