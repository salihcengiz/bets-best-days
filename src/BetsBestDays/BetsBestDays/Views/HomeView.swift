import SwiftUI

/// Content of the countdowns screen, in one scrolling column:
/// - regular day: days together, then the two countdown cards (closest first)
/// - special day: celebration cards in place of the countdowns, then days together
/// Until the anniversary day is picked, its card only offers the wheel.
/// The header and footer come from the root view; the playlist has its own section.
struct HomeView: View {
    /// Fixed moment for previews. In the app this is nil and the screen ticks every second.
    var fixedNow: Date? = nil

    @State private var isWheelPresented = false

    var body: some View {
        Group {
            if let fixedNow {
                HomeContent(now: fixedNow, onPickAnniversary: openWheel)
            } else {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    HomeContent(now: context.date, onPickAnniversary: openWheel)
                }
            }
        }
        .sheet(isPresented: $isWheelPresented) {
            AnniversaryWheelView()
        }
    }

    private func openWheel() {
        isWheelPresented = true
    }
}

private struct HomeContent: View {
    let now: Date
    let onPickAnniversary: () -> Void

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

    /// Countdown cards, stacked; their equal columns line up.
    /// Before the anniversary day is picked, the anniversary card is the pick card.
    private var countdownSections: some View {
        VStack(spacing: Theme.spacingM) {
            ForEach(countdowns, id: \.title) { item in
                CountdownView(
                    title: item.title,
                    countdown: DateLogic.countdown(from: now, to: item.date),
                    dateText: DateLogic.longDateText(item.date)
                )
            }
            if !store.isAnniversaryDayPicked {
                pickAnniversaryCard
            }
        }
    }

    /// Card shown in place of the anniversary countdown until the wheel is spun.
    private var pickAnniversaryCard: some View {
        Button(action: onPickAnniversary) {
            HStack {
                Text("Yıl Dönümümüzü Belirle")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: Theme.spacingS)
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.spacingL)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.separator, lineWidth: Theme.borderWidth)
            )
            .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Yıl Dönümümüzü Belirle")
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

    /// Birthday and (once picked) anniversary countdowns, the closest one first.
    private var countdowns: [(title: String, date: Date)] {
        let birthday = DateLogic.nextOccurrence(of: store.birthDate, from: now)
        var items = [(title: DateLogic.countdownTitle(for: .birthday, anniversaryNumber: 0), date: birthday)]
        if store.isAnniversaryDayPicked {
            let anniversary = DateLogic.nextOccurrence(of: store.relationshipStart, from: now)
            items.append((title: DateLogic.countdownTitle(for: .anniversary,
                                                          anniversaryNumber: DateLogic.anniversaryNumber(on: anniversary)),
                          date: anniversary))
        }
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
