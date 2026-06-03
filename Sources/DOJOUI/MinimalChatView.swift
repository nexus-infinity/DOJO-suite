/*
 Sacred Node: ◼︎ DOJO
 Frequency: 741 Hz (Manifestation)
 Purpose: Minimal multimodal chat interface — bare-bones text input + message history.
          Inspired by Claude Desktop / ChatGPT / Gemini minimal shell.
          Used by DOJOApp as its primary conversation surface.
*/

import SwiftUI
import DOJOShared

#if os(iOS)
import UIKit
#endif

public struct MinimalChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var streamingContent: String = ""
    @FocusState private var inputFocused: Bool

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
                        if isProcessing && !streamingContent.isEmpty {
                            MinimalMessageBubble(message: ChatMessage(role: .assistant, content: streamingContent))
                                .id("streaming")
                        } else if isProcessing {
                            MinimalProcessingIndicator().transition(.opacity)
                        }
                    }
                    .padding()
                    .frame(maxWidth: 800, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation { proxy.scrollTo(lastMessage.id, anchor: .bottom) }
                    }
                }
                .onChange(of: streamingContent) { _, _ in
                    withAnimation { proxy.scrollTo("streaming", anchor: .bottom) }
                }
            }

            Divider()

            // Input area
            HStack(spacing: 12) {
                TextField("Type a message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .submitLabel(.send)
                    .lineLimit(1...6)
                    .padding(8)
                    .background(controlBackground)
                    .cornerRadius(8)
                    .focused($inputFocused)
                    .onSubmit {
                        sendMessage()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            inputFocused = true
                        }
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DOJORetryLastUserMessage"))) { _ in
            guard !isProcessing, let lastUser = messages.last(where: { $0.role == .user }) else { return }
            inputText = lastUser.content
            sendMessage()
        }
        // TODO: Benchmark module — planned (external harness evaluating Claude AI Mac app via benchmarks/packets/)
    }

    private var controlBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #elseif os(watchOS)
        return Color.gray.opacity(0.2)
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

        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif

        isProcessing = true
        streamingContent = ""
        let conversationId = UUID().uuidString

        Task {
            let client = SpinningTopClient()
            do {
                try await client.streamMessage(text, conversationId: conversationId) { token in
                    Task { @MainActor in self.streamingContent += token }
                }
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: streamingContent))
                    streamingContent = ""
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
                    streamingContent = ""
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
                Group {
                    if message.role == .assistant {
                        Text(.init(message.content))
                            .textSelection(.enabled)
                    } else {
                        Text(message.content)
                    }
                }
                .padding(12)
                .background(bubbleBackground)
                .foregroundColor(bubbleForeground)
                .cornerRadius(12)

                if message.role == .assistant && message.content.hasPrefix("Error:") {
                    Button("Retry") {
                        NotificationCenter.default.post(name: Notification.Name("DOJORetryLastUserMessage"), object: nil)
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }

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
        #elseif os(watchOS)
        return Color.gray.opacity(0.2)
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

