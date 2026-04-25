//
//  AppError.swift
//  Vocano
//
//  Created by GPT-5.1 Codex on 2025/11/21.
//

import Foundation

struct AppError: Error, LocalizedError, Identifiable {

    let id: String
    let title: String
    let detail: String?
    let issuedAt: Date
    /// HTTP status code, if this error originated from an API response.
    let statusCode: Int?

    init(title: String, detail: String? = nil, statusCode: Int? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.detail = detail
        self.issuedAt = Date()
        self.statusCode = statusCode
    }

    // LocalizedError – makes error.localizedDescription return a readable string
    // instead of the default "Vocano.AppError error 1." NSError bridge.
    var errorDescription: String? {
        if let detail = detail, !detail.isEmpty {
            return "\(title): \(detail)"
        }
        return title
    }

    var localizedDescription: String { errorDescription ?? title }

    var info: String { return detail ?? title }
    
}

