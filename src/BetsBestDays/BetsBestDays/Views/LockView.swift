import SwiftUI

/// Shown instead of the whole app until `appUnlockDate`: a large live countdown framed
/// by two orange bands. The bands are decorative only (not the app's header and footer);
/// the top one carries the app name in the brand font.
/// The root view swaps this screen out when time is up.
struct LockView: View {
    @Environment(DataStore.self) private var store

    var body: some View {
        VStack(spacing: 0) {
            topBand

            TimelineView(.periodic(from: .now, by: 1)) { context in
                countdown(now: context.date)
                    .padding(.horizontal, Theme.spacingL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }

            bottomBand
        }
        .background(Theme.background.ignoresSafeArea())
    }

    // MARK: - Bands

    /// Orange band under the status bar with the app name in white.
    private var topBand: some View {
        Text("BET'S BEST DAYS")
            .font(Theme.brandFont(size: 48))
            .foregroundStyle(Theme.onAccent)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.top, Theme.spacingM)
            .padding(.bottom, Theme.spacingL)
            .background(Theme.accent.ignoresSafeArea(edges: .top))
            .accessibilityAddTraits(.isHeader)
    }

    /// Plain orange band at the bottom edge.
    private var bottomBand: some View {
        Theme.accent
            .frame(height: Theme.spacingXXL * 2)
            .ignoresSafeArea(edges: .bottom)
            .accessibilityHidden(true)
    }

    // MARK: - Countdown

    /// Heading, one row of four equal columns inside a light gray card, and the date.
    private func countdown(now: Date) -> some View {
        let left = DateLogic.countdown(from: now, to: store.appUnlockDate)

        return VStack(alignment: .leading, spacing: Theme.spacingXL) {
            Text("Sürprizinin açılmasına kalan süre")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                unit("\(left.days)", label: "GÜN")
                unit(String(format: "%02d", left.hours), label: "SAAT")
                unit(String(format: "%02d", left.minutes), label: "DAKİKA")
                unit(String(format: "%02d", left.seconds), label: "SANİYE")
            }
            .padding(.vertical, Theme.spacingL)
            .padding(.horizontal, Theme.spacingS)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.separator, lineWidth: Theme.borderWidth)
            )

            Text(DateLogic.longDateText(store.appUnlockDate))
                .font(.system(size: 22))
                .foregroundStyle(Theme.textPrimary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Sürprizinin açılmasına kalan süre: \(left.days) gün \(left.hours) saat \(left.minutes) dakika"
        )
    }

    /// One column: a large number centered over its label. All four columns share the width equally.
    private func unit(_ value: String, label: String) -> some View {
        VStack(spacing: Theme.spacingS) {
            Text(value)
                .font(Theme.countdownFont(size: 56))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
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
