//
//  TimeInterval+Vocap.swift
//  Vocano
//
//  Created by GPT-5.1 Codex on 2025/11/21.
//

import Foundation

extension TimeInterval {
    var VocanoClock: String {
        guard isFinite, self > 0 else { return "00:00" }
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// mm:ss.SSS (milliseconds) format for more precise timeline displays
    var VocanoClockMs: String {
        guard isFinite, self >= 0 else { return "00:00.000" }
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let milliseconds = Int((self - floor(self)) * 1000)
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
}

