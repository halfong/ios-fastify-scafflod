import AuthenticationServices
import UIKit

/// Wraps Sign in with Apple into a single async call.
/// Create an instance, `await requestToken()`, then discard.
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private var continuation: CheckedContinuation<String, Error>?

    /// Presents the Sign in with Apple sheet and returns the identity token string.
    /// Throws on failure. Throws `CancellationError` if the user cancels — callers should swallow that silently.
    func requestToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = []
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? UIWindow()
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { continuation = nil }
        guard let appleID = authorization.credential as? ASAuthorizationAppleIDCredential,
              let data = appleID.identityToken,
              let token = String(data: data, encoding: .utf8) else {
            continuation?.resume(throwing: AppleSignInError.noIdentityToken)
            return
        }
        continuation?.resume(returning: token)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer { continuation = nil }
        guard (error as NSError).code != ASAuthorizationError.canceled.rawValue else {
            continuation?.resume(throwing: CancellationError())
            return
        }
        continuation?.resume(throwing: error)
    }
}

enum AppleSignInError: LocalizedError {
    case noIdentityToken
    var errorDescription: String? { L("no_identity_token") }
}
