# @avinashbhalki/capacitor-twilio-voice

A Capacitor plugin for Twilio Voice with native UI support for Android and iOS.

## Features

- ✅ Native call UI for both Android and iOS
- ✅ Mute/Unmute functionality
- ✅ Speaker toggle
- ✅ End call button
- ✅ Automatic screen dismissal on call end
- ✅ CallKit integration on iOS
- ✅ Proper permission handling
- ✅ Twilio Voice SDK integration

## Installation

```bash
npm install @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅        |
| iOS      | ✅        |
| Web      | ❌        |

## API

### `call(options: CallOptions): Promise<void>`

Initiates a Twilio Voice call with a native UI.

#### Parameters

- **options.to** (string): The phone number to call (E.164 format recommended)
- **options.accessToken** (string): Twilio Access Token for authentication

#### Example

```typescript
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';

try {
  await TwilioVoice.call({
    to: '+919999999999',
    accessToken: 'YOUR_TWILIO_ACCESS_TOKEN'
  });
  console.log('Call initiated successfully');
} catch (error) {
  console.error('Failed to initiate call:', error);
}
```

## Android Setup

### 1. Update `AndroidManifest.xml`

The plugin automatically handles permissions and activity registration, but make sure your app's `AndroidManifest.xml` doesn't conflict with these permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. Java/Kotlin Version

Ensure your app uses Java 17. Update `android/build.gradle`:

```gradle
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}
```

### 3. Minimum SDK

The plugin requires minimum SDK 23. Update in `android/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 23
    }
}
```

## iOS Setup

### 1. Update `Info.plist`

Add microphone usage description to your app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice calls</string>
```

### 2. Install Pods

```bash
cd ios/App
pod install
```

### 3. Enable Background Modes in Xcode (CRITICAL)

This step **must** be done manually in Xcode to avoid "CallKit Error 1":

1. Open `ios/App/App.xcworkspace` in Xcode.
2. Select your **App Target** in the project navigator.
3. Click on the **Signing & Capabilities** tab.
4. Click the **+ Capability** button in the top left.
5. Search for and add **Background Modes**.
6. Check the following boxes:
   - ✅ **Audio, AirPlay, and Picture in Picture**
   - ✅ **Voice over IP**

> **Note**: Without these modes enabled, CallKit will reject the call transaction as an "Invalid Action" (Error 1).

## How to Get Twilio Access Token

You need a server-side implementation to generate Twilio Access Tokens. Here's a basic example:

### Node.js Example

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

## Troubleshooting

### Android

**Issue**: Build fails with "Duplicate class" error
- **Solution**: Make sure you're using the correct Capacitor version (8.0.0)

**Issue**: Call doesn't connect
- **Solution**: Check that you have internet connectivity and valid Twilio credentials

### iOS

**Issue**: "Microphone permission denied"
- **Solution**: Make sure `NSMicrophoneUsageDescription` is added to Info.plist

**Issue**: Audio not working
- **Solution**: Check that Background Modes are properly configured

## License

MIT

## Author

Avinash Bhalki

## Repository

https://github.com/avinashbhalki/capacitor-twilio-voice
