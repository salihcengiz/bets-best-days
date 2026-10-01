import Foundation

/// The two yearly days the app celebrates.
nonisolated enum SpecialDay: Sendable {
    case birthday
    case anniversary
}

/// Time left until a moment, split into units for the live countdown.
nonisolated struct Countdown: Equatable, Sendable {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int

    static let zero = Countdown(days: 0, hours: 0, minutes: 0, seconds: 0)
}

/// Elapsed time split into calendar years, months and days.
nonisolated struct DateBreakdown: Equatable, Sendable {
    let years: Int
    let months: Int
    let days: Int
}

/// Every date calculation for the app and the widget.
/// Every function takes `now` as a parameter so the widget can compute future timeline entries.
/// Foundation only, so it can be tested from the command line.
nonisolated enum DateLogic {

    private static var calendar: Calendar { .app }

    // MARK: - Yearly occurrences

    /// Start of day of `date`'s month and day in `year`.
    /// Feb 29 falls back to Feb 28 in non-leap years.
    static func occurrence(of date: Date, in year: Int) -> Date {
        let parts = calendar.dateComponents([.month, .day], from: date)
        let month = parts.month ?? 1
        var day = parts.day ?? 1
        if month == 2, day == 29, !isLeapYear(year) {
            day = 28
        }
        return .day(year, month, day)
    }

    /// The next occurrence on or after today. Returns today's start if today is the day.
    static func nextOccurrence(of date: Date, from now: Date) -> Date {
        let today = calendar.startOfDay(for: now)
        let year = calendar.component(.year, from: now)
        let thisYear = occurrence(of: date, in: year)
        return thisYear >= today ? thisYear : occurrence(of: date, in: year + 1)
    }

    static func isLeapYear(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }

    // MARK: - Birthday

    static func nextBirthday(from now: Date) -> Date {
        nextOccurrence(of: BetContent.birthDate, from: now)
    }

    static func isBirthday(_ now: Date) -> Bool {
        calendar.isDate(nextBirthday(from: now), inSameDayAs: now)
    }

    // MARK: - Anniversary

    static func nextAnniversary(from now: Date) -> Date {
        nextOccurrence(of: BetContent.relationshipStart, from: now)
    }

    /// Which anniversary falls on `anniversaryDate` (1 for the first one).
    static func anniversaryNumber(on anniversaryDate: Date) -> Int {
        calendar.component(.year, from: anniversaryDate)
            - calendar.component(.year, from: BetContent.relationshipStart)
    }

    /// Number of the next (or today's) anniversary, e.g. 8 for the eighth.
    static func nextAnniversaryNumber(from now: Date) -> Int {
        anniversaryNumber(on: nextAnniversary(from: now))
    }

    /// True on the anniversary day. The relationship's start day itself does not count.
    static func isAnniversary(_ now: Date) -> Bool {
        let next = nextAnniversary(from: now)
        return calendar.isDate(next, inSameDayAs: now) && anniversaryNumber(on: next) >= 1
    }

    // MARK: - Special days

    /// Special days that fall on `now`'s date. Usually empty; both if they share a date.
    static func specialDays(on now: Date) -> [SpecialDay] {
        var days: [SpecialDay] = []
        if isBirthday(now) { days.append(.birthday) }
        if isAnniversary(now) { days.append(.anniversary) }
        return days
    }

    /// The closest upcoming special day (today counts). Birthday wins a tie.
    static func nextSpecialDay(from now: Date) -> (day: SpecialDay, date: Date) {
        let birthday = nextBirthday(from: now)
        var anniversary = nextAnniversary(from: now)
        if anniversaryNumber(on: anniversary) < 1 {
            // The relationship starts today or later: skip to its first real anniversary.
            anniversary = occurrence(of: BetContent.relationshipStart,
                                     in: calendar.component(.year, from: BetContent.relationshipStart) + 1)
        }
        return anniversary < birthday ? (.anniversary, anniversary) : (.birthday, birthday)
    }

    // MARK: - Countdown and day counts

    /// Live countdown from `now` to `target`. Zero once the target has passed.
    static func countdown(from now: Date, to target: Date) -> Countdown {
        guard target > now else { return .zero }
        let parts = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: target)
        return Countdown(days: parts.day ?? 0,
                         hours: parts.hour ?? 0,
                         minutes: parts.minute ?? 0,
                         seconds: parts.second ?? 0)
    }

    /// Calendar days from `now`'s date to `target`'s date: tomorrow is 1, today is 0.
    static func daysUntil(_ target: Date, from now: Date) -> Int {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: target)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// Days together: 0 on the start day itself.
    static func daysTogether(_ now: Date) -> Int {
        max(0, daysUntil(now, from: BetContent.relationshipStart))
    }

    /// Time together as calendar years, months and days.
    static func togetherBreakdown(_ now: Date) -> DateBreakdown {
        let start = calendar.startOfDay(for: BetContent.relationshipStart)
        let end = calendar.startOfDay(for: now)
        guard end > start else { return DateBreakdown(years: 0, months: 0, days: 0) }
        let parts = calendar.dateComponents([.year, .month, .day], from: start, to: end)
        return DateBreakdown(years: parts.year ?? 0, months: parts.month ?? 0, days: parts.day ?? 0)
    }

    // MARK: - Surprise notes

    /// A note opens at the start of its unlock day.
    static func isUnlocked(_ unlockDate: Date, now: Date) -> Bool {
        calendar.startOfDay(for: now) >= calendar.startOfDay(for: unlockDate)
    }

    // MARK: - Turkish UI text
    // These strings are shown to the user, so they stay in Turkish.
    // Phrases avoid suffixes on variable words, which would depend on vowel harmony.

    /// Countdown caption in days: today, tomorrow, or "N days left".
    static func daysLeftText(_ days: Int) -> String {
        switch days {
        case ..<1: return "Bugün"
        case 1: return "Yarın"
        default: return "\(days) gün kaldı"
        }
    }

    /// Locked-note caption: "opens tomorrow" or "opens in N days".
    static func unlocksInText(_ days: Int) -> String {
        days <= 1 ? "Yarın açılacak" : "\(days) gün sonra açılacak"
    }

    /// Years, months and days as text. Zero units are left out; "0 days" when nothing has passed.
    static func breakdownText(_ breakdown: DateBreakdown) -> String {
        var parts: [String] = []
        if breakdown.years > 0 { parts.append("\(breakdown.years) yıl") }
        if breakdown.months > 0 { parts.append("\(breakdown.months) ay") }
        if breakdown.days > 0 { parts.append("\(breakdown.days) gün") }
        return parts.isEmpty ? "0 gün" : parts.joined(separator: " ")
    }

    /// Heading above a countdown: "to your birthday" or "to our Nth anniversary".
    static func countdownTitle(for day: SpecialDay, anniversaryNumber: Int) -> String {
        switch day {
        case .birthday: return "Doğum gününe"
        case .anniversary: return "\(anniversaryNumber). yıl dönümümüze"
        }
    }

    /// Day, month, year and weekday, e.g. "13 October 2026 Tuesday" in Turkish.
    static func longDateText(_ date: Date) -> String {
        date.formatted(dateStyle.day().month(.wide).year().weekday(.wide))
    }

    /// Day and month, e.g. "13 October" in Turkish.
    static func shortDateText(_ date: Date) -> String {
        date.formatted(dateStyle.day().month(.wide))
    }

    private static var dateStyle: Date.FormatStyle {
        Date.FormatStyle(locale: Locale(identifier: "tr_TR"), calendar: calendar, timeZone: .current)
    }
}
