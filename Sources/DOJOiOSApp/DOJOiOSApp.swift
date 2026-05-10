import SwiftUI
import FieldKit

@main
struct DOJOiOSApp: App {
    @StateObject private var queue = PacketQueue()

    var body: some Scene {
        WindowGroup {
            PacketListView()
                .environmentObject(queue)
                .task { await queue.load() }
                .preferredColorScheme(.dark)
        }
    }
}
