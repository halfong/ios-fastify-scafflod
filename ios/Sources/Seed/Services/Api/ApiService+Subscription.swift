import Foundation

extension ApiService {

    func getSubscriptionGrades() async throws -> [ApiSubscriptionGrade] {
        let res = try await query("/subscription/grades", accept: ApiSubscriptionGradesResponse.self)
        return res.grades
    }

    func getSubscriptionReceipt() async throws -> ApiSubscriptionReceipt? {
        let res = try await query("/subscription/receipt", accept: ApiSubscriptionReceiptResponse.self)
        return res.receipt
    }

    func verifySubscriptionReceipt(_ jwsData: String) async throws -> ApiSubscriptionVerifyResponse {
        return try await query(
            "/subscription/apple/verify",
            method: "POST",
            body: ["receiptData": jwsData],
            accept: ApiSubscriptionVerifyResponse.self
        )
    }

    @discardableResult
    func getAuditState(cacheMode: Int = 0) async throws -> ApiSubscriptionReceiptResponse {
        return try await query(
            "/subscription/audit?cacheMode=\(cacheMode)",
            accept: ApiSubscriptionReceiptResponse.self
        )
    }

}
