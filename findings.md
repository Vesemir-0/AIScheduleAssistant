# 研究发现

## 项目现状

- 新建的 SwiftUI 项目
- 使用默认模板代码
- 目标平台：macOS
- 当前只有基础框架

## 技术栈研究

### macOS 菜单栏应用
- 使用 `NSStatusBar` 和 `NSStatusItem`
- SwiftUI 需要通过 `NSHostingView` 桥接

### 权限需求
1. **屏幕录制权限**：监听剪贴板中的截图
2. **辅助功能权限**：使用 Accessibility API 读取选中文本
3. **日历权限**：访问和修改日历事件
4. **提醒事项权限**：访问和修改待办清单

### 系统 API

#### EventKit（日历和提醒事项）
```swift
import EventKit

let eventStore = EKEventStore()
// 请求日历权限
eventStore.requestAccess(to: .event) { granted, error in }
// 请求提醒事项权限
eventStore.requestAccess(to: .reminder) { granted, error in }
```

#### Accessibility API（读取选中文本）
```swift
import ApplicationServices

// 需要在 Info.plist 中声明
// 使用 AXUIElement 获取选中文本
```

#### 剪贴板监听
```swift
import AppKit

let pasteboard = NSPasteboard.general
// 监听 changeCount 变化
```

## AI 集成方案

### OpenAI 兼容 API
- 使用标准的 HTTP 请求
- 支持自定义 base URL
- 支持多种模型（GPT-4、Claude、国内大模型等）

### Prompt 设计要点
1. 识别日期和时间
2. 提取任务描述
3. 判断是日历事件还是待办事项
4. 智能分类（基于现有分类列表）

## 架构设计

### MVVM 模式
- **Model**：Event、Reminder、AIConfig
- **ViewModel**：处理业务逻辑
- **View**：SwiftUI 视图

### 模块划分
1. **MenuBarManager**：菜单栏管理
2. **ContentCapture**：内容获取（截图、文本）
3. **AIService**：AI 调用和处理
4. **CalendarService**：日历集成
5. **ReminderService**：待办清单集成
6. **ConfigManager**：配置管理

## 开源项目参考

- [Maccy](https://github.com/p0deje/Maccy)：剪贴板管理器，可参考菜单栏实现
- [Itsycal](https://github.com/sfsam/Itsycal)：菜单栏日历应用
- [Raycast](https://www.raycast.com/)：参考 UI/UX 设计（闭源但可参考理念）

## 潜在挑战

1. **长截图支持**：系统截图工具不直接支持，可能需要引导用户使用第三方工具或分多次截图
2. **AI 识别准确性**：需要精心设计 prompt 和处理逻辑
3. **分类管理**：如何定义"大类原则"，避免分类过细
4. **隐私安全**：API key 安全存储，用户数据不上传
5. **权限管理**：多个系统权限的请求和处理

## 下一步行动

1. 设计详细的应用架构
2. 创建核心数据模型
3. 实现菜单栏基础框架
