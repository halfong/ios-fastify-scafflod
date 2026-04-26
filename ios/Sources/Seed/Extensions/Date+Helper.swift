import Foundation

enum DatePeriodRange: String {
  case day
  case week
  case month
  case year
}

struct DatePeriod {
  let start: Date
  let end: Date

  func contains(_ date: Date) -> Bool {
    return date >= start && date <= end
  }
}

extension Date {
    // Format milliseconds to readable timestamp
    static func msToTimeString(_ ms: Int?) -> String {
        guard let ms = ms else { return "0:00" }
        let seconds = ms / 1000
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    /// Returns a date string in the format "yyyy-MM-ddT00:00:00Z" (UTC midnight, no matter the timezone)
    func toDayUTCString() -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let startOfUTC = calendar.startOfDay(for: self)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        // Manually set time to 00:00:00 for UTC
        var comps = calendar.dateComponents([.year, .month, .day], from: startOfUTC)
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let utcMidnight = calendar.date(from: comps)!
        
        return dateFormatter.string(from: utcMidnight)
    }
    
    static func fromString(_ dateString: String) -> Date {
      return ISO8601DateFormatter().date(from: normalizeDateString(dateString)) ?? Date()
    }

    /// Normalizes an ISO8601 date string to match toDayUTCString() format
    /// Converts formats like "2025-08-11T00:00:00.000Z" or "2025-08-11T00:00:000Z" to "2025-08-11T00:00:00Z"
    static func normalizeDateString(_ dateString: String) -> String {
        // Fix malformed seconds (e.g., "00:00:000Z" -> "00:00:00Z")
        var normalized = dateString
        if let range = normalized.range(of: #":\d{3}Z$"#, options: .regularExpression) {
            normalized.replaceSubrange(range, with: ":00Z")
        }
        
        // Parse and reformat
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds]
        var date = parser.date(from: normalized)
        
        if date == nil {
            parser.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
            date = parser.date(from: normalized)
        }
        
        guard let parsedDate = date else {
            return normalized.components(separatedBy: "T").first.map { "\($0)T00:00:00Z" } ?? dateString
        }
        
        // Reformat to standard format matching toDayUTCString()
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter.string(from: parsedDate)
    }

    /// Parses an ISO 8601 string and returns a display string in "yyyy-MM-dd HH:mm" format.
    static func fromISO(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso.date(from: raw) ?? ISO8601DateFormatter().date(from: raw)
        guard let date else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f.string(from: date)
    }

    func addDay(Int days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func diffDays( minus:Date ) -> Int{
      let calendar = Calendar.current
      let components = calendar.dateComponents([.day], from: minus, to: self)
      return components.day ?? 0
    }
    func period(range: DatePeriodRange, at: Date = Date()) -> DatePeriod {
      let calendar = Calendar.current
      var start: Date
      var end: Date

      switch range {
          case .day:
            start = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: at)) ?? self
            end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? self
          case .week:
            start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: at)) ?? self
            end = calendar.date(byAdding: DateComponents(day: 7, second: -1), to: start) ?? self
          case .month:
            start = calendar.date(from: calendar.dateComponents([.year, .month], from: at)) ?? self
            end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start) ?? self
          case .year:
            start = calendar.date(from: calendar.dateComponents([.year], from: at)) ?? self
            end = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start) ?? self
      }

      // Set start time to 00:00:00 and end time to 23:59:59
      start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: start) ?? start
      end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end

      return DatePeriod(start: start, end: end)
    }

    /// Formats the date using the given format string (default: "yyyy/MM/dd").
    /// If the format is "MMMM" (full month name), returns the month as two-digit number (e.g., "September" -> "09").
    /// - Parameter format: The date format string (e.g., "yyyy/MM/dd", "MMMM", "MMM d, yyyy").
    /// - Returns: The formatted date string.
    func format(format: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    func isSameDayAs(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }

    func toFriendlyTime(format: String = "MMM dd, yyyy", _ trans: @escaping (String) -> String = { $0 }) -> String {
      let calendar = Calendar.current
      let daysDifference = calendar.dateComponents([.day], from: self, to: Date()).day ?? 0
      
      if daysDifference > 1 {
          return self.format(format: format)
      } else {
          return friendlyTime(date: self, trans: trans)
      }
    }

    var isValid: Bool {
        return self != Date.distantPast && self != Date.distantFuture
    }
    
    // More comprehensive validation for display purposes
    var isValidForDisplay: Bool {
        // Check for distant dates, invalid timestamps, and reasonable date ranges
        let year1900 = Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? Date.distantPast
        let year2100 = Calendar.current.date(from: DateComponents(year: 2100, month: 1, day: 1)) ?? Date.distantFuture
        
        return self != Date.distantPast && 
               self != Date.distantFuture && 
               self >= year1900 && 
               self <= year2100 &&
               !self.timeIntervalSince1970.isNaN &&
               !self.timeIntervalSince1970.isInfinite
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    /// Smart contextual date formatting:
    /// - Today      → "Today · 11:32"
    /// - Yesterday  → "Yesterday · 02:11"
    /// - This year  → "Feb 28 · 09:30"
    /// - Past year  → "Oct 1, 2025"
    var atom: String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeStr = timeFormatter.string(from: self)
        return "\(atomDate) · \(timeStr)"
    }

    var atomDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.component(.year, from: self) == calendar.component(.year, from: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            return "\(dateFormatter.string(from: self))"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: self)
        }
    }

    var shortDate: String{
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy/MM/dd"
      return formatter.string(from: self)
    }

    var formattedAsMonthDayYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd yyyy"
        return formatter.string(from: self)
    }

}

func friendlyTime(date: Date, now: Date = Date(), trans: @escaping (String) -> String = { $0 }) -> String {
    let calendar = Calendar.current
    
    // More comprehensive date validation for AnyCodable parsing issues
    guard date.isValidForDisplay else {
        return trans("invalid_date")
    }
    
    // If the date is in the future, return a specific message
    if date > now {
        return trans("in_the_future")
    }
    
    // Calculate the time difference with error handling
    guard let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now) as DateComponents? else {
        return trans("unknown_time")
    }
    
    // Format based on the time difference
    if let year = components.year, year > 0 {
        let unitKey = year == 1 ? trans("year") : trans("years")
        return "\(year) \(unitKey) \(trans("ago"))"
    } else if let month = components.month, month > 0 {
        let unitKey = month == 1 ? trans("month") : trans("months")
        return "\(month) \(unitKey) \(trans("ago"))"
    } else if let day = components.day, day > 0 {
        let unitKey = day == 1 ? trans("day") : trans("days")
        return "\(day) \(unitKey) \(trans("ago"))"
    } else if let hour = components.hour, hour > 0 {
        let unitKey = hour == 1 ? trans("hour") : trans("hours")
        return "\(hour) \(unitKey) \(trans("ago"))"
    } else if let minute = components.minute, minute > 0 {
        let unitKey = minute == 1 ? trans("minute") : trans("minutes")
        return "\(minute) \(unitKey) \(trans("ago"))"
    } else {
        return trans("just_now")
    }
}
