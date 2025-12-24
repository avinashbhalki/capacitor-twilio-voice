# Capacitor Twilio Voice Plugin - Contributing Guide

Thank you for considering contributing to the Capacitor Twilio Voice plugin!

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/avinashbhalki/capacitor-twilio-voice.git
cd capacitor-twilio-voice
```

2. Install dependencies:
```bash
npm install
```

3. Build the plugin:
```bash
npm run build
```

## Testing

### Android Testing

1. Create a test Ionic app:
```bash
ionic start test-app blank --type=angular --capacitor
cd test-app
```

2. Install the plugin locally:
```bash
npm install ../capacitor-twilio-voice
npx cap sync android
```

3. Run on Android:
```bash
ionic cap run android
```

### iOS Testing

1. Install pods:
```bash
cd ios/App
pod install
```

2. Run on iOS:
```bash
ionic cap run ios
```

## Code Style

- **TypeScript**: Follow the existing code style
- **Kotlin**: Follow Android Kotlin style guide
- **Swift**: Follow Swift style guide
- Run linters before committing:
```bash
npm run lint
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests and linters
5. Commit with clear messages
6. Push to your fork
7. Create a Pull Request

## Reporting Issues

When reporting issues, please include:
- Plugin version
- Capacitor version
- Platform (Android/iOS)
- Device/Emulator details
- Steps to reproduce
- Error messages/logs

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
