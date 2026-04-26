//
//  ErrorAlertModifier.swift
//  Vocano
//
//  Created by Hal.fong on 2025/12/06.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Bindable private var errorManager = AppErrorManager.shared
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorManager.title,
                isPresented: .constant(errorManager.hasError),
                presenting: errorManager.detail
            ) { _ in
                Button(L("ok")) {
                    errorManager.clear()
                }
            } message: { message in
                Text(message)
            }
    }
}

extension View {
    /// Apply global error alert to the root view
    func withErrorAlert() -> some View {
        self.modifier(ErrorAlertModifier())
    }
}
