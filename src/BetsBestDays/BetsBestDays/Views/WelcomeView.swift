import SwiftUI

/// Shown once, right after the app unlocks: the personal welcome title and message,
/// then a continue button that opens the app. It does not ask for permissions;
/// notification permission is granted at install time.
struct WelcomeView: View {
    @Environment(DataStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingL) {
                    Text("BET'S BEST DAYS")
                        .font(Theme.unitLabelFont)
                        .tracking(Theme.unitLabelTracking)
                        .foregroundStyle(Theme.textSecondary)

                    Text(store.welcomeTitle)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(store.welcomeMessage)
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(Theme.spacingXS)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Theme.spacingL)
                .padding(.top, Theme.spacingXXL)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)

            Button {
                withAnimation(.easeInOut(duration: 0.3)) { store.markWelcomeSeen() }
            } label: {
                Text("Devam")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.onAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingM)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }
            .buttonStyle(.plain)
            .padding(Theme.spacingL)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

// MARK: - Previews
// Texts come from the local content file at runtime.

#Preview("Light") {
    WelcomeView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview-welcome")!))
}

#Preview("Dark") {
    WelcomeView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview-welcome")!))
        .preferredColorScheme(.dark)
}
