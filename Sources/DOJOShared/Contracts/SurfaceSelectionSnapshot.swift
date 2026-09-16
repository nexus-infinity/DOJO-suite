import Foundation

/// Read-only description of the locally selected operator surfaces.
/// This is a reporting contract only; it does not activate handoff, CarPlay,
/// Apple TV, Watch, Mac, Home, or any authority-bearing route.
public struct SurfaceSelectionSnapshot: Codable, Sendable, Equatable {
    public let selectedInputSurface: String
    public let selectedOutputSurface: String
    public let source: String
    public let isLivePolicy: Bool

    public init(
        selectedInputSurface: String = "unknown",
        selectedOutputSurface: String = "unknown",
        source: String = "unknown",
        isLivePolicy: Bool = false
    ) {
        self.selectedInputSurface = selectedInputSurface
        self.selectedOutputSurface = selectedOutputSurface
        self.source = source
        self.isLivePolicy = isLivePolicy
    }

    public static let localIOSDefault = SurfaceSelectionSnapshot(
        selectedInputSurface: "iPhone vessel / local capture surface",
        selectedOutputSurface: "iOS FIELD cockpit",
        source: "local iOS default / read-only policy",
        isLivePolicy: false
    )
}
