import Foundation

public protocol PacketRepository: Sendable {
    func save(_ packet: Packet) async throws
    func load(id: UUID) async throws -> Packet?
    func loadAll() async throws -> [Packet]
    func delete(id: UUID) async throws
}
