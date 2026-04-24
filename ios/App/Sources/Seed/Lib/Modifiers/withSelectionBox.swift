import SwiftUI

/// A `ViewModifier` that wraps any view in a SwiftUI `Menu` for picking one option.
///
/// Usage:
/// ```swift
/// someLabel.withSelectionBox(options: allTags, selected: $selectedTag)
/// ```
struct SelectionBoxModifier: ViewModifier {
    let options: [String]
    let required: Bool = false
    var selected: Binding<String?>?
    let onPick: ((String?) -> Void)?

    func body(content: Content) -> some View {
        if !options.isEmpty {
            Menu {
                // "All" / clear entry
                if !required {
                    Button {
                        updateSelection(nil)
                    } label: {
                        optionLabel(label: L("None"), isSelected: currentSelection == nil)
                    }
                }

                Divider()

                ForEach(options, id: \.self) { option in
                    Button {
                        let newValue = currentSelection == option ? nil : option
                        updateSelection(newValue)
                    } label: {
                        optionLabel(label: option, isSelected: currentSelection == option)
                    }
                }
            } label: {
                content
            }
            // .contentShape(Rectangle())
        } else {
            content
        }
    }

    private var currentSelection: String? {
        selected?.wrappedValue
    }

    private func updateSelection(_ value: String?) {
        if let binding = selected {
            binding.wrappedValue = value
        }
        onPick?(value)
    }

    private func optionLabel(label: String, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            Text(label).lato(.t5).foregroundColor(isSelected ? .accent : .text0).lineLimit(1)
            Spacer()
            if isSelected {
                Icon("checkmark", size: 16)
                    .foregroundColor(.accent)
            }
        }
    }
}

extension View {
    func withSelectionBox(options: [String], selected: Binding<String?>? = nil, onPick: ((String?) -> Void)? = nil) -> some View {
        modifier(SelectionBoxModifier(options: options, selected: selected, onPick: onPick))
    }
}
