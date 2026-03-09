//
//  PreviewWindow.swift
//  AIScheduleAssistant v2
//
//  Created by Claude on 2026/3/9.
//

import SwiftUI

struct PreviewWindow: View {
    @ObservedObject var viewModel: ContentProcessViewModel
    @Environment(\.dismiss) private var dismiss

    let events: [ParsedEvent]

    @State private var selectedEventIndices: Set<Int> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("AI 识别结果")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Events List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                        EventPreviewCard(
                            event: event,
                            isSelected: selectedEventIndices.contains(index),
                            onToggle: {
                                if selectedEventIndices.contains(index) {
                                    selectedEventIndices.remove(index)
                                } else {
                                    selectedEventIndices.insert(index)
                                }
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Button(allSelected ? "全不选" : "全选") {
                    if allSelected {
                        selectedEventIndices.removeAll()
                    } else {
                        selectedEventIndices = Set(events.indices)
                    }
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("\(selectedEventIndices.count) / \(events.count) 个事件已选择")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("取消") {
                    dismiss()
                }

                Button("添加到日历和待办") {
                    let selectedEvents = selectedEventIndices.map { events[$0] }
                    Task {
                        await viewModel.createSelectedEvents(selectedEvents)
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedEventIndices.isEmpty)
            }
            .padding()
        }
        .onAppear {
            // Select all events by default
            selectedEventIndices = Set(events.indices)
        }
    }

    private var allSelected: Bool {
        selectedEventIndices.count == events.count && !events.isEmpty
    }
}

struct EventPreviewCard: View {
    let event: ParsedEvent
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button {
                onToggle()
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(event.title)
                    .font(.headline)

                // Description
                if let description = event.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Date and Time
                HStack(spacing: 16) {
                    Label(formatDate(event.startDate), systemImage: "calendar")
                    Label(formatTime(event.startDate), systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                // Categories
                HStack(spacing: 8) {
                    CategoryBadge(icon: "calendar", text: event.suggestedCalendar)
                    CategoryBadge(icon: "checklist", text: event.suggestedReminderList)
                }

                // Confidence
                if event.confidence < 0.8 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("识别置信度较低，请检查信息是否准确")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CategoryBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(4)
    }
}

#Preview {
    PreviewWindow(
        viewModel: ContentProcessViewModel(),
        events: [
            ParsedEvent(
                title: "团队会议",
                description: "讨论项目进度",
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600),
                isAllDay: false,
                dueDate: Date(),
                priority: 5,
                suggestedCalendar: "工作",
                suggestedReminderList: "工作",
                confidence: 0.95
            )
        ]
    )
}
