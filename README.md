# capacitor-twilio-voice

A production-ready Capacitor 8 plugin for integrating Twilio Voice calling with native UI support for Android and iOS platforms.

## Features

- 🎯 **Capacitor 8 Compatible** - Built specifically for @capacitor/core v8.0.0
- 📱 **Native UI** - Full-screen native call interface on both platforms
- 🍎 **CallKit Integration** - Seamless iOS CallKit support
- 🤖 **Android Activity** - Dedicated call activity with proper lifecycle management
- 🔊 **Audio Controls** - Mute and speaker toggle functionality
- 📡 **Event System** - Real-time call state notifications
- 🔒 **Production Ready** - Robust error handling and permission management

## Installation

```bash
npm install capacitor-twilio-voice
npx cap sync
```

## Platform Requirements

- **Capacitor**: 8.0.0
- **iOS**: 13.0+
- **Android**: API 22+ (Android 5.1+)

## API Documentation

### Methods

#### `startCall(options: StartCallOptions): Promise<void>`

Initiates a Twilio Voice call with a native full-screen UI.

```typescript
import { TwilioVoice } from 'capacitor-twilio-voice';

await TwilioVoice.startCall({
  toNumber: '+1234567890',
  accessToken: 'your-twilio-access-token'
});
```

**Parameters:**
- `toNumber` (string): Phone number in E.164 format (e.g., +1234567890)
- `accessToken` (string): Twilio Voice access token from your server

#### `endCall(): Promise<void>`

Ends the current active call and closes the native UI.

```typescript
await TwilioVoice.endCall();
```

#### `setMute(options: MuteOptions): Promise<void>`

Sets the microphone mute state during an active call.

```typescript
await TwilioVoice.setMute({ enabled: true });  // Mute
await TwilioVoice.setMute({ enabled: false }); // Unmute
```

#### `setSpeaker(options: SpeakerOptions): Promise<void>`

Toggles speaker mode during an active call.

```typescript
await TwilioVoice.setSpeaker({ enabled: true });  // Speaker on
await TwilioVoice.setSpeaker({ enabled: false }); // Speaker off
```

### Events

Listen to call events using Capacitor's event listener system:

#### `callConnected`

Fired when the call successfully connects.

```typescript
TwilioVoice.addListener('callConnected', () => {
  console.log('Call connected!');
});
```

#### `callDisconnected`

Fired when the call disconnects (user ended, remote party ended, or network issue).

```typescript
TwilioVoice.addListener('callDisconnected', () => {
  console.log('Call disconnected');
});
```

#### `callFailed`

Fired when the call fails to connect or encounters an error.

```typescript
TwilioVoice.addListener('callFailed', (data: { error: string }) => {
  console.error('Call failed:', data.error);
});
```

### TypeScript Interfaces

```typescript
interface StartCallOptions {
  toNumber: string;      // Phone number to call (E.164 format)
  accessToken: string;   // Twilio Voice access token
}

interface MuteOptions {
  enabled: boolean;      // true to mute, false to unmute
}

interface SpeakerOptions {
  enabled: boolean;      // true for speaker on, false for speaker off
}

interface CallFailedEvent {
  error: string;         // Error message
}
```

## Platform Setup

### Android

The plugin handles most of the Android setup automatically, but you need to ensure proper permissions.

#### Required Permissions

The following permissions are automatically added by the plugin:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

#### Runtime Permissions

Request microphone permission before making calls:

```typescript
import { Permissions } from '@capacitor/core';

const result = await Permissions.query({ name: 'microphone' });
if (result.state !== 'granted') {
  await Permissions.request({ name: 'microphone' });
}
```

### iOS

#### Update Info.plist

Add the following to your app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access to make voice calls</string>
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
</array>
```

#### Install CocoaPods Dependencies

```bash
cd ios/App
pod install
cd ../..
```

## Getting Started

### 1. Generate Twilio Access Token

You must generate access tokens from your backend server. Never expose your Twilio credentials in client-side code.

**Backend Example (Node.js):**

```javascript
const twilio = require('twilio');

const accountSid = 'YOUR_ACCOUNT_SID';
const apiKey = 'YOUR_API_KEY';
const apiSecret = 'YOUR_API_SECRET';
const twimlAppSid = 'YOUR_TWIML_APP_SID';

function generateToken(identity) {
  const AccessToken = twilio.jwt.AccessToken;
  const VoiceGrant = AccessToken.VoiceGrant;

  const token = new AccessToken(accountSid, apiKey, apiSecret, {
    identity: identity,
    ttl: 3600
  });

  const voiceGrant = new VoiceGrant({
    outgoingApplicationSid: twimlAppSid,
    incomingAllow: true
  });

  token.addGrant(voiceGrant);

  return token.toJwt();
}
```

### 2. Implement in Your App

**Basic Example (TypeScript/Angular):**

```typescript
import { Component } from '@angular/core';
import { TwilioVoice } from 'capacitor-twilio-voice';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
})
export class HomePage {

  constructor() {
    this.setupEventListeners();
  }

  setupEventListeners() {
    TwilioVoice.addListener('callConnected', () => {
      console.log('Call connected!');
    });

    TwilioVoice.addListener('callDisconnected', () => {
      console.log('Call ended');
    });

    TwilioVoice.addListener('callFailed', (data) => {
      console.error('Call failed:', data.error);
    });
  }

  async makeCall() {
    // Fetch token from your server
    const response = await fetch('https://your-server.com/token');
    const { token } = await response.json();

    try {
      await TwilioVoice.startCall({
        toNumber: '+1234567890',
        accessToken: token
      });
    } catch (error) {
      console.error('Failed to start call:', error);
    }
  }
}
```

## Demo

For a complete working example, see the [demo/DEMO_STEPS.md](demo/DEMO_STEPS.md) file.

## Architecture

### Android Implementation

- **Language**: Kotlin
- **SDK**: Twilio Voice Android SDK 6.1.4
- **UI**: Dedicated `CallActivity` with custom layout
- **Audio**: Managed via `AudioManager` with proper focus handling
- **Permissions**: Runtime permission checks using Capacitor's permission system

### iOS Implementation

- **Language**: Swift
- **SDK**: Twilio Voice iOS SDK 6.8
- **UI**: Dedicated `CallViewController` with programmatic UI
- **CallKit**: Full CallKit integration for native iOS call experience
- **Audio**: AVAudioSession management with proper category settings

## Troubleshooting

### Common Issues

**Call fails immediately**
- Verify your access token is valid and not expired
- Check Twilio account balance
- Ensure phone number is in E.164 format (+1234567890)
- Review Twilio debugger logs in your console

**No audio during call**
- Ensure microphone permissions are granted
- Check device volume settings
- Verify Bluetooth devices aren't interfering

**CallKit not appearing (iOS)**
- Test on a physical device (CallKit doesn't work on simulator)
- Verify Info.plist permissions are set correctly
- Check that voip background mode is enabled

**Build errors**
- Run `npx cap sync` after installation
- Clean build folders (Android: `./gradlew clean`, iOS: Xcode > Product > Clean Build Folder)
- Ensure you're using Capacitor 8.0.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- GitHub Issues: https://github.com/avinashbhalki/capacitor-twilio-voice/issues

## Author

Avinash Bhalki

## Acknowledgments

- Built with [Capacitor](https://capacitorjs.com/)
- Powered by [Twilio Voice SDK](https://www.twilio.com/docs/voice/sdks)
