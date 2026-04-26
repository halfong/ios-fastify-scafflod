import SwiftUI

// ContentView is kept as a legacy reference.
// Navigation is now handled by App.swift → OnboardView / AuthView / HomeView.
// Delete this file when you no longer need the example.

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ApiCredential.shared)
        .environmentObject(ApiService.shared)
}
