//
//  WelcomeView.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject private var permissionManager = PermissionManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("欢迎使用 AI Schedule Assistant")
                .font(.title)
                .fontWeight(.bold)

            Text("在开始使用之前，我们需要获取一些系统权限")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                PermissionItem(
                    icon: "camera.fill",
                    title: "屏幕录制",
                    description: "用于截图功能",
                    status: permissionManager.screenRecordingStatus
                )

                PermissionItem(
                    icon: "calendar",
                    title: "日历",
                    description: "用于创建日历事件",
                    status: permissionManager.calendarStatus
                )

                PermissionItem(
                    icon: "checklist",
                    title: "提醒事项",
                    description: "用于创建待办事项",
                    status: permissionManager.remindersStatus
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            VStack(spacing: 12) {
                Button("请求权限") {
                    requestPermissions()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("稍后设置") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }

            Text("您可以随时在设置中管理这些权限")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 500)
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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if status == .granted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
