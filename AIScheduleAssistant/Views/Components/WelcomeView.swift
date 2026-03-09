//
//  WelcomeView.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject private var permissionManager = PermissionManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            // Icon and title
            VStack(spacing: 16) {
                Image(systemName: "figure.pool.swim")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primaryCoral,
                                DesignSystem.Colors.accentWater
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 8) {
                    Text("欢迎来到温泉旅馆 🌿")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("让 AI 水豚帮你整理日程")
                        .font(.system(size: 16))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }

            // Permission list card
            VStack(alignment: .leading, spacing: 20) {
                Text("在开始之前，需要一些小小的准备：")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                VStack(spacing: 16) {
                    PermissionItem(
                        icon: "camera.fill",
                        title: "屏幕录制",
                        description: "用于截图功能",
                        status: permissionManager.screenRecordingStatus
                    )

                    DividerCapybara()

                    PermissionItem(
                        icon: "calendar",
                        title: "日历",
                        description: "用于创建日历事件",
                        status: permissionManager.calendarStatus
                    )

                    DividerCapybara()

                    PermissionItem(
                        icon: "checklist",
                        title: "提醒事项",
                        description: "用于创建待办事项",
                        status: permissionManager.remindersStatus
                    )
                }
            }
            .padding(24)
            .floatingCard(shadowColor: DesignSystem.Colors.shadowWarm)

            // Action buttons
            VStack(spacing: 14) {
                Button {
                    requestPermissions()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                        Text("开始准备权限")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CapybaraPrimaryButtonStyle())
                .controlSize(.large)

                Button("稍后设置") {
                    dismiss()
                }
                .buttonStyle(CapybaraSecondaryButtonStyle())
            }

            Text("您可以随时在设置中管理这些权限")
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(48)
        .frame(width: 560)
        .background(DesignSystem.Colors.backgroundWarm)
    }

    private func requestPermissions() {
        // Request calendar and reminders first (these show system dialogs)
        Task {
            // Request calendar permission
            do {
                try await permissionManager.requestCalendarPermission()
                print("Calendar permission requested")
            } catch {
                print("Calendar permission error: \(error)")
            }

            // Small delay between requests
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Request reminders permission
            do {
                try await permissionManager.requestRemindersPermission()
                print("Reminders permission requested")
            } catch {
                print("Reminders permission error: \(error)")
            }

            // Wait before opening screen recording settings
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            // Open screen recording settings
            await MainActor.run {
                permissionManager.openSystemPreferences(for: .screenRecording)
            }
        }
    }
}

struct PermissionItem: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(statusColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            if status == .granted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.successGreen)
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.textTertiary.opacity(0.3))
            }
        }
    }

    private var statusColor: Color {
        status == .granted ? DesignSystem.Colors.successGreen : DesignSystem.Colors.textSecondary
    }
}

#Preview {
    WelcomeView()
}
