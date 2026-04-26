import Foundation
import StoreKit

// MARK: - Plan Factors

struct ApiSubscriptionFactor: Decodable {
    let auditorName: String
    let quota: Int
    let quotaWindow: String  // "week" | "month" | "year"

    var displayName: String {
        switch auditorName {
        case "ASR_DURATION": return "Transcription"
        case "LLM_TOKENS":   return "AI Review"
        default:             return auditorName
        }
    }

    var formattedQuota: String { formatValue(Double(quota)) }

    func formatValue(_ value: Double) -> String {
        switch auditorName {
        case "ASR_DURATION":
            let hours = Int(value) / 3600
            if hours >= 1 { return "\(hours) hr" }
            let mins = Int(value) / 60
            if mins >= 1  { return "\(mins) min" }
            return String(format: "%.1f sec", value)
        case "LLM_TOKENS":
            let millions = Int(value) / 1_000_000
            if millions >= 1 { return "\(millions)M tokens" }
            let thousands = Int(value) / 1_000
            if thousands >= 1 { return "\(thousands)K tokens" }
            return "\(Int(value)) tokens"
        default:
            return "\(Int(value))"
        }
    }
}

// MARK: - Grades
// Mirrors T_GradeConfig from server/src/services/audit/config.ts

struct ApiSubscriptionGrade: Decodable {
    let id: String           // "FREE", "PRO"
    let name: String         // "Free", "Pro"
    let description: String
    let factors: [ApiSubscriptionFactor]
    let productIds: [String]
}

struct ApiSubscriptionGradesResponse: Decodable {
    let success: Bool
    let grades: [ApiSubscriptionGrade]
}

// MARK: - Verify / Receipt
// Mirrors StoredReceipt from server/src/services/receipt.service.ts

struct ApiSubscriptionReceipt: Codable {
    let productId: String
    let originalTransactionId: String
    let status: String          // "active" | "expired" | "canceled"
    let startAt: String
    let endAt: String?
    let source: String
    let environment: String
    let revokedAt: String?
    let updatedAt: String

    var isActive: Bool { status == "active" && !expired }

    var expired: Bool {
        guard let str = endAt else { return false }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso.date(from: str) ?? ISO8601DateFormatter().date(from: str)
        return date.map { $0 < Date() } ?? false
    }
}

struct ApiSubscriptionReceiptResponse: Decodable {
    let success: Bool
    let receipt: ApiSubscriptionReceipt?
}

struct ApiSubscriptionVerifyResponse: Decodable {
    let success: Bool
    let receipt: ApiSubscriptionReceipt
}

