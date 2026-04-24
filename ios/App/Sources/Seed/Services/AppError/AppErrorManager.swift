//
//  AppErrorManager.swift
//  Vocano
//
//  Created by Hal.fong on 2025/12/06.
//

import Foundation
import SwiftUI

@Observable
final class AppErrorManager {
    static let shared = AppErrorManager()
    
    var error: AppError? = nil
    
    private init() {}
    
    /// Show an error. 402 errors are suppressed (PurchaseSheet is shown instead via ApiService.paymentRequired).
    func show(_ error: any Error) {
        let appError: AppError
        if let ae = error as? AppError {
            appError = ae
        } else {
            appError = AppError(title: "Error", detail: error.localizedDescription)
        }
        if appError.statusCode == 402 {
            return  // suppress generic alert; ApiService.paymentRequired triggers PurchaseSheet
        }
        self.error = appError
    }

    func show(_ title: String, detail: String?){
      self.show( AppError( title: title, detail: detail ))
    }
    
    /// Clear the current error
    func clear() {
        self.error = nil
    }
    
    /// Get the error title to display
    var title: String {
        error?.title ?? "Error"
    }
    
    /// Get the error detail message to display
    var detail: String? {
        error?.detail
    }
    
    /// Check if there's an active error
    var hasError: Bool {
        return error != nil
    }
}
