import Foundation

// MARK: - Capability Declaration

/// The five questions every device must answer.
/// A device does NOT need all five — but it must declare honestly.
public enum HALCapability: String, Codable, CaseIterable {
    case sense    // Can you observe?
    case process  // Can you think?
    case store    // Can you remember?
    case relay    // Can you communicate?
    case act      // Can you output?
}

/// Strength of a given capability — not binary, but bounded.
/// This is NOT a percentage. It's a tier.
public enum CapabilityTier: Int, Codable, Comparable, Hashable {
    case none     = 0  // Cannot do this at all
    case minimal  = 1  // Threshold logic only (ESP32-class)
    case moderate = 2  // Can run lightweight models, buffer hours of data
    case full     = 3  // Can run full O₁→O₂→O₃ pipeline for this capability

    public static func < (lhs: CapabilityTier, rhs: CapabilityTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// The complete capability profile of a device.
/// This is the answer to the five HAL questions.
public struct HALProfile: Codable, Equatable, Hashable {
    public let sense: CapabilityTier
    public let process: CapabilityTier
    public let store: CapabilityTier
    public let relay: CapabilityTier
    public let act: CapabilityTier

    /// The device's strongest capability — determines its murmor class.
    public var primaryRole: HALCapability {
        let ranked: [(HALCapability, CapabilityTier)] = [
            (.sense, sense), (.process, process),
            (.store, store), (.relay, relay), (.act, act)
        ]
        return ranked.max(by: { $0.1 < $1.1 })?.0 ?? .relay
    }

    /// Dominant chamber layer — the role this device leads with.
    /// Layer 1 (Base/Observe) = Sentinel
    /// Layer 2 (Middle/Orient) = Cognitive or Relay
    /// Layer 3 (Crown/Operate) = Anchor
    public var chamberLayer: Int {
        switch primaryRole {
        case .sense:                    return 1
        case .process, .relay, .store:  return 2
        case .act:                      return 3
        }
    }

    /// All field layers this device can satisfy — a device can belong to multiple layers.
    /// This is the authoritative source for invariant checks.
    ///
    /// Layer 1: sense >= .minimal   (can observe the environment)
    /// Layer 2: process >= .moderate (can orient and make decisions)
    /// Layer 3: act >= .minimal     (can deliver output)
    public var satisfiedLayers: Set<Int> {
        var layers: Set<Int> = []
        if sense   >= .minimal  { layers.insert(1) }
        if process >= .moderate { layers.insert(2) }
        if act     >= .minimal  { layers.insert(3) }
        return layers
    }

    public init(
        sense: CapabilityTier = .none,
        process: CapabilityTier = .none,
        store: CapabilityTier = .none,
        relay: CapabilityTier = .none,
        act: CapabilityTier = .none
    ) {
        self.sense = sense
        self.process = process
        self.store = store
        self.relay = relay
        self.act = act
    }
}
