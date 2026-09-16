import Foundation

/// Reporting pin for the landscape / place channel.
///
/// This does not activate MapKit, Core Location, CarPlay navigation,
/// ATLAS chamber UI, or any authority-bearing route.
public struct LandscapePlaceSnapshot: Codable, Sendable, Equatable {
    public let channel: String
    public let state: String
    public let placeKnown: Bool
    public let mapRuntime: Bool
    public let carPlayCollapsed: Bool
    public let authorityCeiling: String
    public let hold: String
    public let contractPath: String

    public init(
        channel: String,
        state: String,
        placeKnown: Bool,
        mapRuntime: Bool,
        carPlayCollapsed: Bool,
        authorityCeiling: String,
        hold: String,
        contractPath: String
    ) {
        self.channel = channel
        self.state = state
        self.placeKnown = placeKnown
        self.mapRuntime = mapRuntime
        self.carPlayCollapsed = carPlayCollapsed
        self.authorityCeiling = authorityCeiling
        self.hold = hold
        self.contractPath = contractPath
    }

    /// Initiation pin: the space exists and is held empty of map runtime.
    public static let v0Held = LandscapePlaceSnapshot(
        channel: "DOJO landscape / place",
        state: "HOLD.LandscapeMappingUnseated",
        placeKnown: false,
        mapRuntime: false,
        carPlayCollapsed: false,
        authorityCeiling: "Reporting pin only. Not MapKit, not vehicle nav, not CarPlay, not Today first-screen.",
        hold: "HOLD.LandscapeMappingUnseated",
        contractPath: "docs/DOJO_LANDSCAPE_PLACE_CHANNEL_CONTRACT_V0.md"
    )
}
