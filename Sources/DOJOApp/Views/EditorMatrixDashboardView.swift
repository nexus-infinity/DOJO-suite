import SwiftUI
import DOJOShared
import DOJOUI

/// Behind-the-scenes control surface for composing FIELD projections.
///
/// This view controls coordinates across independent matrices. It does not
/// claim that a preview is live, publishable, or authority-bearing.
struct EditorMatrixDashboardView: View {
    @Environment(\.openWindow) private var openWindow

    @State private var inputChannel: InputChannel = .none
    @State private var spatialRelation: SpatialRelation = .inside
    @State private var augmentationChannel: AugmentationChannel = .sight
    @State private var projectionArchetype: ProjectionArchetype = .copilot
    @State private var attentionLevel: AttentionLevel = .ambient

    private var selection: EditorMatrixSelection {
        EditorMatrixSelection(
            inputChannel: inputChannel,
            spatialRelation: spatialRelation,
            augmentationChannel: augmentationChannel,
            projectionArchetype: projectionArchetype,
            attentionLevel: attentionLevel,
            authorityState: .preview
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(FieldPalette.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    truthStrip

                    matrixSection(
                        eyebrow: "01 · ACQUISITION",
                        title: "What enters the FIELD",
                        subtitle: "HAL normalises hardware. Selection does not grant authority."
                    ) {
                        choiceGrid(InputChannel.allCases, selection: $inputChannel)
                    }

                    matrixSection(
                        eyebrow: "02 · SPATIAL RELATION",
                        title: "Where the channel sits",
                        subtitle: "The four relations remain a reusable axis across every surface."
                    ) {
                        choiceGrid(SpatialRelation.allCases, selection: $spatialRelation)
                    }

                    matrixSection(
                        eyebrow: "03 · AUGMENTATION",
                        title: "How FIELD returns support",
                        subtitle: "Active channels only. Taste and smell remain HOLD."
                    ) {
                        choiceGrid(AugmentationChannel.allCases, selection: $augmentationChannel)
                    }

                    matrixSection(
                        eyebrow: "04 · PROJECTION ARCHETYPE",
                        title: "Which functional lens receives the coordinate",
                        subtitle: "Templates are projections through the matrix, not separate systems."
                    ) {
                        choiceGrid(ProjectionArchetype.allCases, selection: $projectionArchetype)
                    }

                    matrixSection(
                        eyebrow: "05 · ATTENTION CLAIM",
                        title: "How honestly the projection may interrupt",
                        subtitle: "Blend when supporting. Contrast when interrupting."
                    ) {
                        choiceGrid(AttentionLevel.allCases, selection: $attentionLevel)
                    }

                    coordinatePanel
                }
                .padding(24)
            }
        }
        .background(FieldPalette.void)
        .frame(minWidth: 980, minHeight: 720)
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("FIELD EDITOR MATRIX")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Text("One control surface · independent axes · no hidden promotion")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(FieldPalette.textMuted)
            }

            Spacer()

            Button("Open microphone channel") {
                openWindow(id: "g6-hardware-channel")
            }
            .buttonStyle(.bordered)

            Button("Open lifecycle witness") {
                openWindow(id: "cockpit-alpha")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(FieldPalette.surface)
    }

    private var truthStrip: some View {
        HStack(spacing: 10) {
            truthCell("INPUT", inputChannel.rawValue, inputChannel == .none ? .orange : .cyan)
            truthCell("RELATION", spatialRelation.rawValue, .cyan)
            truthCell("RETURN", augmentationChannel.rawValue, .purple)
            truthCell("LENS", projectionArchetype.rawValue, .purple)
            truthCell("AUTHORITY", "PREVIEW · not published", .orange)
        }
    }

    private func truthCell(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func matrixSection<Content: View>(
        eyebrow: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(Chamber.atlas.color)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(FieldPalette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(FieldPalette.textMuted)
            }

            content()
        }
        .padding(16)
        .background(FieldPalette.surface)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(FieldPalette.border, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func choiceGrid<Option: CaseIterable & Identifiable & RawRepresentable>(
        _ options: Option.AllCases,
        selection: Binding<Option>
    ) -> some View where Option.RawValue == String, Option.AllCases: RandomAccessCollection {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
            ForEach(options) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: 11, weight: selection.wrappedValue.id == option.id ? .bold : .medium))
                        .foregroundStyle(selection.wrappedValue.id == option.id ? FieldPalette.textPrimary : FieldPalette.textMuted)
                        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                        .padding(.horizontal, 10)
                        .background(selection.wrappedValue.id == option.id ? Chamber.dojo.color.opacity(0.28) : FieldPalette.surfaceRaised)
                        .overlay {
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(selection.wrappedValue.id == option.id ? Chamber.dojo.color : FieldPalette.border)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var coordinatePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT MATRIX COORDINATE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(Chamber.tata.color)
                    Text(selection.coordinate)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(FieldPalette.textPrimary)
                }
                Spacer()
                Text(inputChannel == .none ? "HOLD · choose an input" : "PREVIEW")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(inputChannel == .none ? Color.orange : Chamber.atlas.color)
            }

            Text("This coordinate is local editor state only. Publish, runtime activation and Chronicle receipt remain separate witnessed actions.")
                .font(.system(size: 11))
                .foregroundStyle(FieldPalette.textMuted)
        }
        .padding(16)
        .background(FieldPalette.surfaceRaised)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Chamber.tata.color.opacity(0.55), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
