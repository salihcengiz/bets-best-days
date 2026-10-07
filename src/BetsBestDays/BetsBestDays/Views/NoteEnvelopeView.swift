import SwiftUI

/// Reading screen for an unlocked note. Plays a short envelope-opening animation
/// (about one second), then shows the letter and marks the note as read.
/// Shown inside the notes section, so the app's header and footer stay visible.
struct NoteEnvelopeView: View {
    let note: SurpriseNote
    /// Called by the back button; the parent returns to the list.
    let onClose: () -> Void

    @Environment(DataStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Phase = .closed

    /// Animation steps, in order.
    private enum Phase: Int, Comparable {
        case closed, flapOpen, letterOut, reading

        static func < (lhs: Phase, rhs: Phase) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton

            if phase == .reading {
                letter
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
            } else {
                envelope
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
        .task { await playAnimation() }
    }

    // MARK: - Back button

    private var backButton: some View {
        Button(action: onClose) {
            HStack(spacing: Theme.spacingXS) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                Text("Notlar")
                    .font(Theme.bodyFont)
            }
            .foregroundStyle(Theme.accent)
            .padding(.vertical, Theme.spacingS)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Theme.spacingL)
        .padding(.top, Theme.spacingS)
    }

    // MARK: - Envelope animation

    private let envelopeWidth: CGFloat = 280
    private let envelopeHeight: CGFloat = 180

    /// Back, letter, front pocket and flap, drawn in that order so the letter
    /// slides out from inside the envelope.
    private var envelope: some View {
        ZStack(alignment: .top) {
            envelopeShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .frame(width: envelopeWidth, height: envelopeHeight)

            letterPreview
                .offset(y: phase >= .letterOut ? -envelopeHeight * 0.55 : Theme.spacingM)

            envelopeShape(UnevenRoundedRectangle(bottomLeadingRadius: Theme.cornerRadius,
                                                 bottomTrailingRadius: Theme.cornerRadius))
                .frame(width: envelopeWidth, height: envelopeHeight * 0.6)
                .offset(y: envelopeHeight * 0.4)

            envelopeShape(FlapShape())
                .frame(width: envelopeWidth, height: envelopeHeight * 0.55)
                .rotation3DEffect(.degrees(phase >= .flapOpen ? 180 : 0),
                                  axis: (x: 1, y: 0, z: 0),
                                  anchor: .top,
                                  perspective: 0.5)
                .zIndex(phase >= .flapOpen ? -1 : 1)
        }
        .frame(width: envelopeWidth, height: envelopeHeight)
        .accessibilityHidden(true)
    }

    private func envelopeShape<S: Shape>(_ shape: S) -> some View {
        shape
            .fill(Theme.surface)
            .overlay(shape.stroke(Theme.separator, lineWidth: Theme.borderWidth))
    }

    /// The letter while it is still in or leaving the envelope.
    private var letterPreview: some View {
        Text(note.title)
            .font(Theme.headlineFont)
            .foregroundStyle(Theme.textPrimary)
            .lineLimit(2)
            .padding(Theme.spacingM)
            .frame(width: envelopeWidth - Theme.spacingXL, height: envelopeHeight - Theme.spacingM,
                   alignment: .topLeading)
            .background(Theme.background, in: RoundedRectangle(cornerRadius: Theme.cornerRadius - 4))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius - 4)
                    .stroke(Theme.separator, lineWidth: Theme.borderWidth)
            )
    }

    private func playAnimation() async {
        guard phase == .closed else { return }
        if reduceMotion {
            phase = .reading
            store.markRead(note)
            return
        }
        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeInOut(duration: 0.35)) { phase = .flapOpen }
        try? await Task.sleep(for: .milliseconds(350))
        withAnimation(.easeOut(duration: 0.35)) { phase = .letterOut }
        try? await Task.sleep(for: .milliseconds(450))
        withAnimation(.easeInOut(duration: 0.3)) { phase = .reading }
        store.markRead(note)
    }

    // MARK: - Letter

    /// The open letter: unlock date, title and full text.
    private var letter: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text(("Açılış: " + DateLogic.shortDateText(note.unlockDate))
                        .uppercased(with: Locale(identifier: "tr_TR")))
                    .font(Theme.unitLabelFont)
                    .tracking(Theme.unitLabelTracking)
                    .foregroundStyle(Theme.textSecondary)

                Text(note.title)
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(note.body)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textPrimary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Theme.spacingL)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.separator, lineWidth: Theme.borderWidth)
            )
            .padding(Theme.spacingL)
        }
    }
}

/// Triangular envelope flap pointing down from the top edge.
private struct FlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews
// Placeholder note; real notes come from the local content file.

private let previewNote = SurpriseNote(
    id: UUID(),
    unlockDate: .now,
    title: "Note title",
    body: "Note text. A few sentences to see how the letter wraps across lines on the screen."
)

#Preview("Light") {
    NoteEnvelopeView(note: previewNote, onClose: {})
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview")!))
}

#Preview("Dark") {
    NoteEnvelopeView(note: previewNote, onClose: {})
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview")!))
        .preferredColorScheme(.dark)
}
