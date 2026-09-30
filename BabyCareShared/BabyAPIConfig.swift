import Foundation

/// Connect mode chips: Offline (iCloud care) or Cloud (live API).
enum ConnectHostPreset: Equatable {
    case offline
    case cloud
    case none
}

/// User-editable Baby API origin + GraphQL path builder.
enum BabyAPIConfig {
    static let baseURLDefaultsKey = "baby.api.baseURL"
    /// Default Cloud URL (former Local preset).
    static let localPreset = "http://127.0.0.1:3000"
    /// Bootstrap origin for Cloud pairing redeem (also saved as base URL after redeem).
    /// Override via Info.plist `BabyProductionPairingOrigin` when set.
    static var productionPairingOrigin: String {
        if let plist = Bundle.main.object(forInfoDictionaryKey: "BabyProductionPairingOrigin") as? String,
           let origin = normalize(plist), !origin.isEmpty
        {
            return origin
        }
        return "http://127.0.0.1:3000"
    }

    /// Cloud pairing / URL preset (same string as `localPreset` unless plist overrides).
    static var cloudPreset: String { productionPairingOrigin }

    /// Alias for older call sites / tests.
    static var productionPreset: String { cloudPreset }

    /// Map a URL field value to Cloud / none. Offline is never inferred from URL.
    static func resolveHostPreset(
        for raw: String,
        cloudPreset: String = cloudPreset,
        localPreset: String = localPreset
    ) -> ConnectHostPreset {
        guard let origin = normalize(raw) else { return .none }
        if let cloud = normalize(cloudPreset), cloud == origin {
            return .cloud
        }
        // Former Local URL still counts as Cloud (Cloud chip defaults to this URL).
        if let local = normalize(localPreset), local == origin {
            return .cloud
        }
        return .none
    }

    /// Strip whitespace and a single trailing `/`. Keep origin only (scheme + host + optional port).
    static func normalize(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil
        else {
            return nil
        }
        var comps = URLComponents()
        comps.scheme = scheme
        comps.host = url.host
        comps.port = url.port
        guard var origin = comps.string else { return nil }
        while origin.hasSuffix("/") {
            origin.removeLast()
        }
        return origin
    }

    static func validate(_ raw: String) -> Bool {
        normalize(raw) != nil
    }

    /// `{normalizedBase}/api/graphql/baby`
    static func graphqlURL(base raw: String) -> URL? {
        guard let origin = normalize(raw) else { return nil }
        return URL(string: origin + "/api/graphql/baby")
    }

    static func loadBaseURL(defaults: UserDefaults = .standard) -> String {
        defaults.string(forKey: baseURLDefaultsKey) ?? ""
    }

    static func saveBaseURL(_ raw: String, defaults: UserDefaults = .standard) -> Bool {
        guard let origin = normalize(raw) else { return false }
        defaults.set(origin, forKey: baseURLDefaultsKey)
        return true
    }

    static func clearBaseURL(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: baseURLDefaultsKey)
    }
}

/// Connect defaults and URL field visibility (Offline | Cloud).
enum ConnectHostURLField {
    static var defaultPreset: ConnectHostPreset { .offline }

    /// Cloud URL field defaults to former local preset.
    static var cloudDefaultURL: String { BabyAPIConfig.localPreset }

    static func isVisible(selected: ConnectHostPreset) -> Bool {
        selected == .cloud
    }

    static func showsPairingFields(selected: ConnectHostPreset) -> Bool {
        selected == .cloud
    }
}

/// Chip tap side effects for Offline | Cloud (keeps URL field defaults in sync).
enum ConnectPresetSelection {
    static func apply(
        _ preset: ConnectHostPreset,
        baseURL: String
    ) -> (selected: ConnectHostPreset, baseURL: String) {
        switch preset {
        case .offline:
            return (.offline, baseURL)
        case .cloud:
            return (.cloud, ConnectHostURLField.cloudDefaultURL)
        case .none:
            return (.none, baseURL)
        }
    }
}

/// watchOS `.buttonStyle(.plain)` only hits opaque label pixels — never use clear fill.
enum ConnectPresetChipHit {
    enum Fill: Equatable {
        case accent
        case material
        case clear
    }

    /// Opaque fill so the full chip frame is tappable with `.buttonStyle(.plain)`.
    static func fill(isSelected: Bool) -> Fill {
        isSelected ? .accent : .material
    }
}

enum AuthGate {
    /// Connect screen when auth is not bypassed and user is not connected.
    static func showsConnect(bypassAuth: Bool, isConnected: Bool) -> Bool {
        !bypassAuth && !isConnected
    }
}

/// Persisted care data mode for cold start.
enum CareDataModeStore {
    static let defaultsKey = "baby.care.dataMode"

    static func save(_ mode: CareDataMode, defaults: UserDefaults = .standard) {
        defaults.set(mode.rawValue, forKey: defaultsKey)
    }

    static func load(defaults: UserDefaults = .standard) -> CareDataMode? {
        guard let raw = defaults.string(forKey: defaultsKey) else { return nil }
        return CareDataMode(rawValue: raw)
    }

    static func clear(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: defaultsKey)
    }
}

/// Cold-start restore from Keychain token + saved base URL (no Connect re-entry).
enum BabySessionRestore {
    static func shouldRestoreLive(hasToken: Bool, hasBaseURL: Bool, isConnected: Bool) -> Bool {
        !isConnected && hasToken && hasBaseURL
    }

    static func shouldRestoreOffline(savedMode: CareDataMode?, isConnected: Bool) -> Bool {
        !isConnected && savedMode == .offline
    }

    /// Live client when both credentials exist; otherwise nil (show Connect).
    static func makeLiveClientIfPossible(
        tokenStore: any BabyAPITokenStoring = BabyAPITokenStore(),
        defaults: UserDefaults = .standard
    ) -> BabyGraphQLClient? {
        guard let token = tokenStore.load(), !token.isEmpty else { return nil }
        let origin = BabyAPIConfig.loadBaseURL(defaults: defaults)
        guard !origin.isEmpty else { return nil }
        return BabyGraphQLClient(baseURLRaw: origin, token: token)
    }
}
