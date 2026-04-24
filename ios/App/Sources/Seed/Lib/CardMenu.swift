import SwiftUI

struct CardMenuItem: View {

  let icon: String?
  let title: String
  let subtitle: String?

  let trailing: () -> AnyView
  let action: () -> Void
  let onLongPress: (() -> Void)?
  
  init(icon: String?, title: String, subtitle: String?, trailing: @escaping () -> AnyView, action: @escaping () -> Void, onLongPress: (() -> Void)? = nil) {
    self.icon = icon
    self.title = title
    self.subtitle = subtitle
    self.trailing = trailing
    self.action = action
    self.onLongPress = onLongPress
  }

  var body: some View {
    HStack(spacing: 12) {
        if let icon = icon {
          Image(systemName: icon)
            .lato(.t4, weight: .regular)
            .foregroundColor(Color.text1)
            .frame(width: 24, height: 24)
        }
        VStack(alignment: .leading, spacing: 0) {
            Text(title).lato(.t4)
            if let subtitle = subtitle {
                Text(subtitle).lato(.t6).foregroundColor(.text1)
            }
        }
        Spacer()
        trailing()
    }
    .contentShape(Rectangle())
    .padding(.all, 18)
    .tapBackground() {
        action()
    }
    .simultaneousGesture(LongPressGesture().onEnded { _ in
        onLongPress?()
    })
  }
}

struct CardMenu: View {

  let items: [CardMenuItem]

  var body: some View {
    VStack(spacing: 0) {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            item
            if index < items.count - 1 {
                Divider().padding(.leading, 52)
            }
        }
    }
    .background(Color.lighten)
    .cornerRadius(UISize.cornerRadius) 
  }
}