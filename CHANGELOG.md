# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-24

### Added
- Initial release of Capacitor Twilio Voice plugin
- Full-screen native call UI for Android and iOS
- `startCall()` method to initiate outgoing calls
- `endCall()` method to disconnect active calls
- `setMute()` method to control microphone state
- `setSpeaker()` method to control audio output
- Event listeners for call lifecycle:
  - `callConnected` - Fired when call is connected
  - `callDisconnected` - Fired when call ends normally
  - `callFailed` - Fired when call fails with error details
- Android implementation with Kotlin
  - Twilio Voice Android SDK 6.1.3
  - Custom CallActivity with native UI
  - Proper audio focus management
  - Runtime permission handling
- iOS implementation with Swift
  - Twilio Voice iOS SDK 6.9.0
  - CallKit integration
  - Custom CallViewController with native UI
  - AVAudioSession management
- Comprehensive documentation and examples
- TypeScript definitions
- Production-ready error handling
- No TODOs or placeholders

### Features
- **Native Call UI**: Full-screen interface with mute, speaker, and end call buttons
- **Call Duration**: Automatic timer showing elapsed call time
- **Audio Management**: Proper handling of audio routing and focus
- **Permission Handling**: Automatic runtime permission requests
- **Event System**: Real-time call state notifications
- **Error Handling**: Comprehensive error reporting with codes and messages
- **Lifecycle Management**: Automatic UI cleanup on call end/failure

### Platform Support
- Android API 22+ (Android 5.1+)
- iOS 13.0+
- Capacitor 6.0.0+

### Documentation
- Complete API reference
- Installation and setup guide
- Usage examples for Angular/Ionic and React
- Backend integration examples
- Troubleshooting guide
