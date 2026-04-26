import SwiftUI

struct StyledActionButton: View {
    let title: String?
    let icon: FontIcon?
    let isDisabled: Bool
    let action: () async -> Void
    var backgroundColor: Color = Color.accent
    var foregroundColor: Color = .white
    var height: CGFloat = 54 // Default height (18*2 + ~18 for text)
    
    @State private var isLoading = false

    init(title: String? = nil, icon: FontIcon? = nil, isDisabled: Bool = false, backgroundColor: Color = Color.accent, foregroundColor: Color = .white, height: CGFloat = 54, action: @escaping () async -> Void ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
        self.action = action
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.height = height
    }
    
    // Computed properties for proportional scaling
    private var verticalPadding: CGFloat {
        height * 0.33 // About 1/3 of height for padding
    }
    
    private var iconSize: FontSize {
        switch height {
          case 0..<32: return .t4
          case 32..<44: return .t3
          case 44..<60: return .t2
          case 60..<76: return .t1
          default: return .t4
        }
    }
    
    private var fontSize: FontSize {
        switch height {
          case 0..<32: return .t5
          case 32..<44: return .t4
          case 44..<60: return .t4
          case 60..<76: return .t3
          default: return .t4
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                if let icon = icon {
                    Icon(icon, size: iconSize)
                        .foregroundColor(foregroundColor)
                }
                if let title = title {
                    Text(title)
                        .lato(fontSize, weight: .bold)
                }
            }
            .opacity(isLoading ? 0 : 1)

            if isLoading {
                ProgressView()
                    .scaleEffect(fontSize.rawValue / 17)
                    .foregroundColor(foregroundColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, fontSize.rawValue )
        .background( backgroundColor.opacity(isDisabled || isLoading ? 0.3 : 1) )
        .foregroundColor(foregroundColor.opacity(isDisabled || isLoading ? 0.6 : 1))
        // .overlay(
        //     RoundedRectangle(cornerRadius: 10)
        //         .stroke(
        //             isDisabled || isLoading ?
        //             Color.gray.opacity(0.3) :
        //             Color.clear,
        //             lineWidth: 1
        //         )
        // )
        .shadow(
            color: (isDisabled || isLoading) ?
            .clear :
            backgroundColor.opacity(0.4),
            radius: UISize.cornerRadius,
            x: 0,
            y: 3
        )
        .tapBackground() {
            guard !isDisabled && !isLoading else { return }
            isLoading = true
            await action()
            isLoading = false
        }
        .cornerRadius(UISize.cornerRadius)
    }
}
