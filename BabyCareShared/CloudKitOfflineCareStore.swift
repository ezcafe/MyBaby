import CloudKit
import Foundation

/// CloudKit private DB Offline store. Container: `iCloud.vn.in4.MyBaby`.
final class CloudKitOfflineCareStore: OfflineCareStoring, @unchecked Sendable {
    static let containerIdentifier = "iCloud.vn.in4.MyBaby"
    static let recordType = "CareEvent"
    /// Field keys for status projection fetches (avoid pulling unused record data).
    static let careEventDesiredKeys: [CKRecord.FieldKey] = [
        "kind", "at", "schemaVersion", "side", "ml", "diaperKind", "durationSec",
    ]

    private let database: CKDatabase

    init(containerIdentifier: String = CloudKitOfflineCareStore.containerIdentifier) {
        let container = CKContainer(identifier: containerIdentifier)
        self.database = container.privateCloudDatabase
    }

    init(database: CKDatabase) {
        self.database = database
    }

    func append(_ event: CareEvent) async throws {
        let record = Self.makeRecord(from: event)
        do {
            _ = try await database.save(record)
        } catch {
            throw OfflineCareStoreError.saveFailed(error.localizedDescription)
        }
    }

    func fetchRecent(limit: Int) async throws -> [CareEvent] {
        let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "at", ascending: false)]
        do {
            let (results, _) = try await database.records(
                matching: query,
                inZoneWith: nil,
                desiredKeys: Self.careEventDesiredKeys,
                resultsLimit: limit
            )
            var events: [CareEvent] = []
            for (_, result) in results {
                if case .success(let record) = result, let event = Self.event(from: record) {
                    events.append(event)
                }
            }
            return events.sorted { $0.at > $1.at }
        } catch let error as CKError where error.code == .notAuthenticated {
            throw OfflineCareStoreError.iCloudUnavailable("Sign in to iCloud to use Offline")
        } catch {
            throw OfflineCareStoreError.fetchFailed(error.localizedDescription)
        }
    }

    static func makeRecord(from event: CareEvent) -> CKRecord {
        let id = CKRecord.ID(recordName: event.id)
        let record = CKRecord(recordType: recordType, recordID: id)
        record["kind"] = event.kind as CKRecordValue
        record["at"] = event.at as CKRecordValue
        record["schemaVersion"] = event.schemaVersion as CKRecordValue
        if let side = event.side { record["side"] = side as CKRecordValue }
        if let ml = event.ml { record["ml"] = ml as CKRecordValue }
        if let diaperKind = event.diaperKind { record["diaperKind"] = diaperKind as CKRecordValue }
        if let durationSec = event.durationSec { record["durationSec"] = durationSec as CKRecordValue }
        return record
    }

    static func event(from record: CKRecord) -> CareEvent? {
        guard let kind = record["kind"] as? String else { return nil }
        let at = (record["at"] as? Date) ?? .now
        let schemaVersion = (record["schemaVersion"] as? Int) ?? CareEvent.currentSchemaVersion
        return CareEvent(
            id: record.recordID.recordName,
            kind: kind,
            at: at,
            side: record["side"] as? String,
            ml: record["ml"] as? Int,
            diaperKind: record["diaperKind"] as? String,
            durationSec: record["durationSec"] as? Int,
            schemaVersion: schemaVersion
        )
    }

    static func userMessage(for error: OfflineCareStoreError) -> String {
        switch error {
        case .iCloudUnavailable(let message): return message
        case .saveFailed: return "Could not save Offline care"
        case .fetchFailed: return "Could not load Offline care"
        }
    }
}
