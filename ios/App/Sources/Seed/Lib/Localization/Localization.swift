import Foundation
import Combine

/// A generic, reusable localization module.
///
/// Place `.lproj/Localizable.strings` files inside your app bundle under:
///   - `Locales/<code>.lproj/Localizable.strings`  (preferred)
///   - `<code>.lproj/Localizable.strings`           (fallback)
///
/// Usage:
/// ```swift
/// // Change language
/// Localization.shared.setLanguage("zh")
///
/// // Look up a key
/// let text = L("hello_world")
/// ```
///
/// To drive SwiftUI re-renders on language change, observe this singleton as an
/// environment object and use `.id(localization.currentLanguageCode)` on your
/// root content view.
final class Localization: ObservableObject {

    // MARK: - Singleton

    static let shared = Localization()

    // MARK: - Published State

    /// The BCP-47 language code currently in use (e.g. `"en"`, `"zh"`).
    /// Publishing this property lets SwiftUI observe changes via `objectWillChange`.
    @Published private(set) var currentLanguageCode: String = "en"

    // MARK: - Private

    private var localizedStrings: [String: String] = [:]

    private init() {
        loadStrings(for: currentLanguageCode)
    }

    // MARK: - Public API

    /// Switch the active language. No-ops if `code` matches the current language.
    func setLanguage(_ code: String) {
        guard code != currentLanguageCode else { return }
        currentLanguageCode = code
        loadStrings(for: code)
    }

    /// Return the localized string for `key`, or `key` itself when missing.
    func string(forKey key: String) -> String {
        localizedStrings[key] ?? key
    }

    /// Return a formatted localized string using `String(format:)`.
    func string(forKey key: String, arguments: CVarArg...) -> String {
        let template = localizedStrings[key] ?? key
        return String(format: template, arguments: arguments)
    }

    // MARK: - Private Helpers

    private func loadStrings(for code: String) {
        let candidatePaths: [String?] = [
            Bundle.main.path(forResource: "Localizable", ofType: "strings",
                             inDirectory: "Locales/\(code).lproj"),
            Bundle.main.path(forResource: "Localizable", ofType: "strings",
                             inDirectory: "\(code).lproj"),
        ]

        if let path = candidatePaths.compactMap({ $0 }).first,
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            localizedStrings = dict
            return
        }

        // Fallback to English if available and not already English
        if code != "en" {
            currentLanguageCode = "en"
            loadStrings(for: "en")
        }
    }
}

// MARK: - Global Helpers

/// Returns the localized string for `key` using the current language.
func L(_ key: String) -> String {
    Localization.shared.string(forKey: key)
}

/// Returns a formatted localized string for `key` using the current language.
func L(_ key: String, _ arguments: CVarArg...) -> String {
    Localization.shared.string(forKey: key, arguments: arguments)
}
