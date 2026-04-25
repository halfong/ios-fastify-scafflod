import SwiftUI

struct StyledOptionsGroup<SelectionValue: Hashable>: View {
    let label: String?
    @Binding var selection: SelectionValue
    let options: [(SelectionValue, String)]
    var maxSelections: Int = 1
    var isMultipleSelection: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                Text(label)
                    .lato(.t4, weight: .bold)
                    .foregroundColor(.text0)
            }

            FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(options, id: \.0) { option in
                  Text(option.1)
                      .lato(.t4, weight: .regular)
                      .lineLimit(2)
                      .multilineTextAlignment(.center)
                      .padding(.vertical, 12)
                      .padding(.horizontal, 16) 
                      .background(isSelected(option.0) ? Color.accent : .bg1)
                      .foregroundColor(isSelected(option.0) ? .white : .text1)
                      .tapBackground {
                          handleSelection(option.0)
                      }
                      .cornerRadius(UISize.cornerRadius)
                }
            }
        }
    }

    private func isSelected(_ value: SelectionValue) -> Bool {
        if isMultipleSelection, let set = selection as? Set<SelectionValue> {
            return set.contains(value)
        } else {
            return selection == value
        }
    }

    private func handleSelection(_ value: SelectionValue) {
        if isMultipleSelection, var selectedSet = selection as? Set<SelectionValue> {
            if selectedSet.contains(value) {
                selectedSet.remove(value)
            } else if selectedSet.count < maxSelections {
                selectedSet.insert(value)
            }
            if let binding = $selection as? Binding<Set<SelectionValue>> {
                binding.wrappedValue = selectedSet
            }
        } else {
            selection = value
        }
    }
}
