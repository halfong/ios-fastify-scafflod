import SwiftUI

// MARK: - GlossyModifier

struct GlossyModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                // Glossy light highlight on top half
                LinearGradient(
                    colors: [Color.white.opacity(0.30), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .allowsHitTesting(false)
            )
            .overlay(
                // Inset shadow: bright at top edge, dark at bottom
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), Color.black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func glossy(cornerRadius: CGFloat = UISize.cornerRadius) -> some View {
        modifier(GlossyModifier(cornerRadius: cornerRadius))
    }
}
