//
//  AIScheduleAssistant_v2App.swift
//  AIScheduleAssistant v2
//
//  Created by Huang Peng on 2026/3/9.
//

import SwiftUI

@main
struct AIScheduleAssistant_v2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Return empty scene to prevent default window
        WindowGroup {
            EmptyView()
        }
        .defaultSize(width: 0, height: 0)
        .windowResizability(.contentSize)
    }

    init() {
        // Hide the default window immediately
        DispatchQueue.main.async {
            NSApplication.shared.windows.forEach { window in
                if window.title.isEmpty {
                    window.close()
                }
            }
        }
    }
}
