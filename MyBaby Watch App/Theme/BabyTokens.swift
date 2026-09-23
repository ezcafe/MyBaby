import SwiftUI

enum BabyTokens {
    // Adaptive via ColorScheme helpers:
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x171717) : Color(hex: 0xFAFAFA)
    }

    static func foreground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0xFAFAFA) : Color(hex: 0x1A1A1A)
    }

    static func muted(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0xA0A0A0) : Color(hex: 0x6B6B6B)
    }

    static func accent(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x2DD4BF) : Color(hex: 0x0D9488)
    }

    static func accentForeground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x171717) : Color(hex: 0xFFFFFF)
    }

    static func hairline(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x404040) : Color(hex: 0xE5E5E5)
    }

    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x1A1A1A) : Color(hex: 0xFFFFFF)
    }

    static let outerRadius: CGFloat = 8
    static let nestedRadius: CGFloat = 6
    static let minHit: CGFloat = 44
}

struct BabyPalette {
    let scheme: ColorScheme

    var background: Color { BabyTokens.background(scheme) }
    var foreground: Color { BabyTokens.foreground(scheme) }
    var muted: Color { BabyTokens.muted(scheme) }
    var accent: Color { BabyTokens.accent(scheme) }
    var accentForeground: Color { BabyTokens.accentForeground(scheme) }
    var hairline: Color { BabyTokens.hairline(scheme) }
    var surface: Color { BabyTokens.surface(scheme) }
}
