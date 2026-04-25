import SwiftUI

struct TabOption {
    let value: String?
    let icon: Icon?
    let label: String
    let color: Color
}

struct TabComponent: View {
    let options: [TabOption]
    @Binding var selected: String?
    let onCancel: (() -> Void)?
    let onAdd: (() -> Void)?
    let onMore: ((String) -> Void)?

    init(
        options: [TabOption],
        selected: Binding<String?>,
        onCancel: (() -> Void)? = nil,
        onAdd: (() -> Void)? = nil,
        onMore: ((String) -> Void)? = nil
    ) {
        self.options = options
        self._selected = selected
        self.onCancel = onCancel
        self.onAdd = onAdd
        self.onMore = onMore
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                Spacer().frame(width: UISize.screenXPadding-6)
                // Close button when cancellable and showClose
                if let onCancel = onCancel, selected != nil {
                  TabItem(
                        option: TabOption(
                            value: nil,
                            icon: Icon("xmark", size: .t4),
                            label: "Close",
                            color: .gray
                        ),
                        isSelected: false,
                        showLabel: false
                    ) {
                      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = nil
                        onCancel()
                      }
                    }
                }

                // Tab options
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    TabItem(
                        option: option,
                        isSelected: selected == option.value,
                        showLabel: selected == option.value
                    ) {
                        if selected == option.value, let val = option.value {
                            onMore?(val)
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selected = option.value
                            }
                        }
                    }
                }

                // Add button
                if let onAdd = onAdd {
                    TabItem(
                        option: TabOption(
                            value: nil,
                            icon: Icon("plus", size: .t5),
                            label: L("New Tag"),
                            color: .text1
                        ),
                        isSelected: false,
                        showLabel: false
                    ) {
                        onAdd()
                    }
                }

                Spacer().frame(width: UISize.screenXPadding)
            }
            .padding(.vertical, 4)
        }
        .scrollClipDisabled()
        .padding(.vertical, -4)
    }
}

struct TabItem: View {

    let option: TabOption
    let isSelected: Bool
    let showLabel: Bool
    let onTap: () -> Void

    init(
        option: TabOption,
        isSelected: Bool,
        showLabel: Bool,
        onTap: @escaping () -> Void
    ) {
        self.option = option
        self.isSelected = isSelected
        self.showLabel = showLabel
        self.onTap = onTap
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon = option.icon {
                icon.foregroundColor(isSelected ? option.color : .text0)
            }
            if option.icon == nil || showLabel {
                Text(option.label)
                    .lato(.t5, weight: .bold)
                    .foregroundColor(isSelected ? option.color : .text0)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 16)
        .frame(minWidth: 64, minHeight: 44)
        .safeGlassCapsule(tint: isSelected ? option.color.opacity(0.1) : .clear)
        // .cornerRadius(UISize.cornerRadius)
        .tapOpacity(onTap: onTap)
    }
}
