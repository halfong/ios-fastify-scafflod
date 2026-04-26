import Foundation

struct ApiAuth: Codable {
    let token: String
    let expiry: String
    let user: ApiUser
    
    var expiryDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: expiry) {
            return date
        }
        
        let formatter2 = ISO8601DateFormatter()
        formatter2.formatOptions = .withInternetDateTime
        return formatter2.date(from: expiry) ?? Date()
    }

    var expired: Bool {
        return expiryDate.timeIntervalSinceNow <= 0
    }
}
