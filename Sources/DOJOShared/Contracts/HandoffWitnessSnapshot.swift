import Foundation

/// Read-only handoff witness contract stub.
/// This does not activate WatchConnectivity, Continuity, MultipeerConnectivity,
/// Mac, Watch, CarPlay, Apple TV, transport, or AKRON paths.
public struct HandoffWitnessSnapshot: Codable, Sendable, Equatable {
    public let handoffAvailable: BoundaryReachability
    public let handoffReliability: HandoffReliability
    public let source: String
    public let isLiveWitness: Bool

    public init(
        handoffAvailable: BoundaryReachability = .unknown,
        handoffReliability: HandoffReliability = .unknown,
        source: String = "no live handoff witness / contract stub",
        isLiveWitness: Bool = false
    ) {
        self.handoffAvailable = handoffAvailable
        self.handoffReliability = handoffReliability
        self.source = source
        self.isLiveWitness = isLiveWitness
    }

    public static let contractStub = HandoffWitnessSnapshot()
}
