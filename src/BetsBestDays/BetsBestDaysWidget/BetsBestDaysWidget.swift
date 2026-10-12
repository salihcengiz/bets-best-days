//
//  BetsBestDaysWidget.swift
//  BetsBestDaysWidget
//
//  Created by Salih Cengiz on 1.10.2026.
//

import WidgetKit
import SwiftUI

// The three widget kinds shown in the widget gallery. All share DaysProvider,
// so they switch to the next day exactly at midnight.

/// Overview: birthday, anniversary and days together.
/// Keeps the template's type name so the bundle keeps compiling.
struct BetsBestDaysWidget: Widget {
    let kind = "OverviewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaysProvider()) { entry in
            OverviewWidgetView(entry: entry)
        }
        .configurationDisplayName("Özet")
        .description("Doğum günü, yıl dönümü ve birlikte geçen günler.")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}

/// The closest special day: days left, or a celebration on the day itself.
struct SpecialDayWidget: Widget {
    let kind = "SpecialDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaysProvider()) { entry in
            SpecialDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Özel Gün")
        .description("En yakın özel güne kalan gün.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

/// Days together since the relationship started.
struct TogetherWidget: Widget {
    let kind = "TogetherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaysProvider()) { entry in
            TogetherWidgetView(entry: entry)
        }
        .configurationDisplayName("Birlikte")
        .description("Birlikte geçen günler.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Previews
// Entries are computed from the local content file at runtime: today, and the next
// special day itself (to see the celebration state).

private var previewEntries: [DaysEntry] {
    let now = Date()
    let special = DateLogic.nextSpecialDay(from: now).date
    return [DaysEntry(date: now), DaysEntry(date: special.addingTimeInterval(10 * 3600))]
}

#Preview("Special day, small", as: .systemSmall) {
    SpecialDayWidget()
} timeline: {
    for entry in previewEntries { entry }
}

#Preview("Special day, circular", as: .accessoryCircular) {
    SpecialDayWidget()
} timeline: {
    for entry in previewEntries { entry }
}

#Preview("Special day, inline", as: .accessoryInline) {
    SpecialDayWidget()
} timeline: {
    for entry in previewEntries { entry }
}

#Preview("Together, small", as: .systemSmall) {
    TogetherWidget()
} timeline: {
    DaysEntry(date: .now)
}

#Preview("Together, circular", as: .accessoryCircular) {
    TogetherWidget()
} timeline: {
    DaysEntry(date: .now)
}

#Preview("Overview, medium", as: .systemMedium) {
    BetsBestDaysWidget()
} timeline: {
    for entry in previewEntries { entry }
}

#Preview("Overview, rectangular", as: .accessoryRectangular) {
    BetsBestDaysWidget()
} timeline: {
    DaysEntry(date: .now)
}
