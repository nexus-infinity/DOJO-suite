/*
 Sacred Node: 🎭 Arkadaš Grand Gallery
 Frequencies: 717 Hz (Arkadaš / companion) · 963 Hz (Obi-Wan / observer) · 852 Hz (AI Mind / king's chamber)
 Purpose: GeometricCognitive conversation interface — digital copilot "eye in the sky".

 Design philosophy:
   - Characters DO NOT announce themselves. Visual differentiation only: glyph + color tint.
   - No "This is Arkadaš speaking", no "Roger that", no radio protocol.
   - Three voices, one continuous presence. Military precision meets ultimate AI warmth.
   - arkadaş (Turkish): friend, companion. The system IS the wise friend in the field.
*/

import SwiftUI
import DOJOShared
import DOJOUI

// MARK: - Character Visual Palette

extension GeometricCharacter {
    /// Primary color per character — used for bubbles, glyphs, presence indicators.
    var color: Color {
        switch self {
        case .arkadas: return Color(red: 0.85, green: 0.62, blue: 0.12)  // warm amber/gold
        case .obiWan:  return Color(red: 0.28, green: 0.52, blue: 0.88)  // blue/steel
        case .aiMind:  return Color(red: 0.18, green: 0.72, blue: 0.50)  // cool green
        }
    }

    var subtleBackground: Color { color.opacity(0.10) }
    var activePulseColor: Color  { color.opacity(0.35) }
    var borderColor: Color       { color.opacity(0.28) }
}

// MARK: - ArkadašContentView

public struct ArkadašContentView: View {
    @StateObject private var engine = CopilotEngine()
    @State private var inputText: String = ""
    @FocusState private var inputFocused: Bool

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            presenceRow
            Divider()
            messageThread
            Divider()
            inputBar
        }
        .frame(minWidth: 560, minHeight: 500)
        .background(FieldPalette.void)
        .preferredColorScheme(.dark)
        .onAppear { inputFocused = true }
    }

    // MARK: Header

    private var headerBar: some View {
        HStack(spacing: 8) {
            Text("🎭 Arkadaš")
                .font(.system(size: 17, weight: .semibold))
            Text("•")
                .foregroundColor(.secondary)
            Text("Grand Gallery")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            if engine.dojoConnected {
                Label("DOJO", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(4)
            }
            Text("852 Hz")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.10))
                .cornerRadius(4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: Presence Row

    private var presenceRow: some View {
        HStack(spacing: 18) {
            ForEach(GeometricCharacter.allCases, id: \.rawValue) { character in
                PresenceIndicator(
                    character: character,
                    isActive: engine.activeCharacter == character
                )
            }
            Spacer()
            if !engine.dojoConnected {
                Text("local mode")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(FieldPalette.surface)
    }

    // MARK: Message Thread

    private var messageThread: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(engine.messages) { message in
                        ArkadašMessageRow(message: message)
                            .id(message.id)
                    }
                    if engine.isProcessing {
                        ArkadašTypingIndicator(character: engine.activeCharacter ?? .arkadas)
                            .id("__typing__")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .onChange(of: engine.messages.count) { _, _ in
                guard let last = engine.messages.last else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onChange(of: engine.isProcessing) { processing, _ in
                if processing {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("__typing__", anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Say something…", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .focused($inputFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(FieldPalette.surface)
                .cornerRadius(10)
                .onSubmit { sendMessage() }

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(canSend ? .accentColor : Color.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !engine.isProcessing
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !engine.isProcessing else { return }
        inputText = ""
        Task { await engine.process(input: text) }
    }
}

