import Foundation

/// Which Connect host preset matches the URL field (or none for custom / empty).
enum ConnectHostPreset: Equatable {
    case local
    case production
    case none
}

/// User-editable Baby API origin + GraphQL path builder.
enum BabyAPIConfig {
    static let baseURLDefaultsKey = "baby.api.baseURL"
    static let localPreset = "http://127.0.0.1:3000"
    /// Bootstrap origin for Production pairing redeem (also saved as base URL after redeem).
    /// Override via Info.plist `BabyProductionPairingOrigin` when set.
    static var productionPairingOrigin: String {
        if let plist = Bundle.main.object(forInfoDictionaryKey: "BabyProductionPairingOrigin") as? String,
           let origin = normalize(plist), !origin.isEmpty
        {
            return origin
        }
        // Default: local Next for simulator; set plist / constant for real deploy.
        return "http://127.0.0.1:3000"
    }

    /// Production preset fills the pairing bootstrap origin (not empty paste field).
    static var productionPreset: String { productionPairingOrigin }

    /// Map a URL field value to Local / Production / none. When both presets normalize equal, prefer `.local` (UI tap still sets `.production` explicitly).
    static func resolveHostPreset(
        for raw: String,
        localPreset: String = localPreset,
        productionPreset: String = productionPreset
    ) -> ConnectHostPreset {
        guard let origin = normalize(raw) else { return .none }
        if let local = normalize(localPreset), local == origin {
            return .local
        }
        if let production = normalize(productionPreset), production == origin {
            return .production
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

/// Whether Connect shows the editable API URL field (Production only; Local hides it).
enum ConnectHostURLField {
    static func isVisible(selected: ConnectHostPreset) -> Bool {
        selected == .production
    }
}

enum AuthGate {
    /// Connect screen when auth is not bypassed and user is not connected.
    static func showsConnect(bypassAuth: Bool, isConnected: Bool) -> Bool {
        !bypassAuth && !isConnected
    }
}

/// Cold-start restore from Keychain token + saved base URL (no Connect re-entry).
enum BabySessionRestore {
    static func shouldRestoreLive(hasToken: Bool, hasBaseURL: Bool, isConnected: Bool) -> Bool {
        !isConnected && hasToken && hasBaseURL
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

