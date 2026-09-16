import Foundation

/// Read-only home reachability contract stub.
/// This does not probe network, transport, or AKRON and does not imply
/// HOME_CONNECTED, HOME_RATIFIED, or CANONICAL state.
public struct HomeReachabilitySnapshot: Codable, Sendable, Equatable {
    public let homeReachable: BoundaryReachability
    public let source: String
    public let isLiveProbe: Bool

    public init(
        homeReachable: BoundaryReachability = .unknown,
        source: String = "no live home probe / contract stub",
        isLiveProbe: Bool = false
    ) {
        self.homeReachable = homeReachable
        self.source = source
        self.isLiveProbe = isLiveProbe
    }

    public static let contractStub = HomeReachabilitySnapshot()
}
