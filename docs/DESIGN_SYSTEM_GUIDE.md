# 设计系统使用指南

## 快速开始

### 导入设计系统

在任何 SwiftUI 视图文件中，设计系统会自动可用（因为它在同一个 target 中）。

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        Text("Hello")
            .foregroundColor(DesignSystem.Colors.textPrimary)
    }
}
```

---

## 色彩使用

### 基础色彩

```swift
// 背景色
DesignSystem.Colors.backgroundWarm        // #FDF6ED 燕麦暖米色

// 主色调
DesignSystem.Colors.primaryCoral          // #EF8A6B 珊瑚橘
DesignSystem.Colors.primaryCoralLight     // #F5A88E 浅珊瑚橘
DesignSystem.Colors.primaryCoralDark      // #E67350 深珊瑚橘

// 卡片色
DesignSystem.Colors.surfacePearl          // #FFFFFF 珍珠白

// 点缀色
DesignSystem.Colors.accentWater           // #78BFC1 温泉水蓝
DesignSystem.Colors.accentWaterLight      // #B8DFE0 浅水蓝

// 成功色
DesignSystem.Colors.successGreen          // #A3C57B 草木绿
DesignSystem.Colors.successGreenLight     // #C5DBA3 浅草木绿

// 文字色
DesignSystem.Colors.textPrimary           // #5C4033 咖啡棕
DesignSystem.Colors.textSecondary         // #8B6F5E 次要文字
DesignSystem.Colors.textTertiary          // #A89080 三级文字
```

### 使用示例

```swift
// 标题文字
Text("标题")
    .foregroundColor(DesignSystem.Colors.textPrimary)

// 次要文字
Text("描述")
    .foregroundColor(DesignSystem.Colors.textSecondary)

// 背景
.background(DesignSystem.Colors.backgroundWarm)

// 渐变背景
.background(
    LinearGradient(
        colors: [
            DesignSystem.Colors.primaryCoral,
            DesignSystem.Colors.primaryCoralDark
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
```

---

## 圆角使用

### 圆角规范

```swift
DesignSystem.CornerRadius.extraLarge  // 24pt - 主要卡片、按钮
DesignSystem.CornerRadius.large       // 18pt - 次要卡片
DesignSystem.CornerRadius.medium      // 12pt - 小组件、徽章
DesignSystem.CornerRadius.small       // 8pt  - 输入框内部元素
```

### 使用示例

```swift
// 主要按钮
RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)

// 卡片
.cornerRadius(DesignSystem.CornerRadius.extraLarge)

// 徽章
.cornerRadius(DesignSystem.CornerRadius.medium)
```

---

## 间距使用

### 间距规范

```swift
DesignSystem.Spacing.tiny         // 4pt
DesignSystem.Spacing.small        // 8pt
DesignSystem.Spacing.medium       // 12pt
DesignSystem.Spacing.regular      // 16pt
DesignSystem.Spacing.large        // 20pt
DesignSystem.Spacing.extraLarge   // 24pt
DesignSystem.Spacing.huge         // 32pt
```

### 使用示例

```swift
// VStack 间距
VStack(spacing: DesignSystem.Spacing.large) {
    // 内容
}

// 内边距
.padding(DesignSystem.Spacing.extraLarge)

// 水平间距
HStack(spacing: DesignSystem.Spacing.medium) {
    // 内容
}
```

---

## 按钮样式

### 主要按钮（Primary Button）

用于：主要操作、确认、提交

```swift
Button("保存") {
    // 操作
}
.buttonStyle(CapybaraPrimaryButtonStyle())

// 带图标
Button {
    // 操作
} label: {
    HStack(spacing: 8) {
        Image(systemName: "checkmark.circle.fill")
        Text("保存")
    }
}
.buttonStyle(CapybaraPrimaryButtonStyle())
```

**视觉特点**：
- 珊瑚橘渐变背景
- 白色文字
- 超大圆角（24pt）
- 暖色阴影
- 点击缩放动画

---

### 次要按钮（Secondary Button）

用于：取消、返回、次要操作

```swift
Button("取消") {
    // 操作
}
.buttonStyle(CapybaraSecondaryButtonStyle())
```

**视觉特点**：
- 珍珠白背景
- 咖啡棕文字
- 超大圆角（24pt）
- 灰色边框
- 点击缩放动画

---

## 输入框样式

### 标准输入框

```swift
TextField("请输入", text: $text)
    .textFieldStyle(CapybaraTextFieldStyle())
```

**视觉特点**：
- 珍珠白背景
- 水蓝色边框
- 中圆角（12pt）
- 咖啡棕文字

---

### 安全输入框

```swift
SecureField("请输入密码", text: $password)
    .textFieldStyle(CapybaraTextFieldStyle())
```

---

## 卡片样式

### 浮动卡片（Floating Card）

用于：主要内容卡片、列表项

```swift
VStack {
    // 卡片内容
}
.padding(20)
.floatingCard()

// 自定义阴影颜色
.floatingCard(shadowColor: DesignSystem.Colors.shadowCool)

// 自定义圆角
.floatingCard(
    shadowColor: DesignSystem.Colors.shadowWarm,
    cornerRadius: DesignSystem.CornerRadius.large
)
```

**视觉特点**：
- 珍珠白背景
- 超大圆角（默认 24pt）
- 软投影（默认暖色）
- 漂浮效果

---

### 磨砂玻璃卡片（Glass Card）

用于：输入框、加载状态、弹窗

```swift
VStack {
    // 卡片内容
}
.padding(20)
.glassCard()
```

**视觉特点**：
- 半透明水蓝色背景
- 模糊效果
- 水蓝色边框
- 超大圆角（24pt）

---

## 组件使用

### 分隔线

```swift
DividerCapybara()
```

**视觉特点**：
- 咖啡棕 20% 透明度
- 比系统分隔线更柔和

---

### 徽章（Badge）

```swift
BadgeCapybara(
    icon: "calendar",
    text: "工作",
    color: DesignSystem.Colors.primaryCoral
)
```

**视觉特点**：
- 圆角（12pt）
- 半透明背景
- 图标 + 文字

---

### 章节标题

```swift
SectionHeaderCapybara(
    title: "API 配置",
    icon: "network"
)
```

**视觉特点**：
- 珊瑚橘图标
- 咖啡棕文字
- 左对齐

---

## 动画使用

### 弹性动画

```swift
.animation(
    .spring(response: 0.3, dampingFraction: 0.7),
    value: isSelected
)
```

用于：选中状态、展开/收起

---

### 缩放动画

```swift
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.easeInOut(duration: 0.2), value: isPressed)
```

用于：按钮点击

---

### 颜色过渡

```swift
.foregroundColor(isActive ? DesignSystem.Colors.primaryCoral : DesignSystem.Colors.textSecondary)
.animation(.easeInOut(duration: 0.2), value: isActive)
```

用于：状态切换

---

## 完整示例

### 示例 1：简单卡片

```swift
struct SimpleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("标题")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Text("这是一段描述文字")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)

            HStack {
                BadgeCapybara(
                    icon: "calendar",
                    text: "工作",
                    color: DesignSystem.Colors.primaryCoral
                )

                BadgeCapybara(
                    icon: "clock",
                    text: "14:00",
                    color: DesignSystem.Colors.accentWater
                )
            }
        }
        .padding(20)
        .floatingCard(shadowColor: DesignSystem.Colors.shadowWarm)
    }
}
```

---

### 示例 2：带按钮的表单

```swift
struct FormView: View {
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // 标题
            VStack(spacing: 8) {
                Text("用户信息")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("请填写您的基本信息")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            // 表单卡片
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("姓名")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)

                    TextField("请输入姓名", text: $name)
                        .textFieldStyle(CapybaraTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("邮箱")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)

                    TextField("请输入邮箱", text: $email)
                        .textFieldStyle(CapybaraTextFieldStyle())
                }
            }
            .padding(20)
            .floatingCard()

            // 按钮
            HStack(spacing: 16) {
                Button("取消") {
                    // 取消操作
                }
                .buttonStyle(CapybaraSecondaryButtonStyle())

                Button {
                    // 保存操作
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("保存")
                    }
                }
                .buttonStyle(CapybaraPrimaryButtonStyle())
            }
        }
        .padding(32)
        .background(DesignSystem.Colors.backgroundWarm)
    }
}
```

---

### 示例 3：可选择的列表项

```swift
struct SelectableListItem: View {
    let title: String
    let description: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(
                        isSelected
                            ? DesignSystem.Colors.successGreen
                            : DesignSystem.Colors.textTertiary.opacity(0.4)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()
            }
            .padding(16)
            .background(DesignSystem.Colors.surfacePearl)
            .cornerRadius(DesignSystem.CornerRadius.extraLarge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .stroke(
                        isSelected ? DesignSystem.Colors.successGreen : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected
                    ? DesignSystem.Colors.successGreen.opacity(0.2)
                    : DesignSystem.Colors.shadowNeutral,
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
    }
}
```

---

## 最佳实践

### 1. 颜色使用

✅ **推荐**：
```swift
.foregroundColor(DesignSystem.Colors.textPrimary)
```

❌ **不推荐**：
```swift
.foregroundColor(.black)
.foregroundColor(Color(hex: "#5C4033"))
```

---

### 2. 圆角使用

✅ **推荐**：
```swift
.cornerRadius(DesignSystem.CornerRadius.extraLarge)
```

❌ **不推荐**：
```swift
.cornerRadius(24)
```

---

### 3. 间距使用

✅ **推荐**：
```swift
VStack(spacing: DesignSystem.Spacing.large) { }
.padding(DesignSystem.Spacing.extraLarge)
```

❌ **不推荐**：
```swift
VStack(spacing: 20) { }
.padding(24)
```

---

### 4. 按钮样式

✅ **推荐**：
```swift
Button("保存") { }
    .buttonStyle(CapybaraPrimaryButtonStyle())
```

❌ **不推荐**：
```swift
Button("保存") { }
    .buttonStyle(.borderedProminent)
```

---

### 5. 卡片样式

✅ **推荐**：
```swift
VStack { }
    .padding(20)
    .floatingCard()
```

❌ **不推荐**：
```swift
VStack { }
    .padding(20)
    .background(Color.white)
    .cornerRadius(24)
    .shadow(radius: 8)
```

---

## 扩展设计系统

### 添加新颜色

在 `DesignSystem.swift` 的 `Colors` enum 中添加：

```swift
enum Colors {
    // 现有颜色...

    // 新颜色
    static let customColor = Color(hex: "#ABCDEF")
}
```

---

### 添加新组件

在 `DesignSystem.swift` 底部添加：

```swift
struct MyCustomComponent: View {
    var body: some View {
        // 组件实现
    }
}
```

---

### 添加新按钮样式

```swift
struct MyCustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // 样式实现
    }
}
```

---

## 常见问题

### Q: 如何在深色模式下使用？

A: 当前设计系统针对浅色模式优化。如需支持深色模式，建议：
1. 在 `Colors` enum 中添加深色模式颜色
2. 使用 `@Environment(\.colorScheme)` 检测当前模式
3. 根据模式返回不同颜色

---

### Q: 如何自定义阴影？

A: 使用 `.shadow()` 修饰符：

```swift
.shadow(
    color: DesignSystem.Colors.shadowWarm,
    radius: 12,
    x: 0,
    y: 4
)
```

---

### Q: 如何创建渐变背景？

A: 使用 `LinearGradient`：

```swift
.background(
    LinearGradient(
        colors: [
            DesignSystem.Colors.primaryCoral,
            DesignSystem.Colors.primaryCoralDark
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
```

---

## 总结

设计系统提供了完整的视觉语言和可复用组件，确保整个应用的视觉一致性。遵循本指南，可以快速创建符合"温泉水豚"主题的界面。

**核心原则**：
1. 使用设计系统定义的常量，而非硬编码值
2. 优先使用预定义的组件和样式
3. 保持视觉一致性
4. 注重细节和动画
