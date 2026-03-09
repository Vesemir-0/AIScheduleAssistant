//
//  AppDelegate.swift
//  AIScheduleAssistant
//
//  Created by Claude on 2026/3/9.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var welcomeWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var previewWindow: NSWindow?
    private var previewViewModel: ContentProcessViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide all windows created by SwiftUI
        NSApplication.shared.windows.forEach { $0.close() }

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Use custom menu bar icon
            if let image = NSImage(named: "MenuBarIcon") {
                image.isTemplate = true  // Makes it adapt to light/dark mode
                button.image = image
            } else {
                // Fallback to system icon if custom icon not found
                button.image = NSImage(systemSymbolName: "calendar.badge.plus", accessibilityDescription: "AI Schedule Assistant")
            }
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover for menu
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 250, height: 200)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView(appDelegate: self))

        // Show welcome window on first launch
        checkAndShowWelcome()
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    private func checkAndShowWelcome() {
        let hasShownWelcome = UserDefaults.standard.bool(forKey: "hasShownWelcome")

        if !hasShownWelcome {
            showWelcomeWindow()
            UserDefaults.standard.set(true, forKey: "hasShownWelcome")
        }
    }

    func showWelcomeWindow() {
        let welcomeView = WelcomeView()
        let hostingController = NSHostingController(rootView: welcomeView)

        welcomeWindow = NSWindow(contentViewController: hostingController)
        welcomeWindow?.title = "欢迎"
        welcomeWindow?.styleMask = [.titled, .closable]
        welcomeWindow?.center()
        welcomeWindow?.makeKeyAndOrderFront(nil)
        welcomeWindow?.level = .floating
    }

    func showSettingsWindow() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "设置"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable]
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showPreviewWindow(events: [ParsedEvent], viewModel: ContentProcessViewModel) {
        // Store the view model reference
        previewViewModel = viewModel

        let previewView = PreviewWindow(viewModel: viewModel, events: events)
        let hostingController = NSHostingController(rootView: previewView)

        previewWindow = NSWindow(contentViewController: hostingController)
        previewWindow?.title = "AI 识别结果"
        previewWindow?.styleMask = [.titled, .closable, .resizable]
        previewWindow?.setContentSize(NSSize(width: 600, height: 500))
        previewWindow?.center()
        previewWindow?.makeKeyAndOrderFront(nil)
        previewWindow?.level = .floating
        NSApp.activate(ignoringOtherApps: true)
    }
}
