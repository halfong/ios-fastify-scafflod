import SwiftUI

// MARK: - Color extensions

extension Color {
    /// Page / absolute background (white in light mode, black in dark mode).
    static var bg0: Color { Color(UIColor.systemBackground) }
    /// Primary accent / brand color.
    static var accent: Color { Color("AccentColor") }
    /// Primary background.
    static var bg1: Color { Color(UIColor.systemBackground) }
    /// Primary label / text.
    static var text0: Color { Color(UIColor.label) }
    /// Secondary label / text.
    static var text1: Color { Color(UIColor.secondaryLabel) }
    /// Tertiary label / text.
    static var text2: Color { Color(UIColor.tertiaryLabel) }
    /// Subtle fill / separator used for borders and dividers.
    static var lighten: Color { Color(UIColor.systemFill) }
}

// MARK: - ShapeStyle sugar (enables leading-dot syntax in View modifiers)

extension ShapeStyle where Self == Color {
    static var accent: Color { .accent }
    static var bg0: Color { .bg0 }
    static var bg1: Color { .bg1 }
    static var text0: Color { .text0 }
    static var text1: Color { .text1 }
    static var text2: Color { .text2 }
    static var lighten: Color { .lighten }
}
