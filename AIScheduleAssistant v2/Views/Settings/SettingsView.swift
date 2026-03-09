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
                    Label("AI 配置", systemImage: "brain.head.profile")
                }

            BehaviorSettingsView()
                .tabItem {
                    Label("行为设置", systemImage: "gearshape.2")
                }

            PermissionsView()
                .tabItem {
                    Label("权限管理", systemImage: "lock.shield")
                }
        }
        .frame(width: 650, height: 520)
    }
}

struct AIConfigView: View {
    @ObservedObject private var configService = ConfigService.shared
    @State private var validationErrors: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue.gradient)

                    Text("AI 配置")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("配置 AI 模型和参数")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // API Configuration Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "API 配置", icon: "network")

                    VStack(spacing: 12) {
                        SettingRow(label: "API 端点") {
                            TextField("https://api.openai.com/v1", text: $configService.settings.aiConfig.baseURL)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        SettingRow(label: "API Key") {
                            SecureField("输入 API Key", text: $configService.settings.aiConfig.apiKey)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        SettingRow(label: "模型名称") {
                            TextField("gpt-4", text: $configService.settings.aiConfig.model)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }

                // Model Parameters Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "模型参数", icon: "slider.horizontal.3")

                    VStack(spacing: 16) {
                        SettingRow(label: "Temperature") {
                            HStack(spacing: 12) {
                                Slider(value: $configService.settings.aiConfig.temperature, in: 0...2, step: 0.1)
                                    .tint(.blue)

                                Text(String(format: "%.1f", configService.settings.aiConfig.temperature))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }

                        SettingRow(label: "Max Tokens") {
                            TextField("4000", value: $configService.settings.aiConfig.maxTokens, format: .number)
                                .textFieldStyle(CustomTextFieldStyle())
                                .frame(width: 120)
                        }
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }

                // Validation Errors
                if !validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(validationErrors, id: \.self) { error in
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.subheadline)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        configService.resetToDefaults()
                    }) {
                        Label("恢复默认", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button(action: {
                        validationErrors = configService.validateConfig()
                        if validationErrors.isEmpty {
                            configService.saveSettings()
                        }
                    }) {
                        Label("保存设置", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct BehaviorSettingsView: View {
    @ObservedObject private var configService = ConfigService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gearshape.2")
                        .font(.system(size: 40))
                        .foregroundStyle(.purple.gradient)

                    Text("行为设置")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("自定义应用行为和保存选项")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Add Mode Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "添加模式", icon: "plus.circle")

                    VStack(spacing: 12) {
                        Toggle(isOn: $configService.settings.autoAddMode) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("自动添加")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("无需预览确认，直接添加到日历")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }

                // Save Target Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "保存选项", icon: "square.and.arrow.down")

                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach([
                                (SaveTarget.both, "日历和待办清单", "同时保存到日历和待办清单"),
                                (SaveTarget.calendarOnly, "仅日历", "只保存到日历应用"),
                                (SaveTarget.reminderOnly, "仅待办清单", "只保存到提醒事项")
                            ], id: \.0) { target, title, description in
                                RadioOption(
                                    isSelected: configService.settings.saveTarget == target,
                                    title: title,
                                    description: description
                                ) {
                                    configService.settings.saveTarget = target
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }

                // Feature Toggles Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "功能开关", icon: "switch.2")

                    VStack(spacing: 12) {
                        Toggle(isOn: $configService.settings.enableScreenshotCapture) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("启用截图功能")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("通过截图识别日程信息")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))

                        Divider()

                        Toggle(isOn: $configService.settings.enableTextCapture) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("启用文本选择功能")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("通过选中文本识别日程信息")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }

                // Save Button
                Button(action: {
                    configService.saveSettings()
                }) {
                    Label("保存设置", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
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

// MARK: - Custom Components

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

struct SettingRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            content()
        }
    }
}

struct RadioOption: View {
    let isSelected: Bool
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.08) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Styles

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(.primary)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
}
