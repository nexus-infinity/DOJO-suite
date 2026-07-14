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
                // Bridge: MFC-01 sealed voice object → FieldKit PacketQueue (audio path + hash).
                // voiceRef alone is not evidence; sealed object carries original + SHA-256.
                .onChange(of: murmur.lastSealedVoiceObject) { _, sealed in
                    guard let sealed else { return }
                    Task { await queue.enqueueSealedVoice(sealed) }
                }
        }
        // Stop capture cleanly when app backgrounds — AVAudioEngine can't survive background.
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { murmur.stopForBackground() }
        }
    }
}
