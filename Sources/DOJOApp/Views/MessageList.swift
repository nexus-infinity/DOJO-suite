import SwiftUI
import DOJOUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    enum Role { case user, assistant }
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
                .padding(.vertical, 8)
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
        VStack(spacing: 16) {
            Text("◼︎")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(Chamber.dojo.color.opacity(0.4))
                .shadow(color: Chamber.dojo.glowColor, radius: 20)
            Text("DOJO is listening")
                .font(.system(.title3, design: .rounded, weight: .light))
                .foregroundStyle(FieldPalette.textMuted)
            Text("741 Hz · phi4:14b")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct MessageRow: View {
    let message: ChatMessage
    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isUser { Spacer(minLength: 80) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if !isUser {
                    HStack(spacing: 6) {
                        Text("◼︎")
                            .font(.system(size: 11))
                            .foregroundStyle(Chamber.dojo.color)
                        Text("DOJO")
                            .font(.system(.caption2, design: .monospaced, weight: .medium))
                            .foregroundStyle(Chamber.dojo.color.opacity(0.8))
                    }
                }

                Text(message.content)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                    .textSelection(.enabled)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isUser
                                ? Chamber.dojo.color.opacity(0.18)
                                : FieldPalette.surface
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isUser ? Chamber.dojo.color.opacity(0.3) : FieldPalette.border,
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: isUser ? Chamber.dojo.color.opacity(0.1) : .clear, radius: 8)
            }

            if !isUser { Spacer(minLength: 80) }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}

struct ThinkingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(spacing: 6) {
                Text("◼︎")
                    .font(.system(size: 11))
                    .foregroundStyle(Chamber.dojo.color)
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Chamber.dojo.color.opacity(phase == i ? 1 : 0.3))
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(FieldPalette.surface)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(FieldPalette.border, lineWidth: 1))
            )
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
