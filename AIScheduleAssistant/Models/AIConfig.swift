//
//  AIConfig.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation

struct AIConfig: Codable {
    var baseURL: String
    var apiKey: String
    var model: String
    var temperature: Double
    var maxTokens: Int

    static let `default` = AIConfig(
        baseURL: "https://api.openai.com/v1",
        apiKey: "",
        model: "gpt-4",
        temperature: 0.7,
        maxTokens: 4000  // Increased to allow longer responses
    )
}
