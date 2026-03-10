# AI Schedule Assistant

[中文文档](README_CN.md)

【AIScheduleAssistant，一款免费开源的使用AI从截图或文本中识别日程信息的智能macOS菜单栏应用】 https://www.bilibili.com/video/BV1CZPZzYE9g/?share_source=copy_web&vd_source=e7f291854be2ed6de2c8a06ca5facd2a

An intelligent macOS menu bar application that uses AI to recognize schedule information from screenshots or selected text, and automatically adds them to your system Calendar and Reminders.

## Features

- 📸 **Screenshot Recognition**: Capture screenshots and let AI extract schedule information
- ⌨️ **Text Input**: Manually input or paste text containing schedule information
- 🤖 **AI-Powered**: Uses OpenAI-compatible APIs for intelligent parsing
- 📅 **Flexible Saving**: Choose to save to Calendar only, Reminders only, or both
- 🏷️ **Smart Categorization**: AI matches existing categories or creates new ones
- ⚙️ **Flexible Configuration**: Support for any OpenAI-compatible API service
- 🔒 **Privacy First**: All processing happens locally, API keys stored securely in Keychain
- ⚡ **Auto-Add Mode**: Optional mode to skip preview and add events automatically

## Requirements

- macOS 14.6 or later
- System permissions:
  - Screen Recording (for screenshots)
  - Calendar
  - Reminders

## Installation

1. Download the latest release from [Releases](https://github.com/Vesemir-0/AIScheduleAssistant/releases)
2. Move the app to your Applications folder
3. Launch the app - it will appear in your menu bar
4. Grant necessary permissions when prompted
5. Configure your AI API settings

## Configuration

### AI API Setup

1. Click the menu bar icon
2. Select "Settings"
3. In the "AI Configuration" tab:
   - **API Endpoint**: Your API base URL (e.g., `https://api.openai.com/v1`)
   - **API Key**: Your API key
   - **Model Name**: Model to use (e.g., `gpt-4`, `claude-3-opus`)
   - **Temperature**: 0-2 (default: 0.7)
   - **Max Tokens**: Maximum response length (default: 4000)

### Supported AI Services

Any service with OpenAI-compatible API:
- OpenAI (GPT-4, GPT-3.5)
- Anthropic Claude (via compatible endpoints)
- Azure OpenAI
- Local models (Ollama, LM Studio)
- Chinese LLMs (Tongyi Qianwen, Wenxin Yiyan, etc.)

## Usage

### Screenshot Recognition

1. Click the menu bar icon
2. Select "Screenshot Capture"
3. Select the area to capture
4. AI will analyze and show recognized events
5. Review and confirm to add to Calendar and/or Reminders

### Text Input

1. Click the menu bar icon
2. Select "Text Input"
3. Type or paste text containing schedule information
4. Click "Process" to analyze
5. Review and confirm to add

### Save Target Options

Configure where events are saved in Settings > Behavior Settings:
- **Calendar and Reminders**: Save to both (default)
- **Calendar Only**: Only create calendar events
- **Reminders Only**: Only create reminder items

### Auto-Add Mode

Enable in Settings > Behavior Settings to skip the preview step and add events automatically.

## How It Works

1. **Content Capture**: Screenshot or text input
2. **AI Analysis**: Sends to configured AI service with current date/time and existing categories
3. **Event Parsing**: AI returns structured JSON with:
   - Event title and description
   - Start/end dates (ISO 8601 format)
   - Suggested categories
   - Priority level
4. **Smart Saving**: Creates calendar events and/or reminders based on your save target preference
5. **Smart Categorization**: Matches existing categories or creates new ones following broad category principles

## Privacy & Security

- All data processing happens on your device
- API keys stored securely in macOS Keychain
- No user data collected or uploaded
- Screenshots and text only used temporarily during processing
- AI requests controlled by you

## Development

### Building from Source

```bash
git clone https://github.com/Vesemir-0/AIScheduleAssistant.git
cd AIScheduleAssistant
open "AIScheduleAssistant.xcodeproj"
```

### Project Structure

```
AIScheduleAssistant/
├── App/                    # App lifecycle
├── Views/                  # SwiftUI views
│   ├── MenuBar/           # Menu bar interface
│   ├── Preview/           # Event preview window
│   ├── Settings/          # Settings interface
│   └── Components/        # Reusable components
├── ViewModels/            # View models
├── Services/              # Business logic
│   ├── ContentCaptureService
│   ├── AIService
│   ├── EventKitService
│   ├── ConfigService
│   ├── PermissionManager
│   └── Logger
├── Models/                # Data models
└── Utils/                 # Utilities
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and EventKit
- AI-powered by OpenAI-compatible APIs
- Inspired by the need for seamless schedule management

## Support

- 🐛 [Report Issues](https://github.com/Vesemir-0/AIScheduleAssistant/issues)
- 💡 [Feature Requests](https://github.com/Vesemir-0/AIScheduleAssistant/issues)
- 📖 [Documentation](https://github.com/Vesemir-0/AIScheduleAssistant/wiki)

---

Made with ❤️ for productivity enthusiasts
