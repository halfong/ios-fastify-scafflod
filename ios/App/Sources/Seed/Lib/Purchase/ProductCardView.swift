import SwiftUI
import StoreKit

// MARK: - Plan Card

struct ProductCardView: View {
    let product: Product
    let isCurrent: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .lato(.t4, weight: .bold)
                            .foregroundColor(.text0)
                        if isCurrent {
                            Text(L("Current"))
                                .lato(.t6, weight: .bold)
                                .foregroundColor(.accent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.accent.opacity(0.12))
                                .cornerRadius(6)
                        }
                    }

                    Text(product.description)
                      .lato(.t5)
                      .foregroundColor(.text1)
                      .lineLimit(2)
                      .frame(minHeight: 40, alignment: .top)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice).lato(.t4, weight: .bold).foregroundColor(.accent)
                    if let period = product.subscription?.subscriptionPeriod {
                        Text("/ " + period.localizedDescription).lato(.t5)
                    }
                }
            }
            .opacity( isCurrent ? 0.6 : 1 )
        }
        .padding(16)
        .background(Color.lighten)
        .cornerRadius(UISize.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: UISize.cornerRadius)
                .stroke(
                    isSelected ? Color.accent : Color.clear,
                    lineWidth: 1
                )
        )
        .tapScale { onSelect() }
    }
}

// MARK: - SubscriptionPeriod helper

private extension Product.SubscriptionPeriod {
    var localizedDescription: String {
        var components = DateComponents()
        switch unit {
        case .day:   components.day = value
        case .week:  components.weekOfMonth = value
        case .month: components.month = value
        case .year:  components.year = value
        @unknown default: break
        }
        let fmt = DateComponentsFormatter()
        fmt.unitsStyle = .full
        return fmt.string(from: components) ?? "\(value) \(unit)"
    }
}
