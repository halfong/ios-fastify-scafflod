import SwiftUI

// MARK: - Styled Calendar Picker
struct StyledCalendarPicker: View {
    let label: String?
    @Binding var selection: Date
    
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    private let today = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let label = label {
                Text(label)
                    .lato(.t4, weight: .bold)
                    .foregroundColor(.text0)
            }
            
            VStack(spacing: 0) {
                // Month/Year header
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.text0)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .lato(.t4, weight: .bold)
                        .foregroundColor(.text0)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.text0)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Days of week header
                HStack {
                    ForEach(weekdayHeaders, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.text1)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(calendarDays, id: \.self) { date in
                        if let date = date {
                            Button(action: { selectDate(date) }) {
                                dayView(for: date)
                            }
                            .disabled(!isDateInCurrentMonth(date))
                        } else {
                            Text("")
                                .frame(height: 36)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.black.opacity(0.02))
            .overlay(
                RoundedRectangle(cornerRadius: UISize.cornerRadius)
                    .stroke(.lighten, lineWidth: 1)
            )
            .cornerRadius(UISize.cornerRadius)
        }
    }
    
    private func dayView(for date: Date) -> some View {
        let dayNumber = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selection)
        let isToday = calendar.isDate(date, inSameDayAs: today)
        let isCurrentMonth = isDateInCurrentMonth(date)
        
        return Text("\(dayNumber)")
            .lato(.t4, weight: isToday ? .black : .regular)
            .foregroundColor(
                isSelected ? .white :
                isToday ? .accent :
                isCurrentMonth ? .text0 : .text1
            )
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill( isSelected ? Color.accent : Color.clear )
            )
            .overlay(
                isToday && !isSelected ?
                Circle()
                    .stroke(Color.accent.opacity(0.2), lineWidth: 1) :
                nil
            )
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start) else {
            return []
        }
        
        let monthLastDay = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end) ?? monthInterval.end
        guard let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthLastDay) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        while date <= monthLastWeek.end {
            days.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return days
    }
    
    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newMonth
    }
    
    private func selectDate(_ date: Date) {
        // Combine selected date with current time
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        if let combinedDate = calendar.date(from: combinedComponents) {
            selection = combinedDate
        }
    }
} 
