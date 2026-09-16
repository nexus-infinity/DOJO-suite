import Foundation

/// Watch-shaped adapter over `InteractionContextFactory`.
/// Pins `activeDevice` to `.watch` and forwards optional BPM / HRV samples.
/// HealthKit stays in the Watch app target; this type never imports it.
public enum WatchInteractionContextAdapter {
    public static func make(
        heartRateBPM: Double?,
        heartRateVariabilityMS: Double?,
        preferredOutputMode: OutputMode? = nil,
        environmentState: EnvironmentState = .unknown
    ) -> InteractionContext {
        InteractionContextFactory.make(
            inputMode: .unknown,
            preferredOutputMode: preferredOutputMode,
            heartRateBPM: heartRateBPM,
            heartRateVariabilityMS: heartRateVariabilityMS,
            environmentState: environmentState,
            activeDevice: .watch
        )
    }
}
