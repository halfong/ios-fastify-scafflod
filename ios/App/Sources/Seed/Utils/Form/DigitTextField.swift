import SwiftUI
import UIKit

/// Custom text field for numeric input with:
/// - Clear on first input after focus
/// - Always append input to end (no cursor navigation)
/// - Dimmed text when blurred
struct DigitTextField: View {
  @Binding var text: String
  let placeholder: String
  var fontSize: FontSize = .t4
  var customFontSize: CGFloat? = nil
  var keyboardType: UIKeyboardType = .decimalPad
  var textAlign: TextAlignment = .trailing
  var isFocused: Binding<Bool>? = nil
  var bare:Bool = false
  
  @State private var internalIsFocused: Bool = false
  
  private var actualFontSize: CGFloat {
    customFontSize ?? fontSize.rawValue
  }
  
  private var focusBinding: Binding<Bool> {
    if let isFocused = isFocused {
      return isFocused
    } else {
      return $internalIsFocused
    }
  }
  
  var body: some View {
    let textField = DigitTextFieldInternal(
      text: $text,
      placeholder: placeholder,
      fontSize: actualFontSize,
      keyboardType: keyboardType,
      textAlign: textAlign,
      isFocused: focusBinding
    )
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(height: 52)
    .frame(maxWidth: .infinity)
    
    if bare {
      textField
    } else {
      textField
        .background(
          RoundedRectangle(cornerRadius: UISize.cornerRadius)
            .fill(focusBinding.wrappedValue ? .black.opacity(0.05) : .bg1.opacity(0.5))
        )
        .overlay(
          RoundedRectangle(cornerRadius: UISize.cornerRadius)
            .stroke(focusBinding.wrappedValue ? Color.accent : .lighten, lineWidth: 1)
        )
        .cornerRadius(UISize.cornerRadius)
    }
  }
}

private struct DigitTextFieldInternal: UIViewRepresentable {
  @Binding var text: String
  let placeholder: String
  let fontSize: CGFloat
  let keyboardType: UIKeyboardType
  let textAlign: TextAlignment
  @Binding var isFocused: Bool
  
  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.keyboardType = keyboardType
    textField.textAlignment = textAlignToNSTextAlignment(textAlign)
    textField.font = UIFont(name: "Lato-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    textField.tintColor = .clear
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .none
    textField.spellCheckingType = .no
    textField.smartQuotesType = .no
    textField.smartDashesType = .no
    textField.smartInsertDeleteType = .no
    textField.delegate = context.coordinator
    context.coordinator.textField = textField
    return textField
  }
  
  func updateUIView(_ uiView: UITextField, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
    uiView.keyboardType = keyboardType
    uiView.textAlignment = textAlignToNSTextAlignment(textAlign)
    // Use binding value for text color instead of modifying state here
    uiView.textColor = isFocused ? UIColor(named: "accent") : UIColor(named: "text0")
    
    // Handle programmatic focus
    // Note: updateUIView is already called on the main thread, so we can call becomeFirstResponder directly
    if isFocused && !uiView.isFirstResponder {
      uiView.becomeFirstResponder()
    } else if !isFocused && uiView.isFirstResponder {
      uiView.resignFirstResponder()
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  private func textAlignToNSTextAlignment(_ alignment: TextAlignment) -> NSTextAlignment {
    switch alignment {
    case .leading:
      return .left
    case .trailing:
      return .right
    case .center:
      return .center
    }
  }
  
  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: DigitTextFieldInternal
    weak var textField: UITextField?
    private var shouldClearOnNextInput = false
    
    init(parent: DigitTextFieldInternal) {
      self.parent = parent
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      // UITextFieldDelegate methods are already called on the main thread
      self.parent.isFocused = true
      shouldClearOnNextInput = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      // UITextFieldDelegate methods are already called on the main thread
      self.parent.isFocused = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      // Filter out non-numeric characters and emoji to prevent RTI issues
      let allowedCharacters: CharacterSet
      if parent.keyboardType == .decimalPad {
        allowedCharacters = CharacterSet(charactersIn: "0123456789.。")
      } else {
        allowedCharacters = CharacterSet.decimalDigits
      }
      
      // Check if replacement string contains only allowed characters
      if !string.isEmpty && string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
        return false
      }
      
      var currentText = textField.text ?? ""
      
      // Normalize full-width period (。) to regular period (.) for decimal input
      var normalizedString = string
      if parent.keyboardType == .decimalPad && string.contains("。") {
        normalizedString = string.replacingOccurrences(of: "。", with: ".")
      }
      
      // Clear on first input after focus
      if shouldClearOnNextInput && !normalizedString.isEmpty {
        currentText = ""
        shouldClearOnNextInput = false
      }
      
      // Handle backspace
      if normalizedString.isEmpty {
        if !currentText.isEmpty {
          currentText = String(currentText.dropLast())
        }
      } else {
        // Always append at end
        currentText += normalizedString
      }
      
      textField.text = currentText
      // Notify the text input system to maintain proper session handling
      textField.sendActions(for: .editingChanged)
      // UITextFieldDelegate methods are already called on the main thread
      // Use async only to avoid potential SwiftUI state update warnings during text input
      DispatchQueue.main.async {
        self.parent.text = currentText
      }
      return false
    }
  }
}