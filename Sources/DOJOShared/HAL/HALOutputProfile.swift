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

// MARK: - TV Connector Policy

/// How HAL handles hearing aid source priority when a phone call arrives.
/// Unitron firmware behavior is hardware-dependent — validate before picking a default.
public enum TVConnectorPolicy: String, Codable {
    case alwaysOn       // Murmors continuous; phone calls route separately via iPhone
    case deferToCall    // Murmors pause when hearing aids switch to phone stream
    case mixIfSupported // Reduce murmur volume during call if firmware allows mixing
}
