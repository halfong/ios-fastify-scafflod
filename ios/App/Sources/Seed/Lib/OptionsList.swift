import SwiftUI

/// Inline scrollable list of selectable string options.
struct OptionsList: View {
    let options: [String]

    @Binding var selected: String?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0){
                  ForEach(options, id: \.self) { option in
                      HStack {
                          Text(option)
                              .lato(.t4)
                              .foregroundStyle(selected == option ? Color.accent : Color.text0)
                              .lineLimit(1)
                          Spacer()
                          if selected == option {
                              Image(systemName: "checkmark")
                                  .font(.system(size: 13, weight: .semibold))
                                  .foregroundStyle(Color.accent)
                          }
                      }
                      .padding(.horizontal, FontSize.t5.rawValue)
                      .padding(.vertical, 16)
                      .background( selected == option ? Color.accent.opacity(0.02) : Color.clear )
                      .overlay(
                          Rectangle().frame(height: 1).foregroundStyle(.lighten),
                          alignment: .bottom
                      )
                      .id(option)
                      .tapBackground {
                        selected = option
                      } 
                  }
                }
            }
            .safeGlassRect(tint: .clear, cornerRadius: UISize.cornerRadius)
            .frame(maxHeight: .infinity)
            .onChange(of: selected) { _, newValue in
                if let newValue {
                    withAnimation { proxy.scrollTo(newValue, anchor: .center) }
                }
            }
            .onAppear {
                if let selected {
                    proxy.scrollTo(selected, anchor: .center)
                }
            }
            } // ScrollViewReader
            // .clipShape(RoundedRectangle(cornerRadius: UISize.cornerRadius))
    }
}
