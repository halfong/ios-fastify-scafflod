//
//  EditableText.swift
//  Vocano
//
//  Created by GPT-5.1 Codex on 2025/11/21.
//

import SwiftUI

struct EditableText: View {
    let text: String
    var placeholder: String = "Untitled"
    var onSubmit: (String) -> Void
    // 新增样式属性
    var font: Font = .body
    var foregroundColor: Color = .accent
    var alignment: TextAlignment = .center
    var icon: Icon = Icon("pencil", size: 12)

    @State private var isEditing = false
    @State private var draft = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Display mode view (始终居中或自定义对齐)
            displayModeView
                .opacity(isEditing ? 0 : 1)
            // Edit mode view
            if isEditing {
                TextField(placeholder, text: $draft)
                    .font(font)
                    .foregroundColor(foregroundColor)
                    .multilineTextAlignment(alignment)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit { finishEditing() }
                    .onAppear {
                        draft = text
                        DispatchQueue.main.async {
                            isFocused = true
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isEditing)
        .onChange(of: isFocused) { _, focused in
            if !focused, isEditing {
                finishEditing()
            }
        }
    }
    
    private var displayModeView: some View {
        HStack(spacing: 6) {
            Text(displayText)
                .font(font)
                .foregroundColor(foregroundColor)
                .multilineTextAlignment(alignment)
            icon
                .foregroundColor(.text1)
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : (alignment == .leading ? .leading : .trailing))
        .contentShape(Rectangle())
        .onTapGesture {
            beginEditing()
        }
    }

    private var displayText: String {
        text.isEmpty ? placeholder : text
    }

    private func beginEditing() {
        draft = text
        isEditing = true
        DispatchQueue.main.async {
            isFocused = true
        }
    }

    private func finishEditing() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        isEditing = false
        guard !trimmed.isEmpty else {
            draft = text
            return
        }
        guard trimmed != text else { return }
        onSubmit(trimmed)
    }
}


