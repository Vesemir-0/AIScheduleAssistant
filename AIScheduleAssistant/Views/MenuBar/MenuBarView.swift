//
//  MenuBarView.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import SwiftUI

struct MenuBarView: View {
    weak var appDelegate: AppDelegate?
    @StateObject private var viewModel = ContentProcessViewModel()
    @State private var showSettings = false
    @State private var showTextInput = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with branding
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.primaryCoral)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI 日程助手")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    Text("让水豚帮你整理日程")
                        .font(.system(size: 11))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.backgroundWarm,
                        DesignSystem.Colors.backgroundWarm.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            DividerCapybara()
                .padding(.vertical, 8)

            VStack(spacing: 8) {
                MenuButton(
                    icon: "camera.fill",
                    title: "截图获取",
                    subtitle: "轻松捕捉屏幕信息",
                    iconColor: DesignSystem.Colors.accentWater
                ) {
                    Task {
                        await viewModel.captureScreenshot()
                    }
                }

                MenuButton(
                    icon: "text.cursor",
                    title: "文本输入",
                    subtitle: "粘贴或输入日程文本",
                    iconColor: DesignSystem.Colors.primaryCoral
                ) {
                    showTextInput = true
                }
            }
            .padding(.horizontal, 12)

            DividerCapybara()
                .padding(.vertical, 8)

            VStack(spacing: 8) {
                MenuButton(
                    icon: "gearshape.fill",
                    title: "设置",
                    iconColor: DesignSystem.Colors.textSecondary
                ) {
                    appDelegate?.showSettingsWindow()
                }

                MenuButton(
                    icon: "info.circle.fill",
                    title: "关于",
                    iconColor: DesignSystem.Colors.textSecondary
                ) {
                    showAboutDialog()
                }
            }
            .padding(.horizontal, 12)

            DividerCapybara()
                .padding(.vertical, 8)

            MenuButton(
                icon: "rectangle.portrait.and.arrow.right",
                title: "退出",
                iconColor: DesignSystem.Colors.textTertiary
            ) {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(width: 280)
        .background(DesignSystem.Colors.backgroundWarm)
        .sheet(isPresented: $showTextInput) {
            TextInputWindow { text in
                Task {
                    await viewModel.captureTextFromInput(text)
                }
            }
        }
        .onChange(of: viewModel.state) {
            handleStateChange(viewModel.state)
        }
    }

    private func handleStateChange(_ state: ProcessingState) {
        switch state {
        case .completed(let events):
            appDelegate?.showPreviewWindow(events: events, viewModel: viewModel)
        case .error(let error):
            showErrorAlert(error)
        default:
            break
        }
    }

    private func handleProcessingResult() async {
        // This method is no longer needed but kept for compatibility
    }

    private func showErrorAlert(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "错误"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    private func showAboutDialog() {
        let alert = NSAlert()
        alert.messageText = "AI Schedule Assistant"
        alert.informativeText = """
        版本 1.0

        通过 AI 智能识别截图和文本中的日程信息，
        自动添加到系统日历和待办清单。

        © 2026 开源项目
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconColor: Color = DesignSystem.Colors.primaryCoral
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, subtitle != nil ? 10 : 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(isHovered ? DesignSystem.Colors.primaryCoral.opacity(0.1) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    MenuBarView()
}
