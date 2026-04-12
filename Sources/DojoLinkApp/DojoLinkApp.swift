import SwiftUI
import DOJOShared
import DOJOUI

// ◼︎ DojoLink · 741 Hz · Manifestation Channel

// ── Entry ─────────────────────────────────────────────────────────────────────

@main
struct DojoLinkApp: App {
    var body: some Scene {
        WindowGroup {
            DojoLinkMainView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 440, height: 720)
    }
}

// ── Main view ─────────────────────────────────────────────────────────────────

@MainActor
struct DojoLinkMainView: View {
    @State private var messages: [LinkMessage] = []
    @State private var inputText = ""
    @State private var isProcessing = false
    @State private var isOnline = false
    @State private var conversationId = UUID().uuidString

    private let client = SpinningTopClient()

    var body: some View {
        VStack(spacing: 0) {
            header
            messageList
            inputBar
        }
        .frame(minWidth: 360, minHeight: 500)
        .background(FieldPalette.void)
        .preferredColorScheme(.dark)
        .task { isOnline = (try? await client.healthCheck()) ?? false }
    }

    // ── Header ────────────────────────────────────────────────────────────────

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Chamber.dojo.color.opacity(isOnline ? 0.12 : 0.04))
                    .frame(width: 34, height: 34)
                    .blur(radius: 5)
                Text("◼︎")
                    .font(.system(size: 16))
                    .foregroundStyle(Chamber.dojo.color)
                    .shadow(color: isOnline ? Chamber.dojo.glowColor : .clear, radius: 6)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("DOJO")
                    .font(FieldType.title)
                    .foregroundStyle(FieldPalette.textPrimary)
                Text("741 Hz · Manifestation")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
            }
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(isOnline ? Chamber.dojo.color : Color(hex: "#EF4444"))
                    .shadow(color: isOnline ? Chamber.dojo.glowColor : .clear, radius: 4)
                Text(isOnline ? "LIVE" : "OFFLINE")
                    .font(FieldType.badge)
                    .foregroundStyle(isOnline ? Chamber.dojo.color : FieldPalette.textMuted)
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(FieldPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(FieldPalette.border, lineWidth: 1))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(FieldPalette.surface.opacity(0.95))
        .overlay(alignment: .bottom) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
    }

    // ── Message list ──────────────────────────────────────────────────────────

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(messages) { msg in
                            LinkMessageRow(message: msg).id(msg.id)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: messages.last?.content) { _, _ in
                if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Chamber.dojo.color.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .blur(radius: 12)
                Text("◼︎")
                    .font(.system(size: 38))
                    .foregroundStyle(Chamber.dojo.color.opacity(0.45))
            }
            Text("DOJO · 741 Hz")
                .font(FieldType.title)
                .foregroundStyle(FieldPalette.textDim)
            Text("Manifestation channel.\nBegin when ready.")
                .font(FieldType.chronicle)
                .foregroundStyle(FieldPalette.textDim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    // ── Input bar ─────────────────────────────────────────────────────────────

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Message DOJO…", text: $inputText, axis: .vertical)
                .font(FieldType.chatInput)
                .foregroundStyle(FieldPalette.textPrimary)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .onSubmit { send() }

            Button(action: send) {
                let ready = !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing
                ZStack {
                    Circle()
                        .fill(ready ? Chamber.dojo.color : FieldPalette.border)
                        .frame(width: 32, height: 32)
                        .shadow(color: ready ? Chamber.dojo.glowColor : .clear, radius: 8)
                    if isProcessing {
                        ProgressView().scaleEffect(0.5).tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
            .animation(.easeInOut(duration: 0.15), value: isProcessing)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(FieldPalette.surface.opacity(0.9))
        .overlay(alignment: .top) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
    }

    // ── Send ──────────────────────────────────────────────────────────────────

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        messages.append(LinkMessage(role: "user", content: text))
        inputText = ""
        isProcessing = true

        let assistantIdx = messages.count
        messages.append(LinkMessage(role: "assistant", content: "", isStreaming: true))

        Task {
            do {
                try await client.streamMessage(text, conversationId: conversationId) { token in
                    Task { @MainActor in
                        guard assistantIdx < messages.count else { return }
                        messages[assistantIdx].content += token
                    }
                }
                isOnline = true
            } catch {
                guard assistantIdx < messages.count else { return }
                messages[assistantIdx].content = "◼︎ DOJO unreachable at :7410"
                isOnline = false
            }
            if assistantIdx < messages.count { messages[assistantIdx].isStreaming = false }
            isProcessing = false
        }
    }
}

// ── Message row ───────────────────────────────────────────────────────────────
