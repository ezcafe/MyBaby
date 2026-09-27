import Foundation

/// App Group mailbox for complications — status only, never tokens.
struct BabyCareStatusDTO: Codable, Equatable, Sendable {
    var version: Int
    var writtenAt: Date
    var openNapStartedAt: Date?
    var runningTimerKind: String?
    var runningTimerStartedAt: Date?
    var nextFeedInSeconds: TimeInterval?
    var feedOverdueSeconds: TimeInterval?
    var diaperOverdueSeconds: TimeInterval?
    var lastFeedIcon: String
    var lastFeedSentence: String
    var lastNapIcon: String
    var lastNapSentence: String
    var lastDiaperIcon: String
    var lastDiaperSentence: String
    var lastPumpIcon: String?
    var lastPumpSentence: String?
    var lastFeedAt: Date?
    var lastNapAt: Date?
    var lastDiaperAt: Date?
    var lastPumpAt: Date?
    var ageDays: Int
}

enum BabyCareStatusStore {
    static let appGroupId = "group.vn.in4.MyBaby"
    static let storageKey = "BabyCareStatusDTO.v1"
    static let dtoVersion = 2

    /// Coding keys that must never appear on the DTO (security check for tests).
    static let forbiddenKeys: Set<String> = [
        "token", "pairingCode", "authorization", "mny", "password", "secret",
    ]

    static func defaults(suiteName: String = appGroupId) -> UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func dto(from snapshot: BabyHomeStatusSnapshot, now: Date = .now) -> BabyCareStatusDTO {
        BabyCareStatusDTO(
            version: dtoVersion,
            writtenAt: now,
            openNapStartedAt: snapshot.openNapStartedAt,
            runningTimerKind: snapshot.runningTimerKind?.rawValue,
            runningTimerStartedAt: snapshot.runningTimerStartedAt,
            nextFeedInSeconds: snapshot.nextFeedInSeconds,
            feedOverdueSeconds: snapshot.feedOverdueSeconds,
            diaperOverdueSeconds: snapshot.diaperOverdueSeconds,
            lastFeedIcon: snapshot.lastFeed.iconSystemName,
            lastFeedSentence: snapshot.lastFeed.sentence,
            lastNapIcon: snapshot.lastNap.iconSystemName,
            lastNapSentence: snapshot.lastNap.sentence,
            lastDiaperIcon: snapshot.lastDiaper.iconSystemName,
            lastDiaperSentence: snapshot.lastDiaper.sentence,
            lastPumpIcon: snapshot.lastPump.iconSystemName,
            lastPumpSentence: snapshot.lastPump.sentence,
            lastFeedAt: snapshot.lastFeedAt,
            lastNapAt: snapshot.lastNapAt,
            lastDiaperAt: snapshot.lastDiaperAt,
            lastPumpAt: snapshot.lastPumpAt,
            ageDays: snapshot.ageDays
        )
    }

    static func save(_ dto: BabyCareStatusDTO, suiteName: String = appGroupId) {
        guard let defaults = defaults(suiteName: suiteName) else { return }
        guard let data = try? JSONEncoder().encode(dto) else { return }
        defaults.set(data, forKey: storageKey)
    }

    static func save(snapshot: BabyHomeStatusSnapshot, suiteName: String = appGroupId, now: Date = .now) {
        save(dto(from: snapshot, now: now), suiteName: suiteName)
    }

    static func load(suiteName: String = appGroupId) -> BabyCareStatusDTO? {
        guard let defaults = defaults(suiteName: suiteName),
              let data = defaults.data(forKey: storageKey)
        else { return nil }
        return try? JSONDecoder().decode(BabyCareStatusDTO.self, from: data)
    }

    /// Build a snapshot for signal/widget UI; falls back to sample when store empty.
    static func snapshotForWidgets(
        suiteName: String = appGroupId,
        now: Date = .now
    ) -> BabyHomeStatusSnapshot {
        guard let dto = load(suiteName: suiteName) else {
            return .sampleNextFeed(now: now)
        }
        return apply(dto: dto, onto: .sampleNextFeed(now: now))
    }

    static func apply(dto: BabyCareStatusDTO, onto base: BabyHomeStatusSnapshot) -> BabyHomeStatusSnapshot {
        var snap = base
        snap.ageDays = dto.ageDays
        snap.openNapStartedAt = dto.openNapStartedAt
        snap.runningTimerKind = dto.runningTimerKind.flatMap(BabyCareRunningTimerKind.init(rawValue:))
        snap.runningTimerStartedAt = dto.runningTimerStartedAt
        snap.nextFeedInSeconds = dto.nextFeedInSeconds
        snap.feedOverdueSeconds = dto.feedOverdueSeconds
        snap.diaperOverdueSeconds = dto.diaperOverdueSeconds
        snap.lastFeed = .init(
            iconSystemName: dto.lastFeedIcon,
            sentence: dto.lastFeedSentence,
            isEmpty: dto.lastFeedSentence.isEmpty
        )
        snap.lastNap = .init(
            iconSystemName: dto.lastNapIcon,
            sentence: dto.lastNapSentence,
            isEmpty: dto.lastNapSentence.isEmpty
        )
        snap.lastDiaper = .init(
            iconSystemName: dto.lastDiaperIcon,
            sentence: dto.lastDiaperSentence,
            isEmpty: dto.lastDiaperSentence.isEmpty
        )
        if let icon = dto.lastPumpIcon, let sentence = dto.lastPumpSentence {
            snap.lastPump = .init(
                iconSystemName: icon,
                sentence: sentence,
                isEmpty: sentence.isEmpty
            )
        }
        snap.lastFeedAt = dto.lastFeedAt
        snap.lastNapAt = dto.lastNapAt
        snap.lastDiaperAt = dto.lastDiaperAt
        snap.lastPumpAt = dto.lastPumpAt
        return snap
    }

    /// Encoded JSON object keys — used to assert no secrets.
    static func encodedObjectKeys(_ dto: BabyCareStatusDTO) throws -> Set<String> {
        let data = try JSONEncoder().encode(dto)
        let obj = try JSONSerialization.jsonObject(with: data)
        guard let dict = obj as? [String: Any] else { return [] }
        return Set(dict.keys)
    }
}
