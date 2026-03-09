//
//  PreviewWindow.swift
//  AIScheduleAssistant
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
            HStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28))
                    .foregroundColor(DesignSystem.Colors.successGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI 为你整理好了这些日程")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("像荷叶一样清晰明了")
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(DesignSystem.Colors.backgroundWarm)

            DividerCapybara()

            // Events List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                        EventPreviewCard(
                            event: event,
                            isSelected: selectedEventIndices.contains(index),
                            onToggle: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if selectedEventIndices.contains(index) {
                                        selectedEventIndices.remove(index)
                                    } else {
                                        selectedEventIndices.insert(index)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(24)
            }
            .background(DesignSystem.Colors.backgroundWarm.opacity(0.5))

            DividerCapybara()

            // Footer
            HStack(spacing: 16) {
                Button(allSelected ? "全不选" : "全选") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if allSelected {
                            selectedEventIndices.removeAll()
                        } else {
                            selectedEventIndices = Set(events.indices)
                        }
                    }
                }
                .buttonStyle(CapybaraSecondaryButtonStyle())

                Spacer()

                HStack(spacing: 6) {
                    Text("\(selectedEventIndices.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryCoral)
                    Text("/ \(events.count) 个事件已选择")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()

                Button("取消") {
                    dismiss()
                }
                .buttonStyle(CapybaraSecondaryButtonStyle())

                Button {
                    let selectedEvents = selectedEventIndices.map { events[$0] }
                    Task {
                        await viewModel.createSelectedEvents(selectedEvents)
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                        Text("添加到日历")
                    }
                }
                .buttonStyle(CapybaraPrimaryButtonStyle())
                .disabled(selectedEventIndices.isEmpty)
            }
            .padding(24)
            .background(DesignSystem.Colors.backgroundWarm)
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
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 16) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? DesignSystem.Colors.successGreen : DesignSystem.Colors.textTertiary.opacity(0.4))

                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(event.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .multilineTextAlignment(.leading)

                    // Description
                    if let description = event.description {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.leading)
                    }

                    // Date and Time
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                            Text(formatDate(event.startDate))
                                .font(.system(size: 13))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)

                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 13))
                            Text(formatTime(event.startDate))
                                .font(.system(size: 13))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }

                    // Categories
                    HStack(spacing: 10) {
                        BadgeCapybara(
                            icon: "calendar",
                            text: event.suggestedCalendar,
                            color: DesignSystem.Colors.primaryCoral
                        )
                        BadgeCapybara(
                            icon: "checklist",
                            text: event.suggestedReminderList,
                            color: DesignSystem.Colors.accentWater
                        )
                    }

                    // Confidence warning
                    if event.confidence < 0.8 {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 13))
                            Text("识别置信度较低，请检查信息是否准确")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(DesignSystem.Colors.primaryCoral)
                        .padding(10)
                        .background(DesignSystem.Colors.primaryCoral.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(DesignSystem.Colors.surfacePearl)
            .cornerRadius(DesignSystem.CornerRadius.extraLarge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .stroke(
                        isSelected ? DesignSystem.Colors.successGreen : Color.clear,
                        lineWidth: 3
                    )
            )
            .shadow(
                color: isSelected ? DesignSystem.Colors.successGreen.opacity(0.2) : DesignSystem.Colors.shadowWarm,
                radius: isSelected ? 16 : 8,
                x: 0,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(.plain)
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
        .background(DesignSystem.Colors.primaryCoral.opacity(0.1))
        .foregroundColor(DesignSystem.Colors.primaryCoral)
        .cornerRadius(DesignSystem.CornerRadius.small)
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
