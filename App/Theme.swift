import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum Theme {
    enum Colors {
        static let background = Color(hex: "#0D1117")
        static let textPrimary = Color(hex: "#F9FAFB")
        static let mutedBackground = Color(hex: "#161B22")
        static let mutedText = Color(hex: "#9CA3AF")
        static let componentsSurface = Color(hex: "#161B22")
        static let componentsBorder = Color(hex: "#1F2937")

        static let primaryBackground = Color(hex: "#10B981")
        static let primaryText = Color.white
        static let secondaryBackground = Color(hex: "#06B6D4")
        static let secondaryText = Color.white
        static let accentBackground = Color(hex: "#3B82F6")
        static let accentText = Color.white
        static let destructiveBackground = Color(hex: "#EF4444")
        static let destructiveText = Color.white

        static let inputBackground = Color(hex: "#0D1117")
        static let inputBorder = Color(hex: "#374151")
        static let focusBorder = Color(hex: "#06B6D4")

        static let cardBackground = Color(hex: "#161B22")
        static let cardText = Color(hex: "#F3F4F6")
        static let popoverBackground = Color(hex: "#1E293B")
        static let popoverText = Color(hex: "#E5E7EB")

        static let chartOne = Color(hex: "#10B981")
        static let chartTwo = Color(hex: "#06B6D4")
        static let chartThree = Color(hex: "#3B82F6")
        static let chartFour = Color(hex: "#F59E0B")
        static let chartFive = Color(hex: "#8B5CF6")
    }

    enum Fonts {
        static func sans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.themeCustom("Inter", size: size, weight: weight)
        }

        static func serifDisplay(size: CGFloat) -> Font {
            Font.themeCustom("DMSerifDisplay-Regular", size: size, weight: .regular)
        }

        static func mono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.themeCustom("JetBrainsMono-Regular", size: size, weight: weight, design: .monospaced)
        }
    }
}

private extension Font {
    static func themeCustom(_ name: String, size: CGFloat, weight: Font.Weight, design: Font.Design = .default) -> Font {
        #if canImport(UIKit)
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size).weight(weight)
        }
        #endif
        return Font.system(size: size, weight: weight, design: design)
    }
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
