import SwiftUI

/// A live countdown block: a heading, four large orange numbers with small unit labels,
/// and the target date underneath. The parent view decides when it refreshes.
struct CountdownView: View {
    let title: String
    let countdown: Countdown
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text(title)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)

            HStack(alignment: .firstTextBaseline, spacing: Theme.spacingL) {
                unit(countdown.days, label: "GÜN", padded: false)
                unit(countdown.hours, label: "SAAT")
                unit(countdown.minutes, label: "DAKİKA")
                unit(countdown.seconds, label: "SANİYE")
            }

            Text(dateText)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(title): \(countdown.days) gün \(countdown.hours) saat \(countdown.minutes) dakika, \(dateText)"
        )
    }

    /// One number with its label below. Hours, minutes and seconds are always two digits.
    private func unit(_ value: Int, label: String, padded: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text(padded ? String(format: "%02d", value) : "\(value)")
                .font(Theme.countdownFont(size: 48))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(Theme.unitLabelFont)
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

// MARK: - Previews

/// Ticks every second, counting down to the next birthday from the real content.
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

#Preview("Long numbers") {
    CountdownView(
        title: DateLogic.countdownTitle(for: .anniversary, anniversaryNumber: 2),
        countdown: Countdown(days: 364, hours: 23, minutes: 59, seconds: 59),
        dateText: DateLogic.longDateText(.day(2030, 1, 1))
    )
    .padding(Theme.spacingL)
    .background(Theme.background)
}
