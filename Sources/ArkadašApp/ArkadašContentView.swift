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

#if canImport(AppKit)
import AppKit
#endif

private enum PlatformColors {
    static var windowBackground: Color {
        #if canImport(AppKit)
        return Color(nsColor: NSColor.windowBackgroundColor)
        #elseif canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(.sRGB, red: 0.95, green: 0.95, blue: 0.95, opacity: 1)
        #endif
    }

    static var controlBackground: Color {
        #if canImport(AppKit)
        return Color(nsColor: NSColor.controlBackgroundColor)
        #elseif canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(.sRGB, red: 0.92, green: 0.92, blue: 0.92, opacity: 1)
        #endif
    }
}

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
        .background(PlatformColors.windowBackground)
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
        .background(PlatformColors.controlBackground.opacity(0.6))
    }

    // MARK: Message Thread

    private var messageThread: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(engine.messages) { message in
                        MessageRow(message: message)
                            .id(message.id)
                    }
                    if engine.isProcessing {
                        TypingIndicator(character: engine.activeCharacter ?? .arkadas)
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
                .background(PlatformColors.controlBackground)
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

// MARK: - Presence Indicator

struct PresenceIndicator: View {
    let character: GeometricCharacter
    let isActive: Bool

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(isActive ? character.activePulseColor : character.subtleBackground)
                    .frame(width: 24, height: 24)
                Text(character.glyph)
                    .font(.system(size: 12))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(character.displayName)
                    .font(.system(size: 11, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? character.color : .secondary)
                Text("\(Int(character.frequencyHz)) Hz")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}

// MARK: - Message Row

struct MessageRow: View {
    let message: ConversationMessage

    var body: some View {
        if message.isUser {
            userBubble
        } else if let character = message.character {
            characterBubble(character)
        }
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 80)
            VStack(alignment: .trailing, spacing: 3) {
                Text(message.text)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                Text(message.timestamp, style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func characterBubble(_ character: GeometricCharacter) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Glyph avatar — visual identity, NOT a verbal announcement
            Text(character.glyph)
                .font(.system(size: 12))
                .frame(width: 24, height: 24)
                .background(character.subtleBackground)
                .clipShape(Circle())
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(message.text)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(character.subtleBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(character.borderColor, lineWidth: 1)
                    )
                Text(message.timestamp, style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 60)
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    let character: GeometricCharacter
    @State private var animating = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(character.glyph)
                .font(.system(size: 12))
                .frame(width: 24, height: 24)
                .background(character.subtleBackground)
                .clipShape(Circle())

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(character.color)
                        .frame(width: 7, height: 7)
                        .opacity(animating ? 1.0 : 0.2)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.18),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(character.subtleBackground)
            .cornerRadius(16)

            Spacer()
        }
        .onAppear { animating = true }
    }
}

// MARK: - Preview

#if DEBUG
struct ArkadašContentView_Previews: PreviewProvider {
    static var previews: some View {
        ArkadašContentView()
            .frame(width: 600, height: 600)
    }
}
#endif
