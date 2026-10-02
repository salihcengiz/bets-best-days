import SwiftUI
import UIKit

/// Full-width row that opens the shared playlist.
/// Spotify opens it if installed; otherwise the link opens in the browser.
struct PlaylistButton: View {
    @Environment(DataStore.self) private var store

    var body: some View {
        Button(action: openPlaylist) {
            HStack(spacing: Theme.spacingM) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Oynatma listemiz")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Spotify'da aç")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer(minLength: Theme.spacingS)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.spacingM)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.separator, lineWidth: Theme.borderWidth)
            )
            .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Spotify'da açar")
    }

    /// Tries the Spotify app first (universal link); falls back to the browser.
    private func openPlaylist() {
        let url = store.playlistURL
        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { opened in
            if !opened {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    PlaylistButton()
        .environment(DataStore())
        .padding(Theme.spacingL)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
}

#Preview("Dark") {
    PlaylistButton()
        .environment(DataStore())
        .padding(Theme.spacingL)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
        .preferredColorScheme(.dark)
}
