import SwiftUI

enum ButtonPosition {
    case left
    case center
    case right
    case none
}

/**
@usage:
.safeAreaInset(edge: .bottom) {
  SmartCapsule(
    position: currentType == nil ? .left : .right,
    items: currentType == nil ?
      [
        (icon: Icon(.settingsDev), action: { showProfileSheet = true }),
        (icon: "arrow.left.arrow.right", action: { showExchangeRatesSheet = true }),
      ]
      :
      [
        (icon: Icon(.cross), action: { currentType = nil })
      ]
  )
}
*/
/// @deprecated not using
struct SmartCapsule: View {
    let position: ButtonPosition
    let items: [(icon: Icon, color: Color, action: () -> Void)]
    let tint: Color

    private let size: CGFloat = 68

    init(
        position: ButtonPosition,
        items: [(icon: Icon, color: Color, action: () -> Void)] = [],
        tint: Color = .clear
    ) {
        self.position = position
        self.items = items.compactMap { $0 }
        self.tint = tint
    }

    var body: some View {
        GeometryReader { geo in
            if position != .none && !items.isEmpty {
                let itemCount = CGFloat(items.count)
                let perItemWidth = size * (itemCount > 1 ? 1.0 : 1.2)
                let totalWidth = itemCount * perItemWidth
                
                HStack(spacing: 0) {
                    ForEach(0..<items.count, id: \.self) { idx in
                        let item = items[idx]
                        Button(action: item.action) {
                            item.icon.foregroundColor(item.color)
                                .frame(width: perItemWidth, height: size)
                                .contentShape(Rectangle())
                        }
                    }
                }
                .frame(width: totalWidth, height: size)
                // Unified Liquid Glass Layer
                .safeGlassCapsule(tint: tint)
                .offset(x: calculateOffset(totalWidth, in: geo.size.width))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(height: size)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: position)
    }

    private func calculateOffset(_ width: CGFloat, in totalWidth: CGFloat) -> CGFloat {
        switch position {
        case .left: return 0
        case .center: return (totalWidth - width) / 2
        case .right: return totalWidth - width
        case .none: return 0
        }
    }
}
