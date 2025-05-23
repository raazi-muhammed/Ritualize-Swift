import SwiftUI

extension Color {
    static let muted = adaptive(
        light: Color(red: 228 / 255, green: 227 / 255, blue: 234 / 255),
        dark: Color(red: 45 / 255, green: 45 / 255, blue: 46 / 255),
    )

    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(
            uiColor: UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .light:
                    return UIColor(light)
                case .dark:
                    return UIColor(dark)
                case .unspecified:
                    return UIColor(light)
                @unknown default:
                    return UIColor(light)
                }
            })
    }
}
