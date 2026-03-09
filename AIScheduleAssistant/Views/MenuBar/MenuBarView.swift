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
            MenuButton(icon: "camera.fill", title: "截图获取") {
                Task {
                    await viewModel.captureScreenshot()
                }
            }

            MenuButton(icon: "text.cursor", title: "文本输入") {
                showTextInput = true
            }

            Divider()
                .padding(.vertical, 4)

            MenuButton(icon: "gearshape.fill", title: "设置") {
                appDelegate?.showSettingsWindow()
            }

            MenuButton(icon: "info.circle.fill", title: "关于") {
                showAboutDialog()
            }

            Divider()
                .padding(.vertical, 4)

            MenuButton(icon: "xmark.circle.fill", title: "退出") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(8)
        .frame(width: 250)
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(title)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
        )
        .onHover { isHovered in
            if isHovered {
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
