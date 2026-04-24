import SwiftUI

// MARK: - Styled Picker
struct StyledPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    let label: String?
    @Binding var selection: SelectionValue
    let content: () -> Content

    init(label: String?, selection: Binding<SelectionValue>, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self._selection = selection
        self.content = content
    }

    var body: some View {
        HStack(alignment: .center) {
            if let label = label {
                Text(label)
                    .lato(.t4, weight: .bold)
                    .foregroundColor(.text0)
                    .frame(minWidth: 72, alignment: .leading)
                Spacer()
            }

            Picker("", selection: $selection, content: content)
                .pickerStyle(.menu)
                .menuStyle(.button)
                .buttonStyle(.plain)
                .accentColor(.accent)
                // .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(height:54)
                .background(Color.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: UISize.cornerRadius)
                        .stroke(Color.lighten, lineWidth: 1)
                )
                .tapBackground()
                .cornerRadius(UISize.cornerRadius)
        }
        .frame(height: 54)
    }
}
