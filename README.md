# AI Schedule Assistant

[中文文档](README_CN.md)

An intelligent macOS menu bar application that uses AI to recognize schedule information from screenshots or selected text, and automatically adds them to your system Calendar and Reminders.

## Features

- 📸 **Screenshot Recognition**: Capture screenshots and let AI extract schedule information
- 📝 **Text Selection**: Select text anywhere and convert it to calendar events
- 🤖 **AI-Powered**: Uses OpenAI-compatible APIs for intelligent parsing
- 📅 **Dual Creation**: Automatically creates both calendar events and reminders
- 🏷️ **Smart Categorization**: AI matches existing categories or creates new ones
- ⚙️ **Flexible Configuration**: Support for any OpenAI-compatible API service
- 🔒 **Privacy First**: All processing happens locally, API keys stored securely in Keychain

## Requirements

- macOS 13.0 or later
- System permissions:
  - Screen Recording (for screenshots)
  - Accessibility (for text selection)
  - Calendar
  - Reminders

## Installation

1. Download the latest release from [Releases](https://github.com/yourusername/AIScheduleAssistant/releases)
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
   - **Max Tokens**: Maximum response length (default: 1000)

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
5. Review and confirm to add to Calendar and Reminders

### Text Selection

1. Select text containing schedule information in any app
2. Click the menu bar icon
3. Select "Capture Selected Text"
4. AI will analyze and show recognized events
5. Review and confirm to add

### Auto-Add Mode

Enable in Settings > Behavior Settings to skip the preview step and add events automatically.

## How It Works

1. **Content Capture**: Screenshot or text selection
2. **AI Analysis**: Sends to configured AI service with current date/time and existing categories
3. **Event Parsing**: AI returns structured JSON with:
   - Event title and description
   - Start/end dates (ISO 8601 format)
   - Suggested categories
   - Priority level
4. **Dual Creation**: Creates both calendar event and reminder with linked IDs
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
git clone https://github.com/yourusername/AIScheduleAssistant.git
cd AIScheduleAssistant
open "AIScheduleAssistant v2.xcodeproj"
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

- 🐛 [Report Issues](https://github.com/yourusername/AIScheduleAssistant/issues)
- 💡 [Feature Requests](https://github.com/yourusername/AIScheduleAssistant/issues)
- 📖 [Documentation](https://github.com/yourusername/AIScheduleAssistant/wiki)

---

Made with ❤️ for productivity enthusiasts
