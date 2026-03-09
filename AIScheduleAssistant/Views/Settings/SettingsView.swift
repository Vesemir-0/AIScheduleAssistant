//
//  SettingsView.swift
//  AIScheduleAssistant
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
                    Label("行为设置", systemImage: "gearshape.fill")
                }

            PermissionsView()
                .tabItem {
                    Label("权限管理", systemImage: "lock.shield.fill")
                }
        }
        .frame(width: 700, height: 580)
        .background(DesignSystem.Colors.backgroundWarm)
    }
}

struct AIConfigView: View {
    @ObservedObject private var configService = ConfigService.shared
    @State private var validationErrors: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    Image("SettingsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)

                    Text("AI 配置中心")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("让水豚更聪明地理解你的日程")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.top, 24)

                // API Configuration Section
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderCapybara(title: "API 配置", icon: "network")

                    VStack(spacing: 16) {
                        SettingRow(label: "API 端点") {
                            TextField("https://api.openai.com/v1", text: $configService.settings.aiConfig.baseURL)
                                .textFieldStyle(CapybaraTextFieldStyle())
                        }

                        SettingRow(label: "API Key") {
                            SecureField("输入 API Key", text: $configService.settings.aiConfig.apiKey)
                                .textFieldStyle(CapybaraTextFieldStyle())
                        }

                        SettingRow(label: "模型名称") {
                            TextField("gpt-4", text: $configService.settings.aiConfig.model)
                                .textFieldStyle(CapybaraTextFieldStyle())
                        }
                    }
                    .padding(20)
                    .floatingCard(shadowColor: DesignSystem.Colors.shadowCool)
                }

                // Model Parameters Section
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderCapybara(title: "模型参数", icon: "slider.horizontal.3")

                    VStack(spacing: 20) {
                        SettingRow(label: "Temperature") {
                            HStack(spacing: 16) {
                                Slider(value: $configService.settings.aiConfig.temperature, in: 0...2, step: 0.1)
                                    .tint(DesignSystem.Colors.primaryCoral)

                                Text(String(format: "%.1f", configService.settings.aiConfig.temperature))
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .frame(width: 45, alignment: .trailing)
                            }
                        }

                        SettingRow(label: "Max Tokens") {
                            TextField("4000", value: $configService.settings.aiConfig.maxTokens, format: .number)
                                .textFieldStyle(CapybaraTextFieldStyle())
                                .frame(width: 140)
                        }
                    }
                    .padding(20)
                    .floatingCard(shadowColor: DesignSystem.Colors.shadowWarm)
                }

                // Validation Errors
                if !validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(validationErrors, id: \.self) { error in
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(DesignSystem.Colors.primaryCoral)
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DesignSystem.Colors.primaryCoral.opacity(0.1))
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                    }
                }

                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        configService.resetToDefaults()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("恢复默认")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(CapybaraSecondaryButtonStyle())

                    Button(action: {
                        validationErrors = configService.validateConfig()
                        if validationErrors.isEmpty {
                            configService.saveSettings()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("保存设置")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(CapybaraPrimaryButtonStyle())
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 32)
        }
        .background(DesignSystem.Colors.backgroundWarm)
    }
}

struct BehaviorSettingsView: View {
    @ObservedObject private var configService = ConfigService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    Image("SettingsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)

                    Text("行为设置")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("自定义你的使用习惯")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.top, 24)

                // Add Mode Section
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderCapybara(title: "添加模式", icon: "plus.circle")

                    Toggle(isOn: $configService.settings.autoAddMode) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("自动添加")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Text("无需预览确认，直接添加到日历")
                                .font(.system(size: 13))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primaryCoral))
                    .padding(20)
                    .floatingCard(shadowColor: DesignSystem.Colors.shadowWarm)
                }

                // Save Target Section
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderCapybara(title: "保存选项", icon: "square.and.arrow.down")

                    VStack(spacing: 14) {
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
                    .padding(20)
                    .floatingCard(shadowColor: DesignSystem.Colors.shadowCool)
                }

                // Feature Toggles Section
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderCapybara(title: "功能开关", icon: "switch.2")

                    VStack(spacing: 16) {
                        Toggle(isOn: $configService.settings.enableScreenshotCapture) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("启用截图功能")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                Text("通过截图识别日程信息")
                                    .font(.system(size: 13))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primaryCoral))

                        DividerCapybara()

                        Toggle(isOn: $configService.settings.enableTextCapture) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("启用文本选择功能")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                Text("通过选中文本识别日程信息")
                                    .font(.system(size: 13))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primaryCoral))
                    }
                    .padding(20)
                    .floatingCard(shadowColor: DesignSystem.Colors.shadowNeutral)
                }

                // Save Button
                Button(action: {
                    configService.saveSettings()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("保存设置")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CapybaraPrimaryButtonStyle())
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 32)
        }
        .background(DesignSystem.Colors.backgroundWarm)
    }
}

struct PermissionsView: View {
    @ObservedObject private var permissionManager = PermissionManager.shared
    @State private var isRequesting = false
    @State private var refreshID = UUID()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    Image("SettingsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)

                    Text("权限管理")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("确保水豚能正常工作")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.top, 24)

                // Permissions list
                VStack(spacing: 16) {
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

                    DividerCapybara()

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

                    DividerCapybara()

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
                .padding(24)
                .floatingCard(shadowColor: DesignSystem.Colors.shadowWarm)

                // Info box
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.accentWater)
                    Text("某些权限需要在系统设置中手动授权。应用会自动检测权限状态变化。")
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(16)
                .background(DesignSystem.Colors.accentWaterLight.opacity(0.15))
                .cornerRadius(DesignSystem.CornerRadius.medium)

                // Refresh button
                Button {
                    permissionManager.checkAllPermissions()
                    refreshID = UUID()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("刷新状态")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CapybaraSecondaryButtonStyle())
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 32)
        }
        .background(DesignSystem.Colors.backgroundWarm)
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
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(statusColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                HStack(spacing: 8) {
                    statusIcon
                    statusText
                }

                if status != .granted {
                    VStack(spacing: 8) {
                        if let onRequest = onRequest {
                            Button("请求权限") {
                                print("🔘 Button tapped for: \(title)")
                                onRequest()
                            }
                            .buttonStyle(CapybaraSecondaryButtonStyle())
                            .controlSize(.small)
                        }

                        Button("打开系统设置") {
                            print("🔘 Open settings tapped for: \(title)")
                            onOpenSettings()
                        }
                        .buttonStyle(CapybaraSecondaryButtonStyle())
                        .controlSize(.small)
                    }
                }
            }
        }
        .padding(.vertical, 12)
    }

    private var statusIcon: some View {
        Image(systemName: status == .granted ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(status == .granted ? DesignSystem.Colors.successGreen : DesignSystem.Colors.primaryCoral)
    }

    private var statusText: Text {
        Text(status == .granted ? "已授权" : "未授权")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(status == .granted ? DesignSystem.Colors.successGreen : DesignSystem.Colors.primaryCoral)
    }

    private var statusColor: Color {
        status == .granted ? DesignSystem.Colors.successGreen : DesignSystem.Colors.textSecondary
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
                .foregroundColor(DesignSystem.Colors.primaryCoral)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()
        }
    }
}

struct SettingRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)

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
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryCoral : DesignSystem.Colors.textTertiary.opacity(0.4))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()
            }
            .padding(16)
            .background(
                isSelected
                    ? DesignSystem.Colors.primaryCoral.opacity(0.1)
                    : Color.clear
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isSelected
                            ? DesignSystem.Colors.primaryCoral.opacity(0.3)
                            : DesignSystem.Colors.textTertiary.opacity(0.2),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Styles

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(8)
            .background(DesignSystem.Colors.surfacePearl)
            .cornerRadius(DesignSystem.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(DesignSystem.Colors.textTertiary.opacity(0.2), lineWidth: 1)
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
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(configuration.isPressed ? DesignSystem.Colors.primaryCoral.opacity(0.8) : DesignSystem.Colors.primaryCoral)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.surfacePearl)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.textTertiary.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
}
