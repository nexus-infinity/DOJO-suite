import Foundation

/// Deterministic normalization of biometric samples into shared interface state.
/// Raw sensor frameworks remain outside DOJOShared.
public enum BiometricStatePolicy {
    public static func normalize(
        heartRateBPM: Double?,
        heartRateVariabilityMS: Double?
    ) -> BiometricState {
        guard let heartRateBPM, heartRateBPM > 0 else {
            return .unknown
        }

        if let heartRateVariabilityMS, heartRateVariabilityMS > 0 {
            if heartRateBPM >= 95 && heartRateVariabilityMS <= 35 {
                return .stress
            }
            if (55...90).contains(heartRateBPM) && heartRateVariabilityMS >= 45 {
                return .steady
            }
            if (75...110).contains(heartRateBPM) && heartRateVariabilityMS >= 35 {
                return .discovery
            }
            return .unknown
        }

        if (55...90).contains(heartRateBPM) {
            return .steady
        }
        return .unknown
    }
}
