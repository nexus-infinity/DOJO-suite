import SwiftUI
import DOJOShared
import DOJOUI

@main
struct DOJOApp: App {
    init() {
        let shared = DOJOShared()
        shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            DOJOMainView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 720)
    }
}

// ── Main layout ───────────────────────────────────────────────────────────────

struct DOJOMainView: View {
    @StateObject private var health = ChamberHealthMonitor()
    @State private var messages: [ChatMessage] = []
    @State private var input: String = ""
    @State private var isProcessing = false
    @State private var streamingContent = ""

    var body: some View {
        ZStack {
            // Void background
            FieldPalette.void.ignoresSafeArea()

            // Aurora glow behind everything
            AuroraLayer(health: health)

            HStack(spacing: 0) {
                // Left sidebar — chamber signals
                ChamberRail(health: health)

                // Divider
                Rectangle()
                    .fill(FieldPalette.border)
                    .frame(width: 1)

                // Main conversation surface
                VStack(spacing: 0) {
                    ConversationHeader(health: health)
                    MessageList(
                        messages: messages,
                        streamingContent: streamingContent,
                        isProcessing: isProcessing
                    )
                    InputBar(
                        input: $input,
                        isProcessing: isProcessing,
                        onSend: sendMessage
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }
        messages.append(ChatMessage(role: .user, content: text))
        input = ""
        isProcessing = true
        streamingContent = ""
        let cid = UUID().uuidString
        Task {
            let client = SpinningTopClient()
            do {
                try await client.streamMessage(text, conversationId: cid) { token in
                    Task { @MainActor in streamingContent += token }
                }
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: streamingContent))
                    streamingContent = ""
                    isProcessing = false
                }
            } catch {
                // Fallback to direct port 7410
                do {
                    let response = try await client.sendMessage(text)
                    await MainActor.run {
                        messages.append(ChatMessage(role: .assistant, content: response.response))
                        streamingContent = ""
                        isProcessing = false
                    }
                } catch {
                    await MainActor.run {
                        messages.append(ChatMessage(role: .assistant, content: "◼︎ \(error.localizedDescription)"))
                        streamingContent = ""
                        isProcessing = false
                    }
                }
            }
        }
    }
}

// Views/: AuroraLayer, ChamberRail, ConversationHeader, MessageList, InputBar
// Controllers/: ChamberHealthMonitor

