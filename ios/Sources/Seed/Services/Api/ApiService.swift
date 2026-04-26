import Foundation
import Combine

struct ApiErrorResponse: Decodable {
    let message: String
}

/// Stateless, use ApiCredential.shared for auth info
final class ApiService: ObservableObject {

    static let shared = ApiService()
    static let timeoutInterval: TimeInterval = 30

    // Backend URL from AppConfig - internal property accessed by extensions
    internal var baseURL: String { AppConfig.backendURL }

    /// Set to `true` when the server returns 402 Payment Required.
    /// Observed by HomeView to present PurchaseSheet.
    @Published var paymentRequired: Bool = false

    private var _cache: [String: (data: Data, cachedAt: Date)] = [:]
    private let _cacheTTL: TimeInterval = 3600

    /// - Parameter cacheMode: `0` = no cache (default), `1` = use cached data if within TTL, `-1` = force refresh and update cache
    func query<T: Decodable>(
        _ endpoint: String,
        method: String = "GET",
        query: [String: String] = [:],
        body: [String: Any]? = nil,
        accept: T.Type,
        includeAuth: Bool = true,
        cacheMode: Int = 0
    ) async throws -> T {
        let cacheKey = "\(method) \(endpoint)"

        if cacheMode == 1, let entry = _cache[cacheKey],
           Date().timeIntervalSince(entry.cachedAt) < _cacheTTL {
            return try JSONDecoder().decode(T.self, from: entry.data)
        }

        if cacheMode == -1 {
            _cache.removeValue(forKey: cacheKey)
        }

        let request = try buildRequest( endpoint, method: method, body: body, query: query, includeAuth: includeAuth )

        // Perform Request
        let (data, response) = try await URLSession.shared.data(for: request)
        // Parse Response Data to Type
        let object = try handleResponse(response: response, data: data, accept: T.self)

        if cacheMode != 0 {
            _cache[cacheKey] = (data, Date())
        }

        return object
    }

    private func buildRequest( _ endpoint: String, method: String = "GET", body: [String: Any]? = nil, query: [String: String] = [:], includeAuth: Bool = true ) throws -> URLRequest {
        // Build URL with query string parameters
        let urlString = "\(baseURL)\(endpoint)"
        guard var urlComponents = URLComponents(string: urlString) else {
            throw AppError(title: "Invalid URL", detail: "Invalid URL: \(urlString)")
        }
        
        // Add query string parameters
        if !query.isEmpty {
            urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw AppError(title: "Invalid URL", detail: "Invalid URL: \(urlString)")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.timeoutInterval = ApiService.timeoutInterval
        // Add Authorization header if token available
        if includeAuth, let token = ApiCredential.shared.data?.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // Set HTTP body if provided
        if let body = body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        return urlRequest
    }

    private func handleResponse<T:Decodable>( response: URLResponse, data: Data, accept: T.Type ) throws -> T { 
      guard let httpResponse = response as? HTTPURLResponse else {
        throw AppError(title: "Invalid Response", detail: "Invalid response")
      }
      // print("[ApiService] \(httpResponse.statusCode): \(httpResponse.url?.absoluteString ?? "unknown")")
      // print("-> \(String(data: data, encoding: .utf8)?.prefix(200) ?? "⚠️ Cannot decode as UTF-8")")

      guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
        // Handle error response
        let errorData = (try? JSONDecoder().decode(ApiErrorResponse.self, from: data)) ?? ApiErrorResponse(message: "Invalid ApiErrorResponse")
        if httpResponse.statusCode == 402 {
          DispatchQueue.main.async {
            self.paymentRequired = true
            // If the client already thinks the user is subscribed, the server-side
            // quota/subscription state is out of sync. Re-verify entitlements so the
            // server receipt is refreshed, which usually resolves the 402 on retry.
            if PurchaseManager.shared.isSubscribed {
              print("402 but local subscription is active. Refreshing status...")
              Task { await PurchaseManager.shared.refreshStatus() }
            }
          }
        }
        throw AppError(title: "Request Failed \(httpResponse.statusCode)", detail: errorData.message, statusCode: httpResponse.statusCode)
      }
      // Successful response
      do {
        return try JSONDecoder().decode(accept, from: data)
      }catch {
        throw AppError(
          title: "Invalid Response Data",
          detail: String(data: data, encoding: .utf8) ?? "nil")
      }
    }

}
