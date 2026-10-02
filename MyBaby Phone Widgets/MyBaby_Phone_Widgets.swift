import SwiftUI
import WidgetKit

struct BabyCarePhoneProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BabyCarePhoneEntry {
        BabyCarePhoneEntry(date: .now, snapshot: .sampleNextFeed(), careType: .auto)
    }

    func snapshot(
        for configuration: BabyCarePhoneHomeIntent,
        in context: Context
    ) async -> BabyCarePhoneEntry {
        let snap = context.isPreview
            ? BabyHomeStatusSnapshot.sampleOpenNap()
            : BabyCareStatusStore.snapshotForWidgets()
        return BabyCarePhoneEntry(
            date: .now,
            snapshot: snap,
            careType: configuration.careType.careType
        )
    }

    func timeline(
        for configuration: BabyCarePhoneHomeIntent,
        in context: Context
    ) async -> Timeline<BabyCarePhoneEntry> {
        let snapshot = BabyCareStatusStore.snapshotForWidgets()
        let entry = BabyCarePhoneEntry(
            date: .now,
            snapshot: snapshot,
            careType: configuration.careType.careType
        )
        let refresh = BabyCareWidgetTimeline.nextUpdate(for: snapshot)
        return Timeline(entries: [entry], policy: .after(refresh))
    }

    func recommendations() -> [AppIntentRecommendation<BabyCarePhoneHomeIntent>] {
        BabyCarePhoneTypeAppEnum.allCases.map { type in
            AppIntentRecommendation(
                intent: BabyCarePhoneHomeIntent(careType: type),
                description: type.recommendationDescription
            )
        }
    }
}

struct BabyCarePhoneEntry: TimelineEntry {
    let date: Date
    let snapshot: BabyHomeStatusSnapshot
    let careType: BabyCareComplicationCareType
}

struct BabyCarePhoneHomeEntryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var family
    var entry: BabyCarePhoneEntry

    private var display: BabyCareComplicationDisplay {
        BabyCareComplicationDisplay.resolve(
            entry.snapshot,
            careType: entry.careType,
            now: entry.date
        )
    }

    private var accent: Color {
        display.color == .red
            ? BabyTokens.danger(colorScheme)
            : BabyTokens.accent(colorScheme)
    }

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumLayout
            case .accessoryRectangular:
                accessoryRectangular
            case .accessoryCircular:
                accessoryCircular
            case .accessoryInline:
                accessoryInline
            default:
                smallLayout
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(display.accessibilitySummary)
        .containerBackground(for: .widget) {
            if isAccessoryFamily {
                AccessoryWidgetBackground()
            } else {
                BabyTokens.surface(colorScheme)
            }
        }
    }

    private var isAccessoryFamily: Bool {
        switch family {
        case .accessoryRectangular, .accessoryCircular, .accessoryInline:
            return true
        default:
            return false
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(display.kindLabel, systemImage: display.iconSystemName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            primaryValue
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(accent)
                .minimumScaleFactor(0.6)
            if display.showsOverdueCue {
                Label("Overdue", systemImage: "exclamationmark.circle.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(accent)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Label(display.kindLabel, systemImage: display.iconSystemName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                    .lineLimit(1)
                primaryValue
                    .font(.title.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(accent)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
            Text(secondaryLine)
                .font(.caption)
                .foregroundStyle(BabyTokens.muted(colorScheme))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120, alignment: .trailing)
                .privacySensitive()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
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
                .privacySensitive()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var accessoryCircular: some View {
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

    private var accessoryInline: some View {
        HStack(spacing: 2) {
            Image(systemName: display.iconSystemName)
            inlineText
        }
        .font(.caption)
        .foregroundStyle(accent)
        .monospacedDigit()
    }

    @ViewBuilder
    private var primaryValue: some View {
        switch display.mode {
        case .running(_, let startedAt):
            Text(startedAt, style: .timer)
                .lineLimit(1)
                .privacySensitive()
        case .idle(_, _, _):
            Text(display.idleRelative ?? BabyCareComplicationDisplay.emptyPrimaryText)
                .lineLimit(1)
                .privacySensitive()
        case .empty:
            Text(BabyCareComplicationDisplay.emptyPrimaryText)
        }
    }

    @ViewBuilder
    private var smallPrimaryValue: some View {
        switch display.mode {
        case .running(_, let startedAt):
            Text(startedAt, style: .timer)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .privacySensitive()
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
            .privacySensitive()
        case .empty:
            Text(BabyCareComplicationDisplay.emptyPrimaryText)
        }
    }

    @ViewBuilder
    private var widePrimaryValue: some View {
        switch display.mode {
        case .running(_, let startedAt):
            Text(startedAt, style: .timer)
                .privacySensitive()
        case .idle(_, _, _):
            Text(display.idleRelative ?? BabyCareComplicationDisplay.emptyPrimaryText)
                .privacySensitive()
        case .empty:
            Text(BabyCareComplicationDisplay.emptyPrimaryText)
        }
    }

    @ViewBuilder
    private var inlineText: some View {
        switch display.mode {
        case .running(let kind, let startedAt):
            (Text("\(kind.kindLabel) · ") + Text(startedAt, style: .timer))
                .privacySensitive()
        case .idle(let kind, _, _):
            Text("Last \(kind.kindLabel.lowercased()) · \(display.idleRelative ?? "")")
                .privacySensitive()
        case .empty:
            Text(BabyCareComplicationDisplay.emptyPrimaryText)
        }
    }

    private var secondaryLine: String {
        switch display.mode {
        case .running:
            if let at = entry.snapshot.lastFeedAt {
                let rel = BabyCareComplicationDisplay.formatRelative(entry.date.timeIntervalSince(at))
                return "Last feed · \(rel)"
            }
            return entry.snapshot.lastFeed.isEmpty ? "No feed yet" : entry.snapshot.lastFeed.sentence
        case .idle(_, _, let sentence):
            if display.showsOverdueCue {
                return "\(display.kindLabel) overdue"
            }
            return sentence
        case .empty:
            return BabyCareComplicationDisplay.emptyPrimaryText
        }
    }
}

struct BabyCarePhoneHomeWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: BabyCareWidgetKinds.phoneHome,
            intent: BabyCarePhoneHomeIntent.self,
            provider: BabyCarePhoneProvider()
        ) { entry in
            BabyCarePhoneHomeEntryView(entry: entry)
                .widgetURL(
                    BabyHomeDeepLink.url(
                        page: BabyCareComplicationDisplay.resolve(
                            entry.snapshot,
                            careType: entry.careType,
                            now: entry.date
                        ).deepLinkPage
                    )
                )
        }
        .configurationDisplayName("Baby Care")
        .description(
            "Live care timer, or last care with in/out-of-range color. Choose Auto or a care type."
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline,
        ])
    }
}
