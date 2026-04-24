import Foundation
import CryptoKit

extension String {
    /// Compute MD5 hash of the string
    var md5: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Get display width for a character based on Unicode East Asian Width property
    /// 全角字符返回2，半角字符返回1
    private func characterWidth(_ char: Character) -> Int {
        guard let scalar = char.unicodeScalars.first else { return 1 }
        let value = scalar.value
        
        // Fullwidth (F) and Wide (W) characters = 2
        // Based on Unicode East Asian Width property
        
        // Fullwidth ASCII variants (FF00-FF60)
        if (0xFF01...0xFF5E).contains(value) {  // Fullwidth forms (！＂＃ etc)
            return 2
        }
        
        // Fullwidth symbols and currency (FFE0-FFE6)
        if (0xFFE0...0xFFE6).contains(value) {  // ￠￡￢￣ etc
            return 2
        }
        
        // Halfwidth Katakana and Hangul (FF61-FFDC)
        if (0xFF61...0xFFDC).contains(value) {  // ｡｢｣ etc (halfwidth)
            return 1
        }
        
        // Halfwidth symbols (FFE8-FFEE)
        if (0xFFE8...0xFFEE).contains(value) {  // Halfwidth forms
            return 1
        }
        
        // Wide characters (W) and Fullwidth (F)
        // Hangul Jamo
        if (0x1100...0x115F).contains(value) || (0xA960...0xA97C).contains(value) {
            return 2
        }
        
        // CJK and related scripts (all fullwidth)
        if (0x2E80...0x2EFF).contains(value) ||  // CJK Radicals Supplement
           (0x2F00...0x2FDF).contains(value) ||  // Kangxi Radicals
           (0x3000...0x303F).contains(value) ||  // CJK Symbols and Punctuation (including fullwidth space)
           (0x3040...0x309F).contains(value) ||  // Hiragana
           (0x30A0...0x30FF).contains(value) ||  // Katakana
           (0x3100...0x312F).contains(value) ||  // Bopomofo
           (0x3130...0x318F).contains(value) ||  // Hangul Compatibility Jamo
           (0x3190...0x319F).contains(value) ||  // Kanbun
           (0x31A0...0x31BF).contains(value) ||  // Bopomofo Extended
           (0x31C0...0x31EF).contains(value) ||  // CJK Strokes
           (0x31F0...0x31FF).contains(value) ||  // Katakana Phonetic Extensions
           (0x3200...0x32FF).contains(value) ||  // Enclosed CJK Letters and Months
           (0x3300...0x33FF).contains(value) ||  // CJK Compatibility
           (0x3400...0x4DBF).contains(value) ||  // CJK Extension A
           (0x4E00...0x9FFF).contains(value) ||  // CJK Unified Ideographs
           (0xA000...0xA48F).contains(value) ||  // Yi Syllables
           (0xA490...0xA4CF).contains(value) ||  // Yi Radicals
           (0xAC00...0xD7A3).contains(value) ||  // Hangul Syllables
           (0xF900...0xFAFF).contains(value) ||  // CJK Compatibility Ideographs
           (0xFE10...0xFE19).contains(value) ||  // Vertical forms
           (0xFE30...0xFE4F).contains(value) ||  // CJK Compatibility Forms
           (0xFE50...0xFE6F).contains(value) ||  // Small Form Variants
           (0x1F200...0x1F251).contains(value) || // Enclosed Ideographic Supplement
           (0x20000...0x2A6DF).contains(value) || // CJK Extension B
           (0x2A700...0x2B73F).contains(value) || // CJK Extension C
           (0x2B740...0x2B81F).contains(value) || // CJK Extension D
           (0x2B820...0x2CEAF).contains(value) || // CJK Extension E
           (0x2CEB0...0x2EBEF).contains(value) || // CJK Extension F
           (0x2F800...0x2FA1F).contains(value) || // CJK Compatibility Ideographs Supplement
           (0x30000...0x3134F).contains(value) {  // CJK Extension G
            return 2
        }
        
        // Default: halfwidth/narrow = 1
        return 1
    }
    
    /// Calculate display width considering fullwidth characters as 2 units
    /// 计算显示宽度：全角字符2单位，半角字符1单位
    private var displayWidth: Int {
        return self.reduce(0) { $0 + characterWidth($1) }
    }
    
    /// Truncate string to maximum display width, adding "..." if truncated
    /// 截断字符串到最大显示宽度，超出部分用"..."代替
    /// Fullwidth characters (全角字符) count as 2 units, halfwidth (半角字符) as 1
    /// - Parameter maxLength: Maximum display width of the resulting string
    /// - Returns: Truncated string with "..." appended if original was longer
    func truncated(to maxLength: Int) -> String {
        let ellipsis = self.hasSuffix("...") ? "" : "..."
        let ellipsisWidth = 3
        
        guard self.displayWidth > maxLength else { return self }
        
        var currentWidth = 0
        var result = ""
        
        for char in self {
            let charWidth = characterWidth(char)
            if currentWidth + charWidth + ellipsisWidth > maxLength {
                break
            }
            result.append(char)
            currentWidth += charWidth
        }
        
        return result + ellipsis
    }
}

extension Data {
    /// Compute MD5 hash of the data
    var md5: String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension URL {
    /// Compute MD5 hash of file contents
    func md5() throws -> String {
        let data = try Data(contentsOf: self)
        return data.md5
    }
}
