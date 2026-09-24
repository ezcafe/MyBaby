import Foundation

enum BabyHomePage: Int, CaseIterable, Identifiable, Hashable {
    case feed = 0
    case sleep
    case diaper
    case pump
    case lastCare

    var id: Int { rawValue }

    /// Keep selected page and ±1 neighbor mounted; unload the rest to cut TabView RSS.
    static func shouldMount(_ page: BabyHomePage, selected: BabyHomePage) -> Bool {
        abs(page.rawValue - selected.rawValue) <= 1
    }

    var queryValue: String {
        switch self {
        case .feed: return "feed"
        case .sleep: return "sleep"
        case .diaper: return "diaper"
        case .pump: return "pump"
        case .lastCare: return "status"
        }
    }

    static func fromQuery(_ value: String?) -> BabyHomePage? {
        guard let value else { return nil }
        switch value.lowercased() {
        case "feed", "breast", "bottle": return .feed
        case "sleep", "nap": return .sleep
        case "diaper": return .diaper
        case "pump", "pump-amount", "pumpamount", "pump_amount": return .pump
        case "status", "lastcare", "last-care": return .lastCare
        default: return nil
        }
    }
}

enum BabyHomeDeepLink {
    static let scheme = "mybaby"
    static let host = "home"

    /// Maps `mybaby://home?page=sleep` → page. Unknown → `.feed`.
    static func page(from url: URL) -> BabyHomePage {
        guard url.scheme == scheme, url.host == host else {
            return .feed
        }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let page = items?.first(where: { $0.name == "page" })?.value
        return BabyHomePage.fromQuery(page) ?? .feed
    }

    static func url(page: BabyHomePage) -> URL {
        URL(string: "\(scheme)://\(host)?page=\(page.queryValue)")!
    }
}
