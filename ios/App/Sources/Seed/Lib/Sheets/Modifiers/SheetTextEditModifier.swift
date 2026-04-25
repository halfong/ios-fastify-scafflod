import SwiftUI

extension View {
    func sheetTextEdit(
        isPresented: Binding<Bool>,
        title: String,
        value: String,
        placeholder: String = "Good for writing",
        minLength: Int = 0,
        maxLength: Int = 2048,
        onComplete: @escaping (String) -> Void
    ) -> some View {
        self.modifier(TextEditSheetPresenter(isPresented: isPresented, title: title, value: value, placeholder: placeholder, minLength: minLength, maxLength: maxLength, onComplete: onComplete))
    }
}

private struct TextEditSheetPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let value: String
    let placeholder: String
    let minLength: Int
    let maxLength: Int
    let onComplete: (String) -> Void
    
    @State private var editedText: String
    
    init(isPresented: Binding<Bool>, title: String, value: String, placeholder: String, minLength: Int, maxLength: Int, onComplete: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.minLength = minLength
        self.maxLength = maxLength
        self.onComplete = onComplete
        self._editedText = State(initialValue: value)
    }
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            SheetGenericView(
                title: title,
                onComplete: {
                    // Validate min/max length if needed
                    if editedText.count >= minLength && editedText.count <= maxLength {
                        onComplete(editedText)
                        return true
                    }
                    return false
                }
            ) {
                StyledTextEditor(
                    label: nil,
                    placeholder: placeholder,
                    text: $editedText,
                    autoFocus: true,
                    bare: true
                )
                .padding(.horizontal, UISize.screenXPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}
