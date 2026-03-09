//
//  CapturedContent.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import AppKit

enum ContentType {
    case image(NSImage)
    case text(String)
}

struct CapturedContent {
    let type: ContentType
    let timestamp: Date
    let source: String  // "screenshot" or "text_selection"

    init(type: ContentType, source: String) {
        self.type = type
        self.timestamp = Date()
        self.source = source
    }
}
