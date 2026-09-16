import Foundation

/// Read-only static pyramid map contract.
/// Names the at-rest FIELD structure without starting dynamic spinning-top
/// testing, runtime expansion, authority mutation, or app-surface behavior.
public struct PyramidAtRestMapSnapshot: Codable, Sendable, Equatable {
    public let foundation: String
    public let chambers: [String]
    public let contracts: [String]
    public let surfaces: [String]
    public let authorityCeiling: String
    public let capacityLoadState: String
    public let receiptPaths: [String]
    public let holdLine: String
    public let isDynamicTestActive: Bool
    public let authorityMutation: BoundaryAuthorityMutation

    public init(
        foundation: String,
        chambers: [String],
        contracts: [String],
        surfaces: [String],
        authorityCeiling: String,
        capacityLoadState: String,
        receiptPaths: [String],
        holdLine: String,
        isDynamicTestActive: Bool = false,
        authorityMutation: BoundaryAuthorityMutation = .none
    ) {
        self.foundation = foundation
        self.chambers = chambers
        self.contracts = contracts
        self.surfaces = surfaces
        self.authorityCeiling = authorityCeiling
        self.capacityLoadState = capacityLoadState
        self.receiptPaths = receiptPaths
        self.holdLine = holdLine
        self.isDynamicTestActive = isDynamicTestActive
        self.authorityMutation = authorityMutation
    }

    public static let v0 = PyramidAtRestMapSnapshot(
        foundation: "DOJOShared contract authority",
        chambers: [
            "FIELD",
            "DOJO",
            "Arkadas",
            "SOMA",
            "AKRON boundary"
        ],
        contracts: [
            "Packet",
            "PacketState",
            "PacketReceipt",
            "PacketRepository",
            "BoundaryCapacitySnapshot"
        ],
        surfaces: [
            "Rock / terminal back-gate verification",
            "Cursor / editor static operating board",
            "Xcode / DOJO-suite front-gate build lane",
            "Notion / traffic control"
        ],
        authorityCeiling: "unknown / no live authority ceiling",
        capacityLoadState: "static pyramid finalisation / dynamic test HOLD",
        receiptPaths: [
            "local build receipt",
            "explicit AKRON receipt request only",
            "operator reconciliation"
        ],
        holdLine: "HOLD.DynamicSpinningTopTest"
    )
}
