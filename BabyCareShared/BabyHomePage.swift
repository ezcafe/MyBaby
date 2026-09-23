import Foundation

enum BabyHomePage: Int, CaseIterable, Identifiable, Hashable {
    case feedBottle = 0
    case sleep
    case diaper
    case pump
    case lastCare

    var id: Int { rawValue }

    var queryValue: String {
        switch self {
        case .feedBottle: return "feed"
        case .sleep: return "sleep"
        case .diaper: return "diaper"
        case .pump: return "pump"
        case .lastCare: return "status"
        }
    }

    static func fromQuery(_ value: String?) -> BabyHomePage? {
        guard let value else { return nil }
        switch value.lowercased() {
        case "feed", "bottle", "breast": return .feedBottle
        case "sleep", "nap": return .sleep
        case "diaper": return .diaper
        case "pump": return .pump
        case "status", "lastcare", "last-care": return .lastCare
        default: return nil
        }
    }
}

enum BabyHomeDeepLink {
    static let scheme = "mybaby"
    static let host = "home"

    /// Maps `mybaby://home?page=sleep` → page. Unknown → `.feedBottle`.
    static func page(from url: URL) -> BabyHomePage {
        guard url.scheme == scheme, url.host == host else {
            return .feedBottle
        }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let page = items?.first(where: { $0.name == "page" })?.value
        return BabyHomePage.fromQuery(page) ?? .feedBottle
    }

    static func url(page: BabyHomePage) -> URL {
        URL(string: "\(scheme)://\(host)?page=\(page.queryValue)")!
    }
}
