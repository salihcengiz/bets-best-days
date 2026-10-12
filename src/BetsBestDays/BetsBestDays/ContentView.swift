import SwiftUI

/// The four sections reachable from the footer.
enum AppTab: CaseIterable {
    case home
    case notes
    case coupons
    case playlist

    var title: String {
        switch self {
        case .home: return "Sayaçlar"
        case .notes: return "Notlar"
        case .coupons: return "Kuponlar"
        case .playlist: return "Oynatma Listemiz"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "calendar"
        case .notes: return "envelope"
        case .coupons: return "ticket"
        case .playlist: return "music.note.list"
        }
    }
}

/// App skeleton: the same orange header and footer on every screen, the section title
/// under the header, and the selected section's content in between.
/// Screens never draw their own header or footer.
struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            header
                .zIndex(1)
            sectionTitle

            screen(for: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(selectedTab)
                .transition(.opacity)

            footer
                .zIndex(1)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .background(Theme.background.ignoresSafeArea())
        .tint(Theme.accent)
        .environment(\.locale, Locale(identifier: "tr_TR"))
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    // MARK: - Header

    /// Orange band under the status bar with the app name in the brand font.
    private var header: some View {
        Text("BET'S BEST DAYS")
            .font(Theme.brandFont(size: 40))
            .foregroundStyle(Theme.onAccent)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.top, Theme.spacingS)
            .padding(.bottom, Theme.spacingM)
            // Small neutral shadow on the band only (not the text), falling onto the content below.
            .background(Theme.accent.ignoresSafeArea(edges: .top).shadow(radius: 2, y: 2))
            .accessibilityAddTraits(.isHeader)
    }

    /// Large title of the current section, on the regular background under the header.
    private var sectionTitle: some View {
        Text(selectedTab.title)
            .font(Theme.titleFont)
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.spacingL)
            .padding(.top, Theme.spacingL)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Content

    @ViewBuilder
    private func screen(for tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .notes: NotesView()
        case .coupons: CouponsView()
        case .playlist: PlaylistView()
        }
    }

    // MARK: - Footer

    /// Orange band with one button per section. The selected one is solid white,
    /// the others are dimmed white.
    private var footer: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                footerButton(for: tab)
            }
        }
        .padding(.horizontal, Theme.spacingS)
        .padding(.top, Theme.spacingS)
        .padding(.bottom, Theme.spacingXS)
        // Small neutral shadow on the band only, falling onto the content above.
        .background(Theme.accent.ignoresSafeArea(edges: .bottom).shadow(radius: 2, y: -2))
    }

    private func footerButton(for tab: AppTab) -> some View {
        let isSelected = tab == selectedTab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: Theme.spacingXS) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .frame(height: 24)
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 2)
            }
            .foregroundStyle(Theme.onAccent.opacity(isSelected ? 1 : 0.65))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingXS)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
