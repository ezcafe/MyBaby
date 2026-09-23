import Foundation

struct BabyCareStatusLine: Equatable, Sendable {
    var iconSystemName: String
    var sentence: String
    var isEmpty: Bool
}

struct BabyHomeStatusSnapshot: Equatable, Sendable {
    var title: String
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

    static let defaultBottleChips = [60, 90, 120]

    static func ageTitle(ageDays: Int) -> String {
        if ageDays < 30 {
            let n = max(ageDays, 0)
            return "Baby Care · \(n) \(n == 1 ? "day" : "days")"
        }
        let months = ageDays / 30
        return "Baby Care · \(months) \(months == 1 ? "month" : "months")"
    }

    static func sampleNextFeed(now: Date = .now) -> BabyHomeStatusSnapshot {
        BabyHomeStatusSnapshot(
            title: ageTitle(ageDays: 120),
            feedHeaderDetail: "Next feed is in about 12min.",
            feedTip: "About 6–8 feeds a day.",
            bottleTip: "Pick an amount below.",
            bottleChipMls: defaultBottleChips,
            sleepTip: "Tap to start or end a nap.",
            diaperTip: "Tap a kind to log a change.",
            pumpTip: "Tap Pump L or R to start.",
            openNapStartedAt: nil,
            nextFeedInSeconds: 12 * 60,
            feedOverdueSeconds: nil,
            diaperOverdueSeconds: nil,
            lastFeed: .init(
                iconSystemName: "bottle.fill",
                sentence: "Last feed was a bottle of 120 ml, 25m ago.",
                isEmpty: false
            ),
            lastNap: .init(
                iconSystemName: "moon.zzz.fill",
                sentence: "No nap logged yet.",
                isEmpty: true
            ),
            lastDiaper: .init(
                iconSystemName: "toilet.fill",
                sentence: "Last diaper was wet, 1h ago.",
                isEmpty: false
            ),
            lastPump: .init(
                iconSystemName: "drop.fill",
                sentence: "No pump logged yet.",
                isEmpty: true
            )
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
            sentence: "Baby is napping now (for 12:04).",
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
        case .overdueFeed, .nextFeed: return .feedBottle
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
}
