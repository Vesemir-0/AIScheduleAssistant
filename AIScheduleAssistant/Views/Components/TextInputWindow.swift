//
//  TextInputWindow.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import SwiftUI

struct TextInputWindow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""
    let onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("输入文本")
                .font(.title2)
                .fontWeight(.bold)

            Text("请粘贴或输入包含日程信息的文本")
                .font(.caption)
                .foregroundColor(.secondary)

            TextEditor(text: $inputText)
                .font(.body)
                .frame(minHeight: 200)
                .border(Color.gray.opacity(0.3), width: 1)
                .cornerRadius(4)

            HStack {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("确认") {
                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSubmit(inputText)
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 500, height: 350)
    }
}

#Preview {
    TextInputWindow { text in
        print("Submitted: \(text)")
    }
}
