import SwiftUI

// Usage:
// Text("This is Lato Black").lato(.t1, weight: .bold)
// Icon(FontIcon.icoShow, size: .t2)
// Icon(FontIcon.icoShow, size: 32)
enum FontSize: CGFloat {
    case t1 = 40
    case t2 = 28
    case t3 = 24
    case t4 = 17
    case t5 = 15
    case t6 = 13
    case t7 = 10
}

enum LatoWeight: String {
    case regular = "Lato-Regular"
    case bold = "Lato-Bold"
    case black = "Lato-Black"
    
    var systemWeight: Font.Weight {
        switch self {
          case .regular: return .regular
          case .bold: return .bold
          case .black: return .black
        }
    }
}

/// A global struct to provide custom fonts.
struct AppFont {
    
    /// Provides a custom Lato font with specified size and weight.
    static func lato(_ size: FontSize, weight: LatoWeight = .regular) -> Font {
      let font = Font.custom(weight.rawValue, size: size.rawValue)
      return font
    }

    static func lato(_ size: CGFloat, weight: LatoWeight = .regular) -> Font {
        .custom(weight.rawValue, size: size)
    }
    
    /// Provides a system font with specified size and weight for fallback.
    static func system(_ size: FontSize, weight: LatoWeight) -> Font {
        .system(size: size.rawValue, weight: weight.systemWeight, design: .default)
    }
}

/**
 * Use this:
 */
 // Text("This is Lato Black").lato()
extension View {
    func lato(_ size: FontSize = .t4, weight: LatoWeight? = nil) -> some View {
        self.font(AppFont.lato(size, weight: weight ?? .regular)).lineSpacing(size.rawValue * 0.4)
    }
    
    func lato(_ size: CGFloat? = nil, weight: LatoWeight? = nil) -> some View {
        self.font(AppFont.lato(size ?? 16, weight: weight ?? .regular)).lineSpacing((size ?? 16) * 0.4)
    }
}
