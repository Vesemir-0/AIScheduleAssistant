# Contributing to AI Schedule Assistant

Thank you for your interest in contributing to AI Schedule Assistant! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- macOS version and app version
- Screenshots if applicable

### Suggesting Features

Feature suggestions are welcome! Please create an issue with:
- A clear description of the feature
- Use cases and benefits
- Any implementation ideas you have

### Code Contributions

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed
4. **Test your changes**
   - Ensure the app builds successfully
   - Test all affected functionality
   - Check for memory leaks
5. **Commit your changes**
   ```bash
   git commit -m "Add: brief description of your changes"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**
   - Provide a clear description of the changes
   - Reference any related issues
   - Include screenshots for UI changes

## Development Setup

### Prerequisites
- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

### Building the Project
```bash
git clone https://github.com/Vesemir-0/AIScheduleAssistant.git
cd AIScheduleAssistant
open "AIScheduleAssistant v2.xcodeproj"
```

### Project Structure
```
AIScheduleAssistant/
├── App/                    # App lifecycle and delegates
├── Views/                  # SwiftUI views
├── ViewModels/            # View models (MVVM)
├── Services/              # Business logic services
├── Models/                # Data models
└── Utils/                 # Utility classes
```

## Code Style Guidelines

### Swift Style
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Keep functions focused and concise
- Add comments for complex logic

### Architecture
- Follow MVVM pattern
- Keep views lightweight
- Business logic belongs in services
- Use dependency injection where appropriate

### Naming Conventions
- **Classes/Structs**: PascalCase (e.g., `ContentCaptureService`)
- **Functions/Variables**: camelCase (e.g., `captureScreenshot`)
- **Constants**: camelCase (e.g., `maxTokens`)
- **Enums**: PascalCase with lowercase cases (e.g., `SaveTarget.both`)

## Testing

- Test all new features thoroughly
- Verify existing functionality still works
- Test with different AI providers
- Test permission handling
- Check memory usage

## Documentation

- Update README.md if adding new features
- Add inline comments for complex code
- Update technical documentation in docs/
- Include usage examples for new features

## Commit Message Guidelines

Use clear, descriptive commit messages:
- `Add: new feature description`
- `Fix: bug description`
- `Update: what was updated`
- `Refactor: what was refactored`
- `Docs: documentation changes`

## Pull Request Process

1. Ensure your code builds without warnings
2. Update documentation as needed
3. Add yourself to contributors if it's your first PR
4. Wait for review and address feedback
5. Once approved, your PR will be merged

## Code of Conduct

### Our Standards
- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior
- Harassment or discriminatory language
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information
- Other unprofessional conduct

## Questions?

Feel free to:
- Open an issue for questions
- Start a discussion in GitHub Discussions
- Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to AI Schedule Assistant! 🎉
