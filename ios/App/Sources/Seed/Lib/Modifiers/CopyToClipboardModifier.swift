import SwiftUI

struct CopyToClipboardModifier: ViewModifier {
    let text: String
    let message: String

    init(text: String, message: String = "Copied") {
        self.text = text
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .tapOpacity {
                UIPasteboard.general.string = text
                ToastManager.shared.show(message)
            }
    }
}

extension View {
    func copyToClipboard(_ text: String, message: String? = nil) -> some View {
        modifier(CopyToClipboardModifier(text: text, message: message ?? L("copied")))
    }
}
