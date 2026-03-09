//
//  SettingsView.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            AIConfigView()
                .tabItem {
                    Label("AI 配置", systemImage: "brain")
                }

            BehaviorSettingsView()
                .tabItem {
                    Label("行为设置", systemImage: "slider.horizontal.3")
                }

            PermissionsView()
                .tabItem {
                    Label("权限管理", systemImage: "lock.shield")
                }
        }
        .frame(width: 600, height: 500)
    }
}

struct AIConfigView: View {
    @ObservedObject private var configService = ConfigService.shared
    @State private var validationErrors: [String] = []

    var body: some View {
        Form {
            Section("API 配置") {
                LabeledContent("API 端点") {
                    TextField("https://api.openai.com/v1", text: $configService.settings.aiConfig.baseURL)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 350)
                }

                LabeledContent("API Key") {
                    SecureField("输入 API Key", text: $configService.settings.aiConfig.apiKey)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 350)
                }

                LabeledContent("模型名称") {
                    TextField("gpt-4", text: $configService.settings.aiConfig.model)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 350)
                }
            }

            Section("模型参数") {
                LabeledContent("Temperature") {
                    HStack {
                        Slider(value: $configService.settings.aiConfig.temperature, in: 0...2, step: 0.1)
                            .frame(width: 250)
                        Text(String(format: "%.1f", configService.settings.aiConfig.temperature))
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                LabeledContent("Max Tokens") {
                    TextField("1000", value: $configService.settings.aiConfig.maxTokens, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
            }

            if !validationErrors.isEmpty {
                Section("验证错误") {
                    ForEach(validationErrors, id: \.self) { error in
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
            }

            HStack {
                Button("恢复默认") {
                    configService.resetToDefaults()
                }

                Spacer()

                Button("保存") {
                    validationErrors = configService.validateConfig()
                    if validationErrors.isEmpty {
                        configService.saveSettings()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct BehaviorSettingsView: View {
    @ObservedObject private var configService = ConfigService.shared

    var body: some View {
        Form {
            Section("添加模式") {
                Toggle("自动添加（无需预览确认）", isOn: $configService.settings.autoAddMode)
                Text("关闭后，AI 识别内容后会显示预览窗口供您确认")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("功能开关") {
                Toggle("启用截图功能", isOn: $configService.settings.enableScreenshotCapture)
                Toggle("启用文本选择功能", isOn: $configService.settings.enableTextCapture)
            }

            Section("快捷键") {
                LabeledContent("截图") {
                    Text("待实现")
                        .foregroundColor(.secondary)
                }

                LabeledContent("文本选择") {
                    Text("待实现")
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Spacer()
                Button("保存") {
                    configService.saveSettings()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct PermissionsView: View {
    @ObservedObject private var permissionManager = PermissionManager.shared
    @State private var isRequesting = false
    @State private var refreshID = UUID()

    var body: some View {
        Form {
            Section("系统权限状态") {
                PermissionRow(
                    icon: "camera.fill",
                    title: "屏幕录制权限",
                    description: "用于截图功能",
                    status: permissionManager.screenRecordingStatus,
                    onOpenSettings: {
                        permissionManager.openSystemPreferences(for: .screenRecording)
                    }
                )
                .id(permissionManager.screenRecordingStatus)

                Divider()

                PermissionRow(
                    icon: "accessibility",
                    title: "辅助功能权限",
                    description: "用于读取选中文本",
                    status: permissionManager.accessibilityStatus,
                    onOpenSettings: {
                        permissionManager.openSystemPreferences(for: .accessibility)
                    },
                    onRequest: {
                        permissionManager.requestAccessibilityPermission()
                        // Refresh status after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            permissionManager.checkAllPermissions()
                        }
                    }
                )
                .id(permissionManager.accessibilityStatus)

                Divider()

                PermissionRow(
                    icon: "calendar",
                    title: "日历权限",
                    description: "用于创建日历事件",
                    status: permissionManager.calendarStatus,
                    onOpenSettings: {
                        print("📍 Opening calendar settings")
                        permissionManager.openSystemPreferences(for: .calendar)
                    },
                    onRequest: {
                        print("📍 Calendar request button clicked")
                        Task {
                            print("📍 Starting calendar permission request")
                            do {
                                try await permissionManager.requestCalendarPermission()
                                print("📍 Calendar permission request completed")
                                // Refresh status
                                await MainActor.run {
                                    permissionManager.checkAllPermissions()
                                }
                            } catch {
                                print("❌ Calendar permission error: \(error)")
                            }
                        }
                    }
                )
                .id(permissionManager.calendarStatus)

                Divider()

                PermissionRow(
                    icon: "checklist",
                    title: "提醒事项权限",
                    description: "用于创建待办事项",
                    status: permissionManager.remindersStatus,
                    onOpenSettings: {
                        print("📍 Opening reminders settings")
                        permissionManager.openSystemPreferences(for: .reminders)
                    },
                    onRequest: {
                        print("📍 Reminders request button clicked")
                        Task {
                            print("📍 Starting reminders permission request")
                            do {
                                try await permissionManager.requestRemindersPermission()
                                print("📍 Reminders permission request completed")
                                // Refresh status
                                await MainActor.run {
                                    permissionManager.checkAllPermissions()
                                }
                            } catch {
                                print("❌ Reminders permission error: \(error)")
                            }
                        }
                    }
                )
                .id(permissionManager.remindersStatus)
            }

            Section {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("某些权限需要在系统设置中手动授权。应用会自动检测权限状态变化。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Spacer()
                Button("刷新状态") {
                    permissionManager.checkAllPermissions()
                    refreshID = UUID()
                }
            }
        }
        .padding()
        .id(refreshID)
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus
    let onOpenSettings: () -> Void
    var onRequest: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    statusIcon
                    statusText
                }

                if status != .granted {
                    if let onRequest = onRequest {
                        Button("请求权限") {
                            print("🔘 Button tapped for: \(title)")
                            onRequest()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }

                    Button("打开系统设置") {
                        print("🔘 Open settings tapped for: \(title)")
                        onOpenSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var statusIcon: some View {
        Image(systemName: status == .granted ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(status == .granted ? .green : .red)
    }

    private var statusText: Text {
        Text(status == .granted ? "已授权" : "未授权")
            .font(.subheadline)
            .foregroundColor(status == .granted ? .green : .red)
    }
}

#Preview {
    SettingsView()
}
