import Foundation

enum WatchPairError: Error, Equatable {
    case badURL
    case httpStatus(Int)
    case pairCode(String)
    case decoding
    case transport
    case emptyCode
}

struct WatchPairRedeemResult: Equatable {
    var baseURL: String
    var token: String
}

protocol WatchPairClienting: Sendable {
    func redeem(code: String) async throws -> WatchPairRedeemResult
}

/// POST `{pairingOrigin}/api/watch/pair/redeem` with `{ code }`.
struct WatchPairClient: WatchPairClienting {
    var pairingOriginRaw: String
    var session: URLSession = .shared

    func redeem(code: String) async throws -> WatchPairRedeemResult {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WatchPairError.emptyCode }
        guard let origin = BabyAPIConfig.normalize(pairingOriginRaw),
              let url = URL(string: origin + "/api/watch/pair/redeem")
        else {
            throw WatchPairError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["code": trimmed]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw WatchPairError.transport
        }
        guard let http = response as? HTTPURLResponse else {
            throw WatchPairError.transport
        }
        guard (200 ... 299).contains(http.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let codeStr = json["code"] as? String
            {
                throw WatchPairError.pairCode(codeStr)
            }
            throw WatchPairError.httpStatus(http.statusCode)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any],
              let baseURL = dataObj["baseURL"] as? String,
              let token = dataObj["token"] as? String,
              !baseURL.isEmpty,
              !token.isEmpty
        else {
            throw WatchPairError.decoding
        }
        return WatchPairRedeemResult(baseURL: baseURL, token: token)
    }
}

enum WatchPairRequestBuilder {
    static func redeemURL(pairingOriginRaw: String) -> URL? {
        guard let origin = BabyAPIConfig.normalize(pairingOriginRaw) else { return nil }
        return URL(string: origin + "/api/watch/pair/redeem")
    }
}
