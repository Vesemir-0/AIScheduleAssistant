//
//  AppSettings.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import Foundation

struct AppSettings: Codable {
    var autoAddMode: Bool
    var enableScreenshotCapture: Bool
    var enableTextCapture: Bool
    var aiConfig: AIConfig

    static let `default` = AppSettings(
        autoAddMode: false,  // Default to preview mode for safety
        enableScreenshotCapture: true,
        enableTextCapture: true,
        aiConfig: .default
    )
}
