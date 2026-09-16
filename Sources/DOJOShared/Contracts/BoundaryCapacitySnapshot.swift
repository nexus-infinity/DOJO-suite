import Foundation

public enum BoundaryReachability: String, Codable, Sendable, Equatable {
    case yes
    case no
    case unknown
}

public enum HandoffReliability: String, Codable, Sendable, Equatable {
    case witnessed
    case intermittent
    case failed
    case unknown
}

public enum BoundaryDriveReadiness: String, Codable, Sendable, Equatable {
    case yes
    case no
    case degraded
    case unknown
}

public enum BoundaryAuthorityMutation: String, Codable, Sendable, Equatable {
    case none
}

/// Read-only capacity report for boundary/handoff state.
/// This type records observed inputs only. It must not promote packets, mutate
/// authority, claim HOME_RATIFIED, or call any AKRON receipt path.
public struct BoundaryCapacitySnapshot: Codable, Sendable, Equatable {
    public let homeReachable: BoundaryReachability
    public let queueDepth: Int
    public let lastReceiptID: String?
    public let vesselState: VesselState?
    public let murmurPendingCount: Int?
    public let selectedInputSurface: String
    public let selectedOutputSurface: String
    public let handoffAvailable: BoundaryReachability
    public let handoffReliability: HandoffReliability
    public let authorityCeiling: AuthorityLevel?
    public let holdReasons: [String]
    public let canDriveNow: BoundaryDriveReadiness
    public let authorityMutation: BoundaryAuthorityMutation

    public init(
        homeReachable: BoundaryReachability = .unknown,
        queueDepth: Int,
        lastReceiptID: String? = nil,
        vesselState: VesselState? = nil,
        murmurPendingCount: Int? = nil,
        selectedInputSurface: String = "unknown",
        selectedOutputSurface: String = "unknown",
        handoffAvailable: BoundaryReachability = .unknown,
        handoffReliability: HandoffReliability = .unknown,
        authorityCeiling: AuthorityLevel? = nil,
        holdReasons: [String] = [],
        canDriveNow: BoundaryDriveReadiness = .unknown,
        authorityMutation: BoundaryAuthorityMutation = .none
    ) {
        self.homeReachable = homeReachable
        self.queueDepth = queueDepth
        self.lastReceiptID = lastReceiptID
        self.vesselState = vesselState
        self.murmurPendingCount = murmurPendingCount
        self.selectedInputSurface = selectedInputSurface
        self.selectedOutputSurface = selectedOutputSurface
        self.handoffAvailable = handoffAvailable
        self.handoffReliability = handoffReliability
        self.authorityCeiling = authorityCeiling
        self.holdReasons = holdReasons
        self.canDriveNow = canDriveNow
        self.authorityMutation = authorityMutation
    }

    public static func observed(
        packets: [Packet],
        murmurPendingCount: Int? = nil,
        homeReachable: BoundaryReachability = .unknown,
        vesselState: VesselState? = nil,
        selectedInputSurface: String = "unknown",
        selectedOutputSurface: String = "unknown",
        handoffAvailable: BoundaryReachability = .unknown,
        handoffReliability: HandoffReliability = .unknown,
        authorityCeiling: AuthorityLevel? = nil,
        holdReasons: [String] = [],
        canDriveNow: BoundaryDriveReadiness = .unknown
    ) -> BoundaryCapacitySnapshot {
        BoundaryCapacitySnapshot(
            homeReachable: homeReachable,
            queueDepth: packets.count,
            lastReceiptID: packets.first(where: { $0.receipt != nil })?.receipt?.receiptID,
            vesselState: vesselState,
            murmurPendingCount: murmurPendingCount,
            selectedInputSurface: selectedInputSurface,
            selectedOutputSurface: selectedOutputSurface,
            handoffAvailable: handoffAvailable,
            handoffReliability: handoffReliability,
            authorityCeiling: authorityCeiling,
            holdReasons: holdReasons,
            canDriveNow: canDriveNow,
            authorityMutation: .none
        )
    }
}
