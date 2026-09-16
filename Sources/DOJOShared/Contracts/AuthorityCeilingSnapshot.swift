import Foundation

/// Read-only authority ceiling reporting stub.
/// This does not advance AuthorityLevel, mutate SealedVoiceAuthority, promote
/// packets, infer HOME_RATIFIED, or infer CANONICAL state.
public struct AuthorityCeilingSnapshot: Codable, Sendable, Equatable {
    public let authorityCeiling: AuthorityLevel?
    public let source: String
    public let isLiveAuthorityPolicy: Bool

    public init(
        authorityCeiling: AuthorityLevel? = nil,
        source: String = "no live authority ceiling / reporting stub",
        isLiveAuthorityPolicy: Bool = false
    ) {
        self.authorityCeiling = authorityCeiling
        self.source = source
        self.isLiveAuthorityPolicy = isLiveAuthorityPolicy
    }

    public static let reportingStub = AuthorityCeilingSnapshot()
}
