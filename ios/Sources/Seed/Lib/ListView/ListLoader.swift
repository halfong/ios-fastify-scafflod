import SwiftUI

struct ListLoader: View {
    let loadMore: () async -> Void
    let isOvered: Bool
    let isLoading: Bool
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView().scaleEffect(0.8)
            } else {
                Text(L(isOvered ? "all_loaded" : "loading_more"))
                    .lato(.t5, weight: .regular)
                    .foregroundColor(.text2)
            }
            Spacer()
        }
        .frame(height: 60)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.frame(in: .global).minY) { _, y in
                        if y < UIScreen.main.bounds.height && !isLoading && !isOvered {
                            Task { await loadMore() }
                        }
                    }
            }
        )
    }
}