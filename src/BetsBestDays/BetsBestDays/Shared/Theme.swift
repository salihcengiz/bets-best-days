import SwiftUI
import UIKit

/// Single source for every color, size and font in the app and the widget.
/// The only accent is orange; everything else is neutral.
nonisolated enum Theme {

    // MARK: - Colors (light / dark)

    /// Countdown digits, active button, selected tab, progress, special-day card.
    static let accent = Color(light: 0xFF6B1A, dark: 0xFF8A4C)
    /// Screen background. Dark gray in dark mode, never pure black.
    static let background = Color(light: 0xFFFFFF, dark: 0x1C1C1E)
    /// Cards and grouped areas: a subtle step away from the background.
    static let surface = Color(light: 0xF6F6F6, dark: 0x2A2A2D)
    static let textPrimary = Color(light: 0x1A1A1A, dark: 0xF2F2F2)
    static let textSecondary = Color(light: 0x6E6E73, dark: 0x9A9AA0)
    /// Hairline borders and dividers. Used instead of shadows.
    static let separator = Color(light: 0xEBEBEB, dark: 0x3A3A3C)
    /// Text placed on an orange background. Only used at large sizes.
    static let onAccent = Color(light: 0xFFFFFF, dark: 0xFFFFFF)

    // MARK: - Shape

    static let cornerRadius: CGFloat = 14
    static let borderWidth: CGFloat = 1

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: - Typography

    /// Large countdown digits. Monospaced so ticking seconds don't shift the layout.
    static func countdownFont(size: CGFloat = 64) -> Font {
        .system(size: size, weight: .light).monospacedDigit()
    }

    /// Small unit labels next to numbers. Write the text in uppercase in the source.
    static let unitLabelFont = Font.system(size: 11, weight: .medium)
    static let unitLabelTracking: CGFloat = 1.2

    static let titleFont = Font.system(size: 28, weight: .semibold)
    static let headlineFont = Font.system(size: 20, weight: .semibold)
    static let bodyFont = Font.system(size: 17)
    static let captionFont = Font.system(size: 13)
}

// MARK: - Helpers

private nonisolated extension Color {
    /// A color that switches between two hex values with the system appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private nonisolated extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
