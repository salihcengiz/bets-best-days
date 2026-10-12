import SwiftUI

/// Content of the countdowns screen, in one scrolling column:
/// - regular day: days together, then the two countdown cards (closest first)
/// - special day: celebration cards in place of the countdowns, then days together
/// The header and footer come from the root view; the playlist has its own section.
struct HomeView: View {
    /// Fixed moment for previews. In the app this is nil and the screen ticks every second.
    var fixedNow: Date? = nil

    var body: some View {
        if let fixedNow {
            HomeContent(now: fixedNow)
        } else {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                HomeContent(now: context.date)
            }
        }
    }
}

private struct HomeContent: View {
    let now: Date

    @Environment(DataStore.self) private var store

    var body: some View {
        let specialDays = DateLogic.specialDays(on: now)

        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                if specialDays.isEmpty {
                    togetherSection
                    divider
                    countdownSections
                } else {
                    CelebrationView(days: specialDays, now: now)
                    divider
                    togetherSection
                }
            }
            .padding(Theme.spacingL)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.background)
    }

    /// Both countdown cards, stacked; their equal columns line up.
    private var countdownSections: some View {
        VStack(spacing: Theme.spacingM) {
            ForEach(countdowns, id: \.title) { item in
                CountdownView(
                    title: item.title,
                    countdown: DateLogic.countdown(from: now, to: item.date),
                    dateText: DateLogic.longDateText(item.date)
                )
            }
        }
    }

    // MARK: - Sections

    /// Heading, the screen's single large number (days together) and the breakdown.
    private var togetherSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text("Birlikte")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)

            HStack(alignment: .firstTextBaseline, spacing: Theme.spacingS) {
                Text("\(DateLogic.daysTogether(now))")
                    .font(Theme.countdownFont(size: 64))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("gün")
                    .font(Theme.headlineFont)
            }
            .foregroundStyle(Theme.accent)

            Text(DateLogic.breakdownText(DateLogic.togetherBreakdown(now)))
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.separator)
            .frame(height: Theme.borderWidth)
    }

    // MARK: - Data

    /// Birthday and anniversary countdowns, the closest one first.
    private var countdowns: [(title: String, date: Date)] {
        let birthday = DateLogic.nextOccurrence(of: store.birthDate, from: now)
        let anniversary = DateLogic.nextOccurrence(of: store.relationshipStart, from: now)
        let items = [
            (title: DateLogic.countdownTitle(for: .birthday, anniversaryNumber: 0), date: birthday),
            (title: DateLogic.countdownTitle(for: .anniversary,
                                             anniversaryNumber: DateLogic.anniversaryNumber(on: anniversary)),
             date: anniversary),
        ]
        return items.sorted { $0.date < $1.date }
    }
}

// MARK: - Previews
// Dates are computed from the local content file at runtime; nothing personal is written here.

#Preview("Live") {
    HomeView()
        .environment(DataStore())
}

#Preview("Live, dark") {
    HomeView()
        .environment(DataStore())
        .preferredColorScheme(.dark)
}

#Preview("On the birthday") {
    HomeView(fixedNow: DateLogic.nextBirthday(from: .now).addingTimeInterval(10 * 3600))
        .environment(DataStore())
}
