import Foundation
import CryptoKit
import Security

struct SecureKeychainHelper {
    static func data(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return data
    }

    @discardableResult
    static func store(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

struct SecurePassStorage {
    private let encryptionKeyID = "securepass.encryption.key"
    private let payloadKey = "securepass.pass.payload"

    func loadPasses() -> [SecurePassItem] {
        guard let encrypted = SecureKeychainHelper.data(for: payloadKey) else {
            return SecurePassItem.demo
        }

        do {
            let key = try symmetricKey()
            let plaintext = try decrypt(encrypted, with: key)
            return try JSONDecoder().decode([SecurePassItem].self, from: plaintext)
        } catch {
            return SecurePassItem.demo
        }
    }

    func save(_ passes: [SecurePassItem]) {
        do {
            let key = try symmetricKey()
            let payload = try JSONEncoder().encode(passes)
            let cipher = try encrypt(payload, with: key)
            _ = SecureKeychainHelper.store(cipher, for: payloadKey)
        } catch {
            print("SecurePassStorage error: \(error.localizedDescription)")
        }
    }

    // MARK: - Crypto
    private func symmetricKey() throws -> SymmetricKey {
        if let data = SecureKeychainHelper.data(for: encryptionKeyID) {
            return SymmetricKey(data: data)
        }

        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        guard SecureKeychainHelper.store(keyData, for: encryptionKeyID) else {
            throw NSError(domain: "SecurePass", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to save encryption key"])
        }
        return key
    }

    private func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealed = try AES.GCM.seal(data, using: key)
        guard let combined = sealed.combined else {
            throw NSError(domain: "SecurePass", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid cipher data"])
        }
        return combined
    }

    private func decrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
