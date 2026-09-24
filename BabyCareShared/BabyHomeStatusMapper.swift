import Foundation

struct BabyHomeQuickStatusPayload: Decodable, Equatable, Sendable {
    var lastFeed: BabyStatusEventDTO?
    var lastSleep: BabyStatusEventDTO?
    var lastDiaper: BabyStatusEventDTO?
    var lastPump: BabyStatusEventDTO?
    var openSleep: BabyOpenSleepDTO?
    var feedsToday: Int?
    var birthDate: String?
    var latestWeightKg: Double?
    var recentBottleMl: [Double]?
}

struct BabyStatusEventDTO: Decodable, Equatable, Sendable {
    var id: String?
    var type: String?
    var at: String?
    var endedAt: String?
    var summary: String?
}

struct BabyOpenSleepDTO: Decodable, Equatable, Sendable {
    var id: String?
    var type: String?
    var occurredAt: String?
    var endedAt: String?
}

enum BabyHomeStatusMapper {
    private static let isoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoBasic: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func map(
        _ payload: BabyHomeQuickStatusPayload,
        now: Date = .now
    ) -> BabyHomeStatusSnapshot {
        let ageDays = ageDays(from: payload.birthDate, now: now)
        let recentInts = (payload.recentBottleMl ?? []).map { Int($0.rounded()) }
        let band = CareGuideBottleBand.forAgeDays(ageDays)
        let chips = BabyBottleChipMls.build(
            recentBottleMl: recentInts,
            snaps: band.snaps,
            limit: 3
        )
        let openNap = parseDate(payload.openSleep?.occurredAt)

        return BabyHomeStatusSnapshot(
            title: BabyHomeStatusSnapshot.ageTitle(ageDays: ageDays),
            ageDays: ageDays,
            feedHeaderDetail: nil,
            feedTip: CareGuideTips.breastFeedsTip(ageDays: ageDays),
            bottleTip: CareGuideTips.bottleTip(ageDays: ageDays),
            bottleChipMls: chips,
            sleepTip: CareGuideTips.sleepTip(ageDays: ageDays),
            diaperTip: CareGuideTips.diaperTip(ageDays: ageDays),
            pumpTip: CareGuideTips.pumpTip(ageDays: ageDays),
            openNapStartedAt: openNap,
            nextFeedInSeconds: nil,
            feedOverdueSeconds: nil,
            diaperOverdueSeconds: nil,
            lastFeed: statusLine(
                summary: payload.lastFeed?.summary,
                emptyIcon: "waterbottle.fill",
                emptyText: "No feed yet"
            ),
            lastNap: statusLine(
                summary: payload.lastSleep?.summary,
                emptyIcon: "moon.zzz.fill",
                emptyText: "No nap yet"
            ),
            lastDiaper: statusLine(
                summary: payload.lastDiaper?.summary,
                emptyIcon: "leaf.fill",
                emptyText: "No diaper yet"
            ),
            lastPump: statusLine(
                summary: payload.lastPump?.summary,
                emptyIcon: "drop.fill",
                emptyText: "No pump yet"
            ),
            recentBottleMl: recentInts
        )
    }

    static func decodeStatusData(_ data: Data) throws -> BabyHomeQuickStatusPayload {
        let wrapper = try JSONDecoder().decode(StatusDataWrapper.self, from: data)
        return wrapper.babyHomeQuickStatus
    }

    private struct StatusDataWrapper: Decodable {
        var babyHomeQuickStatus: BabyHomeQuickStatusPayload
    }

    private static func statusLine(
        summary: String?,
        emptyIcon: String,
        emptyText: String
    ) -> BabyCareStatusLine {
        let text = summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            return .init(iconSystemName: emptyIcon, sentence: emptyText, isEmpty: true)
        }
        return .init(iconSystemName: emptyIcon, sentence: text, isEmpty: false)
    }

    private static func ageDays(from birthDate: String?, now: Date) -> Int {
        guard let birthDate, !birthDate.isEmpty else { return 120 }
        let parts = birthDate.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return 120 }
        var comps = DateComponents()
        comps.year = parts[0]
        comps.month = parts[1]
        comps.day = parts[2]
        guard let birth = Calendar.current.date(from: comps) else { return 120 }
        let days = Calendar.current.dateComponents([.day], from: birth, to: now).day ?? 120
        return max(days, 0)
    }

    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }
        return isoFractional.date(from: raw) ?? isoBasic.date(from: raw)
    }
}
