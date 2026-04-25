import Foundation

struct ApiUser: Codable {
    let id: String
    let email: String?
    let name: String?
    let role: String
}
