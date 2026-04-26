import SwiftUI

struct ToastOverlayModifier: ViewModifier {
    @State private var toastManager = ToastManager.shared
    @State private var id = UUID()

    func body(content: Content) -> some View {
        content
            .onAppear { toastManager.register(id) }
            .onDisappear { toastManager.unregister(id) }
            .overlay(alignment: .bottom) {
                if let t = toastManager.current, toastManager.layers.last == id {
                    Text(t.message)
                        .lato(.t4)
                        .foregroundColor(t.isError ? Color.red : .text0)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: toastManager.current?.message)
    }
}

extension View {
    func withToastOverlay() -> some View {
        modifier(ToastOverlayModifier())
    }
}
