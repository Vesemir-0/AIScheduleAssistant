//
//  ContentCaptureService.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import Foundation
import AppKit
import ApplicationServices

enum CaptureError: LocalizedError {
    case screenshotCancelled
    case screenshotFailed
    case noTextSelected
    case accessibilityAPIFailed
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .screenshotCancelled:
            return "截图已取消"
        case .screenshotFailed:
            return "截图失败"
        case .noTextSelected:
            return "未选中任何文本"
        case .accessibilityAPIFailed:
            return "无法读取选中的文本"
        case .permissionDenied:
            return "权限被拒绝"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .screenshotCancelled:
            return "请重新尝试截图"
        case .screenshotFailed:
            return "请检查屏幕录制权限"
        case .noTextSelected:
            return "请先选中要识别的文本"
        case .accessibilityAPIFailed:
            return "请检查辅助功能权限"
        case .permissionDenied:
            return "请在设置中授予必要的权限"
        }
    }
}

class ContentCaptureService {
    static let shared = ContentCaptureService()

    private init() {}

    // MARK: - Screenshot Capture

    func captureScreenshot() async throws -> NSImage {
        let tempPath = "/tmp/ai_schedule_\(UUID().uuidString).png"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", tempPath]  // -i for interactive selection

        try process.run()
        process.waitUntilExit()

        // Check if user cancelled (exit code 1)
        if process.terminationStatus == 1 {
            throw CaptureError.screenshotCancelled
        }

        // Check if file exists
        guard FileManager.default.fileExists(atPath: tempPath) else {
            throw CaptureError.screenshotFailed
        }

        // Load image
        guard let image = NSImage(contentsOfFile: tempPath) else {
            try? FileManager.default.removeItem(atPath: tempPath)
            throw CaptureError.screenshotFailed
        }

        // Clean up temp file
        try? FileManager.default.removeItem(atPath: tempPath)

        return image
    }

    // MARK: - Text Selection Capture

    func captureSelectedText() throws -> String {
        // Check accessibility permission first
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        guard AXIsProcessTrustedWithOptions(options) else {
            throw CaptureError.permissionDenied
        }

        // Get system-wide accessibility element
        let systemWideElement = AXUIElementCreateSystemWide()

        // Get focused element
        var focusedElement: AnyObject?
        let focusedResult = AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )

        guard focusedResult == .success, let element = focusedElement else {
            throw CaptureError.accessibilityAPIFailed
        }

        // Try to get selected text
        var selectedText: AnyObject?
        let selectedResult = AXUIElementCopyAttributeValue(
            element as! AXUIElement,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )

        if selectedResult == .success, let text = selectedText as? String, !text.isEmpty {
            return text
        }

        // If no selected text, try to get value (for text fields)
        var value: AnyObject?
        let valueResult = AXUIElementCopyAttributeValue(
            element as! AXUIElement,
            kAXValueAttribute as CFString,
            &value
        )

        if valueResult == .success, let text = value as? String, !text.isEmpty {
            return text
        }

        throw CaptureError.noTextSelected
    }

    // MARK: - Create CapturedContent

    func createCapturedContent(from image: NSImage) -> CapturedContent {
        return CapturedContent(
            type: .image(image),
            source: "screenshot"
        )
    }

    func createCapturedContent(from text: String) -> CapturedContent {
        return CapturedContent(
            type: .text(text),
            source: "text_selection"
        )
    }
}
