//
//  DesignSystem.swift
//  AIScheduleAssistant
//
//  温泉水豚设计系统
//  Design System inspired by hot spring capybara theme
//

import SwiftUI

// MARK: - Design System

enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // 背景色 - 燕麦暖米色
        static let backgroundWarm = Color(hex: "#FDF6ED")

        // 主色调 - 珊瑚橘（水豚蒸汽）
        static let primaryCoral = Color(hex: "#EF8A6B")
        static let primaryCoralLight = Color(hex: "#F5A88E")
        static let primaryCoralDark = Color(hex: "#E67350")

        // 卡片色 - 珍珠白
        static let surfacePearl = Color.white

        // 温泉水蓝（淡化版用于次要卡片）
        static let accentWater = Color(hex: "#78BFC1")
        static let accentWaterLight = Color(hex: "#B8DFE0")

        // 成功/完成色 - 草木绿（荷叶）
        static let successGreen = Color(hex: "#A3C57B")
        static let successGreenLight = Color(hex: "#C5DBA3")

        // 文字色 - 咖啡棕（水豚毛发）
        static let textPrimary = Color(hex: "#5C4033")
        static let textSecondary = Color(hex: "#8B6F5E")
        static let textTertiary = Color(hex: "#A89080")

        // 阴影色
        static let shadowWarm = Color(hex: "#EF8A6B").opacity(0.15)
        static let shadowCool = Color(hex: "#78BFC1").opacity(0.12)
        static let shadowNeutral = Color(hex: "#5C4033").opacity(0.08)
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let extraLarge: CGFloat = 24  // 主要卡片、按钮
        static let large: CGFloat = 18       // 次要卡片
        static let medium: CGFloat = 12      // 小组件、徽章
        static let small: CGFloat = 8        // 输入框内部元素
    }

    // MARK: - Spacing

    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 24
        static let huge: CGFloat = 32
    }

    // MARK: - Shadow

    enum Shadow {
        static let warm = (color: Colors.shadowWarm, radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let cool = (color: Colors.shadowCool, radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let neutral = (color: Colors.shadowNeutral, radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

struct FloatingCardModifier: ViewModifier {
    let shadowColor: Color
    let cornerRadius: CGFloat

    init(shadowColor: Color = DesignSystem.Colors.shadowWarm, cornerRadius: CGFloat = DesignSystem.CornerRadius.extraLarge) {
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.surfacePearl)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: 12, x: 0, y: 4)
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                DesignSystem.Colors.accentWaterLight.opacity(0.3)
                    .blur(radius: 10)
            )
            .cornerRadius(DesignSystem.CornerRadius.extraLarge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .stroke(DesignSystem.Colors.accentWater.opacity(0.3), lineWidth: 1.5)
            )
    }
}

extension View {
    func floatingCard(shadowColor: Color = DesignSystem.Colors.shadowWarm, cornerRadius: CGFloat = DesignSystem.CornerRadius.extraLarge) -> some View {
        modifier(FloatingCardModifier(shadowColor: shadowColor, cornerRadius: cornerRadius))
    }

    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

// MARK: - Custom Button Styles

struct CapybaraPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primaryCoral,
                                DesignSystem.Colors.primaryCoralDark
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: DesignSystem.Colors.shadowWarm, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct CapybaraSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .fill(DesignSystem.Colors.surfacePearl)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .stroke(DesignSystem.Colors.textTertiary.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: DesignSystem.Colors.shadowNeutral, radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Custom Text Field Style

struct CapybaraTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .padding(12)
            .background(DesignSystem.Colors.surfacePearl)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.accentWater.opacity(0.3), lineWidth: 1.5)
            )
    }
}

// MARK: - Custom Components

struct SectionHeaderCapybara: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primaryCoral)

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()
        }
    }
}

struct BadgeCapybara: View {
    let icon: String
    let text: String
    let color: Color

    init(icon: String, text: String, color: Color = DesignSystem.Colors.primaryCoral) {
        self.icon = icon
        self.text = text
        self.color = color
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

struct DividerCapybara: View {
    var body: some View {
        Divider()
            .background(DesignSystem.Colors.textTertiary.opacity(0.2))
    }
}
