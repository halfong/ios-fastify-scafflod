import Foundation
import Combine

final class ApiCredential: ObservableObject {

    static let KeychainKey = "ApiCredential.ApiAuth"
    static var shared = ApiCredential()

    @Published var data: ApiAuth?

    init() {
        loadFromKeychain()
    }

    func clear(){
        KeychainManager.shared.delete(for: Self.KeychainKey)
        DispatchQueue.main.async {
            self.data = nil
        }
    }

    func set( auth: ApiAuth) {
        DispatchQueue.main.async {
            self.data = auth
            self.saveToKeychain()
        }
    }

    func set(user: ApiUser) {
        DispatchQueue.main.async {
            if let existed = self.data {
                self.data = ApiAuth(
                  token : existed.token,
                  expiry : existed.expiry,
                  user : user
                )
            }else{
              print("[ApiCredential] ❌ Cannot set user without existed token")
            }
            self.saveToKeychain()
        }
    }

    private func saveToKeychain() {
        guard let data = data else { return }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data),
           let jsonString = String(data: encoded, encoding: .utf8) {
            KeychainManager.shared.save(jsonString, for: Self.KeychainKey)
        }
    }

    private func loadFromKeychain() {
        guard let jsonString = KeychainManager.shared.getString(for: Self.KeychainKey) else {
            DispatchQueue.main.async {
                self.data = nil
            }
            return
        }
        
        let decoder = JSONDecoder()
        if let jsonData = jsonString.data(using: .utf8),
           let auth = try? decoder.decode(ApiAuth.self, from: jsonData) {
            DispatchQueue.main.async {
                self.data = auth
            }
        }
    }

}
