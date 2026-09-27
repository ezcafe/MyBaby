import Foundation

enum BabyCareRunningTimerKind: String, Codable, Equatable, Sendable {
    case nap
    case breastLeft
    case breastRight
    case pumpLeft
    case pumpRight
    case pumpBoth

    var kindLabel: String {
        switch self {
        case .nap: return "Nap"
        case .breastLeft: return "Breast L"
        case .breastRight: return "Breast R"
        case .pumpLeft: return "Pump L"
        case .pumpRight: return "Pump R"
        case .pumpBoth: return "Pump"
        }
    }

    var iconSystemName: String {
        switch self {
        case .nap: return "moon.zzz.fill"
        case .breastLeft, .breastRight: return "waterbottle.fill"
        case .pumpLeft, .pumpRight, .pumpBoth: return "drop.fill"
        }
    }

    var deepLinkPage: BabyHomePage {
        switch self {
        case .nap: return .sleep
        case .breastLeft, .breastRight: return .feed
        case .pumpLeft, .pumpRight, .pumpBoth: return .pump
        }
    }

    var lastCareKind: BabyCareLastCareKind {
        switch self {
        case .nap: return .nap
        case .breastLeft, .breastRight: return .feed
        case .pumpLeft, .pumpRight, .pumpBoth: return .pump
        }
    }
}

enum BabyCareLastCareKind: String, Codable, Equatable, Sendable {
    case feed
    case nap
    case diaper
    case pump

    var kindLabel: String {
        switch self {
        case .feed: return "Feed"
        case .nap: return "Nap"
        case .diaper: return "Diaper"
        case .pump: return "Pump"
        }
    }

    var iconSystemName: String {
        switch self {
        case .feed: return "waterbottle.fill"
        case .nap: return "moon.zzz.fill"
        case .diaper: return "leaf.fill"
        case .pump: return "drop.fill"
        }
    }

    var deepLinkPage: BabyHomePage {
        switch self {
        case .feed: return .feed
        case .nap: return .sleep
        case .diaper: return .diaper
        case .pump: return .pump
        }
    }
}

/// Face / Smart Stack care filter (Option 1: Auto + fixed types).
enum BabyCareComplicationCareType: String, CaseIterable, Equatable, Sendable {
    case auto
    case feed
    case sleep
    case diaper
    case pump

    /// Fixed slots always deep-link here; Auto uses the resolved display page.
    var fixedDeepLinkPage: BabyHomePage? {
        switch self {
        case .auto: return nil
        case .feed: return .feed
        case .sleep: return .sleep
        case .diaper: return .diaper
        case .pump: return .pump
        }
    }

    var fixedLastCareKind: BabyCareLastCareKind? {
        switch self {
        case .auto: return nil
        case .feed: return .feed
        case .sleep: return .nap
        case .diaper: return .diaper
        case .pump: return .pump
        }
    }
}

enum BabyCareComplicationColor: Equatable, Sendable {
    case teal
    case red
}

/// Glance model for all accessory families (Gate A2).
struct BabyCareComplicationDisplay: Equatable, Sendable {
    enum Mode: Equatable, Sendable {
        case running(kind: BabyCareRunningTimerKind, startedAt: Date)
        case idle(kind: BabyCareLastCareKind, at: Date, sentence: String)
        case empty
    }

    var mode: Mode
    var color: BabyCareComplicationColor
    var kindLabel: String
    var iconSystemName: String
    var deepLinkPage: BabyHomePage
    /// Relative age for idle (e.g. "25m"); unused when running (use Text.timer).
    var idleRelative: String?

    static func resolve(
        _ snapshot: BabyHomeStatusSnapshot,
        careType: BabyCareComplicationCareType = .auto,
        now: Date = .now
    ) -> BabyCareComplicationDisplay {
        switch careType {
        case .auto:
            return resolveAuto(snapshot, now: now)
        case .feed, .sleep, .diaper, .pump:
            return resolveFixed(snapshot, careType: careType, now: now)
        }
    }

    private static func resolveAuto(
        _ snapshot: BabyHomeStatusSnapshot,
        now: Date
    ) -> BabyCareComplicationDisplay {
        if let running = resolveRunning(snapshot, matching: nil) {
            return makeRunning(running.kind, startedAt: running.startedAt)
        }

        if let last = resolveLastCare(snapshot, matching: nil) {
            return makeIdle(last, ageDays: snapshot.ageDays, now: now)
        }

        return makeEmpty(deepLinkPage: .lastCare)
    }

    private static func resolveFixed(
        _ snapshot: BabyHomeStatusSnapshot,
        careType: BabyCareComplicationCareType,
        now: Date
    ) -> BabyCareComplicationDisplay {
        let page = careType.fixedDeepLinkPage ?? .lastCare
        let lastKind = careType.fixedLastCareKind

        if let lastKind, let running = resolveRunning(snapshot, matching: lastKind) {
            return makeRunning(running.kind, startedAt: running.startedAt, deepLinkOverride: page)
        }

        if let lastKind, let last = resolveLastCare(snapshot, matching: lastKind) {
            var idle = makeIdle(last, ageDays: snapshot.ageDays, now: now)
            idle.deepLinkPage = page
            return idle
        }

        return makeEmpty(deepLinkPage: page, kindLabel: lastKind?.kindLabel ?? "Care")
    }

    private static func makeRunning(
        _ kind: BabyCareRunningTimerKind,
        startedAt: Date,
        deepLinkOverride: BabyHomePage? = nil
    ) -> BabyCareComplicationDisplay {
        BabyCareComplicationDisplay(
            mode: .running(kind: kind, startedAt: startedAt),
            color: .teal,
            kindLabel: kind.kindLabel,
            iconSystemName: kind.iconSystemName,
            deepLinkPage: deepLinkOverride ?? kind.deepLinkPage,
            idleRelative: nil
        )
    }

    private static func makeIdle(
        _ last: (kind: BabyCareLastCareKind, at: Date, sentence: String),
        ageDays: Int,
        now: Date
    ) -> BabyCareComplicationDisplay {
        let out = CareGuideIntervals.isOutOfRange(
            kind: last.kind,
            eventAt: last.at,
            ageDays: ageDays,
            now: now
        )
        let relative = formatRelative(now.timeIntervalSince(last.at))
        let sentence = last.sentence.isEmpty
            ? "Last \(last.kind.kindLabel.lowercased()) · \(relative)"
            : last.sentence
        return BabyCareComplicationDisplay(
            mode: .idle(kind: last.kind, at: last.at, sentence: sentence),
            color: out ? .red : .teal,
            kindLabel: last.kind.kindLabel,
            iconSystemName: last.kind.iconSystemName,
            deepLinkPage: last.kind.deepLinkPage,
            idleRelative: relative
        )
    }

    private static func makeEmpty(
        deepLinkPage: BabyHomePage,
        kindLabel: String = "Care"
    ) -> BabyCareComplicationDisplay {
        BabyCareComplicationDisplay(
            mode: .empty,
            color: .teal,
            kindLabel: kindLabel,
            iconSystemName: "heart.fill",
            deepLinkPage: deepLinkPage,
            idleRelative: nil
        )
    }

    /// `matching` nil = any running timer (auto priority). Else only that care family.
    private static func resolveRunning(
        _ snapshot: BabyHomeStatusSnapshot,
        matching: BabyCareLastCareKind?
    ) -> (kind: BabyCareRunningTimerKind, startedAt: Date)? {
        let candidates: [(BabyCareRunningTimerKind, Date)] = {
            var list: [(BabyCareRunningTimerKind, Date)] = []
            if let start = snapshot.openNapStartedAt {
                list.append((.nap, start))
            }
            if let kind = snapshot.runningTimerKind, let start = snapshot.runningTimerStartedAt {
                list.append((kind, start))
            }
            return list
        }()

        let filtered: [(BabyCareRunningTimerKind, Date)]
        if let matching {
            filtered = candidates.filter { $0.0.lastCareKind == matching }
        } else {
            // Auto priority: nap → breast → pump (first match in candidate order for nap,
            // then prefer breast over pump when both exist without nap).
            if let nap = candidates.first(where: { $0.0 == .nap }) {
                return nap
            }
            if let breast = candidates.first(where: {
                $0.0 == .breastLeft || $0.0 == .breastRight
            }) {
                return breast
            }
            if let pump = candidates.first(where: {
                $0.0 == .pumpLeft || $0.0 == .pumpRight || $0.0 == .pumpBoth
            }) {
                return pump
            }
            return nil
        }

        // Fixed: prefer nap, then whatever is running for that family.
        if let nap = filtered.first(where: { $0.0 == .nap }) {
            return nap
        }
        return filtered.first
    }

    private static func resolveLastCare(
        _ snapshot: BabyHomeStatusSnapshot,
        matching: BabyCareLastCareKind?
    ) -> (kind: BabyCareLastCareKind, at: Date, sentence: String)? {
        var candidates: [(BabyCareLastCareKind, Date, String)] = []
        if let at = snapshot.lastFeedAt {
            candidates.append((.feed, at, snapshot.lastFeed.isEmpty ? "" : snapshot.lastFeed.sentence))
        }
        if let at = snapshot.lastNapAt {
            candidates.append((.nap, at, snapshot.lastNap.isEmpty ? "" : snapshot.lastNap.sentence))
        }
        if let at = snapshot.lastDiaperAt {
            candidates.append((.diaper, at, snapshot.lastDiaper.isEmpty ? "" : snapshot.lastDiaper.sentence))
        }
        if let at = snapshot.lastPumpAt {
            candidates.append((.pump, at, snapshot.lastPump.isEmpty ? "" : snapshot.lastPump.sentence))
        }
        if let matching {
            return candidates.first(where: { $0.0 == matching }).map { ($0.0, $0.1, $0.2) }
        }
        guard let best = candidates.max(by: { $0.1 < $1.1 }) else { return nil }
        return (best.0, best.1, best.2)
    }

    static func formatRelative(_ interval: TimeInterval) -> String {
        formatRelativeLines(interval).line1
    }

    /// Small faces may stack two lines; Option A keeps a single hours token when ≥1h.
    static func formatRelativeLines(_ interval: TimeInterval) -> (line1: String, line2: String?) {
        let m = max(0, Int(interval / 60))
        if m < 60 { return ("\(m)m", nil) }
        let h = m / 60
        return ("\(h)h", nil)
    }
}
