import SwiftUI

/// Shown instead of the whole app until `appUnlockDate`: only a live countdown.
/// No header, footer or lock icon. The root view swaps it out when time is up.
struct LockView: View {
    @Environment(DataStore.self) private var store

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                Text("BET'S BEST DAYS")
                    .font(Theme.unitLabelFont)
                    .tracking(Theme.unitLabelTracking)
                    .foregroundStyle(Theme.textSecondary)

                CountdownView(
                    title: "Sürprizinin açılmasına kalan süre",
                    countdown: DateLogic.countdown(from: context.date, to: store.appUnlockDate),
                    dateText: DateLogic.longDateText(store.appUnlockDate)
                )
            }
            .padding(Theme.spacingL)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

// MARK: - Previews
// The unlock date comes from the local content file at runtime.

#Preview("Light") {
    LockView()
        .environment(DataStore())
}

#Preview("Dark") {
    LockView()
        .environment(DataStore())
        .preferredColorScheme(.dark)
}
