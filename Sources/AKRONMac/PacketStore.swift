import Foundation
import FieldKit

@MainActor
final class PacketStore: ObservableObject {
    @Published private(set) var packets: [Packet] = []
    private let repository: any PacketRepository = PacketFileStore()

    func refresh() async {
        packets = ((try? await repository.loadAll()) ?? [])
            .sorted { $0.createdAt > $1.createdAt }
    }
}
