import Foundation

/// Pure factory for `InteractionContext`.
/// Normalizes optional heart-rate samples, then resolves output mode.
/// It does not read HealthKit, WatchConnectivity, or UI state.
public enum InteractionContextFactory {
    public static func make(
        inputMode: InputMode,
        preferredOutputMode: OutputMode? = nil,
        heartRateBPM: Double? = nil,
        heartRateVariabilityMS: Double? = nil,
        environmentState: EnvironmentState,
        activeDevice: DeviceSurface
    ) -> InteractionContext {
        let biometricState = BiometricStatePolicy.normalize(
            heartRateBPM: heartRateBPM,
            heartRateVariabilityMS: heartRateVariabilityMS
        )
        let resolvedOutputMode = OutputModePolicy.resolve(
            preferredOutputMode: preferredOutputMode,
            inputMode: inputMode,
            biometricState: biometricState,
            environmentState: environmentState
        )
        return InteractionContext(
            inputMode: inputMode,
            preferredOutputMode: preferredOutputMode,
            resolvedOutputMode: resolvedOutputMode,
            biometricState: biometricState,
            environmentState: environmentState,
            activeDevice: activeDevice
        )
    }
}
