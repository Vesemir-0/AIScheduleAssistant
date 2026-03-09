//
//  ConfigService.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation
import Combine

class ConfigService: ObservableObject {
    static let shared = ConfigService()

    @Published var settings: AppSettings

    private let defaults = UserDefaults.standard
    private let keychain = KeychainService()

    private let settingsKey = "appSettings"

    private init() {
        // Load settings from UserDefaults
        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded

            // Auto-upgrade old configurations
            if self.settings.aiConfig.maxTokens < 4000 {
                print("⚙️ Upgrading maxTokens from \(self.settings.aiConfig.maxTokens) to 4000")
                self.settings.aiConfig.maxTokens = 4000
                saveSettings()
            }
        } else {
            self.settings = .default
        }

        // Load API key from Keychain
        if let apiKey = try? keychain.getAPIKey() {
            self.settings.aiConfig.apiKey = apiKey
        }
    }

    // Save settings
    func saveSettings() {
        // Save API key to Keychain
        if !settings.aiConfig.apiKey.isEmpty {
            try? keychain.saveAPIKey(settings.aiConfig.apiKey)
        }

        // Save other settings to UserDefaults (without API key)
        var settingsToSave = settings
        settingsToSave.aiConfig.apiKey = ""  // Don't save API key to UserDefaults

        if let encoded = try? JSONEncoder().encode(settingsToSave) {
            defaults.set(encoded, forKey: settingsKey)
        }
    }

    // Update AI config
    func updateAIConfig(_ config: AIConfig) {
        settings.aiConfig = config
        saveSettings()
    }

    // Update behavior settings
    func updateBehaviorSettings(autoAdd: Bool? = nil, screenshot: Bool? = nil, text: Bool? = nil) {
        if let autoAdd = autoAdd {
            settings.autoAddMode = autoAdd
        }
        if let screenshot = screenshot {
            settings.enableScreenshotCapture = screenshot
        }
        if let text = text {
            settings.enableTextCapture = text
        }
        saveSettings()
    }

    // Validate configuration
    func validateConfig() -> [String] {
        var errors: [String] = []

        // Check API base URL
        if settings.aiConfig.baseURL.isEmpty {
            errors.append("API 端点不能为空")
        } else if URL(string: settings.aiConfig.baseURL) == nil {
            errors.append("API 端点格式无效")
        }

        // Check API key
        if settings.aiConfig.apiKey.isEmpty {
            errors.append("API Key 不能为空")
        }

        // Check model name
        if settings.aiConfig.model.isEmpty {
            errors.append("模型名称不能为空")
        }

        // Check temperature range
        if settings.aiConfig.temperature < 0 || settings.aiConfig.temperature > 2 {
            errors.append("Temperature 必须在 0-2 之间")
        }

        // Check max tokens
        if settings.aiConfig.maxTokens < 1 {
            errors.append("Max Tokens 必须大于 0")
        }

        return errors
    }

    // Reset to default settings
    func resetToDefaults() {
        settings = .default
        try? keychain.deleteAPIKey()
        defaults.removeObject(forKey: settingsKey)
    }
}
