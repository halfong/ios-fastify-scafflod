import SwiftUI

@main
struct MyAppApp: App {

    @StateObject private var credential = ApiCredential.shared
    @StateObject private var api = ApiService.shared
    @StateObject private var localization = Localization.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardView()
                } else if credential.data?.expired == false {
                    HomeView()
                } else {
                    AuthView()
                }
            }
            .id(localization.currentLanguageCode)
            .environmentObject(credential)
            .environmentObject(api)
            .environmentObject(localization)
            .withErrorAlert()
            .withLoadingOverlay()
            .tint(.accentColor)
            .onReceive(
                NotificationCenter.default.publisher(for: .userDidFreshSignIn)
            ) { _ in
                // credential is @StateObject — HomeView appears automatically
                print("[App] ✅ User signed in")
            }
        }
    }
}
