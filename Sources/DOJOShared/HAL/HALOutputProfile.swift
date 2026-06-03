import Foundation

// MARK: - HAL Output Profile

/// Active audio delivery path. Single profile at a time — no simultaneous dual stream.
/// Profile switching is managed by DOJOFieldCoordinator based on device availability
/// and whether the user is in home field or organic field.
public enum HALOutputProfile: String, Codable, CaseIterable {
    case broadcast  // TV Connector → hearing aids (home field, always-on ambient)
    case intimate   // Bluetooth direct → hearing aids (mobile / personal)
    case ambient    // Bone conduction — open-ear spatial awareness
    case fallback   // System speakers — last resort
    // Future: splitField(primary:secondary:) — deliberate dual stream, not a launch requirement
}

// MARK: - Field Audio Mode

/// Coherence-driven audio behavior — determines WHAT the field does with audio,
/// independently of WHERE it routes (HALOutputProfile handles routing).
///
/// Set by DOJOFieldCoordinator on confirmed CoherenceLevel transitions.
public enum FieldAudioMode: String, Codable {
    case full        // All paths active — AI-driven speech enabled at full confidence
    case outputOnly  // Output active; ambient sensing suspended (degraded field)
                     // System speaks but with reduced environmental awareness
    case passthrough // Dampen AI output — field doesn't trust its own state (drifting)
                     // No assertive speech; passthrough/ambient audio only
    case silent      // No AI-driven output — field offline (breached)
                     // Single notification then silence
}

// MARK: - TV Connector Policy

/// How HAL handles hearing aid source priority when a phone call arrives.
/// Unitron firmware behavior is hardware-dependent — validate before picking a default.
public enum TVConnectorPolicy: String, Codable {
    case alwaysOn       // Murmors continuous; phone calls route separately via iPhone
    case deferToCall    // Murmors pause when hearing aids switch to phone stream
    case mixIfSupported // Reduce murmur volume during call if firmware allows mixing
}
