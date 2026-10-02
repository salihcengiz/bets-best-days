import SwiftUI

/// Special-day block that replaces the countdowns for the whole day:
/// today's date, then one orange card per special day.
/// It is a plain block: the parent view provides scrolling, padding and background.
struct CelebrationView: View {
    /// Special days falling on `now`. Usually one; both if they share a date.
    let days: [SpecialDay]
    let now: Date

    @Environment(DataStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text(DateLogic.longDateText(now).uppercased(with: Locale(identifier: "tr_TR")))
                .font(Theme.unitLabelFont)
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.textSecondary)

            ForEach(days, id: \.self) { day in
                card(for: day)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Orange card with a heading and the personal message for one special day.
    private func card(for day: SpecialDay) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text(heading(for: day))
                .font(.system(size: 30, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)

            Text(message(for: day))
                .font(.system(size: 20, weight: .regular))
                .lineSpacing(Theme.spacingXS)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Theme.onAccent)
        .padding(Theme.spacingL)
        .padding(.vertical, Theme.spacingS)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
    }

    private func heading(for day: SpecialDay) -> String {
        switch day {
        case .birthday:
            return "Doğum Günün Kutlu Olsun"
        case .anniversary:
            return "\(DateLogic.anniversaryNumber(on: now)). Yıl Dönümümüz Kutlu Olsun"
        }
    }

    private func message(for day: SpecialDay) -> String {
        switch day {
        case .birthday: return store.birthdayMessage
        case .anniversary: return store.anniversaryMessage
        }
    }
}

// MARK: - Previews
// Messages come from the local content file at runtime; nothing personal is written here.

#Preview("Birthday") {
    CelebrationView(days: [.birthday], now: .now)
        .environment(DataStore())
        .padding(Theme.spacingL)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
}

#Preview("Both days, dark") {
    ScrollView {
        CelebrationView(days: [.birthday, .anniversary], now: .now)
            .environment(DataStore())
            .padding(Theme.spacingL)
    }
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
