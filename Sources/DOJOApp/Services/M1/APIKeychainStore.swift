import Foundation
import Security

/// macOS Keychain storage for M1 hosted API keys.
/// Service: org.field.dojo.m1.api-keys · account = provider rawValue

enum APIKeychainStore {
    static let service = "org.field.dojo.m1.api-keys"

    enum KeychainError: LocalizedError {
        case unexpectedStatus(OSStatus)
        case encodingFailed
        case emptyKey

        var errorDescription: String? {
            switch self {
            case .unexpectedStatus(let s):
                return "Keychain status \(s)"
            case .encodingFailed:
                return "Could not encode API key"
            case .emptyKey:
                return "API key is empty"
            }
        }
    }

    static func save(provider: HostedProviderID, key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw KeychainError.emptyKey }
        guard let data = trimmed.data(using: .utf8) else { throw KeychainError.encodingFailed }

        let account = provider.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func load(provider: HostedProviderID) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: provider.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let key = String(data: data, encoding: .utf8),
              !key.isEmpty else {
            return nil
        }
        return key
    }

    static func delete(provider: HostedProviderID) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: provider.rawValue
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func hasKey(provider: HostedProviderID) -> Bool {
        load(provider: provider) != nil
    }

    static func connectionStatus(provider: HostedProviderID) -> String {
        if !provider.isHostedLive { return "Disabled" }
        return hasKey(provider: provider) ? "Key saved" : "No key"
    }
}
