import SwiftUI
import DOJOUI

struct ChatMessage: Identifiable {
    let id: UUID
    let role: Role
    let content: String
    enum Role { case user, assistant }

    init(id: UUID = UUID(), role: Role, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}

struct MessageList: View {
    let messages: [ChatMessage]
    let streamingContent: String
    let isProcessing: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if messages.isEmpty && !isProcessing {
                        EmptyState()
                    }
                    ForEach(messages) { msg in
                        MessageRow(message: msg).id(msg.id)
                    }
                    if isProcessing {
                        if streamingContent.isEmpty {
                            ThinkingIndicator().id("thinking")
                        } else {
                            MessageRow(
                                message: ChatMessage(role: .assistant, content: streamingContent)
                            ).id("streaming")
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: streamingContent) { _, _ in
                withAnimation(.easeOut(duration: 0.1)) {
                    proxy.scrollTo(isProcessing && streamingContent.isEmpty ? "thinking" : "streaming", anchor: .bottom)
                }
            }
        }
        .background(FieldPalette.void)
    }
}

struct EmptyState: View {
    var body: some View {
        Text("Start a conversation")
            .font(.system(.body, design: .rounded, weight: .light))
            .foregroundStyle(FieldPalette.textDim)
            .frame(maxWidth: .infinity)
            .padding(.top, 120)
    }
}

struct MessageRow: View {
    let message: ChatMessage
    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isUser { Spacer(minLength: 80) }

            Text(message.content)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(FieldPalette.textPrimary)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isUser
                            ? Color(hex: "#1E1B4B")
                            : FieldPalette.surface
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(FieldPalette.border, lineWidth: 1)
                        )
                )

            if !isUser { Spacer(minLength: 80) }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
}

struct ThinkingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(FieldPalette.textMuted.opacity(phase == i ? 1 : 0.3))
                        .frame(width: 5, height: 5)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FieldPalette.surface)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FieldPalette.border, lineWidth: 1))
            )
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
