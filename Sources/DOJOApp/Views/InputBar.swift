import SwiftUI
import DOJOUI

struct InputBar: View {
    @Binding var input: String
    let isProcessing: Bool
    let onSend: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("", text: $input, prompt: Text("Ask DOJO anything…").foregroundColor(FieldPalette.textDim), axis: .vertical)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(FieldPalette.textPrimary)
                .tint(Chamber.dojo.color)
                .lineLimit(1...8)
                .textFieldStyle(.plain)
                .focused($focused)
                .onSubmit {
                    if !isProcessing { onSend() }
                }
                .onAppear { focused = true }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FieldPalette.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    focused ? Chamber.dojo.color.opacity(0.5) : FieldPalette.border,
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: focused ? Chamber.dojo.color.opacity(0.15) : .clear, radius: 12)
                )

            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(
                            input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing
                                ? FieldPalette.surface
                                : Chamber.dojo.color
                        )
                        .frame(width: 40, height: 40)
                        .shadow(
                            color: input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing
                                ? .clear
                                : Chamber.dojo.glowColor,
                            radius: 10
                        )
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.6)
                            .tint(FieldPalette.textMuted)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(
                                input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? FieldPalette.textDim
                                    : .white
                            )
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
            .animation(.easeInOut(duration: 0.2), value: input.isEmpty)
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
