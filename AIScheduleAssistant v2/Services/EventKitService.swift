//
//  EventKitService.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import Foundation
import EventKit

enum EventKitError: LocalizedError {
    case permissionDenied
    case calendarNotFound
    case reminderListNotFound
    case eventCreationFailed
    case reminderCreationFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "日历或提醒事项权限被拒绝"
        case .calendarNotFound:
            return "未找到指定的日历"
        case .reminderListNotFound:
            return "未找到指定的待办清单"
        case .eventCreationFailed:
            return "创建日历事件失败"
        case .reminderCreationFailed:
            return "创建待办事项失败"
        }
    }
}

class EventKitService {
    static let shared = EventKitService()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Main API

    func createEvent(_ parsed: ParsedEvent) async throws -> (EKEvent, EKReminder) {
        // Check permissions
        let calendarStatus = EKEventStore.authorizationStatus(for: .event)
        let reminderStatus = EKEventStore.authorizationStatus(for: .reminder)

        guard calendarStatus == .fullAccess || calendarStatus == .writeOnly else {
            throw EventKitError.permissionDenied
        }

        guard reminderStatus == .fullAccess else {
            throw EventKitError.permissionDenied
        }

        // Generate link ID for association
        let linkID = UUID().uuidString

        // Create calendar event
        let event = try await createCalendarEvent(parsed, linkID: linkID)

        // For events with duration (startDate != endDate), create two reminders
        // Otherwise create one reminder
        let startReminder = try await createReminder(parsed, linkID: linkID, isStartReminder: true)

        // Return the start reminder as the primary one
        return (event, startReminder)
    }

    // MARK: - Calendar Event Creation

    private func createCalendarEvent(_ parsed: ParsedEvent, linkID: String) async throws -> EKEvent {
        let event = EKEvent(eventStore: eventStore)

        event.title = parsed.title
        event.startDate = parsed.startDate
        event.endDate = parsed.endDate ?? parsed.startDate.addingTimeInterval(3600) // Default 1 hour
        event.isAllDay = parsed.isAllDay

        // Set notes with link ID
        let description = parsed.description ?? ""
        event.notes = "AI_SCHEDULE_LINK:\(linkID)\n\(description)"

        // Select or create calendar
        event.calendar = try selectOrCreateCalendar(named: parsed.suggestedCalendar)

        // Save event
        do {
            try eventStore.save(event, span: .thisEvent)
            return event
        } catch {
            throw EventKitError.eventCreationFailed
        }
    }

    // MARK: - Reminder Creation

    private func createReminder(_ parsed: ParsedEvent, linkID: String, isStartReminder: Bool) async throws -> EKReminder {
        // Check if this is a multi-day duration event (including all-day events)
        let isMultiDay = parsed.endDate != nil &&
                        !Calendar.current.isDate(parsed.startDate, inSameDayAs: parsed.endDate!)

        if isMultiDay {
            // Create start reminder for multi-day events
            let startReminder = try await createSingleReminder(
                parsed: parsed,
                linkID: linkID,
                dueDate: parsed.startDate,
                titleSuffix: "（开始）",
                isStart: true
            )

            // Create end reminder for multi-day events
            _ = try await createSingleReminder(
                parsed: parsed,
                linkID: linkID,
                dueDate: parsed.endDate!,
                titleSuffix: "（结束）",
                isStart: false
            )

            return startReminder
        } else {
            // Single reminder for same-day events
            return try await createSingleReminder(
                parsed: parsed,
                linkID: linkID,
                dueDate: parsed.startDate,  // Use startDate instead of dueDate
                titleSuffix: nil,
                isStart: true
            )
        }
    }

    private func createSingleReminder(
        parsed: ParsedEvent,
        linkID: String,
        dueDate: Date,
        titleSuffix: String?,
        isStart: Bool
    ) async throws -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)

        // Format title
        var title = parsed.title
        if let suffix = titleSuffix {
            title += suffix
        }

        // Add time range to title if it's not an all-day event and no suffix
        if !parsed.isAllDay && titleSuffix == nil {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            let startTime = timeFormatter.string(from: parsed.startDate)
            let endTime = timeFormatter.string(from: parsed.endDate ?? parsed.dueDate)

            title = "\(title) [\(startTime)-\(endTime)]"
        }

        reminder.title = title

        // Set due date
        let calendar = Calendar.current
        reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)

        // Set priority (EKReminder uses 0-9, where 0 is none, 1-4 is high, 5 is medium, 6-9 is low)
        reminder.priority = parsed.priority

        // Set notes with link ID and time information
        let description = parsed.description ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "zh_CN")

        let startDateStr = dateFormatter.string(from: parsed.startDate)
        let endDateStr = parsed.endDate.map { dateFormatter.string(from: $0) } ?? ""

        var notesContent = "AI_SCHEDULE_LINK:\(linkID)\n"
        notesContent += "开始时间: \(startDateStr)\n"
        if !endDateStr.isEmpty {
            notesContent += "结束时间: \(endDateStr)\n"
        }
        if !description.isEmpty {
            notesContent += "\n\(description)"
        }

        reminder.notes = notesContent

        // Select or create reminder list
        reminder.calendar = try selectOrCreateReminderList(named: parsed.suggestedReminderList)

        // Save reminder
        do {
            try eventStore.save(reminder, commit: true)
            return reminder
        } catch {
            throw EventKitError.reminderCreationFailed
        }
    }

    // MARK: - Calendar Selection/Creation

    private func selectOrCreateCalendar(named name: String) throws -> EKCalendar {
        let calendars = eventStore.calendars(for: .event)

        // 1. Exact match
        if let exactMatch = calendars.first(where: { $0.title == name }) {
            return exactMatch
        }

        // 2. Fuzzy match (case-insensitive, contains)
        let lowercaseName = name.lowercased()
        if let fuzzyMatch = calendars.first(where: { $0.title.lowercased().contains(lowercaseName) || lowercaseName.contains($0.title.lowercased()) }) {
            return fuzzyMatch
        }

        // 3. Create new calendar
        return try createNewCalendar(named: name)
    }

    private func createNewCalendar(named name: String) throws -> EKCalendar {
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = name

        // Find the best source (iCloud if available, otherwise local)
        if let iCloudSource = eventStore.sources.first(where: { $0.sourceType == .calDAV && $0.title == "iCloud" }) {
            newCalendar.source = iCloudSource
        } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else if let defaultSource = eventStore.defaultCalendarForNewEvents?.source {
            newCalendar.source = defaultSource
        } else {
            throw EventKitError.calendarNotFound
        }

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            throw EventKitError.calendarNotFound
        }
    }

    // MARK: - Reminder List Selection/Creation

    private func selectOrCreateReminderList(named name: String) throws -> EKCalendar {
        let reminderLists = eventStore.calendars(for: .reminder)

        print("📋 Available reminder lists:")
        for list in reminderLists {
            print("  - \(list.title) (source: \(list.source?.title ?? "unknown"), type: \(list.source?.sourceType.rawValue ?? -1), canModify: \(list.allowsContentModifications))")
        }

        // 1. Exact match - but verify the source supports reminders
        if let exactMatch = reminderLists.first(where: { $0.title == name && canSaveReminders(to: $0) }) {
            print("✅ Using existing reminder list: \(exactMatch.title)")
            return exactMatch
        }

        // 2. Fuzzy match - but verify the source supports reminders
        let lowercaseName = name.lowercased()
        if let fuzzyMatch = reminderLists.first(where: {
            ($0.title.lowercased().contains(lowercaseName) || lowercaseName.contains($0.title.lowercased())) &&
            canSaveReminders(to: $0)
        }) {
            print("✅ Using fuzzy matched reminder list: \(fuzzyMatch.title)")
            return fuzzyMatch
        }

        // 3. If no match found, try to use any existing modifiable reminder list
        if let anyModifiable = reminderLists.first(where: { canSaveReminders(to: $0) }) {
            print("⚠️ No match for '\(name)', using existing list: \(anyModifiable.title)")
            return anyModifiable
        }

        // 4. Create new reminder list
        print("🆕 Creating new reminder list: \(name)")
        return try createNewReminderList(named: name)
    }

    private func canSaveReminders(to calendar: EKCalendar) -> Bool {
        // Check if the calendar's source allows modifications
        guard let source = calendar.source else { return false }
        return calendar.allowsContentModifications
    }

    private func createNewReminderList(named name: String) throws -> EKCalendar {
        let newList = EKCalendar(for: .reminder, eventStore: eventStore)
        newList.title = name

        print("🔍 Available sources:")
        for source in eventStore.sources {
            print("  - \(source.title) (type: \(source.sourceType.rawValue))")
        }

        // Find the best source - prioritize sources that support reminders
        let sources = eventStore.sources.filter { source in
            source.sourceType == .calDAV || source.sourceType == .local
        }

        print("🔍 Filtered sources (calDAV or local): \(sources.count)")

        // Try iCloud first
        if let iCloudSource = sources.first(where: { $0.sourceType == .calDAV && $0.title.contains("iCloud") }) {
            print("✅ Using iCloud source: \(iCloudSource.title)")
            newList.source = iCloudSource
        }
        // Then try local
        else if let localSource = sources.first(where: { $0.sourceType == .local }) {
            print("✅ Using local source: \(localSource.title)")
            newList.source = localSource
        }
        // Then try default reminder source
        else if let defaultSource = eventStore.defaultCalendarForNewReminders()?.source {
            print("✅ Using default reminder source: \(defaultSource.title)")
            newList.source = defaultSource
        }
        // Finally try any available source
        else if let anySource = sources.first {
            print("⚠️ Using first available source: \(anySource.title)")
            newList.source = anySource
        }
        else {
            print("❌ No suitable source found")
            throw EventKitError.reminderListNotFound
        }

        do {
            print("💾 Attempting to save new reminder list...")
            try eventStore.saveCalendar(newList, commit: true)
            print("✅ Successfully created reminder list: \(name)")
            return newList
        } catch {
            print("❌ Failed to save calendar: \(error)")
            throw EventKitError.reminderListNotFound
        }
    }

    // MARK: - Helper Methods

    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }

    func getReminderLists() -> [EKCalendar] {
        return eventStore.calendars(for: .reminder)
    }
}
