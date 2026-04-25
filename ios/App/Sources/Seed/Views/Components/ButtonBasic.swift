import SwiftUI

struct ButtonBasic: View {
    let title: String?
    let icon: IconSource?
    let isDisabled: Bool
    let action: () async -> Void
    var backgroundColor: Color = Color.accent
    var foregroundColor: Color = .white
    var height: CGFloat = 40

    @State private var isLoading = false

    init(title: String? = nil, icon: IconSource? = nil, isDisabled: Bool = false, backgroundColor: Color = Color.accent, foregroundColor: Color = .white, height: CGFloat = 44, action: @escaping () async -> Void) {
        self.title = title; self.icon = icon; self.isDisabled = isDisabled
        self.action = action; self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor;
        self.height = height
    }

    // Computed properties for proportional scaling
    private var fontSize: CGFloat { max( FontSize.t6.rawValue, min(height * 0.36, FontSize.t4.rawValue) ) }
    private var iconSize: CGFloat { max( FontSize.t6.rawValue, min(height * 0.4, FontSize.t3.rawValue) ) }
    private var effectiveOpacity: Double { isDisabled || isLoading ? 0.3 : 1 }

    var body: some View {
        HStack(spacing: height * 0.2) {
            if isLoading {
                ProgressView().scaleEffect(fontSize / 17)
            }
            if let icon {
                Icon(icon, size: iconSize)
            }
            if let title = title {
                Text(title).lato(fontSize, weight: .bold)
            }
        }
        .padding(.vertical, (height - fontSize) / 2)
        .padding(.horizontal, height * ( title == nil ? 0 : 0.4 ))
        .frame(height: height).frame(minWidth: height)
        .frame(maxWidth: .infinity)
        .foregroundColor(foregroundColor.opacity(isDisabled || isLoading ? 0.6 : 1))
        .safeGlassCapsule(tint: backgroundColor.opacity(effectiveOpacity))
        // .cornerRadius(height / 2)
        .tapScale() {   // @fix redundant when glassEffect avalable
            guard !isDisabled && !isLoading else { return }
            isLoading = true
            await action()
            isLoading = false
        }
    }
}
