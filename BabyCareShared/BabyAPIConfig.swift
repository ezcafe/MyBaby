import Foundation

/// User-editable Baby API origin + GraphQL path builder.
enum BabyAPIConfig {
    static let baseURLDefaultsKey = "baby.api.baseURL"
    static let localPreset = "http://127.0.0.1:3000"
    /// Production preset clears the field — user pastes a real https origin.
    static let productionPreset = ""

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

enum AuthGate {
    /// Connect screen when auth is not bypassed and user is not connected.
    static func showsConnect(bypassAuth: Bool, isConnected: Bool) -> Bool {
        !bypassAuth && !isConnected
    }
}
