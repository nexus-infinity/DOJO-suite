import SwiftUI
import AppKit
import DOJOUI

struct InputBar: View {
    @Binding var input: String
    let isProcessing: Bool
    var isListening: Bool = false
    let onSend: () -> Void
    var onMicTap: (() -> Void)? = nil
    @State private var isFocused = false

    private var isEmpty: Bool { input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack(alignment: .topLeading) {
                if isEmpty {
                    Text("Message DOJO…")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(FieldPalette.textDim)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                DOJOTextInput(
                    text: $input,
                    isFocused: $isFocused,
                    isProcessing: isProcessing,
                    onSubmit: { if !isProcessing && !isEmpty { onSend() } }
                )
                .frame(height: max(36, min(CGFloat(max(1, input.components(separatedBy: "\n").count)) * 20 + 16, 120)))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FieldPalette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? Color.white.opacity(0.2) : FieldPalette.border, lineWidth: 1)
                    )
            )

            if let onMicTap {
                Button(action: onMicTap) {
                    ZStack {
                        Circle()
                            .fill(isListening ? Color(hex: "#EF4444").opacity(0.15) : FieldPalette.surface)
                            .frame(width: 40, height: 40)
                        Image(systemName: isListening ? "mic.fill" : "mic")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isListening ? Color(hex: "#EF4444") : FieldPalette.textMuted)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isProcessing)
                .animation(.easeInOut(duration: 0.15), value: isListening)
            }

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

// NSScrollView subclass: activeAlways tracking fires mouseEntered even when Xcode is front app.
// Hovering the input area activates DOJOApp so the user doesn't need to click first.
private final class DOJOScrollView: NSScrollView {
    weak var trackedTextView: NSTextView?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas { removeTrackingArea(area) }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
        if let tv = trackedTextView {
            window?.makeFirstResponder(tv)
        }
    }
}

// NSTextView subclass: tracks responder transitions and blocks text-service injection.
// Text services (Grammarly, autocorrect, substitution) hook into NSTextInputClient and
// steal first-responder ownership. Disabling them here prevents that interception.
private final class DOJOTextViewImpl: NSTextView {
    var onFocusChange: ((Bool) -> Void)?

    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok {
            print("◼︎ [INPUT] becomeFirstResponder — window key: \(window?.isKeyWindow == true)")
            onFocusChange?(true)
        }
        return ok
    }

    override func resignFirstResponder() -> Bool {
        let newFR = window?.firstResponder
        let ok = super.resignFirstResponder()
        if ok {
            print("◼︎ [INPUT] resignFirstResponder — new FR: \(type(of: newFR as AnyObject))")
            onFocusChange?(false)
        }
        return ok
    }
}

private struct DOJOTextInput: NSViewRepresentable {
    typealias NSViewType = DOJOScrollView

    @Binding var text: String
    @Binding var isFocused: Bool
    let isProcessing: Bool
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> DOJOScrollView {
        let scrollView = DOJOScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false

        let tv = DOJOTextViewImpl()
        tv.delegate = context.coordinator
        tv.isRichText = false
        tv.drawsBackground = false
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: NSFont.systemFontSize)
        tv.textColor = .white
        tv.insertionPointColor = .white
        // Disable all text substitution services — prevents Grammarly and system
        // autocorrect from injecting into the NSTextInputClient chain and stealing focus.
        tv.isAutomaticSpellingCorrectionEnabled = false
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.isAutomaticDashSubstitutionEnabled = false
        tv.isAutomaticTextReplacementEnabled = false
        tv.isAutomaticLinkDetectionEnabled = false
        tv.smartInsertDeleteEnabled = false
        tv.usesFontPanel = false
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.autoresizingMask = [.width, .height]
        tv.textContainer?.widthTracksTextView = true
        tv.textContainer?.lineFragmentPadding = 0
        tv.textContainerInset = NSSize(width: 0, height: 4)
        tv.frame = NSRect(x: 0, y: 0, width: 400, height: 36)
        tv.minSize = NSSize(width: 0, height: 20)
        tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        tv.onFocusChange = { [weak c = context.coordinator] focused in
            c?.setFocused(focused)
        }

        scrollView.documentView = tv
        scrollView.trackedTextView = tv
        context.coordinator.textView = tv

        // Initial focus attempt — works for Dock/Finder launches.
        // For Xcode launches, mouseEntered (hover) will activate without requiring a click.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.activate()
            tv.window?.makeKeyAndOrderFront(nil)
            tv.window?.makeFirstResponder(tv)
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.windowBecameKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )

        return scrollView
    }

    func updateNSView(_ scrollView: DOJOScrollView, context: Context) {
        context.coordinator.parent = self
        guard let tv = scrollView.documentView as? DOJOTextViewImpl else { return }
        // Only push SwiftUI→AppKit when clearing (after send).
        // While user is typing, AppKit is the source of truth — don't overwrite.
        if tv.string != text && text.isEmpty {
            tv.string = ""
        }
        tv.isEditable = !isProcessing
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: DOJOTextInput
        weak var textView: DOJOTextViewImpl?

        init(_ parent: DOJOTextInput) { self.parent = parent }

        func setFocused(_ focused: Bool) {
            parent.isFocused = focused
        }

        @objc func windowBecameKey(_ note: Notification) {
            guard let tv = textView else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                tv.window?.makeFirstResponder(tv)
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            let current = tv.string
            if current.hasSuffix("\n") {
                let trimmed = String(current.dropLast())
                tv.string = trimmed
                parent.text = trimmed
                parent.onSubmit()
            } else {
                parent.text = current
            }
        }

        deinit { NotificationCenter.default.removeObserver(self) }
    }
}
