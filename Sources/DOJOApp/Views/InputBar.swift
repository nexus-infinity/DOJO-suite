import SwiftUI
import DOJOUI

struct InputBar: View {
    @Binding var input: String
    let isProcessing: Bool
    let onSend: () -> Void
    @FocusState private var focused: Bool

    private var isEmpty: Bool { input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack(alignment: .topLeading) {
                if isEmpty {
                    Text("Ask DOJO anything…")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(FieldPalette.textDim)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $input)
                    .scrollContentBackground(.hidden)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                    .tint(Chamber.dojo.color)
                    .frame(height: max(36, min(CGFloat(input.components(separatedBy: "\n").count) * 20 + 16, 120)))
                    .focused($focused)
                    .scrollIndicators(.hidden)
                    .onChange(of: input) { _, newValue in
                        if newValue.hasSuffix("\n") {
                            input = String(newValue.dropLast())
                            if !isProcessing && !isEmpty { onSend() }
                        }
                    }
                    .onAppear { focused = true }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FieldPalette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focused ? Chamber.dojo.color.opacity(0.5) : FieldPalette.border, lineWidth: 1)
                    )
                    .shadow(color: focused ? Chamber.dojo.color.opacity(0.15) : .clear, radius: 12)
            )

            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(isEmpty || isProcessing ? FieldPalette.surface : Chamber.dojo.color)
                        .frame(width: 40, height: 40)
                        .shadow(color: isEmpty || isProcessing ? .clear : Chamber.dojo.glowColor, radius: 10)
                    if isProcessing {
                        ProgressView().scaleEffect(0.6).tint(FieldPalette.textMuted)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isEmpty ? FieldPalette.textDim : .white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isEmpty || isProcessing)
            .animation(.easeInOut(duration: 0.2), value: isEmpty)
            .animation(.easeInOut(duration: 0.2), value: isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(FieldPalette.surface.opacity(0.9))
        .overlay(alignment: .top) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
    }
}
