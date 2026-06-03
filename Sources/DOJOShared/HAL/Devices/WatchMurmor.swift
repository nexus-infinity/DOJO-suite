import Foundation

/// The Watch — Pulse Node. The wrist sentinel.
/// Layer 1 sensing murmor — always on the body, always observing.
public final class WatchMurmor: DOJOMurmor {

    public let identity: MurmorIdentity

    public var profile: HALProfile {
        HALProfile(
            sense:   .full,      // Mic, accelerometer, HR, SpO2, wrist detection
            process: .minimal,   // Can run tiny models, threshold logic
            store:   .minimal,   // Limited — hours of buffer, not days
            relay:   .moderate,  // BLE to iPhone, Wi-Fi if available
            act:     .moderate   // Taptic Engine, small speaker, complication display
        )
    }

    public var localBuffer = EventBuffer(capacity: 500)
    public var lastKnownFieldState: FieldStateSnapshot = .defaultSnapshot

    public init(name: String = "Apple Watch") {
        self.identity = MurmorIdentity(
            name: name,
            deviceClass: .watch,
            profile: HALProfile(sense: .full, process: .minimal, store: .minimal, relay: .moderate, act: .moderate),
            state: .offline
        )
    }

    public func observeLocal() -> SenseEvent? {
        // Heart rate spike → SenseEvent(.heartRate, urgency: .notable)
        // Wrist raise → SenseEvent(.motion, urgency: .routine)
        // Voice detected → SenseEvent(.voiceActivity, urgency: .immediate)
        return nil
    }

    /// Rule 2: act on last known coherence — never goes dark.
    public func operateAutonomously() {
        switch lastKnownFieldState.coherenceLevel {
        case .coherent:
            break  // Silent — green complication
        case .degraded:
            break  // Yellow complication — partial field, still functional
        case .drifting:
            break  // Gentle periodic haptic — "check in when you can"
        case .breached:
            break  // Persistent amber indicator — "field needs attention"
        }
    }

    public func rejoinField(via relay: any DOJORelay) async throws -> SyncResult {
        let snapshot = localBuffer
        let result = try await relay.syncBuffer(snapshot)
        localBuffer = EventBuffer(capacity: 500)
        return result
    }
}
