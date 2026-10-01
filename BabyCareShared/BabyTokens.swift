import SwiftUI

/// Care chrome density — phone uses roomier type/heights than Watch.
enum BabyCareChromePlatform: Equatable {
    case watch
    case phone

    static var current: BabyCareChromePlatform {
        #if os(iOS)
        .phone
        #else
        .watch
        #endif
    }
}

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

    static func danger(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0xF87171) : Color(hex: 0xDC2626)
    }

    static func dangerSurface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x3F1D1D) : Color(hex: 0xFEF2F2)
    }

    static let outerRadius: CGFloat = 8
    static let nestedRadius: CGFloat = 6
    static let minHit: CGFloat = 44

    static var careChromePlatform: BabyCareChromePlatform { .current }

    /// Shared row height for ml chips, Custom, and Diaper tiles.
    static func careChipHeight(for platform: BabyCareChromePlatform = .current) -> CGFloat {
        switch platform {
        case .watch: return minHit
        case .phone: return 52
        }
    }

    static var careChipHeight: CGFloat { careChipHeight(for: .current) }

    /// Tips and section detail — Watch caption2; phone footnote for Dynamic Type.
    static func secondaryFont(for platform: BabyCareChromePlatform = .current) -> Font {
        switch platform {
        case .watch: return .caption2
        case .phone: return .footnote
        }
    }

    static var secondaryFont: Font { secondaryFont(for: .current) }

    static func sectionLeadFont(for platform: BabyCareChromePlatform = .current) -> Font {
        switch platform {
        case .watch: return .headline.weight(.bold)
        case .phone: return .title3.weight(.bold)
        }
    }

    static var sectionLeadFont: Font { sectionLeadFont(for: .current) }

    static func compactChipTitleFont(for platform: BabyCareChromePlatform = .current) -> Font {
        switch platform {
        case .watch: return .caption.weight(.bold)
        case .phone: return .subheadline.weight(.semibold)
        }
    }

    static var compactChipTitleFont: Font { compactChipTitleFont(for: .current) }

    static func roomyChipTitleFont(for platform: BabyCareChromePlatform = .current) -> Font {
        switch platform {
        case .watch, .phone:
            return .headline.weight(.bold)
        }
    }

    static var roomyChipTitleFont: Font { roomyChipTitleFont(for: .current) }

    static func diaperChipTitleFont(for platform: BabyCareChromePlatform = .current) -> Font {
        switch platform {
        case .watch: return .caption2.weight(.semibold)
        case .phone: return .caption.weight(.semibold)
        }
    }

    static var diaperChipTitleFont: Font { diaperChipTitleFont(for: .current) }
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
    var danger: Color { BabyTokens.danger(scheme) }
    var dangerSurface: Color { BabyTokens.dangerSurface(scheme) }
}
