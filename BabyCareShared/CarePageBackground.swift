import Foundation

/// Sense-of-place background kinds for vertical care pages (watchOS HIG).
enum CarePageBackgroundKind: String, Equatable, Sendable {
    case feed
    case feedOverdue
    case sleep
    case diaper
    case diaperOverdue
    case pump
    case lastCare
}

enum CarePageBackground {
    static func kind(
        page: BabyHomePage,
        snapshot: BabyHomeStatusSnapshot
    ) -> CarePageBackgroundKind {
        switch page {
        case .feed:
            if let overdue = snapshot.feedOverdueSeconds, overdue > 0 {
                return .feedOverdue
            }
            return .feed
        case .sleep:
            return .sleep
        case .diaper:
            if let overdue = snapshot.diaperOverdueSeconds, overdue > 0 {
                return .diaperOverdue
            }
            return .diaper
        case .pump:
            return .pump
        case .lastCare:
            return .lastCare
        }
    }

    /// Token id for tests (distinct per kind).
    static func tokenId(_ kind: CarePageBackgroundKind) -> String {
        kind.rawValue
    }
}
