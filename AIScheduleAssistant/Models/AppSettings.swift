//
//  AppSettings.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation

enum SaveTarget: String, Codable {
    case both = "both"
    case calendarOnly = "calendar"
    case reminderOnly = "reminder"
}

struct AppSettings: Codable {
    var autoAddMode: Bool
    var enableScreenshotCapture: Bool
    var enableTextCapture: Bool
    var saveTarget: SaveTarget
    var aiConfig: AIConfig

    static let `default` = AppSettings(
        autoAddMode: false,  // Default to preview mode for safety
        enableScreenshotCapture: true,
        enableTextCapture: true,
        saveTarget: .both,
        aiConfig: .default
    )
}
