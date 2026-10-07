import SwiftUI

/// The three sections reachable from the footer.
enum AppTab: CaseIterable {
    case home
    case notes
    case coupons

    var title: String {
        switch self {
        case .home: return "Sayaçlar"
        case .notes: return "Notlar"
        case .coupons: return "Kuponlar"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "calendar"
        case .notes: return "envelope"
        case .coupons: return "ticket"
        }
    }
}

/// App skeleton: the same header and footer on every screen, with the selected
/// section's content in between. Screens never draw their own header or footer.
struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            header
            hairline

            screen(for: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(selectedTab)
                .transition(.opacity)

            hairline
            footer
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .background(Theme.background.ignoresSafeArea())
        .tint(Theme.accent)
        .environment(\.locale, Locale(identifier: "tr_TR"))
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    // MARK: - Header

    /// Small app name above the large title of the current section.
    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text("BET'S BEST DAYS")
                .font(Theme.unitLabelFont)
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.textSecondary)

            Text(selectedTab.title)
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.spacingL)
        .padding(.top, Theme.spacingS)
        .padding(.bottom, Theme.spacingM)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Content

    @ViewBuilder
    private func screen(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .notes:
            NotesView()
        case .coupons:
            CouponsView()
        }
    }

    // MARK: - Footer

    /// One button per section; the selected one is orange.
    private var footer: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                footerButton(for: tab)
            }
        }
        .padding(.top, Theme.spacingS)
        .padding(.bottom, Theme.spacingXS)
    }

    private func footerButton(for tab: AppTab) -> some View {
        let isSelected = tab == selectedTab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: Theme.spacingXS) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 20, weight: .regular))
                    .frame(height: 24)
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingXS)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var hairline: some View {
        Rectangle()
            .fill(Theme.separator)
            .frame(height: Theme.borderWidth)
    }
}

// MARK: - Previews

#Preview("Light") {
    ContentView()
        .environment(DataStore())
}

#Preview("Dark") {
    ContentView()
        .environment(DataStore())
        .preferredColorScheme(.dark)
}
