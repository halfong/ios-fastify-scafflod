//
//  LoadingManager.swift
//  Vocano
//
//  Created by Copilot on 2025/02/07.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class LoadingManager {
    static let shared = LoadingManager()
    
    var isLoading: Bool = false
    var message: String? = nil
    
    private init() {}
    
    func show(_ message: String? = nil) {
        isLoading = true
        self.message = message
    }
    
    func hide() {
        isLoading = false
        message = nil
    }
}
