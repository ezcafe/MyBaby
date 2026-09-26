import WidgetKit
import SwiftUI

struct BabyCareProvider: TimelineProvider {
    func placeholder(in context: Context) -> BabyCareEntry {
        BabyCareEntry(date: .now, snapshot: .sampleNextFeed())
    }

    func getSnapshot(in context: Context, completion: @escaping (BabyCareEntry) -> Void) {
        let snap = context.isPreview
            ? BabyHomeStatusSnapshot.sampleOpenNap()
            : BabyCareStatusStore.snapshotForWidgets()
        completion(BabyCareEntry(date: .now, snapshot: snap))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BabyCareEntry>) -> Void) {
        let snapshot = BabyCareStatusStore.snapshotForWidgets()
        let entry = BabyCareEntry(date: .now, snapshot: snapshot)
        let refresh = BabyCareWidgetTimeline.nextUpdate(for: snapshot)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct BabyCareEntry: TimelineEntry {
    let date: Date
    let snapshot: BabyHomeStatusSnapshot
}

struct BabyCareWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: BabyCareEntry

    var body: some View {
        let signal = BabyCarePrimarySignal.resolve(entry.snapshot, now: entry.date)
        Group {
            switch family {
            case .accessoryCircular:
                circular(signal)
            case .accessoryCorner:
                Text(BabyCarePrimarySignal.shortLabel(signal))
                    .font(.caption2)
            case .accessoryInline:
                Label(BabyCarePrimarySignal.shortLabel(signal), systemImage: icon(signal))
                    .font(.caption)
            case .accessoryRectangular:
                rectangular(signal)
            default:
                circular(signal)
            }
        }
    }

    private func circular(_ signal: BabyCarePrimaryKind) -> some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: icon(signal))
                    .font(.caption)
                Text(shortValue(signal))
                    .font(.caption.weight(.bold))
                    .minimumScaleFactor(0.6)
            }
            .foregroundStyle(Color(hex: 0x2DD4BF))
        }
    }

    private func rectangular(_ signal: BabyCarePrimaryKind) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Baby Care")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(hex: 0x2DD4BF))
            Text(BabyCarePrimarySignal.shortLabel(signal))
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(
                BabyCarePrimarySignal.secondaryLine(
                    snapshot: entry.snapshot,
                    primary: signal,
                    now: entry.date
                )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func icon(_ signal: BabyCarePrimaryKind) -> String {
        switch signal {
        case .openNap: return "moon.zzz.fill"
        case .overdueFeed, .nextFeed: return "waterbottle.fill"
        case .overdueDiaper: return "toilet.fill"
        case .lastCare: return "heart.fill"
        }
    }

    private func shortValue(_ signal: BabyCarePrimaryKind) -> String {
        switch signal {
        case .openNap(let e): return BabyCarePrimarySignal.formatTimer(e)
        case .nextFeed(let s), .overdueFeed(let s), .overdueDiaper(let s):
            return BabyCarePrimarySignal.formatMinutes(s)
        case .lastCare: return "·"
        }
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
        StaticConfiguration(kind: "BabyCareComplication", provider: BabyCareProvider()) { entry in
            BabyCareWidgetEntryView(entry: entry)
                .widgetURL(
                    BabyHomeDeepLink.url(
                        page: BabyCarePrimarySignal.deepLinkPage(
                            for: BabyCarePrimarySignal.resolve(entry.snapshot)
                        )
                    )
                )
        }
        .configurationDisplayName("Baby Care")
        .description("Open nap, next feed, overdue, or last care — face and Smart Stack.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
