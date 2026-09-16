import SwiftUI
import DOJOShared
import DOJOUI

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
