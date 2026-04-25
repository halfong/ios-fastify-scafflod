import SwiftUI

// MARK: - Styled Text Editor
struct StyledTextEditor: View {
    let label: String?
    var placeholder: String = ""
    @Binding var text: String
    var autoFocus: Bool = false
    var bare: Bool = false
    var minHeight: CGFloat = 100
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .none

    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label).lato(.t4, weight: .bold)
            }
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .frame(minHeight: minHeight, alignment: .top)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $text)
                    .padding(.all, 8)
                    .frame(minHeight: minHeight)
                    .scrollContentBackground(.hidden)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalization)
                    .background(
                        RoundedRectangle(cornerRadius: UISize.cornerRadius)
                            .fill(bare ? Color.clear : (focused ? .black.opacity(0.05) : Color.bg1.opacity(0.5)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: UISize.cornerRadius)
                            .stroke(bare ? Color.clear : (focused ? Color.accent : .lighten), lineWidth: 1)
                    )
                    .focused($focused)
                    .onAppear {
                        if autoFocus {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                focused = true
                            }
                        }
                    }
            }
        }
    }
}
