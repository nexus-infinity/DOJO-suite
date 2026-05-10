import Foundation

public enum PacketState: String, Codable, Sendable, CaseIterable, Equatable {
    case draft        = "DRAFT"
    case queued       = "QUEUED"
    case uploading    = "UPLOADING"
    case sent         = "SENT"
    case acknowledged = "ACKNOWLEDGED"
    case validated    = "VALIDATED"
    case hold         = "HOLD"
    case failed       = "FAILED"
    case retrying     = "RETRYING"
    case expired      = "EXPIRED"

    public var isTerminal: Bool {
        switch self {
        case .validated, .hold, .expired: return true
        default: return false
        }
    }

    public var isUploadable: Bool {
        switch self {
        case .queued, .retrying: return true
        default: return false
        }
    }
}
