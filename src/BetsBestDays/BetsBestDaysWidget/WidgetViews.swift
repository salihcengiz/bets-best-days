import SwiftUI
import WidgetKit

// Views for the three widget kinds. Every value is computed from the entry's date
// with BetContent and DateLogic (shared with the app through target membership).
// UI strings are Turkish; the app is Turkish only.

private let turkish = Locale(identifier: "tr_TR")

// MARK: - Special day (systemSmall, accessoryCircular, accessoryInline)

/// The closest special day: days left, or a celebration on the day itself.
struct SpecialDayWidgetView: View {
    let entry: DaysEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if isLocked(entry) {
                LockedWidgetView(entry: entry)
            } else {
                content
            }
        }
        .environment(\.locale, turkish)
        .containerBackground(for: .widget) {
            isToday && !isLocked(entry) ? Theme.accent : Theme.background
        }
    }

    private var next: (day: SpecialDay, date: Date) { DateLogic.nextSpecialDay(from: entry.date) }
    private var daysLeft: Int { DateLogic.daysUntil(next.date, from: entry.date) }
    private var isToday: Bool { daysLeft == 0 }
    private var number: Int { DateLogic.anniversaryNumber(on: next.date) }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            if isToday {
                Text("Bugün")
                    .font(.system(size: 13, weight: .semibold))
                    .widgetAccentable()
            } else {
                Gauge(value: progress) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(daysLeft)").monospacedDigit()
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .widgetAccentable()
            }
        case .accessoryInline:
            Text(inlineText)
        default:
            if isToday { smallToday } else { smallCountdown }
        }
    }

    /// How far through the year we are towards the next special day (for the ring).
    private var progress: Double {
        max(0, min(1, 1 - Double(daysLeft) / 365))
    }

    private var inlineText: String {
        switch (next.day, isToday) {
        case (.birthday, true): return "Bugün doğum günün"
        case (.anniversary, true): return "Bugün \(number). yıl dönümümüz"
        case (.birthday, false): return "Doğum gününe \(daysLeft) gün"
        case (.anniversary, false): return "\(number). yıl dönümümüze \(daysLeft) gün"
        }
    }

    private var smallCountdown: some View {
        VStack(alignment: .leading, spacing: 2) {
            WidgetLabel(DateLogic.countdownTitle(for: next.day, anniversaryNumber: number))
            Spacer(minLength: 0)
            Text("\(daysLeft)")
                .font(Theme.countdownFont(size: 48))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .widgetAccentable()
            Text(daysLeft == 1 ? "gün kaldı · yarın" : "gün kaldı")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textPrimary)
            Text(DateLogic.shortDateText(next.date))
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var smallToday: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text("BUGÜN")
                .font(Theme.unitLabelFont)
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.onAccent)
            Spacer(minLength: 0)
            Text(next.day == .birthday ? "Doğum Günün Kutlu Olsun" : "\(number). Yıl Dönümümüz Kutlu Olsun")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.onAccent)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Together (systemSmall, accessoryCircular, accessoryInline)

/// Days together since the relationship started.
struct TogetherWidgetView: View {
    let entry: DaysEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if isLocked(entry) {
                LockedWidgetView(entry: entry)
            } else {
                content
            }
        }
        .environment(\.locale, turkish)
        .containerBackground(Theme.background, for: .widget)
    }

    private var days: Int { DateLogic.daysTogether(entry.date) }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("\(days)")
                        .font(.system(size: 16, weight: .semibold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .widgetAccentable()
                    Text("gün")
                        .font(.system(size: 10))
                }
                .padding(4)
            }
        case .accessoryInline:
            Text("Birlikte \(days) gün")
        default:
            VStack(alignment: .leading, spacing: 2) {
                WidgetLabel("Birlikte")
                Spacer(minLength: 0)
                Text("\(days)")
                    .font(Theme.countdownFont(size: 44))
                    .foregroundStyle(Theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .widgetAccentable()
                Text("gün")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textPrimary)
                Text(DateLogic.breakdownText(DateLogic.togetherBreakdown(entry.date)))
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Overview (systemMedium, accessoryRectangular)

/// Birthday, anniversary and days together side by side.
struct OverviewWidgetView: View {
    let entry: DaysEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if isLocked(entry) {
                LockedWidgetView(entry: entry)
            } else if family == .accessoryRectangular {
                rectangular
            } else {
                medium
            }
        }
        .environment(\.locale, turkish)
        .containerBackground(Theme.background, for: .widget)
    }

    private var birthdayDays: Int {
        DateLogic.daysUntil(DateLogic.nextBirthday(from: entry.date), from: entry.date)
    }
    private var anniversaryDays: Int {
        DateLogic.daysUntil(DateLogic.nextAnniversary(from: entry.date), from: entry.date)
    }
    private var anniversaryNumber: Int { DateLogic.nextAnniversaryNumber(from: entry.date) }
    private var togetherDays: Int { DateLogic.daysTogether(entry.date) }

    private var medium: some View {
        HStack(alignment: .top, spacing: Theme.spacingM) {
            column(DateLogic.countdownTitle(for: .birthday, anniversaryNumber: 0),
                   value: birthdayDays, isCountdown: true)
            column(DateLogic.countdownTitle(for: .anniversary, anniversaryNumber: anniversaryNumber),
                   value: anniversaryDays, isCountdown: true)
            column("Birlikte", value: togetherDays, isCountdown: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// One column: label, large number, unit. A countdown at zero reads "today".
    private func column(_ title: String, value: Int, isCountdown: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            WidgetLabel(title)
            Spacer(minLength: 0)
            Text(isCountdown && value == 0 ? "Bugün" : "\(value)")
                .font(Theme.countdownFont(size: 36))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .widgetAccentable()
            Text(isCountdown ? (value == 0 ? " " : "gün kaldı") : "gün")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            row("Doğum günü", value: birthdayDays == 0 ? "Bugün" : "\(birthdayDays) gün")
            row("\(anniversaryNumber). yıl dönümü", value: anniversaryDays == 0 ? "Bugün" : "\(anniversaryDays) gün")
            row("Birlikte", value: "\(togetherDays) gün")
        }
        .font(.system(size: 13))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer(minLength: 4)
            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
                .widgetAccentable()
        }
        .lineLimit(1)
    }
}

// MARK: - Shared pieces

/// True before the app unlocks; widgets then show only the surprise countdown.
private func isLocked(_ entry: DaysEntry) -> Bool {
    entry.date < BetContent.appUnlockDate
}

/// Shown by every widget before the app unlocks.
private struct LockedWidgetView: View {
    let entry: DaysEntry
    @Environment(\.widgetFamily) private var family

    private var whenText: String {
        DateLogic.daysLeftText(DateLogic.daysUntil(BetContent.appUnlockDate, from: entry.date))
    }

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("Sürprizin: \(whenText)")
        case .accessoryCircular:
            Text(whenText)
                .font(.system(size: 13, weight: .semibold))
                .minimumScaleFactor(0.6)
                .widgetAccentable()
        default:
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("Sürprizinin açılmasına kalan süre")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Text(whenText)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .widgetAccentable()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

/// Small uppercase gray label used at the top of widgets.
private struct WidgetLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased(with: turkish))
            .font(.system(size: 10, weight: .medium))
            .tracking(Theme.unitLabelTracking)
            .foregroundStyle(Theme.textSecondary)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }
}
