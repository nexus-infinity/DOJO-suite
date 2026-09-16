import SwiftUI

struct AppleSurfaceMatrixCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("APPLE PORTALS")
                .font(.caption.monospaced().weight(.bold))
                .foregroundStyle(Color(hex: "#A78BFA"))

            surface("iPhone", state: "local capture")
            surface("iPad", state: "same iOS binary · named destination")
            surface("CarPlay", state: "scene seam · entitlement HOLD")

            Text("Portal surfaces only · not DOJO runtime authority")
                .font(.caption2)
                .foregroundStyle(Color(hex: "#64748B"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#111113"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#312E81"), lineWidth: 1)
        }
    }

    private func surface(_ name: LocalizedStringKey, state: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(hex: "#E2E8F0"))

            Spacer(minLength: 12)

            Text(state)
                .font(.caption)
                .foregroundStyle(Color(hex: "#94A3B8"))
                .multilineTextAlignment(.trailing)
        }
    }
}
