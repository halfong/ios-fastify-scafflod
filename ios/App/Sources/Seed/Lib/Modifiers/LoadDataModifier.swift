import SwiftUI

// MARK: - State

private enum DataLoadState {
    case loading
    case loaded
    case failed
}

// MARK: - Modifier

struct LoadDataModifier: ViewModifier {
    let fetch: () async throws -> Void
    let timeout: TimeInterval

    @State private var state: DataLoadState = .loading

    func body(content: Content) -> some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)

            case .failed:
                VStack(spacing: 10) {
                    Text(L("Failed to load"))
                        .lato(.t5)
                        .foregroundColor(.text2)
                    Button(action: { Task { await load() } }) {
                        Text(L("Try Again"))
                            .lato(.t5, weight: .bold)
                            .foregroundColor(.accent)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)

            case .loaded:
                content
            }
        }
        .task { await load() }
    }

    private func load() async {
        state = .loading
        let fetchTask = Task<Void, Error> { try await fetch() }
        let timerTask = Task<Void, Never> {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            fetchTask.cancel()
        }
        do {
            try await fetchTask.value
            timerTask.cancel()
            state = .loaded
        } catch {
            timerTask.cancel()
            state = .failed
        }
    }
}

// MARK: - View Extension

extension View {
    /// Replaces the view with a spinner while `fetch` runs.
    /// Shows a retry button if `fetch` throws or the `timeout` (default 15 s) elapses.
    func loadData(
        timeout: TimeInterval = 15,
        perform fetch: @escaping () async throws -> Void
    ) -> some View {
        modifier(LoadDataModifier(fetch: fetch, timeout: timeout))
    }
}
