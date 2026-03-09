# AI Schedule Assistant

[English](README.md)

一个智能的 macOS 菜单栏应用，使用 AI 识别截图或选中文本中的日程信息，自动添加到系统日历和待办清单。

## 功能特性

- 📸 **截图识别**：截取屏幕内容，AI 自动提取日程信息
- ⌨️ **文本输入**：手动输入或粘贴包含日程信息的文本
- 🤖 **AI 驱动**：使用 OpenAI 兼容 API 进行智能解析
- 📅 **灵活保存**：可选择仅保存到日历、仅保存到待办清单或同时保存
- 🏷️ **智能分类**：AI 自动匹配现有分类或创建新分类
- ⚙️ **灵活配置**：支持所有 OpenAI 兼容的 API 服务
- 🔒 **隐私优先**：本地处理，API Key 安全存储在 Keychain
- ⚡ **自动添加模式**：可选跳过预览直接添加事件

## 系统要求

- macOS 14.6 或更高版本
- 系统权限：
  - 屏幕录制（用于截图）
  - 日历
  - 提醒事项

## 安装

1. 从 [Releases](https://github.com/Vesemir-0/AIScheduleAssistant/releases) 下载最新版本
2. 将应用移动到应用程序文件夹
3. 启动应用 - 它会出现在菜单栏中
4. 根据提示授予必要的权限
5. 配置 AI API 设置

## 配置

### AI API 设置

1. 点击菜单栏图标
2. 选择"设置"
3. 在"AI 配置"标签页中：
   - **API 端点**：API 基础 URL（如 `https://api.openai.com/v1`）
   - **API Key**：你的 API 密钥
   - **模型名称**：要使用的模型（如 `gpt-4`、`claude-3-opus`）
   - **Temperature**：0-2（默认：0.7）
   - **Max Tokens**：最大响应长度（默认：4000）

### 支持的 AI 服务

任何 OpenAI 兼容 API 的服务：
- OpenAI（GPT-4、GPT-3.5）
- Anthropic Claude（通过兼容端点）
- Azure OpenAI
- 本地模型（Ollama、LM Studio）
- 国内大模型（通义千问、文心一言等）

## 使用方法

### 截图识别

1. 点击菜单栏图标
2. 选择"截图获取"
3. 选择要截取的区域
4. AI 会分析并显示识别的事件
5. 审核并确认添加到日历和/或待办清单

### 文本输入

1. 点击菜单栏图标
2. 选择"文本输入"
3. 输入或粘贴包含日程信息的文本
4. 点击"处理"进行分析
5. 审核并确认添加

### 保存目标选项

在设置 > 行为设置中配置事件保存位置：
- **日历和待办清单**：同时保存到两处（默认）
- **仅日历**：只创建日历事件
- **仅待办清单**：只创建待办事项

### 自动添加模式

在设置 > 行为设置中启用，跳过预览步骤直接添加事件。

## 工作原理

1. **内容捕获**：截图或文本输入
2. **AI 分析**：发送到配置的 AI 服务，包含当前日期时间和现有分类
3. **事件解析**：AI 返回结构化 JSON，包含：
   - 事件标题和描述
   - 开始/结束日期（ISO 8601 格式）
   - 建议的分类
   - 优先级
4. **智能保存**：根据保存目标设置创建日历事件和/或待办事项
5. **智能分类**：匹配现有分类或创建新分类（遵循大类原则）

## 隐私与安全

- 所有数据处理在本地进行
- API Key 安全存储在 macOS Keychain 中
- 不收集或上传任何用户数据
- 截图和文本仅在处理时临时使用
- AI 请求由你控制

## 开发

### 从源码构建

```bash
git clone https://github.com/Vesemir-0/AIScheduleAssistant.git
cd AIScheduleAssistant
open "AIScheduleAssistant.xcodeproj"
```

### 项目结构

```
AIScheduleAssistant/
├── App/                    # 应用生命周期
├── Views/                  # SwiftUI 视图
│   ├── MenuBar/           # 菜单栏界面
│   ├── Preview/           # 事件预览窗口
│   ├── Settings/          # 设置界面
│   └── Components/        # 可复用组件
├── ViewModels/            # 视图模型
├── Services/              # 业务逻辑
│   ├── ContentCaptureService
│   ├── AIService
│   ├── EventKitService
│   ├── ConfigService
│   ├── PermissionManager
│   └── Logger
├── Models/                # 数据模型
└── Utils/                 # 工具类
```

## 贡献

欢迎贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 致谢

- 使用 SwiftUI 和 EventKit 构建
- AI 功能由 OpenAI 兼容 API 提供支持
- 灵感来自对无缝日程管理的需求

## 支持

- 🐛 [报告问题](https://github.com/Vesemir-0/AIScheduleAssistant/issues)
- 💡 [功能请求](https://github.com/Vesemir-0/AIScheduleAssistant/issues)
- 📖 [文档](https://github.com/Vesemir-0/AIScheduleAssistant/wiki)

---

用 ❤️ 为效率爱好者打造
