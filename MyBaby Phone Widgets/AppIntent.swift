import AppIntents
import WidgetKit

enum BabyCarePhoneTypeAppEnum: String, AppEnum, CaseIterable {
    case auto
    case feed
    case sleep
    case diaper
    case pump

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Care type")

    static var caseDisplayRepresentations: [BabyCarePhoneTypeAppEnum: DisplayRepresentation] = [
        .auto: "Auto",
        .feed: "Feed",
        .sleep: "Sleep",
        .diaper: "Diaper",
        .pump: "Pump",
    ]

    var careType: BabyCareComplicationCareType {
        switch self {
        case .auto: return .auto
        case .feed: return .feed
        case .sleep: return .sleep
        case .diaper: return .diaper
        case .pump: return .pump
        }
    }

    var recommendationDescription: LocalizedStringResource {
        switch self {
        case .auto: return "Auto — live timer or last care"
        case .feed: return "Feed"
        case .sleep: return "Sleep"
        case .diaper: return "Diaper"
        case .pump: return "Pump"
        }
    }
}

struct BabyCarePhoneHomeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Baby Care"
    static var description = IntentDescription(
        "Live care timer, or last care with in/out-of-range color. Pick Auto or a care type."
    )

    @Parameter(title: "Care type", default: .auto)
    var careType: BabyCarePhoneTypeAppEnum

    init() {
        careType = .auto
    }

    init(careType: BabyCarePhoneTypeAppEnum) {
        self.careType = careType
    }
}
