import Foundation

/// sample = preview; live = GraphQL; offline = iCloud CareEvent store.
enum CareDataMode: String, Equatable, Sendable {
    case sample
    case live
    case offline
}

/// Append-only Offline care event (CloudKit `CareEvent` / in-memory fake).
struct CareEvent: Equatable, Sendable, Identifiable {
    var id: String
    var kind: String
    var at: Date
    var side: String?
    var ml: Int?
    var diaperKind: String?
    var durationSec: Int?
    var schemaVersion: Int

    static let currentSchemaVersion = 1

    init(
        id: String = UUID().uuidString,
        kind: String,
        at: Date = .now,
        side: String? = nil,
        ml: Int? = nil,
        diaperKind: String? = nil,
        durationSec: Int? = nil,
        schemaVersion: Int = CareEvent.currentSchemaVersion
    ) {
        self.id = id
        self.kind = kind
        self.at = at
        self.side = side
        self.ml = ml
        self.diaperKind = diaperKind
        self.durationSec = durationSec
        self.schemaVersion = schemaVersion
    }
}

enum OfflineCareStoreError: Error, Equatable {
    case iCloudUnavailable(String)
    case saveFailed(String)
    case fetchFailed(String)
}

protocol OfflineCareStoring: AnyObject {
    func append(_ event: CareEvent) async throws
    func fetchRecent(limit: Int) async throws -> [CareEvent]
}

/// In-memory store for unit tests.
final class InMemoryOfflineCareStore: OfflineCareStoring, @unchecked Sendable {
    private var events: [CareEvent] = []
    private let lock = NSLock()

    func append(_ event: CareEvent) async throws {
        lock.lock()
        events.append(event)
        lock.unlock()
    }

    func fetchRecent(limit: Int) async throws -> [CareEvent] {
        lock.lock()
        let sorted = events.sorted { $0.at > $1.at }
        let slice = Array(sorted.prefix(limit))
        lock.unlock()
        return slice
    }

    func allEvents() -> [CareEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }
}

/// Projects Offline events into a home snapshot (vital last-* fields).
enum OfflineSnapshotProjector {
    static func make(
        events: [CareEvent],
        ageDays: Int = 120,
        now: Date = .now
    ) -> BabyHomeStatusSnapshot {
        var snap = BabyHomeStatusSnapshot.sampleNextFeed()
        snap.ageDays = ageDays
        snap.openNapStartedAt = nil
        snap.runningTimerKind = nil
        snap.runningTimerStartedAt = nil
        snap.lastFeedAt = nil
        snap.lastNapAt = nil
        snap.lastDiaperAt = nil
        snap.lastPumpAt = nil
        snap.lastFeed = BabyCareStatusLine(iconSystemName: "drop", sentence: "No feed yet", isEmpty: true)
        snap.lastNap = BabyCareStatusLine(iconSystemName: "moon", sentence: "No nap yet", isEmpty: true)
        snap.lastDiaper = BabyCareStatusLine(iconSystemName: "toilet", sentence: "No diaper yet", isEmpty: true)
        snap.lastPump = BabyCareStatusLine(iconSystemName: "waterbottle", sentence: "No pump yet", isEmpty: true)

        let chronological = events.sorted { $0.at < $1.at }
        for event in chronological {
            apply(event, into: &snap, now: now)
        }
        return snap
    }

    private static func apply(_ event: CareEvent, into snap: inout BabyHomeStatusSnapshot, now: Date) {
        switch event.kind {
        case "breast_start":
            snap.runningTimerStartedAt = event.at
            snap.runningTimerKind = event.side == "r" ? .breastRight : .breastLeft
            snap.openNapStartedAt = nil
        case "breast_stop":
            snap.runningTimerKind = nil
            snap.runningTimerStartedAt = nil
            snap.lastFeedAt = event.at
            let sideLabel = event.side == "r" ? "Right" : "Left"
            let dur = event.durationSec.map { " · \($0)s" } ?? ""
            snap.lastFeed = BabyCareStatusLine(
                iconSystemName: "drop.fill",
                sentence: "Breast \(sideLabel)\(dur)",
                isEmpty: false
            )
        case "bottle":
            snap.lastFeedAt = event.at
            let ml = event.ml.map { "\($0) ml" } ?? "bottle"
            snap.lastFeed = BabyCareStatusLine(
                iconSystemName: "waterbottle.fill",
                sentence: "Bottle · \(ml)",
                isEmpty: false
            )
            if let ml = event.ml {
                var recent = snap.recentBottleMl
                if !recent.contains(ml) { recent.insert(ml, at: 0) }
                snap.recentBottleMl = Array(recent.prefix(5))
            }
        case "nap_start":
            snap.openNapStartedAt = event.at
            snap.runningTimerKind = nil
            snap.runningTimerStartedAt = nil
        case "nap_stop":
            snap.openNapStartedAt = nil
            snap.lastNapAt = event.at
            snap.lastNap = BabyCareStatusLine(
                iconSystemName: "moon.fill",
                sentence: "Nap ended",
                isEmpty: false
            )
        case "diaper":
            snap.lastDiaperAt = event.at
            let kind = event.diaperKind ?? "change"
            snap.lastDiaper = BabyCareStatusLine(
                iconSystemName: "toilet.fill",
                sentence: "Diaper · \(kind)",
                isEmpty: false
            )
        case "pump_start":
            snap.runningTimerStartedAt = event.at
            switch event.side {
            case "r": snap.runningTimerKind = .pumpRight
            case "both": snap.runningTimerKind = .pumpBoth
            default: snap.runningTimerKind = .pumpLeft
            }
            snap.openNapStartedAt = nil
        case "pump_stop":
            snap.runningTimerKind = nil
            snap.runningTimerStartedAt = nil
            snap.lastPumpAt = event.at
            snap.lastPump = BabyCareStatusLine(
                iconSystemName: "waterbottle.fill",
                sentence: "Pump stop",
                isEmpty: false
            )
        case "pump_amount":
            snap.lastPumpAt = event.at
            let ml = event.ml.map { "\($0) ml" } ?? "amount"
            snap.lastPump = BabyCareStatusLine(
                iconSystemName: "waterbottle.fill",
                sentence: "Pump · \(ml)",
                isEmpty: false
            )
        default:
            break
        }
        _ = now
    }
}
