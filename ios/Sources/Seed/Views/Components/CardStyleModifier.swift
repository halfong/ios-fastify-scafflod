import SwiftUI

struct CardStyleModifier: ViewModifier {
    var tint: Color? = .accent
    var borderColor: Color = .accent.opacity(0.2)
    var borderDashed: Bool = false
    var borderWidth: CGFloat = 1

    var verticalPadding: CGFloat = 20
    var horizontalPadding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .safeGlassRect(tint: tint)
            .overlay(
                RoundedRectangle(cornerRadius: UISize.cornerRadius)
                    .stroke(
                        borderColor,
                        style: borderDashed ? StrokeStyle(lineWidth: borderWidth, dash: [5, 5]) : StrokeStyle(lineWidth: borderWidth)
                    )
            )
    }
}

extension View {

    func cardPrimary(verticalPadding: CGFloat = 20, horizontalPadding: CGFloat = 16)->some View {
        modifier(CardStyleModifier(
            tint: .accent.opacity(0.1),
            borderColor: .accent.opacity(0.1),
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        ))
    }

    func cardBasic(verticalPadding: CGFloat = 20, horizontalPadding: CGFloat = 16)->some View {
        modifier(CardStyleModifier(
            tint: nil,
            borderColor: .lighten,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        ))
    }

    func cardDashedLine(verticalPadding: CGFloat = 20, horizontalPadding: CGFloat = 16)->some View {
        modifier(CardStyleModifier(
            tint: nil,
            borderColor: .text0.opacity(0.3),
            borderDashed: true,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        ))
    }

}
