import SwiftUI
import FieldKit

@main struct AKRONMacApp: App {
    @StateObject private var store = PacketStore()

    var body: some Scene {
        WindowGroup("◼︎ AKRON") {
            CommandCenterView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .frame(minWidth: 820, minHeight: 520)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
    }
}
