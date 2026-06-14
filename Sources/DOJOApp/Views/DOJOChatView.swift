import SwiftUI
import DOJOShared
import DOJOUI

struct DOJOChatView: View {
    @ObservedObject var health: ChamberHealthMonitor
    @StateObject private var store = ConversationStore()
    @StateObject private var micBridge = VADMicBridge()
    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var streamingContent: String = ""

    private var displayMessages: [ChatMessage] {
        store.current.messages.map { msg in
            ChatMessage(
                id: msg.id,
                role: msg.role == "user" ? .user : .assistant,
                content: msg.content
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            StatusStrip(health: health, messageCount: store.current.messages.count) {
                store.newConversation()
            }
            MessageList(messages: displayMessages, streamingContent: streamingContent, isProcessing: isProcessing)
            InputBar(
                input: $inputText,
                isProcessing: isProcessing,
                isListening: micBridge.isListening,
                onSend: sendMessage,
                onMicTap: toggleMic
            )
        }
        .background(FieldPalette.void)
        .task { await micBridge.requestAuthorization() }
        .onChange(of: micBridge.completedUtterance) { _, utterance in
            guard !utterance.isEmpty else { return }
            send(text: utterance)
        }
    }

    // MARK: - Voice

    private func toggleMic() {
        if micBridge.isListening {
            micBridge.stop()
        } else {
            guard micBridge.authorizationStatus == .authorized else { return }
            try? micBridge.start(profile: .broadcast)
        }
    }

    // MARK: - Send

    private func sendMessage() {
        let text = inputText
        inputText = ""
        send(text: text)
    }

    private func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isProcessing else { return }
        store.append(role: "user", content: trimmed)
        isProcessing = true
        streamingContent = ""
        let conversationId = store.current.id.uuidString
        Task {
            let client = SpinningTopClient()
            do {
                try await client.streamMessage(trimmed, conversationId: conversationId) { token in
                    Task { @MainActor in streamingContent += token }
                }
                await MainActor.run {
                    store.append(role: "assistant", content: streamingContent)
                    streamingContent = ""
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    store.append(role: "assistant", content: "⚠ \(error.localizedDescription)")
                    streamingContent = ""
                    isProcessing = false
                }
            }
        }
    }
}

// Layer 1: honest status — text only, color derived from real health state.
// No animation, no glow, no pill. If it says live, it is live.
private struct StatusStrip: View {
    @ObservedObject var health: ChamberHealthMonitor
    let messageCount: Int
    let onNew: () -> Void

    private var statusText: String {
        switch health.status[.dojo] {
        case .alive:    return "live"
        case .degraded: return "degraded"
        case .offline:  return "offline"
        case .unknown:  return "unknown"
        case nil:       return "connecting"
        }
    }

    private var statusColor: Color {
        switch health.status[.dojo] {
        case .alive:    return FieldPalette.textMuted
        case .degraded: return Color(hex: "#F97316").opacity(0.8)
        case .offline:  return Color(hex: "#EF4444").opacity(0.7)
        default:        return FieldPalette.textDim
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("◼︎  \(statusText)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(statusColor)
            Spacer()
            if messageCount > 0 {
                Button("new conversation") {
                    onNew()
                }
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(FieldPalette.void)
        .overlay(alignment: .bottom) {
            Rectangle().fill(FieldPalette.border.opacity(0.5)).frame(height: 1)
        }
    }
}
