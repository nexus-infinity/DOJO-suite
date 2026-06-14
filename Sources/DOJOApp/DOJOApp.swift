import SwiftUI
import AppKit
import DOJOShared

class DOJOAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let window = NSApp.windows.first(where: { $0.isVisible }) else { return }
            // orderFrontRegardless bypasses app-active check — puts DOJOApp window
            // above Xcode without needing to steal focus, so hover tracking is reachable.
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        NSApp.mainWindow?.makeKeyAndOrderFront(nil)
    }
}

@main
struct DOJOApp: App {
    @NSApplicationDelegateAdaptor(DOJOAppDelegate.self) var appDelegate
    @StateObject private var health = ChamberHealthMonitor()

    var body: some Scene {
        WindowGroup {
            DOJOChatView(health: health)
        }
        .defaultSize(width: 720, height: 600)
    }
}
