//
//  ContentProcessViewModel.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation
import Combine
import AppKit

enum ProcessingState: Equatable {
    case idle
    case capturing
    case analyzing
    case completed([ParsedEvent])
    case error(Error)

    static func == (lhs: ProcessingState, rhs: ProcessingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.capturing, .capturing), (.analyzing, .analyzing):
            return true
        case (.completed(let lhsEvents), .completed(let rhsEvents)):
            return lhsEvents.count == rhsEvents.count
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}

class ContentProcessViewModel: ObservableObject {
    @Published var state: ProcessingState = .idle
    @Published var selectedEvents: Set<String> = [] // Event IDs

    private let captureService = ContentCaptureService.shared
    private let aiService = AIService.shared
    private let eventKitService = EventKitService.shared
    private let configService = ConfigService.shared

    // MARK: - Screenshot Capture

    func captureScreenshot() async {
        await MainActor.run {
            state = .capturing
        }

        do {
            print("📸 Starting screenshot capture...")
            let image = try await captureService.captureScreenshot()
            print("📸 Screenshot captured successfully")
            let content = captureService.createCapturedContent(from: image)
            await analyzeContent(content)
        } catch {
            print("❌ Screenshot capture error: \(error)")
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    // MARK: - Text Capture

    func captureText() async {
        await MainActor.run {
            state = .capturing
        }

        do {
            print("📝 Starting text capture...")
            let text = try captureService.captureSelectedText()
            print("📝 Text captured: \(text.prefix(50))...")
            let content = captureService.createCapturedContent(from: text)
            await analyzeContent(content)
        } catch {
            print("❌ Text capture error: \(error)")
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    // MARK: - Text Input (Manual)

    func captureTextFromInput(_ text: String) async {
        await MainActor.run {
            state = .capturing
        }

        print("📝 Processing input text: \(text.prefix(50))...")
        let content = captureService.createCapturedContent(from: text)
        await analyzeContent(content)
    }

    // MARK: - AI Analysis

    private func analyzeContent(_ content: CapturedContent) async {
        await MainActor.run {
            state = .analyzing
        }

        do {
            print("🤖 Starting AI analysis...")
            let events = try await aiService.analyzeContent(content)
            print("🤖 AI analysis completed, found \(events.count) events")
            await MainActor.run {
                state = .completed(events)
            }

            // If auto-add mode is enabled, create events immediately
            if configService.settings.autoAddMode {
                await createSelectedEvents(events)
            }
        } catch {
            print("❌ AI analysis error: \(error)")
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    // MARK: - Event Creation

    func createSelectedEvents(_ events: [ParsedEvent]) async {
        var successCount = 0
        var failureCount = 0

        for event in events {
            do {
                _ = try await eventKitService.createEvent(event)
                successCount += 1
            } catch {
                failureCount += 1
                print("Failed to create event: \(event.title), error: \(error)")
            }
        }

        // Show notification
        showNotification(success: successCount, failure: failureCount)

        // Reset state
        state = .idle
        selectedEvents.removeAll()
    }

    // MARK: - Notifications

    private func showNotification(success: Int, failure: Int) {
        let notification = NSUserNotification()
        notification.title = "AI Schedule Assistant"

        if failure == 0 {
            notification.informativeText = "成功添加 \(success) 个事件到日历和待办清单"
            notification.soundName = NSUserNotificationDefaultSoundName
        } else {
            notification.informativeText = "成功 \(success) 个，失败 \(failure) 个"
        }

        NSUserNotificationCenter.default.deliver(notification)
    }

    // MARK: - Reset

    func reset() {
        state = .idle
        selectedEvents.removeAll()
    }
}
