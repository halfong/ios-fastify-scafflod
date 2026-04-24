import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    private let service = "cc.holli.Vocano"
    
    // MARK: - Save
    
    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else {
            print("[Keychain] ❌ Failed to encode value for key: \(key)")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("[Keychain] ✅ Saved \(key)")
        } else {
            print("[Keychain] ❌ Failed to save \(key): \(status)")
        }
    }
    
    func save(_ value: Int, for key: String) {
        save(String(value), for: key)
    }
    
    func save(_ value: Date, for key: String) {
        save(String(value.timeIntervalSince1970), for: key)
    }
    
    // MARK: - Retrieve
    
    func getString(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    func getInt(for key: String) -> Int? {
        guard let string = getString(for: key) else { return nil }
        return Int(string)
    }
    
    func getDate(for key: String) -> Date? {
        guard let string = getString(for: key),
              let timeInterval = TimeInterval(string) else { return nil }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    // MARK: - Delete
    
    func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("[Keychain] 🗑️ Deleted \(key)")
        }
    }
    
    func deleteAll(for keys: [String]) {
        print("[Keychain] 🗑️ Deleting keychain items")
        for key in keys {
            delete(for: key)
        }
    }
}
