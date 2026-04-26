import SwiftUI

// MARK: - Styled Text Field
struct StyledTextField: View {

    let label: AnyView?
    let placeholder: String
    @Binding var text: String

    var width: CGFloat? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .none
    var autoFocus: Bool = false
    var textAlign: TextAlignment = .leading

    @FocusState private var focused: Bool
    
    init(
        label: String? = nil,
        placeholder: String,
        text: Binding<String>,
        width: CGFloat? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: UITextAutocapitalizationType = .none,
        autoFocus: Bool = false,
        textAlign: TextAlignment = .leading
    ) {
        self.label = label.map { 
            AnyView(Text($0).lato(.t4, weight: .bold).foregroundColor(.text0))
        }
        self.placeholder = placeholder
        self._text = text
        self.width = width
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.autoFocus = autoFocus
        self.textAlign = textAlign
    }
    
    init<Label: View>(
        label: Label?,
        placeholder: String,
        text: Binding<String>,
        width: CGFloat? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: UITextAutocapitalizationType = .none,
        autoFocus: Bool = false,
        textAlign: TextAlignment = .leading
    ) {
        self.label = label.map { AnyView($0) }
        self.placeholder = placeholder
        self._text = text
        self.width = width
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.autoFocus = autoFocus
        self.textAlign = textAlign
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let label = label {
                label.frame(minWidth: 72, alignment: .leading)
            }
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .multilineTextAlignment(textAlign)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .focused($focused)
                .font(AppFont.lato(.t4, weight: .regular))
                .onChange(of: text) { oldValue, newValue in
                    // @todo this approach is stupid.
                    // Normalize full-width period (。) to regular period (.) for decimal input
                    if keyboardType == .decimalPad && newValue.contains("。") {
                        text = newValue.replacingOccurrences(of: "。", with: ".")
                    }
                }
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                      focused = true
                  }
                }
                .frame(height: .infinity)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: UISize.cornerRadius)
                      .fill( focused ? .black.opacity(0.05) : Color.bg1.opacity(0.5) )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: UISize.cornerRadius)
                      .stroke( focused ? Color.accent : .lighten, lineWidth: 1)
                )
                .cornerRadius(UISize.cornerRadius)
        }
    }
}
