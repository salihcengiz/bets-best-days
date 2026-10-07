import SwiftUI

/// Content of the notes section: the list of surprise notes, and the reading screen
/// when one is opened. Locked notes show only a lock, the unlock date and the days left.
/// The header and footer come from the root view.
struct NotesView: View {
    @Environment(DataStore.self) private var store
    @State private var openNote: SurpriseNote?

    var body: some View {
        ZStack {
            if let openNote {
                NoteEnvelopeView(note: openNote) {
                    withAnimation(.easeInOut(duration: 0.25)) { self.openNote = nil }
                }
                .transition(.opacity)
            } else {
                // Re-checks once a minute so notes unlock at midnight without reopening the app.
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    list(now: context.date)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - List

    @ViewBuilder
    private func list(now: Date) -> some View {
        if store.notes.isEmpty {
            Text("Henüz not yok.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(Theme.spacingL)
        } else {
            ScrollView {
                VStack(spacing: Theme.spacingM) {
                    ForEach(store.notes) { note in
                        row(for: note, now: now)
                    }
                }
                .padding(Theme.spacingL)
            }
            .background(Theme.background)
        }
    }

    @ViewBuilder
    private func row(for note: SurpriseNote, now: Date) -> some View {
        if store.isUnlocked(note, now: now) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { openNote = note }
            } label: {
                unlockedRow(for: note)
            }
            .buttonStyle(.plain)
        } else {
            lockedRow(for: note, now: now)
        }
    }

    /// Open note: title and unlock date. Unread notes get an orange dot.
    private func unlockedRow(for note: SurpriseNote) -> some View {
        let isRead = store.isRead(note)
        return rowContainer {
            Image(systemName: isRead ? "envelope.open" : "envelope")
                .font(.system(size: 20))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                Text(isRead ? "Açılış: \(DateLogic.shortDateText(note.unlockDate))" : "Yeni not")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: Theme.spacingS)

            if !isRead {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("Okunmadı")
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    /// Locked note: no title or text, only the days left and the unlock date.
    private func lockedRow(for note: SurpriseNote, now: Date) -> some View {
        rowContainer {
            Image(systemName: "lock")
                .font(.system(size: 20))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(DateLogic.unlocksInText(DateLogic.daysUntil(note.unlockDate, from: now)))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                Text("Açılış: \(DateLogic.shortDateText(note.unlockDate))")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kilitli not")
    }

    /// Shared card styling for every row.
    private func rowContainer<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: Theme.spacingM) {
            content()
        }
        .padding(Theme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.separator, lineWidth: Theme.borderWidth)
        )
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

// MARK: - Previews
// Notes come from the local content file at runtime; nothing personal is written here.

#Preview("Light") {
    NotesView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview")!))
}

#Preview("Dark") {
    NotesView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview")!))
        .preferredColorScheme(.dark)
}
