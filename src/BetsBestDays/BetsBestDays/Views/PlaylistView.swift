import SwiftUI

/// Content of the playlist section: a short line and the button that opens the shared
/// playlist (Spotify app if installed, otherwise the browser).
/// The header and footer come from the root view.
struct PlaylistView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                Text("Birlikte dinlediğimiz şarkılar tek bir listede.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                PlaylistButton()
            }
            .padding(Theme.spacingL)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.background)
    }
}

// MARK: - Previews

#Preview("Light") {
    PlaylistView()
        .environment(DataStore())
}

#Preview("Dark") {
    PlaylistView()
        .environment(DataStore())
        .preferredColorScheme(.dark)
}
