import Foundation

/// The behind-the-scenes editor control contract.
///
/// These axes stay independent so that selecting a device, a spatial relation,
/// an augmentation channel, or a projection archetype never silently selects
/// authority on another axis.
public struct EditorMatrixSelection: Codable, Sendable, Equatable {
    public let inputChannel: InputChannel
    public let spatialRelation: SpatialRelation
    public let augmentationChannel: AugmentationChannel
    public let projectionArchetype: ProjectionArchetype
    public let attentionLevel: AttentionLevel
    public let authorityState: MatrixAuthorityState

    public init(
        inputChannel: InputChannel = .none,
        spatialRelation: SpatialRelation = .inside,
        augmentationChannel: AugmentationChannel = .sight,
        projectionArchetype: ProjectionArchetype = .copilot,
        attentionLevel: AttentionLevel = .ambient,
        authorityState: MatrixAuthorityState = .hold
    ) {
        self.inputChannel = inputChannel
        self.spatialRelation = spatialRelation
        self.augmentationChannel = augmentationChannel
        self.projectionArchetype = projectionArchetype
        self.attentionLevel = attentionLevel
        self.authorityState = authorityState
    }

    public var coordinate: String {
        [
            inputChannel.rawValue,
            spatialRelation.rawValue,
            augmentationChannel.rawValue,
            projectionArchetype.rawValue,
            attentionLevel.rawValue,
        ].joined(separator: " × ")
    }
}

public enum InputChannel: String, CaseIterable, Codable, Sendable, Identifiable {
    case none = "No live input"
    case microphone = "Microphone / audio"
    case camera = "Camera / vision"
    case location = "GPS / location"
    case motion = "Motion / IMU"
    case wearable = "Wearable / somatic"
    case deviceTelemetry = "Device telemetry"
    case environmental = "Environmental sensor"
    case manual = "Manual operator input"

    public var id: String { rawValue }
}

public enum SpatialRelation: String, CaseIterable, Codable, Sendable, Identifiable {
    case inside = "Dedans · inside"
    case overlay = "Dessus · on top"
    case substrate = "Dessous · below"
    case ambient = "Autour · all around"

    public var id: String { rawValue }
}

public enum AugmentationChannel: String, CaseIterable, Codable, Sendable, Identifiable {
    case sight = "Sight"
    case sound = "Sound"
    case touch = "Touch / haptic"

    public var id: String { rawValue }
}

public enum ProjectionArchetype: String, CaseIterable, Codable, Sendable, Identifiable {
    case coach = "Coach / cohort"
    case copilot = "Copilot / HUD"
    case training = "Training / readiness"
    case amplification = "Mech / amplification"
    case somatic = "Body / somatic"

    public var id: String { rawValue }
}

public enum AttentionLevel: String, CaseIterable, Codable, Sendable, Identifiable {
    case ambient = "0 Ambient"
    case supportive = "1 Supportive"
    case directional = "2 Directional"
    case interruptive = "3 Interruptive"
    case hold = "4 Stop / HOLD"

    public var id: String { rawValue }
}

public enum MatrixAuthorityState: String, CaseIterable, Codable, Sendable, Identifiable {
    case observed = "OBSERVED"
    case preview = "PREVIEW"
    case hold = "HOLD"
    case publishable = "PUBLISHABLE"

    public var id: String { rawValue }
}
