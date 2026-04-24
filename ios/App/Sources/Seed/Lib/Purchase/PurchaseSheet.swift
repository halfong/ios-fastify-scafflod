import SwiftUI
import StoreKit

struct PurchaseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager = PurchaseManager.shared

    @State var selectedProductId: String? = nil
    @State private var showConfetti = false

    var isSubscribed: Bool { manager.isSubscribed }

    // MARK: - Helpers

    func grade(for product: Product) -> ApiSubscriptionGrade? {
        manager.grades.first { $0.productIds.contains(product.id) }
    }

    var body: some View {
        SheetGenericView(title: L("membership")) {
            ScrollView {
              VStack(spacing: 30) {

                  VStack{
                    Image(uiImage: UIImage(named: "AppLogo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    Text(L("app_slogan")).lato(.t2, weight: .bold)
                  }
                  .padding(.vertical, 20 )
                  .aniFadeUp(delay: 0.2)

                  VStack(alignment: .leading, spacing: 12) {
                      Label(L("Record without limits"), systemImage: "waveform.circle.fill").lato(.t5)
                      Label(L("Smart AI summaries in seconds"), systemImage: "sparkles").lato(.t5)
                      Label(L("100+ languages, understood perfectly"), systemImage: "globe").lato(.t5)
                      Label(L("Always ad-free, always private"), systemImage: "lock.shield.fill").lato(.t5)
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .aniFadeUp(delay: 0.6)

                  VStack(alignment: .leading, spacing: 12) {
                    Text(L("Ready for you"))
                      .lato(.t5, weight: .bold)
                      .foregroundColor(.text1)
                      .padding(.horizontal, 4)
                    ForEach(manager.storeProducts, id: \.id) { product in
                        let isCurrent = manager.activeProductId == product.id
                        ProductCardView(
                            product: product,
                            isCurrent: isCurrent,
                            isSelected: selectedProductId == product.id,
                            onSelect: {
                                selectedProductId = product.id
                            }
                        )
                    }
                  }
                  .loadData(timeout: 10) {
                      // guard manager.storeProducts.isEmpty else { return }
                      try await manager.loadProducts()
                  }

                  Spacer().frame(height: 150)
              }
              .padding(.horizontal, UISize.screenXPadding)
          } //.ignoresSafeArea(edges: .top)
        }
          .safeAreaInset(edge: .bottom) { bottomBar }
          .overlay(alignment: .top) {
              if showConfetti {
                  ConfettiView(density: 60, mode: .once)
                      .ignoresSafeArea()
              }
          }
          .task { autoSelectDefault() }
          .onChange(of: manager.storeProducts) { _, _ in autoSelectDefault() }
          .onChange(of: manager.isPurchasing || manager.isLoading) { _, active in
              if active { LoadingManager.shared.show() } else { LoadingManager.shared.hide() }
          }
          .onChange(of: manager.successMessage) { _, msg in
              guard let msg else { return }
              manager.successMessage = nil
              ToastManager.shared.show(msg, isError: false)
              showConfetti = true
              Task {
                  try? await Task.sleep(for: .seconds(2))
                  dismiss()
              }
          }
          .onChange(of: manager.errorMessage) { _, msg in
              guard let msg else { return }
              ToastManager.shared.show(msg, isError: true)
              manager.errorMessage = nil
          }
    }

    func autoSelectDefault() {
        if selectedProductId == nil {
            selectedProductId = manager.activeProductId ?? manager.storeProducts.first?.id
        }
    }

    // MARK: - Bottom Bar

    var bottomBar: some View {
        VStack() {
            let isChanging = isSubscribed && selectedProductId != manager.activeProductId
            let ctaLabel = isChanging ? L("Change Plan") : L("Subscribe")
            let isDisabled = selectedProductId == nil
                || selectedProductId == manager.activeProductId
                || manager.isPurchasing

            ButtonBasic(
                title: ctaLabel,
                isDisabled: isDisabled,
                backgroundColor: .red,
                foregroundColor: .white,
                height: 68
            ) {
              guard let pid = selectedProductId else { return }
              Task { await manager.purchase(pid) }
            }

            Button(
              action: { Task { await manager.restorePurchases() } }
            ) {
              Text(L("Restore Purchase")).lato(.t5, weight: .bold).foregroundColor(.text2)
            }
            .buttonStyle(.plain)
            .disabled(manager.isPurchasing || manager.isLoading)
        }
        .padding(.horizontal, UISize.screenXPadding)
        // .padding(.vertical, 15)
        // .background(.thinMaterial)
    }

}
