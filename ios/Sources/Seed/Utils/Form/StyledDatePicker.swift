import SwiftUI

// MARK: - Styled Date Picker
struct StyledDatePicker: View {
    let label: String?
    let displayedComponents: DatePickerComponents

    init(label: String? = nil, selection: Binding<Date>, displayedComponents: DatePickerComponents = [.date]) {
        self.label = label
        self.displayedComponents = displayedComponents
        self._selection = selection
    }
    
    @Binding var selection: Date
    
    var body: some View {
        HStack(alignment: .center) {
            if let label = label {
                Text(label)
                    .lato(.t4, weight: .bold)
                    .foregroundColor(.text0)
                Spacer()
            }
            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .datePickerStyle(.compact)
                // .cornerRadius(UISize.cornerRadius)
                // .overlay(
                //     RoundedRectangle(cornerRadius: UISize.cornerRadius)
                //         .stroke(.lighten, lineWidth: 1)
                // )
                // .tapBackground()
        }
    }
} 
