//
//  PermissionManager.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation
import EventKit
import AppKit
import Combine

enum PermissionType: String, CaseIterable {
    case screenRecording = "屏幕录制"
    case calendar = "日历"
    case reminders = "提醒事项"
}

enum PermissionStatus {
    case granted
    case denied
    case notDetermined
}

class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published var screenRecordingStatus: PermissionStatus = .notDetermined
    @Published var calendarStatus: PermissionStatus = .notDetermined
    @Published var remindersStatus: PermissionStatus = .notDetermined

    private let eventStore = EKEventStore()
    private var timer: Timer?

    private init() {
        checkAllPermissions()
        startMonitoring()
    }

    // Check all permissions
    func checkAllPermissions() {
        checkScreenRecordingPermission()
        checkCalendarPermission()
        checkRemindersPermission()
    }

    // Start monitoring permission changes
    private func startMonitoring() {
        // Check permissions every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkAllPermissions()
        }
    }

    // MARK: - Screen Recording Permission

    func checkScreenRecordingPermission() {
        // Screen recording permission check is tricky on macOS
        // We can't directly check it, but we can infer from CGWindowListCopyWindowInfo
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]]

        let status: PermissionStatus
        if let windows = windows, !windows.isEmpty {
            status = .granted
        } else {
            status = .denied
        }

        DispatchQueue.main.async { [weak self] in
            self?.screenRecordingStatus = status
            print("🔄 [Main Thread] screenRecordingStatus = \(status)")
        }
    }

    // MARK: - Calendar Permission

    func checkCalendarPermission() {
        let status = EKEventStore.authorizationStatus(for: .event)
        let permStatus = convertEKAuthStatus(status)
        DispatchQueue.main.async { [weak self] in
            self?.calendarStatus = permStatus
        }
    }

    func requestCalendarPermission() async throws {
        print("📍 [PermissionManager] Requesting calendar permission...")
        let currentStatus = EKEventStore.authorizationStatus(for: .event)
        print("📍 [PermissionManager] Current calendar status: \(currentStatus.rawValue)")

        let granted = try await eventStore.requestFullAccessToEvents()
        print("📍 [PermissionManager] Calendar permission result: \(granted)")

        await MainActor.run {
            calendarStatus = granted ? .granted : .denied
            print("📍 [PermissionManager] Calendar status updated to: \(calendarStatus)")
            print("🔄 [Main Thread] calendarStatus = \(calendarStatus)")
        }
    }

    // MARK: - Reminders Permission

    func checkRemindersPermission() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        let permStatus = convertEKAuthStatus(status)
        DispatchQueue.main.async { [weak self] in
            self?.remindersStatus = permStatus
        }
    }

    func requestRemindersPermission() async throws {
        print("📍 [PermissionManager] Requesting reminders permission...")
        let currentStatus = EKEventStore.authorizationStatus(for: .reminder)
        print("📍 [PermissionManager] Current reminders status: \(currentStatus.rawValue)")

        let granted = try await eventStore.requestFullAccessToReminders()
        print("📍 [PermissionManager] Reminders permission result: \(granted)")

        await MainActor.run {
            remindersStatus = granted ? .granted : .denied
            print("📍 [PermissionManager] Reminders status updated to: \(remindersStatus)")
        }
    }

    // MARK: - Helper Methods

    private func convertEKAuthStatus(_ status: EKAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized, .fullAccess:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined, .writeOnly:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }

    // Open system preferences for specific permission
    func openSystemPreferences(for permission: PermissionType) {
        var urlString: String

        switch permission {
        case .screenRecording:
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        case .calendar:
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        case .reminders:
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
        }

        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    // Check if all required permissions are granted
    func allPermissionsGranted() -> Bool {
        return screenRecordingStatus == .granted &&
               calendarStatus == .granted &&
               remindersStatus == .granted
    }

    deinit {
        timer?.invalidate()
    }
}
