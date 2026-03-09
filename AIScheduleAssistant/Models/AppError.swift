//
//  AppError.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation

enum AppError: LocalizedError {
    // Permission errors
    case permissionDenied(String)

    // Capture errors
    case screenshotCancelled
    case screenshotFailed
    case noTextSelected
    case accessibilityAPIFailed

    // AI errors
    case apiKeyMissing
    case invalidAPIURL
    case apiRequestFailed(String)
    case invalidAPIResponse
    case aiParseFailed(String)
    case noEventsFound

    // EventKit errors
    case calendarPermissionDenied
    case reminderPermissionDenied
    case calendarNotFound
    case reminderListNotFound
    case eventCreationFailed
    case reminderCreationFailed

    // Configuration errors
    case invalidConfiguration(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied(let permission):
            return "\(permission)权限被拒绝"
        case .screenshotCancelled:
            return "截图已取消"
        case .screenshotFailed:
            return "截图失败"
        case .noTextSelected:
            return "未选中任何文本"
        case .accessibilityAPIFailed:
            return "无法读取选中的文本"
        case .apiKeyMissing:
            return "API Key 未配置"
        case .invalidAPIURL:
            return "API 端点无效"
        case .apiRequestFailed(let message):
            return "API 请求失败: \(message)"
        case .invalidAPIResponse:
            return "API 响应格式无效"
        case .aiParseFailed(let message):
            return "AI 解析失败: \(message)"
        case .noEventsFound:
            return "未识别到任何事件"
        case .calendarPermissionDenied:
            return "日历权限被拒绝"
        case .reminderPermissionDenied:
            return "提醒事项权限被拒绝"
        case .calendarNotFound:
            return "未找到指定的日历"
        case .reminderListNotFound:
            return "未找到指定的待办清单"
        case .eventCreationFailed:
            return "创建日历事件失败"
        case .reminderCreationFailed:
            return "创建待办事项失败"
        case .invalidConfiguration(let message):
            return "配置错误: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "请在设置中授予必要的权限"
        case .screenshotCancelled:
            return "请重新尝试截图"
        case .screenshotFailed:
            return "请检查屏幕录制权限"
        case .noTextSelected:
            return "请先选中要识别的文本"
        case .accessibilityAPIFailed:
            return "请检查辅助功能权限"
        case .apiKeyMissing:
            return "请在设置中配置 API Key"
        case .invalidAPIURL:
            return "请检查 API 端点配置"
        case .apiRequestFailed:
            return "请检查网络连接和 API 配置"
        case .invalidAPIResponse:
            return "请检查 API 配置是否正确"
        case .aiParseFailed:
            return "请重试或检查输入内容"
        case .noEventsFound:
            return "请确保内容中包含日期和时间信息"
        case .calendarPermissionDenied, .reminderPermissionDenied:
            return "请在系统设置中授予权限"
        case .calendarNotFound, .reminderListNotFound:
            return "请检查分类是否存在"
        case .eventCreationFailed, .reminderCreationFailed:
            return "请重试或检查权限"
        case .invalidConfiguration:
            return "请检查应用配置"
        }
    }
}
