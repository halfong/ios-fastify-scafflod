import SwiftUI

struct ButtonSmart: View {

  let icon: IconSource?
  let title: String?
  let color: Color
  let action: () async -> Void

  init(icon: IconSource? = nil, title: String? = nil, color: Color = .text0, action: @escaping () async -> Void = {}) {
    self.icon = icon; self.title = title; self.action = action; self.color = color
  }

  var body: some View {
    HStack {
      if let icon {
        Icon(icon, size: FontSize.t3.rawValue)
          .foregroundColor(color)
      }
      if let title = title{
        Text(title).lato(.t4, weight: .bold).foregroundColor(color)
      }
    }
    .padding(.horizontal, icon == nil ? 0 : 16)
    .frame(width: title == nil ? 64 : nil, height: 54)
    .background(.ultraThinMaterial)
    .cornerRadius(24)
    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(color.opacity(0.2), lineWidth: 1)
        .background(color.opacity(0.06))
        
    )
     .clipShape(RoundedRectangle(cornerRadius: 24))
    .tapScale(onTap: action)
  }

}
