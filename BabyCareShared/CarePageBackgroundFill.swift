import SwiftUI

enum CarePageBackgroundFill {
    @ViewBuilder
    static func containerFill(_ kind: CarePageBackgroundKind, scheme: ColorScheme) -> some View {
        let dark = scheme == .dark
        switch kind {
        case .feed:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x134E4A : 0xCCFBF1),
                    BabyTokens.background(scheme),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .feedOverdue:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x7C2D12 : 0xFED7AA),
                    BabyTokens.background(scheme),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sleep:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x1E1B4B : 0x312E81),
                    Color(hex: dark ? 0x171717 : 0x1E1B4B),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .diaper:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x292524 : 0xF5F5F4),
                    BabyTokens.background(scheme),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .diaperOverdue:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x713F12 : 0xFEF3C7),
                    BabyTokens.background(scheme),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .pump:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x115E59 : 0x99F6E4),
                    BabyTokens.background(scheme),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .lastCare:
            LinearGradient(
                colors: [
                    Color(hex: dark ? 0x0C4A6E : 0xE0F2FE),
                    BabyTokens.background(scheme),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
