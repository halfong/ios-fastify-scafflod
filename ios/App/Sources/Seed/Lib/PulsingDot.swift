import SwiftUI

/// A small animated accent-coloured dot indicating live/in-progress status.
struct PulsingDot: View {
    @State private var animating = false
    let size: CGFloat
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .scaleEffect(animating ? 1.4 : 1.0)
            .opacity(animating ? 0.4 : 1.0)
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: animating
            )
            .onAppear { animating = true }
    }
}
