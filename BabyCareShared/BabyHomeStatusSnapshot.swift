import Foundation

struct BabyCareStatusLine: Equatable, Sendable {
    var iconSystemName: String
    var sentence: String
    var isEmpty: Bool
}

struct BabyHomeStatusSnapshot: Equatable, Sendable {
    var title: String
    /// Calendar age in days — drives Last care header (“Last care · 4 months”).
    var ageDays: Int
    var feedHeaderDetail: String?
    var feedTip: String
    var bottleTip: String
    var bottleChipMls: [Int]
    var sleepTip: String
    var diaperTip: String
    var pumpTip: String
    var openNapStartedAt: Date?
    var nextFeedInSeconds: TimeInterval?
    var feedOverdueSeconds: TimeInterval?
    var diaperOverdueSeconds: TimeInterval?
    var lastFeed: BabyCareStatusLine
    var lastNap: BabyCareStatusLine
    var lastDiaper: BabyCareStatusLine
    var lastPump: BabyCareStatusLine
    /// Distinct recent formula ml for chip builder (web `recentBottleMl`).
    var recentBottleMl: [Int]

    /// Last care page lead, e.g. “Last care · 4 months”.
    var lastCareHeaderLead: String {
        Self.lastCareLead(ageDays: ageDays)
    }

    /// Unused in chrome after Gate A2 (title removed); kept for samples / future.
    static func ageTitle(ageDays: Int) -> String {
        "Baby Care · \(agePhrase(ageDays: ageDays))"
    }

    static func agePhrase(ageDays: Int) -> String {
        if ageDays < 30 {
            let n = max(ageDays, 0)
            return "\(n) \(n == 1 ? "day" : "days")"
        }
        let months = ageDays / 30
        return "\(months) \(months == 1 ? "month" : "months")"
    }

    static func lastCareLead(ageDays: Int) -> String {
        "Last care · \(agePhrase(ageDays: ageDays))"
    }

    static func sampleNextFeed(now: Date = .now) -> BabyHomeStatusSnapshot {
        let ageDays = 120
        let band = CareGuideBottleBand.forAgeDays(ageDays)
        let recent: [Int] = []
        let chips = BabyBottleChipMls.build(
            recentBottleMl: recent,
            snaps: band.snaps,
            limit: 3
        )
        return BabyHomeStatusSnapshot(
            title: ageTitle(ageDays: ageDays),
            ageDays: ageDays,
            feedHeaderDetail: "Next feed is in about 12min.",
            feedTip: CareGuideTips.breastFeedsTip(ageDays: ageDays),
            bottleTip: CareGuideTips.bottleTip(ageDays: ageDays),
            bottleChipMls: chips,
            sleepTip: CareGuideTips.sleepTip(ageDays: ageDays),
            diaperTip: CareGuideTips.diaperTip(ageDays: ageDays),
            pumpTip: CareGuideTips.pumpTip(ageDays: ageDays),
            openNapStartedAt: nil,
            nextFeedInSeconds: 12 * 60,
            feedOverdueSeconds: nil,
            diaperOverdueSeconds: nil,
            lastFeed: .init(
                // `bottle.fill` often renders blank on watchOS — use waterbottle.
                iconSystemName: "waterbottle.fill",
                sentence: "Bottle 120 ml · 25m",
                isEmpty: false
            ),
            lastNap: .init(
                iconSystemName: "moon.zzz.fill",
                sentence: "No nap yet",
                isEmpty: true
            ),
            lastDiaper: .init(
                iconSystemName: "leaf.fill",
                sentence: "Wet · 1h",
                isEmpty: false
            ),
            lastPump: .init(
                iconSystemName: "drop.fill",
                sentence: "No pump yet",
                isEmpty: true
            ),
            recentBottleMl: recent
        )
    }

    static func sampleOpenNap(now: Date = .now) -> BabyHomeStatusSnapshot {
        var s = sampleNextFeed(now: now)
        s.openNapStartedAt = now.addingTimeInterval(-12 * 60 - 4)
        s.feedHeaderDetail = nil
        s.nextFeedInSeconds = nil
        s.sleepTip = "Nap is running."
        s.lastNap = .init(
            iconSystemName: "moon.zzz.fill",
            sentence: "Napping · 12:04",
            isEmpty: false
        )
        return s
    }
}

enum BabyCarePrimaryKind: Equatable, Sendable {
    case openNap(elapsed: TimeInterval)
    case overdueFeed(duration: TimeInterval)
    case overdueDiaper(duration: TimeInterval)
    case nextFeed(inSeconds: TimeInterval)
    case lastCare(summary: String)
}

enum BabyCarePrimarySignal {
    /// Priority: open nap → overdue feed/diaper → next feed → last care.
    static func resolve(_ snapshot: BabyHomeStatusSnapshot, now: Date = .now) -> BabyCarePrimaryKind {
        if let start = snapshot.openNapStartedAt {
            return .openNap(elapsed: max(0, now.timeIntervalSince(start)))
        }
        if let overdue = snapshot.feedOverdueSeconds, overdue > 0 {
            return .overdueFeed(duration: overdue)
        }
        if let overdue = snapshot.diaperOverdueSeconds, overdue > 0 {
            return .overdueDiaper(duration: overdue)
        }
        if let next = snapshot.nextFeedInSeconds, next >= 0 {
            return .nextFeed(inSeconds: next)
        }
        let summary = snapshot.lastFeed.isEmpty
            ? "No feed logged yet."
            : snapshot.lastFeed.sentence
        return .lastCare(summary: summary)
    }

    static func deepLinkPage(for kind: BabyCarePrimaryKind) -> BabyHomePage {
        switch kind {
        case .openNap: return .sleep
        case .overdueFeed, .nextFeed: return .feed
        case .overdueDiaper: return .diaper
        case .lastCare: return .lastCare
        }
    }

    static func shortLabel(_ kind: BabyCarePrimaryKind) -> String {
        switch kind {
        case .openNap(let elapsed):
            return "Nap \(Self.formatTimer(elapsed))"
        case .overdueFeed(let d):
            return "Feed overdue \(Self.formatMinutes(d))"
        case .overdueDiaper(let d):
            return "Diaper overdue \(Self.formatMinutes(d))"
        case .nextFeed(let s):
            return "Feed \(Self.formatMinutes(s))"
        case .lastCare(let summary):
            return summary
        }
    }

    static func formatTimer(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }

    static func formatMinutes(_ interval: TimeInterval) -> String {
        let m = max(0, Int(interval / 60))
        return "\(m)m"
    }

    /// Last care / complication hero kind label (short).
    static func heroKindLabel(_ kind: BabyCarePrimaryKind) -> String {
        switch kind {
        case .openNap: return "Nap"
        case .overdueFeed: return "Feed overdue"
        case .overdueDiaper: return "Diaper overdue"
        case .nextFeed: return "Next feed"
        case .lastCare: return "Last care"
        }
    }

    /// Large value for Last care hero / rectangular primary.
    static func heroValue(_ kind: BabyCarePrimaryKind) -> String {
        switch kind {
        case .openNap(let elapsed):
            return formatTimer(elapsed)
        case .overdueFeed(let d), .overdueDiaper(let d), .nextFeed(let d):
            return formatMinutes(d)
        case .lastCare(let summary):
            return summary
        }
    }

    /// One secondary line under rectangular primary (not the same as primary).
    static func secondaryLine(
        snapshot: BabyHomeStatusSnapshot,
        primary: BabyCarePrimaryKind,
        now: Date = .now
    ) -> String {
        switch primary {
        case .openNap:
            if let next = snapshot.nextFeedInSeconds, next >= 0 {
                return "Next feed \(formatMinutes(next))"
            }
            return snapshot.lastFeed.isEmpty ? "No feed yet" : snapshot.lastFeed.sentence
        case .overdueFeed, .nextFeed:
            if snapshot.openNapStartedAt != nil {
                let elapsed = max(0, now.timeIntervalSince(snapshot.openNapStartedAt!))
                return "Nap \(formatTimer(elapsed))"
            }
            return snapshot.lastNap.isEmpty ? snapshot.lastDiaper.sentence : snapshot.lastNap.sentence
        case .overdueDiaper:
            return snapshot.lastFeed.isEmpty ? "Check feed" : snapshot.lastFeed.sentence
        case .lastCare:
            return snapshot.lastNap.isEmpty ? snapshot.lastDiaper.sentence : snapshot.lastNap.sentence
        }
    }
}
