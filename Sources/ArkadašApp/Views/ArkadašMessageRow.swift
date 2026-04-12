import SwiftUI
import DOJOShared
import DOJOUI

struct ArkadašMessageRow: View {
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

struct ArkadašTypingIndicator: View {
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
