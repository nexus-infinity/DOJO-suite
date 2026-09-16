import Foundation

/// The kind of environment that produced a feedback observation. This is a
/// description of the witness, not permission to act on the observation.
public enum FieldEnvironmentalFeedbackKind: String, Codable, CaseIterable, Equatable, Sendable {
    case localRuntimeHealth = "LOCAL_RUNTIME_HEALTH"
    case providerState = "PROVIDER_STATE"
    case organicDevice = "ORGANIC_DEVICE"
    case unknown = "UNKNOWN"
}

/// A receipt-bound environmental observation kept separate from the static
/// surface catalogue. The packet deliberately carries source and receipt
/// pointers rather than an interpretation or execution instruction.
public struct FieldSurfaceEnvironmentalFeedbackPacket: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let genotypeID: String
    public let surfaceID: String
    public let environmentID: String
    public let feedbackKind: FieldEnvironmentalFeedbackKind
    public let observedAt: Date
    public let sourcePointer: String
    public let observedState: String
    public let authorityCeiling: String
    public let receiptPointer: String
    public let globalFieldAuthority: Bool

    public init(
        id: String,
        genotypeID: String = FieldSurfaceCoordinationCatalog.genotypeID,
        surfaceID: String,
        environmentID: String,
        feedbackKind: FieldEnvironmentalFeedbackKind,
        observedAt: Date,
        sourcePointer: String,
        observedState: String,
        authorityCeiling: String = "OBSERVATION_ONLY",
        receiptPointer: String,
        globalFieldAuthority: Bool = false
    ) {
        self.id = id
        self.genotypeID = genotypeID
        self.surfaceID = surfaceID
        self.environmentID = environmentID
        self.feedbackKind = feedbackKind
        self.observedAt = observedAt
        self.sourcePointer = sourcePointer
        self.observedState = observedState
        self.authorityCeiling = authorityCeiling
        self.receiptPointer = receiptPointer
        self.globalFieldAuthority = globalFieldAuthority
    }

    /// Returns structural violations without promoting the observation into
    /// interpretation, execution, or global authority.
    public func invariantViolations() -> [String] {
        var violations: [String] = []
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback packet ID is empty")
        }
        if genotypeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback genotype ID is empty")
        } else if genotypeID != FieldSurfaceCoordinationCatalog.genotypeID {
            violations.append("feedback genotype drift")
        }
        if surfaceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback surface ID is empty")
        }
        if environmentID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback environment ID is empty")
        }
        if surfaceID == environmentID {
            violations.append("surface and environment are collapsed")
        }
        if sourcePointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback source pointer is empty")
        }
        if observedState.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("observed state is empty")
        }
        if authorityCeiling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback authority ceiling is empty")
        }
        if receiptPointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append("feedback receipt pointer is empty")
        }
        if globalFieldAuthority {
            violations.append("environmental feedback claims global FIELD authority")
        }
        return violations
    }
}
