# @avinashbhalki/capacitor-twilio-voice

Production-ready Capacitor plugin for Twilio Voice SDK with native call UI for Android and iOS.

## Features

✅ **Native Call UI** - Full-screen call interface with mute, speaker, and end call buttons  
✅ **Twilio Voice SDK** - Latest Twilio Voice SDK integration for both platforms  
✅ **CallKit Support** - iOS CallKit integration for native call experience  
✅ **Audio Management** - Proper audio session and focus handling  
✅ **Event Listeners** - Real-time call state events  
✅ **Production Ready** - No TODOs, complete error handling, fully documented  

## Installation

```bash
npm install @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

## Platform Setup

### Android

#### 1. Add Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

#### 2. Minimum SDK Version

Ensure your `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 22
    }
}
```

### iOS

#### 1. Add Permissions

Add the following to your `ios/App/App/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice calls</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

#### 2. Install Pods

```bash
cd ios/App
pod install
```

## Usage

### Basic Example

```typescript
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';

// Start a call
async function makeCall() {
  try {
    await TwilioVoice.startCall({
      toNumber: '+1234567890',
      accessToken: 'your-twilio-access-token',
      fromNumber: '+0987654321' // Optional
    });
    console.log('Call initiated');
  } catch (error) {
    console.error('Failed to start call:', error);
  }
}

// End the call
async function endCall() {
  try {
    await TwilioVoice.endCall();
    console.log('Call ended');
  } catch (error) {
    console.error('Failed to end call:', error);
  }
}

// Mute/unmute
async function toggleMute(muted: boolean) {
  try {
    await TwilioVoice.setMute({ enabled: muted });
    console.log(`Microphone ${muted ? 'muted' : 'unmuted'}`);
  } catch (error) {
    console.error('Failed to toggle mute:', error);
  }
}

// Speaker on/off
async function toggleSpeaker(enabled: boolean) {
  try {
    await TwilioVoice.setSpeaker({ enabled });
    console.log(`Speaker ${enabled ? 'enabled' : 'disabled'}`);
  } catch (error) {
    console.error('Failed to toggle speaker:', error);
  }
}
```

### Event Listeners

```typescript
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';

// Listen for call connected
TwilioVoice.addListener('callConnected', () => {
  console.log('Call connected!');
});

// Listen for call disconnected
TwilioVoice.addListener('callDisconnected', () => {
  console.log('Call disconnected');
});

// Listen for call failed
TwilioVoice.addListener('callFailed', (event) => {
  console.error('Call failed:', event.error);
  console.error('Error code:', event.code);
});

// Remove all listeners when done
TwilioVoice.removeAllListeners();
```

### Complete Ionic/Angular Example

```typescript
import { Component } from '@angular/core';
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';

@Component({
  selector: 'app-call',
  templateUrl: './call.page.html',
})
export class CallPage {
  private accessToken = '';
  private isMuted = false;
  private isSpeakerOn = false;
  
  async ngOnInit() {
    // Get access token from your backend
    this.accessToken = await this.getAccessTokenFromBackend();
    
    // Setup event listeners
    this.setupCallListeners();
  }
  
  async getAccessTokenFromBackend(): Promise<string> {
    // Call your backend API to get Twilio access token
    const response = await fetch('https://your-api.com/twilio/token');
    const data = await response.json();
    return data.token;
  }
  
  setupCallListeners() {
    TwilioVoice.addListener('callConnected', () => {
      console.log('Call is now connected');
    });
    
    TwilioVoice.addListener('callDisconnected', () => {
      console.log('Call ended normally');
      this.resetCallState();
    });
    
    TwilioVoice.addListener('callFailed', (event) => {
      console.error('Call failed:', event.error);
      this.showError(event.error);
      this.resetCallState();
    });
  }
  
  async makeCall(phoneNumber: string) {
    try {
      await TwilioVoice.startCall({
        toNumber: phoneNumber,
        accessToken: this.accessToken,
        customParameters: {
          // Optional custom parameters for your TwiML
          customParam1: 'value1'
        }
      });
    } catch (error) {
      console.error('Error starting call:', error);
    }
  }
  
  async endCall() {
    try {
      await TwilioVoice.endCall();
    } catch (error) {
      console.error('Error ending call:', error);
    }
  }
  
  async toggleMute() {
    this.isMuted = !this.isMuted;
    try {
      await TwilioVoice.setMute({ enabled: this.isMuted });
    } catch (error) {
      console.error('Error toggling mute:', error);
      this.isMuted = !this.isMuted; // Revert on error
    }
  }
  
  async toggleSpeaker() {
    this.isSpeakerOn = !this.isSpeakerOn;
    try {
      await TwilioVoice.setSpeaker({ enabled: this.isSpeakerOn });
    } catch (error) {
      console.error('Error toggling speaker:', error);
      this.isSpeakerOn = !this.isSpeakerOn; // Revert on error
    }
  }
  
  resetCallState() {
    this.isMuted = false;
    this.isSpeakerOn = false;
  }
  
  showError(message: string) {
    // Show error to user (e.g., using Ionic toast)
    console.error(message);
  }
  
  ngOnDestroy() {
    TwilioVoice.removeAllListeners();
  }
}
```

## API Reference

### Methods

#### `startCall(options: StartCallOptions) => Promise<void>`

Start an outgoing call. Opens a full-screen native call UI.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `toNumber` | `string` | Yes | Phone number or SIP address to call |
| `accessToken` | `string` | Yes | Twilio access token |
| `fromNumber` | `string` | No | Caller ID (if supported by Twilio) |
| `customParameters` | `object` | No | Custom parameters for TwiML |

**Example:**

```typescript
await TwilioVoice.startCall({
  toNumber: '+1234567890',
  accessToken: 'your-token',
  fromNumber: '+0987654321',
  customParameters: {
    userId: '12345',
    callType: 'support'
  }
});
```

---

#### `endCall() => Promise<void>`

End the current active call. Automatically closes the call UI.

**Example:**

```typescript
await TwilioVoice.endCall();
```

---

#### `setMute(options: MuteOptions) => Promise<void>`

Mute or unmute the microphone during an active call.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `enabled` | `boolean` | Yes | `true` to mute, `false` to unmute |

**Example:**

```typescript
await TwilioVoice.setMute({ enabled: true }); // Mute
await TwilioVoice.setMute({ enabled: false }); // Unmute
```

---

#### `setSpeaker(options: SpeakerOptions) => Promise<void>`

Enable or disable speaker mode during an active call.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `enabled` | `boolean` | Yes | `true` for speaker, `false` for earpiece |

**Example:**

```typescript
await TwilioVoice.setSpeaker({ enabled: true }); // Speaker on
await TwilioVoice.setSpeaker({ enabled: false }); // Speaker off
```

---

### Events

#### `callConnected`

Fired when the call is successfully connected.

```typescript
TwilioVoice.addListener('callConnected', () => {
  console.log('Call connected');
});
```

---

#### `callDisconnected`

Fired when the call is disconnected normally.

```typescript
TwilioVoice.addListener('callDisconnected', () => {
  console.log('Call ended');
});
```

---

#### `callFailed`

Fired when the call fails to connect or disconnects with an error.

**Event Data:**

| Property | Type | Description |
|----------|------|-------------|
| `error` | `string` | Error message |
| `code` | `number` | Error code (optional) |

```typescript
TwilioVoice.addListener('callFailed', (event) => {
  console.error('Call failed:', event.error);
  console.error('Error code:', event.code);
});
```

## Call UI

The plugin automatically displays a full-screen native call UI when `startCall()` is invoked.

### UI Features

- **Call Status** - Shows current call state (Calling, Ringing, Connected)
- **Phone Number** - Displays the number being called
- **Call Duration** - Shows elapsed time once connected
- **Mute Button** - Toggle microphone on/off
- **Speaker Button** - Switch between earpiece and speaker
- **End Call Button** - Disconnect the call

### UI Behavior

- The call UI opens automatically when a call starts
- The UI closes automatically when:
  - Call is disconnected
  - Call fails
  - User presses the end call button
- Back button is disabled during calls (Android)
- UI is locked to portrait orientation (Android)

## Getting Twilio Access Token

You need to generate Twilio access tokens from your backend server. Here's a Node.js example:

```javascript
const twilio = require('twilio');

const AccessToken = twilio.jwt.AccessToken;
const VoiceGrant = AccessToken.VoiceGrant;

function generateToken(identity) {
  const accountSid = 'your_account_sid';
  const apiKey = 'your_api_key';
  const apiSecret = 'your_api_secret';
  const outgoingApplicationSid = 'your_twiml_app_sid';

  const voiceGrant = new VoiceGrant({
    outgoingApplicationSid: outgoingApplicationSid,
    incomingAllow: true,
  });

  const token = new AccessToken(accountSid, apiKey, apiSecret, {
    identity: identity,
  });
  
  token.addGrant(voiceGrant);

  return token.toJwt();
}

// Express endpoint example
app.get('/twilio/token', (req, res) => {
  const identity = req.user.id; // Your user identifier
  const token = generateToken(identity);
  res.json({ token });
});
```

## Troubleshooting

### Android

**Issue:** Call UI doesn't appear  
**Solution:** Ensure all permissions are added to AndroidManifest.xml

**Issue:** Audio not working  
**Solution:** Check RECORD_AUDIO permission is granted at runtime

**Issue:** Build fails  
**Solution:** Ensure minSdkVersion is at least 22

### iOS

**Issue:** Microphone permission denied  
**Solution:** Add NSMicrophoneUsageDescription to Info.plist

**Issue:** Pod install fails  
**Solution:** Run `pod repo update` and try again

**Issue:** Audio session error  
**Solution:** Ensure UIBackgroundModes includes 'audio' and 'voip'

## Requirements

- **Capacitor:** 6.0.0 or higher
- **Android:** API 22+ (Android 5.1+)
- **iOS:** iOS 13.0+
- **Twilio Voice SDK:**
  - Android: 6.1.3
  - iOS: 6.9.0

## License

MIT

## Support

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/avinashbhalki/capacitor-twilio-voice/issues).

## Credits

Created by Avinash Bhalki

---

**Note:** This plugin requires a valid Twilio account and proper TwiML configuration. Refer to [Twilio Voice documentation](https://www.twilio.com/docs/voice) for more information.