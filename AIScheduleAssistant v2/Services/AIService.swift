//
//  AIService.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import Foundation
import AppKit
import EventKit

enum AIError: LocalizedError {
    case apiKeyMissing
    case invalidURL
    case requestFailed(String)
    case invalidResponse
    case parseFailed(String)
    case noEventsFound

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API Key 未配置"
        case .invalidURL:
            return "API 端点无效"
        case .requestFailed(let message):
            return "API 请求失败: \(message)"
        case .invalidResponse:
            return "API 响应格式无效"
        case .parseFailed(let message):
            return "解析失败: \(message)"
        case .noEventsFound:
            return "未识别到任何事件"
        }
    }
}

class AIService {
    static let shared = AIService()

    private let configService = ConfigService.shared
    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Main API

    func analyzeContent(_ content: CapturedContent) async throws -> [ParsedEvent] {
        let config = configService.settings.aiConfig

        // Validate configuration
        guard !config.apiKey.isEmpty else {
            throw AIError.apiKeyMissing
        }

        guard let url = URL(string: "\(config.baseURL)/chat/completions") else {
            throw AIError.invalidURL
        }

        // Get existing categories
        let calendars = getExistingCalendars()
        let reminderLists = getExistingReminderLists()

        // Build prompts
        let systemPrompt = buildSystemPrompt(calendars: calendars, reminderLists: reminderLists)

        // Make API request (different format for image vs text)
        let response: String
        switch content.type {
        case .image(let image):
            response = try await makeImageAPIRequest(
                url: url,
                apiKey: config.apiKey,
                model: config.model,
                systemPrompt: systemPrompt,
                image: image,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            )
        case .text(let text):
            response = try await makeTextAPIRequest(
                url: url,
                apiKey: config.apiKey,
                model: config.model,
                systemPrompt: systemPrompt,
                userText: text,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            )
        }

        // Parse response
        let events = try parseResponse(response)

        guard !events.isEmpty else {
            throw AIError.noEventsFound
        }

        return events
    }

    // MARK: - Prompt Building

    private func buildSystemPrompt(calendars: [String], reminderLists: [String]) -> String {
        let currentDateTime = ISO8601DateFormatter().string(from: Date())

        return """
        你是一个专业的日程事件识别助手。你的任务是从图片或文本中识别所有的日程安排、会议、任务和待办事项，并将它们转换为结构化的 JSON 格式。

        当前日期时间：\(currentDateTime)

        用户的现有日历分类：\(calendars.joined(separator: ", "))
        用户的现有待办清单分类：\(reminderLists.joined(separator: ", "))

        请识别所有事件，并为每个事件返回以下信息：
        1. title：事件标题（简洁明了）
        2. description：详细描述（可选）
        3. startDate：开始日期时间（ISO 8601 格式）
        4. endDate：结束日期时间（可选，ISO 8601 格式）
        5. isAllDay：是否全天事件（布尔值）
        6. dueDate：截止日期（ISO 8601 格式）
        7. priority：优先级（默认 5）
        8. suggestedCalendar：建议的日历分类
        9. suggestedReminderList：建议的待办清单分类
        10. confidence：识别置信度（0.0-1.0）

        分类匹配规则：
        - 理解事件的语义和现有分类的含义
        - 优先匹配现有分类
        - 如果没有合适的现有分类，建议创建新分类（遵循大类原则：工作、生活、学习、健康等）
        - 避免创建过于细分的分类

        日期时间处理规则：
        - 所有日期时间必须转换为绝对时间（ISO 8601 格式）
        - 基于当前日期时间计算相对日期（如"明天"、"下周一"）
        - 如果没有指定时间，默认使用 09:00
        - 如果没有指定日期，使用当前日期

        返回格式：
        {
          "events": [
            {
              "title": "事件标题",
              "description": "详细描述",
              "startDate": "2026-03-10T15:00:00+08:00",
              "endDate": "2026-03-10T16:00:00+08:00",
              "isAllDay": false,
              "dueDate": "2026-03-10T15:00:00+08:00",
              "priority": 5,
              "suggestedCalendar": "工作",
              "suggestedReminderList": "工作",
              "confidence": 0.95
            }
          ]
        }
        """
    }

    // MARK: - API Request

    private func makeImageAPIRequest(
        url: URL,
        apiKey: String,
        model: String,
        systemPrompt: String,
        image: NSImage,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        // Convert and compress image
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            throw AIError.requestFailed("无法转换图片格式")
        }

        // Resize image if too large (max 2048px on longest side)
        let maxDimension: CGFloat = 2048
        let originalSize = NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
        var newSize = originalSize

        if originalSize.width > maxDimension || originalSize.height > maxDimension {
            let scale = min(maxDimension / originalSize.width, maxDimension / originalSize.height)
            newSize = NSSize(width: originalSize.width * scale, height: originalSize.height * scale)

            let resizedImage = NSImage(size: newSize)
            resizedImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: newSize))
            resizedImage.unlockFocus()

            guard let resizedTiff = resizedImage.tiffRepresentation,
                  let resizedBitmap = NSBitmapImageRep(data: resizedTiff),
                  let pngData = resizedBitmap.representation(using: .png, properties: [:]) else {
                throw AIError.requestFailed("无法压缩图片")
            }

            let base64Image = pngData.base64EncodedString()
            print("🖼️ Image resized from \(Int(originalSize.width))x\(Int(originalSize.height)) to \(Int(newSize.width))x\(Int(newSize.height))")
            print("🖼️ Base64 size: \(base64Image.count) characters")

            return try await sendImageRequest(url: url, apiKey: apiKey, model: model, systemPrompt: systemPrompt, base64Image: base64Image, temperature: temperature, maxTokens: maxTokens)
        } else {
            guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
                throw AIError.requestFailed("无法转换图片格式")
            }

            let base64Image = pngData.base64EncodedString()
            print("🖼️ Image size: \(Int(originalSize.width))x\(Int(originalSize.height))")
            print("🖼️ Base64 size: \(base64Image.count) characters")

            return try await sendImageRequest(url: url, apiKey: apiKey, model: model, systemPrompt: systemPrompt, base64Image: base64Image, temperature: temperature, maxTokens: maxTokens)
        }
    }

    private func sendImageRequest(
        url: URL,
        apiKey: String,
        model: String,
        systemPrompt: String,
        base64Image: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "请识别这张图片中的所有日程事件、会议、任务和待办事项。"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/png;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "temperature": temperature,
            "max_tokens": maxTokens
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Log request details (without full base64 to avoid console spam)
        print("🌐 Sending image API request...")
        print("🌐 URL: \(url)")
        print("🌐 Model: \(model)")
        print("🌐 Temperature: \(temperature)")
        print("🌐 Max tokens: \(maxTokens)")
        print("🌐 System prompt length: \(systemPrompt.count)")
        print("🌐 Base64 image length: \(base64Image.count)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        print("🌐 API response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API error response:")
            print("❌ Status code: \(httpResponse.statusCode)")
            print("❌ Error body: \(errorMessage)")

            // Try to parse error details
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("❌ Error JSON: \(errorJson)")
            }

            throw AIError.requestFailed(errorMessage)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }

        print("🌐 API response received, content length: \(content.count)")
        return content
    }

    private func makeTextAPIRequest(
        url: URL,
        apiKey: String,
        model: String,
        systemPrompt: String,
        userText: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let userPrompt = """
        请识别以下文本中的所有日程事件、会议、任务和待办事项：

        \(userText)
        """

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": temperature,
            "max_tokens": maxTokens
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Log request details
        print("🌐 Sending text API request...")
        print("🌐 URL: \(url)")
        print("🌐 Model: \(model)")
        print("🌐 Temperature: \(temperature)")
        print("🌐 Max tokens: \(maxTokens)")
        print("🌐 System prompt length: \(systemPrompt.count)")
        print("🌐 User text length: \(userText.count)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        print("🌐 API response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API error response:")
            print("❌ Status code: \(httpResponse.statusCode)")
            print("❌ Error body: \(errorMessage)")

            // Try to parse error details
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("❌ Error JSON: \(errorJson)")
            }

            throw AIError.requestFailed(errorMessage)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }

        print("🌐 API response received, content length: \(content.count)")
        return content
    }

    // MARK: - Response Parsing

    private func parseResponse(_ response: String) throws -> [ParsedEvent] {
        print("🔍 Parsing AI response...")
        print("🔍 Raw response: \(response)")

        // Extract JSON from markdown code blocks if present
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove markdown code block markers and extract only JSON content
        if let jsonStart = jsonString.range(of: "```json"),
           let jsonEnd = jsonString.range(of: "```", range: jsonStart.upperBound..<jsonString.endIndex) {
            // Extract content between ```json and the next ```
            let startIndex = jsonStart.upperBound
            let endIndex = jsonEnd.lowerBound
            jsonString = String(jsonString[startIndex..<endIndex])
        } else if let codeStart = jsonString.range(of: "```"),
                  let codeEnd = jsonString.range(of: "```", range: codeStart.upperBound..<jsonString.endIndex) {
            // Extract content between ``` and the next ```
            let startIndex = codeStart.upperBound
            let endIndex = codeEnd.lowerBound
            jsonString = String(jsonString[startIndex..<endIndex])
        }

        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔍 Cleaned JSON: \(jsonString)")

        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.parseFailed("无法转换响应为数据")
        }

        struct AIResponse: Codable {
            let events: [AIEvent]
        }

        struct AIEvent: Codable {
            let title: String
            let description: String?
            let startDate: String?  // Make optional
            let endDate: String?
            let isAllDay: Bool
            let dueDate: String?
            let priority: Int
            let suggestedCalendar: String
            let suggestedReminderList: String
            let confidence: Double
        }

        let decoder = JSONDecoder()
        let aiResponse = try decoder.decode(AIResponse.self, from: data)

        let formatter = ISO8601DateFormatter()
        // Support both with and without fractional seconds
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]

        return try aiResponse.events.map { aiEvent in
            // Handle events with only dueDate (no startDate)
            let startDate: Date
            if let startDateString = aiEvent.startDate {
                guard let parsedStartDate = formatter.date(from: startDateString) else {
                    throw AIError.parseFailed("无法解析开始日期: \(startDateString)")
                }
                startDate = parsedStartDate
            } else if let dueDateString = aiEvent.dueDate {
                // If no startDate, use dueDate as startDate
                guard let parsedDueDate = formatter.date(from: dueDateString) else {
                    throw AIError.parseFailed("无法解析截止日期: \(dueDateString)")
                }
                startDate = parsedDueDate
            } else {
                throw AIError.parseFailed("事件缺少开始日期和截止日期")
            }

            let endDate = aiEvent.endDate.flatMap { formatter.date(from: $0) }

            // Use endDate as dueDate if dueDate is not provided
            let dueDate: Date
            if let dueDateString = aiEvent.dueDate {
                guard let parsedDueDate = formatter.date(from: dueDateString) else {
                    throw AIError.parseFailed("无法解析截止日期: \(dueDateString)")
                }
                dueDate = parsedDueDate
            } else {
                dueDate = endDate ?? startDate
            }

            return ParsedEvent(
                title: aiEvent.title,
                description: aiEvent.description,
                startDate: startDate,
                endDate: endDate,
                isAllDay: aiEvent.isAllDay,
                dueDate: dueDate,
                priority: aiEvent.priority,
                suggestedCalendar: aiEvent.suggestedCalendar,
                suggestedReminderList: aiEvent.suggestedReminderList,
                confidence: aiEvent.confidence
            )
        }
    }

    // MARK: - Helper Methods

    private func getExistingCalendars() -> [String] {
        return EventKitService.shared.getCalendars().map { $0.title }
    }

    private func getExistingReminderLists() -> [String] {
        return EventKitService.shared.getReminderLists().map { $0.title }
    }
}
