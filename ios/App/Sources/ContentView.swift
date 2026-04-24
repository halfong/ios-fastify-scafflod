import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExampleViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading…")
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Retry") { Task { await viewModel.load() } }
                    }
                    .padding()
                } else {
                    List(viewModel.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.createdAt)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("__APP_NAME__")
            .task { await viewModel.load() }
        }
    }
}

#Preview {
    ContentView()
}
