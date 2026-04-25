import Foundation

// MARK: - Auth response model

struct ApiAuthResponse: Decodable {
    let token: String
    let expiry: String
    let user: ApiUser
}

// MARK: - ApiService auth extension

extension ApiService {

    /// Sign in with an Apple identity token.
    /// On success, persists the credentials via ApiCredential.shared.
    @discardableResult
    func signInWithApple(identityToken: String) async throws -> ApiAuthResponse {
        let res = try await query(
            "/auth/apple",
            method: "POST",
            body: ["identityToken": identityToken],
            accept: ApiAuthResponse.self,
            includeAuth: false
        )
        ApiCredential.shared.set(auth: ApiAuth(token: res.token, expiry: res.expiry, user: res.user))
        return res
    }

    /// Sign in with email and password.
    /// On success, persists the credentials via ApiCredential.shared.
    @discardableResult
    func login(email: String, password: String) async throws -> ApiAuthResponse {
        let res = try await query(
            "/auth/login",
            method: "POST",
            body: ["email": email, "password": password],
            accept: ApiAuthResponse.self,
            includeAuth: false
        )
        ApiCredential.shared.set(auth: ApiAuth(token: res.token, expiry: res.expiry, user: res.user))
        return res
    }

    /// Sign out the current user by clearing stored credentials.
    func logout() {
        ApiCredential.shared.clear()
    }

    /// Fetch the authenticated user's profile.
    func getMe() async throws -> ApiUser {
        return try await query("/auth", accept: ApiUser.self)
    }
}
