import Foundation

/// Sovereign channel identities remain distinct from the devices and services
/// that host or carry their signals.
public enum SovereignChannel: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case aikidoOptics
    case arkadas
    case hal

    public var canonicalDisplayName: String {
        switch self {
        case .aikidoOptics: "Aikidō Optics"
        case .arkadas: "Arkadaş"
        case .hal: "HAL"
        }
    }

    public var transportAlias: String {
        switch self {
        case .aikidoOptics: "aikido-optics"
        case .arkadas: "arkadas"
        case .hal: "hal"
        }
    }
}

public struct ChannelLineageRef: Codable, Equatable, Sendable {
    public let channel: SovereignChannel
    public let geometricRole: String
    public let sourceSurfaceID: String
    public let capabilityUsed: String
    public let coordinatorID: String?
    public let destinationSurfaceID: String?
    public let mappedCapabilityOwnsChannelIdentity: Bool
    public let coordinatorOwnsSourceSignal: Bool
    public let authorityEscalationAllowed: Bool

    public init(
        channel: SovereignChannel,
        geometricRole: String,
        sourceSurfaceID: String,
        capabilityUsed: String,
        coordinatorID: String? = nil,
        destinationSurfaceID: String? = nil,
        mappedCapabilityOwnsChannelIdentity: Bool = false,
        coordinatorOwnsSourceSignal: Bool = false,
        authorityEscalationAllowed: Bool = false
    ) {
        self.channel = channel
        self.geometricRole = geometricRole
        self.sourceSurfaceID = sourceSurfaceID
        self.capabilityUsed = capabilityUsed
        self.coordinatorID = coordinatorID
        self.destinationSurfaceID = destinationSurfaceID
        self.mappedCapabilityOwnsChannelIdentity = mappedCapabilityOwnsChannelIdentity
        self.coordinatorOwnsSourceSignal = coordinatorOwnsSourceSignal
        self.authorityEscalationAllowed = authorityEscalationAllowed
    }

    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if geometricRole.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("channel geometric role is empty")
        }
        if sourceSurfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("channel source surface is empty")
        }
        if capabilityUsed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("channel capability is empty")
        }
        if let coordinatorID, coordinatorID != "hal" {
            violations.append("cross-channel coordinator must be HAL")
        }
        if mappedCapabilityOwnsChannelIdentity {
            violations.append("mapped Apple capability cannot own sovereign channel identity")
        }
        if coordinatorOwnsSourceSignal {
            violations.append("HAL coordinates but cannot own the source signal")
        }
        if authorityEscalationAllowed {
            violations.append("channel lineage cannot escalate authority")
        }
        return violations
    }
}

public enum SovereignChannelLineageContract {
    public static let contractVersion = "DOJO.SovereignChannelLineage.V1"

    /// First mapped Aikidō Optics capability. The iPhone camera supplies visual
    /// evidence; it does not define Aikidō Optics or gain optical authority.
    public static let iPhone14CameraVisualLineage = ChannelLineageRef(
        channel: .aikidoOptics,
        geometricRole: "visualPatternAndSpatialRelationRecognition",
        sourceSurfaceID: "iphone14_camera",
        capabilityUsed: "cameraLensImageCapture",
        coordinatorID: "hal",
        destinationSurfaceID: "field_macos_dojo_visual_surface"
    )

    public static let arkadasAcousticLineage = ChannelLineageRef(
        channel: .arkadas,
        geometricRole: "voiceSoundListeningAndAcousticInteraction",
        sourceSurfaceID: "apple_microphone_surface",
        capabilityUsed: "microphoneAudioCapture",
        coordinatorID: "hal",
        destinationSurfaceID: "dojo_arkadas_acoustic_surface"
    )

    public static let halCoordinationLineage = ChannelLineageRef(
        channel: .hal,
        geometricRole: "timingRoutingContinuityAndCrossChannelArbitration",
        sourceSurfaceID: "hal",
        capabilityUsed: "coordinateWithoutSourceOwnership",
        coordinatorID: nil,
        destinationSurfaceID: nil
    )

    public static let all: [ChannelLineageRef] = [
        iPhone14CameraVisualLineage,
        arkadasAcousticLineage,
        halCoordinationLineage
    ]

    public static func invariantViolations() -> [String] {
        var violations = all.flatMap { $0.invariantViolations() }
        if iPhone14CameraVisualLineage.channel != .aikidoOptics {
            violations.append("visual lineage must remain Aikidō Optics")
        }
        if arkadasAcousticLineage.channel != .arkadas {
            violations.append("acoustic lineage must remain Arkadaş")
        }
        if halCoordinationLineage.channel != .hal {
            violations.append("coordination lineage must remain HAL")
        }
        if Set(all.map(\.channel)) != Set(SovereignChannel.allCases) {
            violations.append("sovereign channel identities are incomplete or collapsed")
        }
        return violations
    }
}
