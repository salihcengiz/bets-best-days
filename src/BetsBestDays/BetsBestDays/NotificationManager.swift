import Foundation
import UserNotifications

/// Local notifications only (no push). Rebuilt from scratch every time the app comes
/// to the foreground, keeping the nearest 64: iOS ignores anything beyond that limit.
enum NotificationManager {

    /// iOS keeps at most 64 pending local notifications per app.
    static let pendingLimit = 64

    /// One notification to schedule. Kept separate from UserNotifications so the
    /// plan can be built and checked without touching the system.
    struct Plan: Equatable {
        let id: String
        let date: Date
        let title: String
        let body: String
    }

    private static var center: UNUserNotificationCenter { .current() }

    // MARK: - Permission

    /// Shows the system permission prompt (first time only). Returns whether it was granted.
    /// No badge: the red app badge would add a third color.
    @discardableResult
    static func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    // MARK: - Scheduling

    /// Removes every pending notification and schedules the nearest ones again.
    static func reschedule(store: DataStore, now: Date = .now) async {
        guard await isAuthorized() else { return }
        let plans = plan(store: store, now: now)

        center.removeAllPendingNotificationRequests()
        for item in plans {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default

            let components = Calendar.app.dateComponents([.year, .month, .day, .hour, .minute], from: item.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: item.id, content: content, trigger: trigger))
        }
        print("NotificationManager: scheduled \(plans.count) notifications")
    }

    /// Every upcoming notification, soonest first, capped at the iOS limit.
    /// - Birthday: only on the day itself, at 00:00 (this year and next).
    /// - Anniversary: 7 days and 1 day before at the configured morning time,
    ///   and on the day itself at 00:00 (this year and next).
    /// - Surprise notes: the morning they unlock.
    /// Anything already in the past is skipped.
    static func plan(store: DataStore, now: Date) -> [Plan] {
        var plans: [Plan] = []
        let calendar = Calendar.app

        // Birthday: the next occurrence and the one after it, at midnight.
        let nextBirthday = DateLogic.nextOccurrence(of: store.birthDate, from: now)
        let birthdays = [nextBirthday,
                         DateLogic.occurrence(of: store.birthDate, in: calendar.component(.year, from: nextBirthday) + 1)]
        for day in birthdays {
            plans.append(Plan(id: "birthday-\(calendar.component(.year, from: day))",
                              date: midnight(of: day),
                              title: "Doğum Günün Kutlu Olsun",
                              body: store.birthdayMessage))
        }

        // Anniversary: the next occurrence and the one after it (never the start day itself).
        let nextAnniversary = DateLogic.nextOccurrence(of: store.relationshipStart, from: now)
        let anniversaries = [nextAnniversary,
                             DateLogic.occurrence(of: store.relationshipStart,
                                                  in: calendar.component(.year, from: nextAnniversary) + 1)]
        for day in anniversaries {
            let number = DateLogic.anniversaryNumber(on: day)
            guard number >= 1 else { continue }
            let key = "anniversary-\(calendar.component(.year, from: day))"
            plans += [
                Plan(id: "\(key)-7", date: morning(of: day, daysBefore: 7),
                     title: "\(number). yıl dönümümüze 7 gün kaldı",
                     body: DateLogic.longDateText(day)),
                Plan(id: "\(key)-1", date: morning(of: day, daysBefore: 1),
                     title: "Yarın \(number). yıl dönümümüz",
                     body: "Yıl dönümümüze 1 gün kaldı."),
                Plan(id: "\(key)-0", date: midnight(of: day),
                     title: "\(number). Yıl Dönümümüz Kutlu Olsun",
                     body: store.anniversaryMessage),
            ]
        }

        // Surprise notes: the morning they unlock.
        for note in store.notes {
            plans.append(Plan(id: "note-\(note.id.uuidString)",
                              date: morning(of: note.unlockDate, daysBefore: 0),
                              title: "Bugün senin için bir sürpriz not açıldı",
                              body: "Notlar bölümünde seni bekliyor."))
        }

        return Array(
            plans
                .filter { $0.date > now }
                .sorted { $0.date < $1.date }
                .prefix(pendingLimit)
        )
    }

    /// 00:00 at the start of `day`.
    private static func midnight(of day: Date) -> Date {
        Calendar.app.startOfDay(for: day)
    }

    /// The configured morning time, `daysBefore` days before `day`.
    private static func morning(of day: Date, daysBefore: Int) -> Date {
        let calendar = Calendar.app
        let start = calendar.date(byAdding: .day, value: -daysBefore, to: calendar.startOfDay(for: day)) ?? day
        return calendar.date(bySettingHour: BetContent.notificationHour,
                             minute: BetContent.notificationMinute,
                             second: 0,
                             of: start) ?? start
    }
}
