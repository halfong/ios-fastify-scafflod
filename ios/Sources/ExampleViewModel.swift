import Foundation

@MainActor
final class ExampleViewModel: ObservableObject {
    @Published var items: [ExampleItem] = []
    @Published var isLoading = false
    @Published var error: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            items = try await apiClient.fetchExamples()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
