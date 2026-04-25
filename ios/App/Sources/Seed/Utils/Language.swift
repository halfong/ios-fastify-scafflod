import SwiftUI

enum Language: String, CaseIterable, Codable {
    case en = "en"
    case es = "es"
    case vi = "vi"
    case zh = "zh"
    case hi = "hi"
    case fr = "fr"
    case ar = "ar"
    case pt = "pt"
    case ru = "ru"
    case ko = "ko"
    case ja = "ja"
    
    var description: String {
        switch self {
        case .en:
            return "English"
        case .es:
            return "Español"
        case .vi:
            return "Tiếng Việt"
        case .zh:
            return "中文"
        case .hi:
            return "हिन्दी"
        case .fr:
            return "Français"
        case .ar:
            return "العربية"
        case .pt:
            return "Português"
        case .ru:
            return "Русский"
        case .ko:
            return "한국어"
        case .ja:
            return "日本語"
        }
    }
    
    var displayName: String {
        switch self {
        case .en:
            return "English"
        case .es:
            return "Español"
        case .vi:
            return "Tiếng Việt"
        case .zh:
            return "中文"
        case .hi:
            return "हिन्दी"
        case .fr:
            return "Français"
        case .ar:
            return "العربية"
        case .pt:
            return "Português"
        case .ru:
            return "Русский"
        case .ko:
            return "한국어"
        case .ja:
            return "日本語"
        }
    }
    
    var iconName: String {
        switch self {
        case .en:
            return "globe.americas"
        case .es:
            return "globe.americas.fill"
        case .vi:
            return "globe.asia.australia"
        case .zh:
            return "globe.asia.australia.fill"
        case .hi:
            return "globe.asia.australia"
        case .ja:
            return "globe.asia.australia.fill"
        case .ko:
            return "globe.asia.australia"
        case .fr:
            return "globe.europe.africa"
        case .pt:
            return "globe.americas.fill"
        case .ru:
            return "globe.europe.africa.fill"
        case .ar:
            return "globe.europe.africa"
        }
    }
    
    var locale: Locale {
        switch self {
        case .en:
            return Locale(identifier: "en")
        case .es:
            return Locale(identifier: "es")
        case .vi:
            return Locale(identifier: "vi")
        case .zh:
            return Locale(identifier: "zh")
        case .hi:
            return Locale(identifier: "hi")
        case .fr:
            return Locale(identifier: "fr")
        case .ar:
            return Locale(identifier: "ar")
        case .pt:
            return Locale(identifier: "pt")
        case .ru:
            return Locale(identifier: "ru")
        case .ko:
            return Locale(identifier: "ko")
        case .ja:
            return Locale(identifier: "ja")
        }
    }
} 