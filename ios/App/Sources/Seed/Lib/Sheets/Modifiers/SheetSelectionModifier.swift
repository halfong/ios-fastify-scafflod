import SwiftUI

struct SheetSelectionOption: Identifiable {
    let id: String
    let title: String
    let description: String?
    let priority: Int
    
    init(id: String, title: String, description: String? = nil, priority: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
    }
}

extension View {
    func sheetSelection(
        isPresented: Binding<Bool>,
        title: String,
        options: [SheetSelectionOption],
        selectedId: String? = nil,
        onSelect: @escaping (String) -> Bool
    ) -> some View {
        self.modifier(SelectionSheetPresenter(isPresented: isPresented, title: title, options: options, selectedId: selectedId, onSelect: onSelect))
    }
}

private struct SelectionSheetPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let options: [SheetSelectionOption]
    let onSelect: (String) -> Bool
    
    @State private var currentSelection: String?
    
    init(isPresented: Binding<Bool>, title: String, options: [SheetSelectionOption], selectedId: String? = nil, onSelect: @escaping (String) -> Bool) {
        self._isPresented = isPresented
        self.title = title
        self.options = options
        self.onSelect = onSelect
        self._currentSelection = State(initialValue: selectedId)
    }
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            SheetGenericView(
                title: title,
            ) {
                let prioritized = options.filter { $0.priority > 0 }.sorted { $0.priority > $1.priority }
                let normal = options.filter { $0.priority == 0 }
                ScrollView {
                  VStack(alignment: .leading, spacing: 0) {
                        if !prioritized.isEmpty {
                            Text(L("Suggestions")).lato(.t6, weight: .bold).foregroundColor(.text1)
                            ForEach(prioritized) { option in
                                optionItem(option, selected: option.id == currentSelection)
                                    .tapBackground {
                                        currentSelection = option.id
                                        if onSelect(option.id) { isPresented = false }
                                    }
                            }
                            Text(L("All")).lato(.t6, weight: .bold).foregroundColor(.text1).padding(.top, 24)
                        }
                        ForEach(normal) { option in
                            optionItem(option, selected: option.id == currentSelection)
                                .tapBackground {
                                    currentSelection = option.id
                                    if onSelect(option.id) { isPresented = false }
                                }
                        }
                    }
                }
                .padding(.horizontal, UISize.screenXPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private func optionItem(_ option: SheetSelectionOption, selected: Bool = false) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.title).lato(.t4, weight: .bold).foregroundColor(selected ? .accent : .text0)
                if let description = option.description {
                    Text(description).lato(.t5, weight: .regular).foregroundColor(.text1).lineLimit(2)
                }
            }
            Spacer()
            if selected { Icon("checkmark.circle.fill", size: .t4).foregroundColor(.accent) }
        }
        .padding(.vertical, 16)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lighten),
            alignment: .bottom
        )
    }
}
