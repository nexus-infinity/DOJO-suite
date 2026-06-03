import SwiftUI
import DOJOShared

struct DOJOChatView: View {
    @ObservedObject var health: ChamberHealthMonitor
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var streamingContent: String = ""

    var body: some View {
        ZStack {
            AuroraLayer(health: health)

            VStack(spacing: 0) {
                ConversationHeader(health: health)
                MessageList(messages: messages, streamingContent: streamingContent, isProcessing: isProcessing)
                InputBar(input: $inputText, isProcessing: isProcessing, onSend: sendMessage)
            }
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }
        messages.append(ChatMessage(role: .user, content: text))
        inputText = ""
        isProcessing = true
        streamingContent = ""
        let conversationId = UUID().uuidString
        Task {
            let client = SpinningTopClient()
            do {
                try await client.streamMessage(text, conversationId: conversationId) { token in
                    Task { @MainActor in streamingContent += token }
                }
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: streamingContent))
                    streamingContent = ""
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: "⚠ \(error.localizedDescription)"))
                    streamingContent = ""
                    isProcessing = false
                }
            }
        }
    }
}
