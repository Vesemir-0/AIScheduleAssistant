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
    @State private var isFocused: Bool = false
    let onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "cube")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.accentWater,
                                DesignSystem.Colors.accentWaterLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("投入你的信息冰块")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("粘贴或输入包含日程的文本")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(.top, 8)

            // Glass-style text editor
            ZStack(alignment: .topLeading) {
                if inputText.isEmpty {
                    Text("例如：明天下午3点开会\n周五晚上7点和朋友吃饭\n下周一提交报告...")
                        .font(.body)
                        .foregroundColor(DesignSystem.Colors.textTertiary.opacity(0.6))
                        .padding(16)
                }

                TextEditor(text: $inputText)
                    .font(.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(Color.clear)
            }
            .frame(minHeight: 180)
            .background(
                DesignSystem.Colors.accentWaterLight.opacity(0.15)
            )
            .cornerRadius(DesignSystem.CornerRadius.extraLarge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .stroke(
                        isFocused
                            ? DesignSystem.Colors.accentWater
                            : DesignSystem.Colors.accentWater.opacity(0.3),
                        lineWidth: 2
                    )
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .shadow(color: DesignSystem.Colors.shadowCool, radius: 8, x: 0, y: 2)
            .onTapGesture {
                isFocused = true
            }

            // Action buttons
            HStack(spacing: 12) {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(CapybaraSecondaryButtonStyle())

                Spacer()

                Button {
                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSubmit(inputText)
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                        Text("开始融化")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(CapybaraPrimaryButtonStyle())
            }
        }
        .padding(32)
        .frame(width: 560, height: 420)
        .background(DesignSystem.Colors.backgroundWarm)
    }
}

#Preview {
    TextInputWindow { text in
        print("Submitted: \(text)")
    }
}
