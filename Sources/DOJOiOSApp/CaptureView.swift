import SwiftUI
import FieldKit

struct CaptureView: View {
    @EnvironmentObject private var queue: PacketQueue
    @Environment(\.dismiss) private var dismiss

    @State private var notes = ""
    @State private var isCapturing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("NOTES")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(hex: "#6B7280"))
                    TextEditor(text: $notes)
                        .font(.system(.body, design: .rounded))
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(hex: "#111113"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#2D2D30"), lineWidth: 1)
                        )
                }

                Spacer()

                Button {
                    guard !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    isCapturing = true
                    let text = notes
                    Task {
                        await queue.enqueue(textNotes: text)
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isCapturing {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Text(isCapturing ? "Capturing…" : "Capture")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color(hex: "#2D2D30") : Color(hex: "#7C3AED"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCapturing)
            }
            .padding(20)
            .background(Color(hex: "#0A0A0C"))
            .navigationTitle("New Capture")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }
            }
        }
    }
}
