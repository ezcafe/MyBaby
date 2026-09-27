import AppIntents
import SwiftUI
import WidgetKit

/// User-facing care filter for face / Smart Stack configuration.
enum BabyCareTypeAppEnum: String, AppEnum, CaseIterable {
    case auto
    case feed
    case sleep
    case diaper
    case pump

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Care type")

    static var caseDisplayRepresentations: [BabyCareTypeAppEnum: DisplayRepresentation] = [
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

struct BabyCareComplicationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Baby Care"
    static var description = IntentDescription(
        "Live care timer, or last care with in/out-of-range color. Pick Auto or a care type."
    )

    @Parameter(title: "Care type", default: .auto)
    var careType: BabyCareTypeAppEnum

    init() {
        careType = .auto
    }

    init(careType: BabyCareTypeAppEnum) {
        self.careType = careType
    }
}

struct BabyCareProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BabyCareEntry {
        BabyCareEntry(date: .now, snapshot: .sampleNextFeed(), careType: .auto)
    }

    func snapshot(
        for configuration: BabyCareComplicationIntent,
        in context: Context
    ) async -> BabyCareEntry {
        let snap = context.isPreview
            ? BabyHomeStatusSnapshot.sampleOpenNap()
            : BabyCareStatusStore.snapshotForWidgets()
        return BabyCareEntry(
            date: .now,
            snapshot: snap,
            careType: configuration.careType.careType
        )
    }

    func timeline(
        for configuration: BabyCareComplicationIntent,
        in context: Context
    ) async -> Timeline<BabyCareEntry> {
        let snapshot = BabyCareStatusStore.snapshotForWidgets()
        let entry = BabyCareEntry(
            date: .now,
            snapshot: snapshot,
            careType: configuration.careType.careType
        )
        let refresh = BabyCareWidgetTimeline.nextUpdate(for: snapshot)
        return Timeline(entries: [entry], policy: .after(refresh))
    }

    func recommendations() -> [AppIntentRecommendation<BabyCareComplicationIntent>] {
        BabyCareTypeAppEnum.allCases.map { type in
            AppIntentRecommendation(
                intent: BabyCareComplicationIntent(careType: type),
                description: type.recommendationDescription
            )
        }
    }
}

struct BabyCareEntry: TimelineEntry {
    let date: Date
    let snapshot: BabyHomeStatusSnapshot
    let careType: BabyCareComplicationCareType
}

struct BabyCareWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: BabyCareEntry

    private var display: BabyCareComplicationDisplay {
        BabyCareComplicationDisplay.resolve(
            entry.snapshot,
            careType: entry.careType,
            now: entry.date
        )
    }

    private var accent: Color {
        display.color == .red ? Color(hex: 0xF87171) : Color(hex: 0x2DD4BF)
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circular
            case .accessoryCorner:
                corner
            case .accessoryInline:
                HStack(spacing: 2) {
                    Image(systemName: display.iconSystemName)
                    inlineText
                }
                .font(.caption)
                .foregroundStyle(accent)
                .monospacedDigit()
            case .accessoryRectangular:
                rectangular
            default:
                circular
            }
        }
    }

    /// Circular: icon + age (two lines when `12h` + `38m`).
    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: display.iconSystemName)
                    .font(.system(size: 10, weight: .semibold))
                smallPrimaryValue
                    .font(.system(size: 11, weight: .bold))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(accent)
            .padding(.horizontal, 2)
        }
    }

    /// Corner: age in the corner (two lines when needed); kind on the curved label.
    private var corner: some View {
        smallPrimaryValue
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .minimumScaleFactor(0.7)
            .foregroundStyle(accent)
            .widgetLabel {
                Text(display.kindLabel)
                    .foregroundStyle(accent)
            }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Baby Care")
                .font(.caption2.weight(.bold))
                .foregroundStyle(accent)
            HStack(spacing: 4) {
                Text(display.kindLabel)
                    .font(.caption.weight(.bold))
                widePrimaryValue
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
            }
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            Text(secondaryLine)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    /// Circular / corner — idle age may stack on two lines.
    @ViewBuilder
    private var smallPrimaryValue: some View {
        switch display.mode {
        case .running(_, let startedAt):
            Text(startedAt, style: .timer)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        case .idle(_, let at, _):
            let lines = BabyCareComplicationDisplay.formatRelativeLines(
                entry.date.timeIntervalSince(at)
            )
            VStack(spacing: 0) {
                Text(lines.line1)
                if let line2 = lines.line2 {
                    Text(line2)
                }
            }
            .lineLimit(2)
        case .empty:
            Text("·")
        }
    }

    /// Rectangular / inline — keep single-line relative (`12h 38m`).
    @ViewBuilder
    private var widePrimaryValue: some View {
        switch display.mode {
        case .running(_, let startedAt):
            Text(startedAt, style: .timer)
        case .idle(_, _, _):
            Text(display.idleRelative ?? "·")
        case .empty:
            Text("·")
        }
    }

    @ViewBuilder
    private var inlineText: some View {
        switch display.mode {
        case .running(let kind, let startedAt):
            Text("\(kind.kindLabel) · ") + Text(startedAt, style: .timer)
        case .idle(let kind, _, _):
            Text("Last \(kind.kindLabel.lowercased()) · \(display.idleRelative ?? "")")
        case .empty:
            Text("Baby Care")
        }
    }

    private var secondaryLine: String {
        switch display.mode {
        case .running:
            if let rel = displayIdleFeedRelative {
                return "Last feed · \(rel)"
            }
            return entry.snapshot.lastFeed.isEmpty ? "No feed yet" : entry.snapshot.lastFeed.sentence
        case .idle(_, _, let sentence):
            if display.color == .red {
                return "\(display.kindLabel) overdue"
            }
            return sentence
        case .empty:
            return "No care yet"
        }
    }

    private var displayIdleFeedRelative: String? {
        guard let at = entry.snapshot.lastFeedAt else { return nil }
        return BabyCareComplicationDisplay.formatRelative(entry.date.timeIntervalSince(at))
    }
}

@main
struct BabyCareWidgets: WidgetBundle {
    var body: some Widget {
        BabyCareComplication()
    }
}

/// One accessory widget for face complications and Smart Stack (overlapping families merged).
struct BabyCareComplication: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "BabyCareComplication",
            intent: BabyCareComplicationIntent.self,
            provider: BabyCareProvider()
        ) { entry in
            BabyCareWidgetEntryView(entry: entry)
                .widgetURL(BabyHomeDeepLink.url(page: entry.displayDeepLinkPage))
        }
        .configurationDisplayName("Baby Care")
        .description(
            "Live care timer, or last care with in/out-of-range color. Choose Auto or a care type — face and Smart Stack."
        )
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

private extension BabyCareEntry {
    var displayDeepLinkPage: BabyHomePage {
        BabyCareComplicationDisplay.resolve(snapshot, careType: careType, now: date).deepLinkPage
    }
}
