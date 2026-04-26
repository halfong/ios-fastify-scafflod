import SwiftUI
import AuthenticationServices

struct AuthView: View {

    @EnvironmentObject private var credential: ApiCredential
    @EnvironmentObject private var api: ApiService

    @State private var isCheckingCredentials = true
    @State private var showEmailLogin = false

    // Email / password fields (shown when showEmailLogin == true)
    @State private var email = ""
    @State private var password = ""

    private let errorManager = AppErrorManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // App icon + branding
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "app.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(.tint)
                    .padding(4)

                Text("__APP_NAME__")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .tracking(-1)

                Text("Your tagline goes here")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(isCheckingCredentials ? 0 : 1)
            .animation(.easeIn(duration: 0.4).delay(0.3), value: isCheckingCredentials)

            // Sign-in controls
            VStack(spacing: 12) {
                if showEmailLogin {
                    VStack(spacing: 10) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, UISize.screenXPadding)
                    .transition(.move(edge: .top).combined(with: .opacity))

                    ButtonBasic(title: "Sign In", height: 56) {
                        do {
                            try await api.login(email: email, password: password)
                            NotificationCenter.default.post(name: .userDidFreshSignIn, object: nil)
                        } catch {
                            errorManager.show(AppError(title: "Sign In Failed", detail: error.localizedDescription))
                        }
                    }
                    .padding(.horizontal, UISize.screenXPadding)
                    .transition(.opacity)
                }

                // Apple Sign In
                ButtonBasic(
                    title: "Sign in with Apple",
                    icon: .system("applelogo"),
                    backgroundColor: .clear,
                    foregroundColor: .primary,
                    height: 64
                ) {
                    do {
                        let coord = AppleSignInCoordinator()
                        let token = try await coord.requestToken()
                        try await api.signInWithApple(identityToken: token)
                        NotificationCenter.default.post(name: .userDidFreshSignIn, object: nil)
                    } catch is CancellationError {
                        // User cancelled — ignore
                    } catch {
                        errorManager.show(AppError(title: "Sign In Error", detail: error.localizedDescription))
                    }
                }
                .padding(.horizontal, UISize.screenXPadding)
                .opacity(isCheckingCredentials ? 0 : 1)
                .animation(.easeIn(duration: 0.4).delay(0.6), value: isCheckingCredentials)

                // Toggle email/password form
                Button(showEmailLogin ? "Use Apple Sign In" : "Use Email & Password") {
                    withAnimation(.spring(response: 0.35)) { showEmailLogin.toggle() }
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .opacity(isCheckingCredentials ? 0 : 1)
                .animation(.easeIn(duration: 0.4).delay(0.7), value: isCheckingCredentials)
            }
            .padding(.bottom, 32)
        }
        .task {
            // Brief pause while restoring credentials from keychain
            try? await Task.sleep(nanoseconds: 120_000_000) // 0.12 s
            if credential.data?.expired == false {
                print("[AuthView] ✅ Already authenticated")
            }
            isCheckingCredentials = false
        }
    }
}

// MARK: - Notification name

extension Notification.Name {
    static let userDidFreshSignIn = Notification.Name("UserDidFreshSignIn")
}

#Preview {
    AuthView()
        .environmentObject(ApiCredential.shared)
        .environmentObject(ApiService.shared)
}
