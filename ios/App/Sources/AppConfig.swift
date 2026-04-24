import Foundation

/// Central configuration for the app.
/// After scaffolding, `apiBaseURL` will be set from __API_BASE_URL__.
enum AppConfig {
    /// Base URL of the API server. Change this value or set it via xcconfig.
    static let apiBaseURL: String = "__API_BASE_URL__"

    /// Alias used by ApiService (Seed).
    static var backendURL: String { apiBaseURL }

    /// Parsed URL — crashes fast if the base URL is malformed.
    static var apiBaseURLValue: URL {
        guard let url = URL(string: apiBaseURL) else {
            fatalError("Invalid API base URL: \(apiBaseURL)")
        }
        return url
    }
}
