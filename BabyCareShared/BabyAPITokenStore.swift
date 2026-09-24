import Foundation
import Security

protocol BabyAPITokenStoring: Sendable {
    func load() -> String?
    func save(_ token: String) throws
    func clear() throws
}

/// In-memory store for unit tests.
final class InMemoryBabyAPITokenStore: BabyAPITokenStoring, @unchecked Sendable {
    private var value: String?

    func load() -> String? { value }

    func save(_ token: String) throws {
        value = token
    }

    func clear() throws {
        value = nil
    }
}

/// Keychain-backed Bearer token storage (never log the secret).
struct BabyAPITokenStore: BabyAPITokenStoring {
    var service: String = "vn.in4.MyBaby.apiToken"
    var account: String = "baby-bearer"

    func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return token
    }

    func save(_ token: String) throws {
        try clear()
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw BabyAPITokenStoreError.osStatus(status)
        }
    }

    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw BabyAPITokenStoreError.osStatus(status)
        }
    }
}

enum BabyAPITokenStoreError: Error {
    case osStatus(OSStatus)
}
