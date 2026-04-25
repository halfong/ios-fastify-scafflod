import SwiftUI

extension View {
    func sheetDateEdit(
        isPresented: Binding<Bool>,
        title: String,
        value: Date?,
        onComplete: @escaping (Date) -> Void
    ) -> some View {
        // Track the current selection in the modifier's scope
        self.modifier(DateSheetPresenter(isPresented: isPresented, title: title, value: value, onComplete: onComplete))
    }
}

private struct DateSheetPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let value: Date?
    let onComplete: (Date) -> Void

    // Hold the temporary date state here
    @State private var selectedDate: Date = Date()

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            SheetGenericView(
                title: title,
                onComplete: {
                    onComplete(selectedDate)
                    return true 
                }
            ) {
              VStack(spacing: 20) {
                  DatePicker(
                      title,
                      selection: $selectedDate,
                      displayedComponents: [.date, .hourAndMinute]
                  )
                  .datePickerStyle(.graphical)
                  .labelsHidden()
              }
              .padding(.all, UISize.screenXPadding)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              .onAppear { selectedDate = value ?? Date() }
            }
        }
    }
}