import Foundation

/// User-visible Fail copy for live GraphQL / HTTP errors (no raw server message).
enum BabyLiveStatusFailCopy {
    static let genericGraphQL = "Could not update care — retry"
    static let unauthorized = "Unauthorized — reconnect"
    static let missingToken = "Missing API token"
    static let badURL = "Bad API URL"
    static let network = "Network error — retry"

    static func from(_ error: Error) -> (text: String, needsReconnect: Bool) {
        guard let gql = error as? BabyGraphQLError else {
            return (network, false)
        }
        switch gql {
        case .graphQL(_, let code) where code == "UNAUTHORIZED" || code == "FORBIDDEN":
            return (unauthorized, true)
        case .httpStatus(401), .httpStatus(403):
            return (unauthorized, true)
        case .missingToken:
            return (missingToken, true)
        case .badURL:
            return (badURL, false)
        case .graphQL:
            return (genericGraphQL, false)
        case .httpStatus(let code):
            return ("HTTP \(code)", false)
        case .decoding, .transport:
            return (network, false)
        }
    }
}
