import Foundation

/// Max gap between care events for recommendation “in range” on the face.
enum CareGuideIntervals {
    /// Hours between feeds ≈ 24 / feedsMin (upper bound of spacing).
    static func feedMaxGapSeconds(ageDays: Int) -> TimeInterval {
        let band = CareGuideBottleBand.forAgeDays(ageDays)
        let feeds = max(band.feedsMin, 1)
        return 24.0 * 3600.0 / Double(feeds)
    }

    static func diaperMaxGapSeconds(ageDays: Int) -> TimeInterval {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return 3 * 3600
        case .m1_3: return 3.5 * 3600
        case .m3_6, .m6_12, .m12_24: return 4 * 3600
        }
    }

    static func pumpMaxGapSeconds(ageDays: Int) -> TimeInterval {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return 3 * 3600
        case .m1_3: return 4 * 3600
        case .m3_6: return 5 * 3600
        case .m6_12: return 6 * 3600
        case .m12_24: return 12 * 3600
        }
    }

    /// Nap gaps are soft — use a generous gap so color stays teal unless very long.
    static func napMaxGapSeconds(ageDays: Int) -> TimeInterval {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return 4 * 3600
        case .m1_3: return 5 * 3600
        default: return 6 * 3600
        }
    }

    static func maxGapSeconds(for kind: BabyCareLastCareKind, ageDays: Int) -> TimeInterval {
        switch kind {
        case .feed: return feedMaxGapSeconds(ageDays: ageDays)
        case .diaper: return diaperMaxGapSeconds(ageDays: ageDays)
        case .nap: return napMaxGapSeconds(ageDays: ageDays)
        case .pump: return pumpMaxGapSeconds(ageDays: ageDays)
        }
    }

    static func isOutOfRange(
        kind: BabyCareLastCareKind,
        eventAt: Date,
        ageDays: Int,
        now: Date = .now
    ) -> Bool {
        let age = now.timeIntervalSince(eventAt)
        guard age >= 0 else { return false }
        return age > maxGapSeconds(for: kind, ageDays: ageDays)
    }
}
