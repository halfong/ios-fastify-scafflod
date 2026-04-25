import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()


    private let defaults = UserDefaults.standard
    private enum Keys { static let receipt = "purchase.receipt" }

    @Published var storeProducts: [Product] = []
    @Published var grades: [ApiSubscriptionGrade] = []
    @Published var lastReceipt: ApiSubscriptionReceipt? { // @important May be `expired`
        didSet {
            if let receipt = lastReceipt, let data = try? JSONEncoder().encode(receipt) {
                defaults.set(data, forKey: Keys.receipt)
            } else {
                defaults.removeObject(forKey: Keys.receipt)
            }
        }
    }
    /// The user's active paid grade, or nil when free / expired
    /// Base on `lastReceipt`
    var activeGrade: ApiSubscriptionGrade? {
        guard let receipt = lastReceipt, receipt.isActive, !grades.isEmpty else { return nil }
        return grades.first(where: { $0.productIds.contains(receipt.productId) })
    }
    var activeProductId: String? { lastReceipt?.isActive == true ? lastReceipt?.productId : nil }


    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    var isSubscribed: Bool { lastReceipt?.isActive == true }
    
    private var transactionListener: Task<Void, Never>?

    private init() {
        if let data = defaults.data(forKey: Keys.receipt),
           let receipt = try? JSONDecoder().decode(ApiSubscriptionReceipt.self, from: data) {
            self.lastReceipt = receipt
        }
        transactionListener = Task { [weak self] in
            for await result in Transaction.updates { await self?.handleTransactionUpdate(result) }
        }
        Task { await initialize() }
    }

    deinit { transactionListener?.cancel() }

    // MARK: - Public

    func initialize() async {
        try? await loadProducts()
    }

    /// Loads grades from the server (if not already loaded) then fetches the
    /// matching StoreKit products. Throws on any network or StoreKit failure.
    func loadProducts() async throws {
        if grades.isEmpty {
            grades = try await ApiService.shared.getSubscriptionGrades()
        }
        let ids = Set(grades.flatMap(\.productIds))
        storeProducts = try await Product.products(for: ids).sorted { $0.price < $1.price }
    }

    func purchase(_ productId: String) async {
        guard let product = storeProducts.first(where: { $0.id == productId }) else {
            errorMessage = "Product not available"; return
        }
        guard let userIdString = ApiCredential.shared.data?.user.id else {
            errorMessage = "Not authenticated"; return
        }
        // User IDs are CUIDs — derive a deterministic UUID via MD5.
        let h = userIdString.md5
        let uuidStr = "\(h.prefix(8))-\(h.dropFirst(8).prefix(4))-\(h.dropFirst(12).prefix(4))-\(h.dropFirst(16).prefix(4))-\(h.dropFirst(20))"
        guard let userUUID = UUID(uuidString: uuidStr) else { errorMessage = "Not authenticated"; return }

        isPurchasing = true; errorMessage = nil; successMessage = nil
        defer { isPurchasing = false }
        do {
            // Drain any queued unfinished transactions that are already expired or revoked
            // before purchasing. StoreKit delivers unfinished transactions oldest-first, so
            // without this, product.purchase() may return a stale cycle instead of the new one.
            for await result in Transaction.unfinished {
                if let tx = try? result.payloadValue {
                    let isExpired = tx.expirationDate.map { $0 < Date() } ?? false
                    if isExpired || tx.revocationDate != nil { await tx.finish() }
                }
            }
            let result = try await product.purchase(options: [.appAccountToken(userUUID)])
            switch result {
            case .success(let v): try await verifyWithServer(v)
            case .userCancelled: break
            case .pending: errorMessage = "Purchase pending approval"
            @unknown default: break
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func restorePurchases() async {
        isLoading = true; errorMessage = nil; successMessage = nil
        defer { isLoading = false }
        // Sync with App Store to pull down any transactions not yet on this device.
        try? await AppStore.sync()
        var restored = 0
        for await result in Transaction.currentEntitlements {
            await handleTransactionUpdate(result); restored += 1
        }
        if restored == 0 { successMessage = "Nothing to restore" }
    }

    func refreshStatus() async {
        isLoading = true; defer { isLoading = false }
        // Fetch the authoritative server receipt — this is the single source of truth.
        lastReceipt = try? await ApiService.shared.getSubscriptionReceipt()
        try? await ApiService.shared.getAuditState(cacheMode: -1)
        if storeProducts.isEmpty { try? await loadProducts() }
    }

    // MARK: - Private

    private func verifyWithServer(_ verification: VerificationResult<Transaction>, silent: Bool = false) async throws {
        // print("[verifyWithServer] Verifying transaction with server...")
        
        let transaction = try checkVerified(verification)
        // Guard against stale/already-expired transactions (common in sandbox where Apple
        // reuses originalTransactionId across re-purchases and returns the latest cycle).
        // Always finish silently — never show an error here. StoreKit queues unfinished
        // transactions oldest-first, so finishing this one lets the real new transaction
        // arrive next via Transaction.updates → handleTransactionUpdate → success message.
        let isExpired = transaction.expirationDate.map { $0 < Date() } ?? false
        if isExpired {
            await transaction.finish()
            return
        }
        let wasSubscribed = isSubscribed
        let previousProductId = lastReceipt?.productId
        let response = try await ApiService.shared.verifySubscriptionReceipt(verification.jwsRepresentation)
        lastReceipt = response.receipt
        try? await ApiService.shared.getAuditState(cacheMode: -1)
        await transaction.finish()
        guard !silent else { return }
        // Use the server's authoritative status rather than the local expiry check,
        // which can race (e.g. short sandbox subscription windows).
        if response.receipt.status == "active" {
            let isChangingPlan = wasSubscribed && previousProductId != transaction.productID
            successMessage = isChangingPlan ? "Plan changed successfully!" : "Subscription activated!"
            // Clear the 402 flag so HomeView doesn't re-present the sheet after dismiss.
            ApiService.shared.paymentRequired = false
        } else {
            errorMessage = "Subscription could not be activated. Please try again."
        }
    }

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>, silent: Bool = false) async {
        do {
            let transaction = try checkVerified(result)
            let isExpired = transaction.expirationDate.map { $0 < Date() } ?? false
            if transaction.revocationDate == nil && !isExpired && grades.flatMap(\.productIds).contains(transaction.productID) {
                try await verifyWithServer(result, silent: silent)
            } else {
                await transaction.finish()
            }
        } catch {}
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw PurchaseError.verificationFailed
        case .verified(let safe): return safe
        }
    }
}

enum PurchaseError: Error { case verificationFailed }

// MARK: - Product + Monthly Price

extension Product {
    /// Returns the price formatted as a monthly equivalent, regardless of the
    /// actual billing period (daily / weekly / monthly / yearly).
    var displayMonthlyPrice: String {
        guard let sub = subscription else { return displayPrice }
        let period = sub.subscriptionPeriod
        let n = Decimal(period.value)
        let monthlyPrice: Decimal
        switch period.unit {
        case .day:   monthlyPrice = price * (Decimal(string: "30.44")! / n)
        case .week:  monthlyPrice = price * (Decimal(string: "4.33")! / n)
        case .month: monthlyPrice = price / n
        case .year:  monthlyPrice = price / (n * 12)
        @unknown default: return displayPrice
        }
        return monthlyPrice.formatted(priceFormatStyle)
    }
}

