import Foundation

// MARK: - API Models

struct ExampleItem: Identifiable, Codable {
    let id: String
    let title: String
    let createdAt: String
}

struct ExampleListResponse: Codable {
    let data: [ExampleItem]
    let total: Int
}

// MARK: - API Client

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = AppConfig.apiBaseURLValue,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchExamples() async throws -> [ExampleItem] {
        let url = baseURL.appendingPathComponent("/api/v1/examples")
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(ExampleListResponse.self, from: data)
        return decoded.data
    }
}

enum APIError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        }
    }
}
