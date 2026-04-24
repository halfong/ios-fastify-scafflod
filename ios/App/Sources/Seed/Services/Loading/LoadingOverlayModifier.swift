//
//  LoadingOverlayModifier.swift
//  Vocano
//
//  Created by Copilot on 2025/02/07.
//

import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    @State private var loadingManager = LoadingManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if loadingManager.isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.accent)
                                .scaleEffect(1.5)
                            
                            if let message = loadingManager.message {
                                Text(message)
                                    .font(AppFont.lato(.t4, weight: .regular))
                                    .foregroundColor(.text0)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .padding(32)
                        .background(.bg1)
                        .cornerRadius(UISize.cornerRadius)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    }
                    .transition(.opacity)
                }
            }
            .disabled(loadingManager.isLoading)
            .animation(.easeInOut(duration: 0.2), value: loadingManager.isLoading)
    }
}

extension View {
    func withLoadingOverlay() -> some View {
        modifier(LoadingOverlayModifier())
    }
}
