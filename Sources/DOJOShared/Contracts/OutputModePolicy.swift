import Foundation

/// Pure output resolution policy for interface surfaces.
/// It makes modality explicit without performing UI, audio, haptic, or routing work.
public enum OutputModePolicy {
    private static let noisyThreshold = 0.7

    public static func resolve(
        preferredOutputMode: OutputMode?,
        inputMode: InputMode,
        biometricState: BiometricState,
        environmentState: EnvironmentState
    ) -> OutputMode {
        if let preferredOutputMode,
           isLawful(preferredOutputMode, environmentState: environmentState) {
            return preferredOutputMode
        }

        switch biometricState {
        case .deepWork:
            return .silent
        case .stress:
            return .haptic
        case .discovery:
            return environmentAllowsVoice(environmentState) ? .visual : .haptic
        case .steady, .unknown:
            break
        }

        if environmentState.isPublic {
            return .haptic
        }
        if let noiseLevel = environmentState.noiseLevel, noiseLevel > noisyThreshold {
            return .visual
        }

        switch inputMode {
        case .visual:
            return .visual
        case .gesture, .biometric:
            return .haptic
        case .voice, .text, .unknown:
            return .visual
        }
    }

    public static func isLawful(
        _ outputMode: OutputMode,
        environmentState: EnvironmentState
    ) -> Bool {
        guard outputMode == .voice else { return true }
        return environmentAllowsVoice(environmentState)
    }

    private static func environmentAllowsVoice(_ environmentState: EnvironmentState) -> Bool {
        if environmentState.isPublic { return false }
        if let noiseLevel = environmentState.noiseLevel, noiseLevel > noisyThreshold { return false }
        return true
    }
}
