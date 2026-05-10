import Foundation

public struct Packet: Codable, Identifiable, Sendable, Equatable {
    public let id: UUID
    public let createdAt: Date
    public let deviceID: String
    public let operatorID: String
    public let integrityHash: String
    public let previousPacketHash: String?
    public let textNotes: String
    public let mediaRefs: [String]
    public let voiceRef: String?
    public let geoHash: String?
    public var state: PacketState
    public var retryCount: Int
    public var receipt: PacketReceipt?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        deviceID: String,
        operatorID: String,
        integrityHash: String,
        previousPacketHash: String? = nil,
        textNotes: String = "",
        mediaRefs: [String] = [],
        voiceRef: String? = nil,
        geoHash: String? = nil,
        state: PacketState = .draft,
        retryCount: Int = 0,
        receipt: PacketReceipt? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.deviceID = deviceID
        self.operatorID = operatorID
        self.integrityHash = integrityHash
        self.previousPacketHash = previousPacketHash
        self.textNotes = textNotes
        self.mediaRefs = mediaRefs
        self.voiceRef = voiceRef
        self.geoHash = geoHash
        self.state = state
        self.retryCount = retryCount
        self.receipt = receipt
    }
}
