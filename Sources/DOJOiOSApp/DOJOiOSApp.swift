import SwiftUI

@main
struct DOJOiOSApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var queue = PacketQueue()
    @StateObject private var murmur = MurmurController()

    var body: some Scene {
        WindowGroup {
            PacketListView()
                .environmentObject(queue)
                .environmentObject(murmur)
                .environmentObject(murmur.captureService)
                .task { await queue.load() }
                .preferredColorScheme(.dark)
                // Bridge: completed murmur session → FieldKit PacketQueue (voiceRef only, no text).
                .onChange(of: murmur.completedSessionRef) { _, ref in
                    guard let ref else { return }
                    Task { await queue.enqueue(textNotes: "", voiceRef: ref) }
                }
        }
        // Stop capture cleanly when app backgrounds — AVAudioEngine can't survive background.
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { murmur.stopForBackground() }
        }
    }
}
