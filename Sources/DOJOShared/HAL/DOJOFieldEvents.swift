import Foundation

// MARK: - Sense Events

/// Something was observed. The universal currency of the field.
public struct SenseEvent: Codable, Identifiable {
    public let id: UUID
    public let sourceID: UUID           // Which murmor produced this
    public let timestamp: Date
    public let senseType: SenseType
    public let payload: SensePayload
    public let urgency: EventUrgency

    public init(
        id: UUID = UUID(),
        sourceID: UUID,
        senseType: SenseType,
        payload: SensePayload,
        urgency: EventUrgency
    ) {
        self.id = id
        self.sourceID = sourceID
        self.timestamp = Date()
        self.senseType = senseType
        self.payload = payload
        self.urgency = urgency
    }
}

public enum SenseType: String, Codable {
    // Physical
    case motion
    case temperature
    case humidity
    case light
    case pressure
    case contact          // door/window open/close

    // Biometric
    case heartRate
    case skinConductance
    case bloodOxygen

    // Digital
    case voiceActivity    // VAD triggered — someone is speaking
    case screenContent    // OCR/vision event
    case audioStream      // System audio captured

    // Composite
    case presenceChange   // Person entered/left a zone
    case environmentShift // Significant change in ambient conditions
}

public struct SensePayload: Codable {
    public let numericValue: Double?
    public let categoricalValue: String?
    public let metadata: [String: String]

    public init(
        numericValue: Double? = nil,
        categoricalValue: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.numericValue = numericValue
        self.categoricalValue = categoricalValue
        self.metadata = metadata
    }
}

public enum EventUrgency: Int, Codable, Comparable {
    case routine   = 0    // Batch with next sync (temperature reading)
    case notable   = 1    // Send within 30 seconds (presence change)
    case immediate = 2    // Send NOW (voice activity, security event)

    public static func < (lhs: EventUrgency, rhs: EventUrgency) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Field State

/// The field's current coherent state, distributed to all murmors.
/// This is what Rule 2 operates from when disconnected.
public struct FieldStateSnapshot: Codable {
    public let timestamp: Date
    public let coherenceLevel: CoherenceLevel
    public let activePhase: DOJOPhase
    public let activeMurmors: [UUID]
    public let lastObserverReading: ObserverReading

    public init(
        timestamp: Date = Date(),
        coherenceLevel: CoherenceLevel,
        activePhase: DOJOPhase,
        activeMurmors: [UUID] = [],
        lastObserverReading: ObserverReading = .zero
    ) {
        self.timestamp = timestamp
        self.coherenceLevel = coherenceLevel
        self.activePhase = activePhase
        self.activeMurmors = activeMurmors
        self.lastObserverReading = lastObserverReading
    }

    /// Safe starting state for devices that have never synced.
    public static var defaultSnapshot: FieldStateSnapshot {
        FieldStateSnapshot(
            timestamp: .distantPast,
            coherenceLevel: .coherent,
            activePhase: .idle
        )
    }
}

/// Observer telemetry embedded in field state — enriches every murmor's
/// local snapshot with OBI-WAN's last reading.
public struct ObserverReading: Codable {
    public let timestamp: Date
    public let alignment: Double    // 0.0–1.0
    public let phase: DOJOPhase

    public init(timestamp: Date, alignment: Double, phase: DOJOPhase) {
        self.timestamp = timestamp
        self.alignment = alignment
        self.phase = phase
    }

    public static var zero: ObserverReading {
        ObserverReading(timestamp: .distantPast, alignment: 0, phase: .idle)
    }
}

public enum CoherenceLevel: String, Codable {
    case coherent   // Green — all layers covered, field is aligned
    case degraded   // Yellow — partial coverage (can act, no dedicated sensing)
    case drifting   // Amber — field is losing alignment or missing output path
    case breached   // Red — no cognitive node, field cannot orient
}

public enum DOJOPhase: String, Codable {
    case observe    // O₁ — listening, sensing
    case orient     // O₂ — processing, routing
    case operate    // O₃ — acting, delivering
    case idle       // Between cycles
}

// MARK: - Act Commands

/// What a murmor can be asked to DO.
/// Fully enumerated — no dynamic payloads.
/// Every output is finite and enumerable.
public enum ActCommand: String, Codable, CaseIterable {
    // Visual
    case indicateCoherent
    case indicateDegraded   // Yellow — partial coverage, functional but incomplete
    case indicateDrifting
    case indicateBreached
    case indicateOff

    // Audio
    case speakResponse
    case playTone
    case silenceOutput

    // Haptic
    case pulseGround    // Grounding haptic pattern
    case pulseAlert     // Attention-needed haptic
    case pulseConfirm   // Acknowledgment haptic

    // Environmental
    case dimLights
    case brightenLights
    case adjustTemperature

    // System
    case syncNow
    case enterSleep
    case wake
}
