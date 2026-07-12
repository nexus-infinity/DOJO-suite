import SwiftUI

// LinkMessage is the data model for DojoLink chat messages.
struct LinkMessage: Identifiable {
    let id = UUID()
    let role: String   // "user" | "assistant"
    var content: String
    var isStreaming: Bool = false
}

struct LinkMessageRow: View {
    let message: LinkMessage

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.role == "user" { Spacer(minLength: 60) }

            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                Text(message.content.isEmpty && message.isStreaming ? " " : message.content)
                    .font(FieldType.body)
                    .foregroundStyle(FieldPalette.textPrimary)
                    .textSelection(.enabled)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(message.role == "user"
                                  ? Chamber.dojo.color.opacity(0.15)
                                  : FieldPalette.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(message.role == "user"
                                            ? Chamber.dojo.color.opacity(0.3)
                                            : FieldPalette.border, lineWidth: 1)
                            )
                    )
                if message.isStreaming {
                    LinkThinkingDots()
                }
            }

            if message.role == "assistant" { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12).padding(.vertical, 4)
    }
}

struct LinkThinkingDots: View {
    @State private var phase = 0
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundStyle(Chamber.dojo.color.opacity(phase == i ? 1 : 0.3))
                    .animation(.easeInOut(duration: 0.2), value: phase)
            }
        }
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}
