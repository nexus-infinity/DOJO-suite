import SwiftUI
import AppKit

#if os(macOS)

// MARK: - App Delegate

@available(macOS 14.0, *)
class DOJOAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let window = NSApp.windows.first(where: { $0.isVisible }) else { return }
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        NSApp.mainWindow?.makeKeyAndOrderFront(nil)
    }
}

// MARK: - Main App

@available(macOS 14.0, *)
@main
struct DOJOApp: App {
    @NSApplicationDelegateAdaptor(DOJOAppDelegate.self) var appDelegate

    var body: some Scene {
        // G6 Hardware Gate — Audio Capture Window (Primary)
        WindowGroup("G6 Audio Capture") {
            DOJOAudioCaptureView()
        }
        .defaultSize(width: 520, height: 650)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Audio Capture") {
                    openAudioCaptureWindow()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }

        // Governor-reviewable cockpit surface — lifecycle truth state
        WindowGroup("Cockpit Alpha", id: "cockpit-alpha") {
            CockpitAlphaView()
        }
        .defaultSize(width: 600, height: 520)
    }
    
    private func openAudioCaptureWindow() {
        // Create a new window by activating the New command
        NSApp
            .sendAction(
                #selector(NSDocumentController.newDocument(_:)),
                to: nil,
                from: nil
            )
    }
}

#endif
