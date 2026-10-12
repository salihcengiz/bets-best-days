import SwiftUI

/// A live countdown card: heading, four equal-width columns (days, hours, minutes,
/// seconds) and the target date. Equal columns keep stacked countdowns aligned even
/// when one has a three-digit day count. The parent view decides when it refreshes.
struct CountdownView: View {
    let title: String
    let countdown: Countdown
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text(title)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 0) {
                unit("\(countdown.days)", label: "GÜN")
                unit(String(format: "%02d", countdown.hours), label: "SAAT")
                unit(String(format: "%02d", countdown.minutes), label: "DAKİKA")
                unit(String(format: "%02d", countdown.seconds), label: "SANİYE")
            }

            Text(dateText)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(Theme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.separator, lineWidth: Theme.borderWidth)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(title): \(countdown.days) gün \(countdown.hours) saat \(countdown.minutes) dakika, \(dateText)"
        )
    }

    /// One column: number centered over its label. All four share the width equally.
    private func unit(_ value: String, label: String) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Text(value)
                .font(Theme.countdownFont(size: 40))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(Theme.unitLabelFont)
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

/// Ticks every second, counting down to the next birthday from the local content.
private struct LiveCountdownPreview: View {
    let store = DataStore()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let target = DateLogic.nextOccurrence(of: store.birthDate, from: context.date)
            CountdownView(
                title: DateLogic.countdownTitle(for: .birthday, anniversaryNumber: 0),
                countdown: DateLogic.countdown(from: context.date, to: target),
                dateText: DateLogic.longDateText(target)
            )
        }
        .padding(Theme.spacingL)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
    }
}

#Preview("Light") {
    LiveCountdownPreview()
}

#Preview("Dark") {
    LiveCountdownPreview()
        .preferredColorScheme(.dark)
}

#Preview("Alignment: two and three digit days") {
    VStack(spacing: Theme.spacingM) {
        CountdownView(
            title: DateLogic.countdownTitle(for: .birthday, anniversaryNumber: 0),
            countdown: Countdown(days: 12, hours: 4, minutes: 5, seconds: 6),
            dateText: DateLogic.longDateText(.day(2030, 1, 1))
        )
        CountdownView(
            title: DateLogic.countdownTitle(for: .anniversary, anniversaryNumber: 2),
            countdown: Countdown(days: 364, hours: 23, minutes: 59, seconds: 59),
            dateText: DateLogic.longDateText(.day(2030, 6, 1))
        )
    }
    .padding(Theme.spacingL)
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Theme.background)
}
