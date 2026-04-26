import SwiftUI

struct SafeGlassEffectModifier: ViewModifier {
    
    let tint: Color?
    let shape: any Shape
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
          content.glassEffect( .regular.interactive().tint(tint), in: shape )
        } else {
            content
              .background(tint?.opacity(0.18) ?? Color.clear)
              .background(.ultraThinMaterial)
              // .shadow(color: (tint ?? .black).opacity(0.15), radius: 8, y: 4)
              .cornerRadius( cornerRadius )
//              .overlay(shape().stroke((tint ?? .text0).opacity(0.12), lineWidth: 1))
        }
    }
}

extension View {
    func safeGlassRect( tint:Color? = nil, cornerRadius: CGFloat = UISize.cornerRadius ) -> some View {
        modifier(
          SafeGlassEffectModifier(
            tint: tint, shape: .rect( cornerRadius: cornerRadius ), cornerRadius: cornerRadius
          )
        )
    }

    func safeGlassCapsule( tint:Color? = nil ) -> some View {
        modifier(
          SafeGlassEffectModifier(
            tint: tint, shape: .capsule, cornerRadius: .infinity
          )
        )
    }
}
