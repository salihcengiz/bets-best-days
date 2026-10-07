import WidgetKit

/// One moment on the widget's timeline. Views compute everything they show
/// (days left, days together, special day) from `date` with DateLogic, so an entry
/// prepared today for next Tuesday shows next Tuesday's numbers.
struct DaysEntry: TimelineEntry {
    let date: Date
}

/// Supplies the widget's timeline: one entry for right now, then one for each of the
/// next seven midnights. WidgetKit switches entries exactly at midnight without waking
/// the app, and asks for a new timeline after the last one (`.atEnd`).
/// No App Group is needed: all values come from BetContent and DateLogic, which are
/// compiled into the widget too.
struct DaysProvider: TimelineProvider {
    /// Midnights covered by one timeline, after the current entry.
    private let daysAhead = 7

    func placeholder(in context: Context) -> DaysEntry {
        DaysEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (DaysEntry) -> Void) {
        completion(DaysEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DaysEntry>) -> Void) {
        let calendar = Calendar.app
        let now = Date()
        var entries = [DaysEntry(date: now)]

        var midnight = calendar.startOfDay(for: now)
        for _ in 0..<daysAhead {
            guard let next = calendar.date(byAdding: .day, value: 1, to: midnight) else { break }
            midnight = next
            entries.append(DaysEntry(date: midnight))
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
