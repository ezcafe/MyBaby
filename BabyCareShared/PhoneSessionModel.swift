import Foundation
import Observation

/// Thin companion session for Phone (Connect / Offline / Cloud). Care home uses `BabyHomeStatusModel` via `PhoneCareWiring`.
@Observable
@MainActor
final class PhoneSessionModel {
    var isConnected: Bool = false
    var mode: CareDataMode = .sample
    /// User-visible Offline / iCloud error or status detail.
    var statusFail: String?
    var iCloudStatusText: String = "Not using Offline"

    private(set) var offlineStore: (any OfflineCareStoring)?
    private(set) var graphQLClient: (any BabyGraphQLClienting)?

    /// Start Offline only after a successful store health fetch.
    func useOffline(store: any OfflineCareStoring = CloudKitOfflineCareStore()) async {
        statusFail = nil
        do {
            _ = try await store.fetchRecent(limit: 1)
            offlineStore = store
            graphQLClient = nil
            mode = .offline
            isConnected = true
            CareDataModeStore.save(.offline)
            iCloudStatusText = "iCloud: OK"
        } catch let err as OfflineCareStoreError {
            offlineStore = nil
            isConnected = false
            mode = .sample
            statusFail = CloudKitOfflineCareStore.userMessage(for: err)
            iCloudStatusText = statusFail ?? "iCloud unavailable"
            CareDataModeStore.clear()
        } catch {
            offlineStore = nil
            isConnected = false
            mode = .sample
            statusFail = "Could not start Offline"
            iCloudStatusText = statusFail ?? "iCloud unavailable"
            CareDataModeStore.clear()
        }
    }

    func useLive(client: any BabyGraphQLClienting) {
        mode = .live
        graphQLClient = client
        offlineStore = nil
        isConnected = true
        statusFail = nil
        iCloudStatusText = "Not using Offline"
        CareDataModeStore.save(.live)
    }

    /// Leave session → Connect. Keeps CloudKit CareEvents. Clears live token.
    func leave(tokenStore: any BabyAPITokenStoring = BabyAPITokenStore()) {
        try? tokenStore.clear()
        BabyAPIConfig.clearBaseURL()
        graphQLClient = nil
        offlineStore = nil
        mode = .sample
        isConnected = false
        statusFail = nil
        iCloudStatusText = "Not using Offline"
        CareDataModeStore.clear()
    }

    /// Redeem pairing code then enter live. `pairClient` must use the chosen Cloud origin.
    func connectWithPairingCode(
        code: String,
        pairClient: any WatchPairClienting,
        tokenStore: any BabyAPITokenStoring = BabyAPITokenStore()
    ) async -> Bool {
        statusFail = nil
        do {
            let result = try await pairClient.redeem(code: code)
            guard BabyAPIConfig.saveBaseURL(result.baseURL) else {
                statusFail = "Bad URL from server"
                return false
            }
            try tokenStore.save(result.token)
            let client = BabyGraphQLClient(baseURLRaw: result.baseURL, token: result.token)
            useLive(client: client)
            return true
        } catch let err as WatchPairError {
            statusFail = Self.pairUserMessage(err)
            return false
        } catch {
            statusFail = "Could not connect"
            return false
        }
    }

    /// Advanced: paste URL + token.
    func connectWithPastedCredentials(
        baseURLRaw: String,
        token: String,
        tokenStore: any BabyAPITokenStoring = BabyAPITokenStore()
    ) -> Bool {
        statusFail = nil
        guard BabyAPIConfig.saveBaseURL(baseURLRaw) else {
            statusFail = "Enter a valid http(s) URL"
            return false
        }
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusFail = "Enter a pairing code or paste a Baby API token (mny_…)"
            return false
        }
        do {
            try tokenStore.save(trimmed)
        } catch {
            statusFail = "Could not save token"
            return false
        }
        let origin = BabyAPIConfig.loadBaseURL()
        useLive(client: BabyGraphQLClient(baseURLRaw: origin, token: trimmed))
        return true
    }

    /// Cold-start restore. Call from App entry (not Connect bypass).
    func restoreColdStart(
        tokenStore: any BabyAPITokenStoring = BabyAPITokenStore(),
        defaults: UserDefaults = .standard,
        makeOfflineStore: () -> any OfflineCareStoring = { CloudKitOfflineCareStore() }
    ) async {
        if BabySessionRestore.shouldRestoreOffline(
            savedMode: CareDataModeStore.load(defaults: defaults),
            isConnected: isConnected
        ) {
            await useOffline(store: makeOfflineStore())
            return
        }
        if let client = BabySessionRestore.makeLiveClientIfPossible(
            tokenStore: tokenStore,
            defaults: defaults
        ) {
            useLive(client: client)
        }
    }

    static func pairUserMessage(_ err: WatchPairError) -> String {
        switch err {
        case .emptyCode:
            return "Enter a pairing code"
        case .badURL:
            return "Bad pairing server URL"
        case .pairCode("EXPIRED"):
            return "Code expired — generate a new one on the web"
        case .pairCode("CONSUMED"):
            return "Code already used — generate a new one"
        case .pairCode("INVALID_CODE"), .pairCode("BAD_REQUEST"):
            return "Invalid or expired code — generate a new one on the web"
        case .pairCode("RATE_LIMITED"):
            return "Too many tries — wait and retry"
        case .pairCode:
            return "Could not redeem code"
        case .httpStatus, .transport:
            return "Network error"
        case .decoding:
            return "Bad server response"
        }
    }
}

/// Offline store that always fails fetch (unit tests).
final class FailingOfflineCareStore: OfflineCareStoring, @unchecked Sendable {
    var error: OfflineCareStoreError = .iCloudUnavailable("Sign in to iCloud to use Offline")

    func append(_ event: CareEvent) async throws {
        throw error
    }

    func fetchRecent(limit: Int) async throws -> [CareEvent] {
        throw error
    }
}

/// Fake pair client for unit tests.
struct FakeWatchPairClient: WatchPairClienting {
    var result: Result<WatchPairRedeemResult, WatchPairError>

    func redeem(code: String) async throws -> WatchPairRedeemResult {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WatchPairError.emptyCode }
        switch result {
        case .success(let value): return value
        case .failure(let err): throw err
        }
    }
}
