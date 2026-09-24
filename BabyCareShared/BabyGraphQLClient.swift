import Foundation

enum BabyGraphQLError: Error, Equatable {
    case missingToken
    case badURL
    case httpStatus(Int)
    case graphQL(message: String, code: String?)
    case decoding
    case transport
}

protocol BabyGraphQLClienting: Sendable {
    func execute(
        document: String,
        variablesJSON: Data?
    ) async throws -> Data
}

/// Thin POST client for `POST {base}/api/graphql/baby`.
struct BabyGraphQLClient: BabyGraphQLClienting {
    var baseURLRaw: String
    var token: String?
    var session: URLSession = .shared

    func execute(document: String, variablesJSON: Data?) async throws -> Data {
        guard let url = BabyAPIConfig.graphqlURL(base: baseURLRaw) else {
            throw BabyGraphQLError.badURL
        }
        guard let token, !token.isEmpty else {
            throw BabyGraphQLError.missingToken
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var root: [String: Any] = ["query": document]
        if let variablesJSON,
           let vars = try? JSONSerialization.jsonObject(with: variablesJSON)
        {
            root["variables"] = vars
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: root)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw BabyGraphQLError.transport
        }
        guard let http = response as? HTTPURLResponse else {
            throw BabyGraphQLError.transport
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw BabyGraphQLError.httpStatus(http.statusCode)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BabyGraphQLError.decoding
        }
        if let errors = json["errors"] as? [[String: Any]], let first = errors.first {
            let message = first["message"] as? String ?? "GraphQL error"
            let code = (first["extensions"] as? [String: Any])?["code"] as? String
            throw BabyGraphQLError.graphQL(message: message, code: code)
        }
        guard let dataObj = json["data"] else {
            throw BabyGraphQLError.decoding
        }
        return try JSONSerialization.data(withJSONObject: dataObj)
    }
}

/// Builds the JSON body keys without sending (for unit tests / inspection).
enum BabyGraphQLRequestBuilder {
    static func makeRequest(
        baseURLRaw: String,
        token: String?,
        document: String,
        variablesJSON: Data?
    ) throws -> (url: URL, headers: [String: String], body: Data) {
        guard let url = BabyAPIConfig.graphqlURL(base: baseURLRaw) else {
            throw BabyGraphQLError.badURL
        }
        guard let token, !token.isEmpty else {
            throw BabyGraphQLError.missingToken
        }
        var root: [String: Any] = ["query": document]
        if let variablesJSON,
           let vars = try? JSONSerialization.jsonObject(with: variablesJSON)
        {
            root["variables"] = vars
        }
        let body = try JSONSerialization.data(withJSONObject: root)
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)",
        ]
        return (url, headers, body)
    }
}

enum BabyGraphQLDocuments {
    static let homeQuickStatus = """
    query BabyHomeQuickStatus($dayFrom: String!, $dayTo: String!) {
      babyHomeQuickStatus(dayFrom: $dayFrom, dayTo: $dayTo) {
        lastFeed { id type at endedAt payload summary }
        lastSleep { id type at endedAt payload summary }
        lastDiaper { id type at endedAt payload summary }
        lastPump { id type at endedAt payload summary }
        openSleep { id type occurredAt endedAt }
        feedsToday
        birthDate
        latestWeightKg
        recentBottleMl
      }
    }
    """

    static let quickCare = """
    mutation BabyQuickCare($input: BabyQuickCareInput!) {
      babyQuickCare(input: $input) {
        replayed
        openSleep { id type occurredAt endedAt }
        steps { step wrote event { id type } }
      }
    }
    """
}

enum BabyClientRequestId {
    /// New id per user press (UUID without dashes, 32 chars).
    static func make() -> String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }

    /// Keep the same id across retries for idempotent replay.
    static func retrySame(_ id: String) -> String { id }
}
