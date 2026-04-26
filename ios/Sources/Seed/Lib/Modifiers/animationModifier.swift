import SwiftUI

struct AniFadeUpModifier: ViewModifier {
    let show: Bool?
    var speed: Double = 0.45
    var delay: Double = 0.0

    @State private var internalShow: Bool = false

    private var effectiveShow: Bool { show ?? internalShow }

    func body(content: Content) -> some View {
        content
            .opacity(effectiveShow ? 1 : 0)
            .scaleEffect(effectiveShow ? 1 : 0.93)
            .blur(radius: effectiveShow ? 0 : 8)
            .offset(y: effectiveShow ? 0 : 28)
            .allowsHitTesting(effectiveShow)
            .animation(.spring(duration: speed).delay(show != nil && effectiveShow ? delay : 0), value: effectiveShow)
            .onAppear {
                guard show == nil else { return }
                Task {
                    try? await Task.sleep(for: .seconds(delay))
                    internalShow = true
                }
            }
    }
}

extension View {
    func aniFadeUp(show: Bool? = nil, speed: Double = 0.45, delay: Double = 0.0) -> some View {
        modifier(AniFadeUpModifier(show: show, speed: speed, delay: delay))
    }
}