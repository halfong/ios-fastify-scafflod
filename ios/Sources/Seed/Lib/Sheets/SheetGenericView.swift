import SwiftUI

/// A reusable generic sheet component with customizable toolbar actions
struct SheetGenericView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showMorePopover = false
    @State private var isExecutingAction = false
    let title: String
    let actions: [(text: String, action: () -> Void, disabled: Bool, color: Color?)]
    let content: Content
    let backgroundColor: Color
    let onComplete: (() async -> Bool)?
    let onCancel: (() -> Bool)?

    /// Primary initializer with ViewBuilder content
    init(title: String, 
         actions: [(text: String, action: () -> Void, disabled: Bool, color: Color?)] = [], 
         backgroundColor: Color = .bg1,
         onComplete: (() async -> Bool)? = nil,
         onCancel: (() -> Bool)? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.actions = actions
        self.content = content()
        self.backgroundColor = backgroundColor
        self.onComplete = onComplete
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationStack {
            content
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .presentationCornerRadius(UISize.cornerRadius*1.6)
            .presentationBackground(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title).lato(.t4, weight: .bold).foregroundColor(.text0)
                }
                
                // Leading cancel button when callbacks are provided
                if onComplete != nil || onCancel != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Icon("xmark", size: .t5)
                            .foregroundColor(.text1)
                            .frame(width: 48, height: 48)
                            .tapBackground {
                                if let onCancel = onCancel {
                                    if onCancel() { dismiss() }
                                } else {
                                    dismiss()
                                }
                            }
                            .cornerRadius(UISize.cornerRadius)
                    }
                }
                
                // Trailing items
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        // Completion button
                        if let onComplete = onComplete {
                            Icon("checkmark", size: .t5)
                                .foregroundColor(.accent)
                                .frame(width: 48, height: 48)
                                .tapBackground {
                                    Task {
                                        if await onComplete() {
                                            dismiss()
                                        }
                                    }
                                }
                                .cornerRadius(UISize.cornerRadius)
                        }
                        
                        // Actions menu
                        if !actions.isEmpty {
                            Button(action: { showMorePopover.toggle() }) {
                                Icon("ellipsis", size: .t3)
                                    .foregroundColor(.text2)
                                    .frame(width: 48, height: 48)
                                    .cornerRadius(UISize.cornerRadius)
                            }
                            .popover(isPresented: $showMorePopover) {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                                        Text(action.text).lato(.t4, weight: .regular)
                                            .foregroundColor(action.disabled ? .text2 : action.color ?? .text0)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .contentShape(Rectangle())
                                            .tapBackground {
                                                if !action.disabled && !isExecutingAction {
                                                    isExecutingAction = true
                                                    showMorePopover = false
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        action.action()
                                                        isExecutingAction = false
                                                    }
                                                }
                                            }
                                        
                                        if index < actions.count - 1 {
                                            Divider()
                                        }
                                    }
                                }
                                .frame(minWidth: 200)
                                .presentationCompactAdaptation(.popover)
                            }
                        }
                        
                        // Simple dismiss when no callbacks
                        if onComplete == nil && onCancel == nil && actions.isEmpty {
                            Icon("chevron.down", size: 18)
                                .frame(width: 48, height: 48)
                                .tapBackground { dismiss() }
                                .cornerRadius(UISize.cornerRadius)
                        }
                    }
                }
            }
            .interactiveDismissDisabled(onComplete != nil || onCancel != nil)
        }
        .withErrorAlert()
        .withToastOverlay()
        .withLoadingOverlay()
    }
}
