import Foundation

/// A message that stays locked until `unlockDate` (start of that day, local time).
nonisolated struct SurpriseNote: Identifiable, Codable, Hashable, Sendable {
    /// Fixed UUID written in BetContent. Read state is stored against it, so never change it.
    let id: UUID
    let unlockDate: Date
    let title: String
    let body: String
}

/// A single-use coupon. Whether it has been redeemed is stored on the device, not here.
nonisolated struct Coupon: Identifiable, Codable, Hashable, Sendable {
    /// Fixed UUID written in BetContent. Redeemed state is stored against it, so never change it.
    let id: UUID
    let title: String
    let detail: String
}

// MARK: - Calendar and date helpers

nonisolated extension Calendar {
    /// The calendar used for every date calculation in the app and the widget:
    /// Gregorian, the device's current time zone, Turkish locale.
    static var app: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale = Locale(identifier: "tr_TR")
        return calendar
    }
}

nonisolated extension Date {
    /// Midnight (local time) of the given day. Keeps dates in BetContent short:
    /// `.day(2026, 10, 13)`
    static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar.app.date(from: components) else {
            preconditionFailure("Invalid date: \(year)-\(month)-\(day)")
        }
        return date
    }
}
