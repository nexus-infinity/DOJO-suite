import SwiftUI
import Foundation

// ◼︎ DojoLink · 741 Hz · Manifestation Channel

// ── Entry ─────────────────────────────────────────────────────────────────────

@main
struct DojoLinkApp: App {
    var body: some Scene {
        WindowGroup {
            DojoLinkMainView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 440, height: 720)
        #endif
    }
}

// ── Local support ─────────────────────────────────────────────────────────────

private struct SpinningTopClient {
    private let baseURL = URL(string: "http://127.0.0.1:7410")!
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4
        configuration.timeoutIntervalForResource = 6
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }

    func healthCheck() async throws -> Bool {
        let url = baseURL.appendingPathComponent("health")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String {
            return ["operational", "healthy", "stable", "degraded"].contains(status)
        }

        return true
    }

    func streamMessage(
        _ message: String,
        conversationId: String,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws {
        let response = try await sendMessage(message, conversationId: conversationId)
        let words = response.components(separatedBy: " ")

        for (index, word) in words.enumerated() {
            onToken(index == 0 ? word : " \(word)")
            try await Task.sleep(nanoseconds: 15_000_000)
        }
    }

    private func sendMessage(_ message: String, conversationId: String) async throws -> String {
        let url = baseURL.appendingPathComponent("chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ChatRequest(userMessage: message, conversationId: conversationId))

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(ChatResponse.self, from: data).response
    }

    private struct ChatRequest: Encodable {
        let userMessage: String
        let character = "padawan"
        let conversationContext: [String]? = nil
        let conversationId: String
    }

    private struct ChatResponse: Decodable {
        let response: String
    }
}

enum Chamber {
    case dojo

    var color: Color {
        Color(hex: "#7C3AED")
    }

    var glowColor: Color {
        color.opacity(0.75)
    }
}

enum FieldPalette {
    static let void = Color(hex: "#05050A")
    static let surface = Color(hex: "#111118")
    static let border = Color(hex: "#2A2A35")
    static let textPrimary = Color(hex: "#F8FAFC")
    static let textMuted = Color(hex: "#94A3B8")
    static let textDim = Color(hex: "#64748B")
}

enum FieldType {
    static let title = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let frequency = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let badge = Font.system(size: 10, weight: .bold, design: .monospaced)
    static let chronicle = Font.system(size: 13, weight: .regular, design: .rounded)
    static let chatInput = Font.system(size: 14, weight: .regular, design: .rounded)
    static let body = Font.system(size: 14, weight: .regular, design: .rounded)
}

extension Color {
    init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rgb)

        let red: Double
        let green: Double
        let blue: Double

        switch value.count {
        case 6:
            red = Double((rgb >> 16) & 0xFF) / 255
            green = Double((rgb >> 8) & 0xFF) / 255
            blue = Double(rgb & 0xFF) / 255
        default:
            red = 1
            green = 1
            blue = 1
        }

        self.init(red: red, green: green, blue: blue)
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
            .onChange(of: messages.count) { _ in
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: messages.last?.content) { _ in
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
            TextField("Message DOJO…", text: $inputText)
                .font(FieldType.chatInput)
                .foregroundStyle(FieldPalette.textPrimary)
                .textFieldStyle(.plain)
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
