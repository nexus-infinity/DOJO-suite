/*
 Sacred Node: ◼︎ DOJO
 Frequency: 741 Hz (Manifestation)
 Purpose: Minimal multimodal chat interface — bare-bones text input + message history.
          Inspired by Claude Desktop / ChatGPT / Gemini minimal shell.
          Used by DOJOApp as its primary conversation surface.
*/

import SwiftUI
import DOJOShared

public struct MinimalChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false

    private let aiService = AIService()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Message history
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MinimalMessageBubble(message: message)
                                .id(message.id)
                        }
                        if isProcessing {
                            MinimalProcessingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input area
            HStack(spacing: 12) {
                TextField("Type a message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...6)
                    .padding(8)
                    .background(controlBackground)
                    .cornerRadius(8)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
            }
            .padding()
        }
    }

    private var controlBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""

        isProcessing = true
        Task {
            do {
                let result = try await aiService.runModelAsync(input: TextInput(data: text))
                await MainActor.run {
                    let assistantMessage = ChatMessage(role: .assistant, content: result.output)
                    messages.append(assistantMessage)
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)")
                    messages.append(errorMessage)
                    isProcessing = false
                }
            }
        }
    }
}

// MARK: - Message Model

public struct ChatMessage: Identifiable {
    public let id = UUID()
    public let role: Role
    public let content: String
    public let timestamp = Date()

    public enum Role {
        case user
        case assistant
    }
}

// MARK: - Message Bubble

struct MinimalMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(bubbleBackground)
                    .foregroundColor(bubbleForeground)
                    .cornerRadius(12)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.role == .assistant { Spacer() }
        }
    }

    private var bubbleBackground: Color {
        message.role == .user ? Color.accentColor : controlBg
    }

    private var bubbleForeground: Color {
        message.role == .user ? .white : .primary
    }

    private var controlBg: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
}

// MARK: - Processing Indicator

struct MinimalProcessingIndicator: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(opacity)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: opacity
                    )
            }
        }
        .padding(12)
        .onAppear { opacity = 1.0 }
    }
}

// MARK: - Preview

#if DEBUG
struct MinimalChatView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalChatView()
            .frame(width: 600, height: 800)
    }
}
#endif
