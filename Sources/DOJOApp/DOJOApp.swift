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

    // Cockpit host — intentionally unsealed until manual smoke test passes
    @State private var showCockpit = false
    @StateObject private var cockpitCoordinator = DOJOFieldCoordinator(engine: CopilotEngine())
    @State private var cockpitController = ParticleBoardController()

    var body: some View {
        ZStack {
            FieldPalette.void.ignoresSafeArea()
            AuroraLayer(health: health)

            HStack(spacing: 0) {
                ChamberRail(health: health)

                Rectangle()
                    .fill(FieldPalette.border)
                    .frame(width: 1)

                VStack(spacing: 0) {
                    cockpitToggleStrip

                    if showCockpit {
                        ParticleBoardView(
                            controller: cockpitController,
                            coordinator: cockpitCoordinator
                        )
                    } else {
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
            }
        }
        .preferredColorScheme(.dark)
    }

    // A thin strip — only entry point into the cockpit surface.
    private var cockpitToggleStrip: some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                if !showCockpit && cockpitController.committedState == nil {
                    cockpitController.load(DocumentPlan(title: "Cockpit v0"))
                }
                showCockpit.toggle()
            } label: {
                Text(showCockpit ? "◉  chat" : "◼︎  cockpit")
                    .font(.system(size: 9, design: .monospaced, weight: .medium))
                    .foregroundStyle(showCockpit ? Chamber.kings.color : FieldPalette.textDim)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
            }
            .buttonStyle(.plain)
        }
        .background(FieldPalette.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
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
