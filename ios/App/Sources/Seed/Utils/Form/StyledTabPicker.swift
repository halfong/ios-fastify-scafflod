import SwiftUI

/// A styled tab picker component for segmented control style selection
///
/// Usage:
/// ```swift
/// enum SortMode: String, CaseIterable {
///     case byDate = "By Date"
///     case byName = "By Name"
/// }
/// 
/// @State private var selectedMode = SortMode.byDate
/// 
/// StyledTabPicker(selection: $selectedMode, options: SortMode.allCases)
/// ```
struct StyledTabPicker<T: RawRepresentable & Hashable & CaseIterable>: View where T.RawValue == String {
    @Binding var selection: T
    let options: [T]
    
    init(selection: Binding<T>, options: [T] = Array(T.allCases)) {
        self._selection = selection
        self.options = options
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option
                    }
                }) {
                    Text(option.rawValue)
                        .lato(.t5, weight: selection == option ? .bold : .regular)
                        .foregroundColor(selection == option ? .bg0 : .text1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selection == option ? Color.accent : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.lighten, lineWidth: 1)
                )
        )
    }
}
