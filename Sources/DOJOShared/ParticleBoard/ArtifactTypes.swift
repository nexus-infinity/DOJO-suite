import Foundation

// MARK: - 1. ANCHOR
public struct RealityAnchor: Codable, Equatable, Sendable {
    public let hashSHA256: String
    public let timestampUTC: Date
    public let storageLocation: String
    
    public init(hashSHA256: String, timestampUTC: Date = Date(), storageLocation: String) {
        self.hashSHA256 = hashSHA256
        self.timestampUTC = timestampUTC
        self.storageLocation = storageLocation
    }
}

// MARK: - 2. O / I / R (Claim Separation)
public enum ClaimClass: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case observed = "Observed"
    case interpretation = "Interpretation"
    case recommendation = "Recommendation"
}

// MARK: - 3. TRIANGLE
public enum TriangleStatus: Codable, Equatable, Sendable {
    case resolved
    case unresolved(missingSides: [TriangleSide], acknowledgedGap: Bool)
    
    public enum TriangleSide: String, Codable, Equatable, Sendable {
        case fact, document, ledgerTime
    }
}

// MARK: - THE PAYLOAD
public struct FieldArtifact: Codable, Equatable, Sendable {
    public let anchor: RealityAnchor
    public let claimClass: ClaimClass
    public let triangle: TriangleStatus
    public let content: String
    
    public init(anchor: RealityAnchor, claimClass: ClaimClass, triangle: TriangleStatus, content: String) {
        self.anchor = anchor
        self.claimClass = claimClass
        self.triangle = triangle
        self.content = content
    }
}
