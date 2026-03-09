//
//  Logger.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import Foundation

enum LogLevel: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    static let shared = Logger()

    private let logFileURL: URL
    private let dateFormatter: DateFormatter

    private init() {
        // Create logs directory
        let logsDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AIScheduleAssistant")
            .appendingPathComponent("logs")

        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)

        // Create log file with date
        let dateString = ISO8601DateFormatter().string(from: Date()).prefix(10)
        logFileURL = logsDir.appendingPathComponent("log_\(dateString).txt")

        // Setup date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    // MARK: - Logging Methods

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }

    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }

    func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: error.localizedDescription, file: file, function: function, line: line)
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }

    // MARK: - Core Logging

    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function) - \(message)\n"

        // Print to console
        print(logMessage, terminator: "")

        // Write to file
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: logFileURL)
            }
        }
    }

    // MARK: - Export Logs

    func exportLogs() -> URL? {
        guard FileManager.default.fileExists(atPath: logFileURL.path) else {
            return nil
        }
        return logFileURL
    }

    func clearLogs() {
        try? FileManager.default.removeItem(at: logFileURL)
    }

    // MARK: - Get All Log Files

    func getAllLogFiles() -> [URL] {
        let logsDir = logFileURL.deletingLastPathComponent()
        guard let files = try? FileManager.default.contentsOfDirectory(at: logsDir, includingPropertiesForKeys: nil) else {
            return []
        }
        return files.filter { $0.pathExtension == "txt" }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
}
