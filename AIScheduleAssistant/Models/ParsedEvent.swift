//
//  ParsedEvent.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation

struct ParsedEvent: Codable {
    let title: String
    let description: String?

    // Calendar event information
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool

    // Reminder information
    let dueDate: Date
    let priority: Int  // 0-9

    // Categories
    let suggestedCalendar: String
    let suggestedReminderList: String

    let confidence: Double

    init(
        title: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date? = nil,
        isAllDay: Bool = false,
        dueDate: Date? = nil,
        priority: Int = 0,
        suggestedCalendar: String,
        suggestedReminderList: String,
        confidence: Double = 1.0
    ) {
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.dueDate = dueDate ?? startDate
        self.priority = min(max(priority, 0), 9)
        self.suggestedCalendar = suggestedCalendar
        self.suggestedReminderList = suggestedReminderList
        self.confidence = min(max(confidence, 0.0), 1.0)
    }
}
