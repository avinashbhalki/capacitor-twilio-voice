# Twilio Voice Capacitor Plugin - Demo Setup Guide

This guide provides step-by-step instructions for integrating and testing the `capacitor-twilio-voice` plugin in your Ionic/Capacitor application.

## Prerequisites

Before you begin, ensure you have:

- Node.js (v14 or later) and npm installed
- Ionic CLI installed (`npm install -g @ionic/cli`)
- Capacitor CLI installed (`npm install -g @capacitor/cli`)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- A Twilio account with Voice API access
- Physical devices for testing (VoIP features don't work reliably on simulators/emulators)

## 1. Create a New Ionic Capacitor Project

If you don't have an existing project, create one:

```bash
ionic start TwilioVoiceDemo blank --type=angular --capacitor
cd TwilioVoiceDemo
```

## 2. Install the Capacitor Twilio Voice Plugin

Install the plugin from npm:

```bash
npm install capacitor-twilio-voice
```

## 3. Sync Capacitor

Run the following command to sync the plugin with your native projects:

```bash
npx cap sync
```

This command will:
- Copy the plugin to the Android and iOS projects
- Update native dependencies
- Generate necessary configuration files

## 4. Android Setup

### 4.1 Update Android Permissions

The plugin automatically adds required permissions, but ensure your app's `AndroidManifest.xml` includes:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.INTERNET" />
```

These are already declared in the plugin's manifest and will be merged automatically.

### 4.2 Request Runtime Permissions

In your app, request microphone permission before making calls:

```typescript
import { Plugins } from '@capacitor/core';
const { Permissions } = Plugins;

async requestMicrophonePermission() {
  const result = await Permissions.query({ name: 'microphone' });

  if (result.state !== 'granted') {
    await Permissions.request({ name: 'microphone' });
  }
}
```

### 4.3 Build and Run on Android

```bash
npx cap open android
```

Build and run from Android Studio on a physical Android device.

## 5. iOS Setup

### 5.1 Update Info.plist

Open `ios/App/App/Info.plist` and add the following permissions:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access to make voice calls</string>
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
</array>
```

### 5.2 Install iOS Dependencies

```bash
cd ios/App
pod install
cd ../..
```

### 5.3 Build and Run on iOS

```bash
npx cap open ios
```

Build and run from Xcode on a physical iOS device.

## 6. Generate Twilio Access Token

To make calls with Twilio Voice, you need to generate an access token from your server.

### 6.1 Backend Setup (Node.js Example)

Create a simple Node.js server to generate access tokens:

```javascript
// server.js
const express = require('express');
const twilio = require('twilio');

const app = express();

// Your Twilio credentials
const accountSid = 'YOUR_ACCOUNT_SID';
const apiKey = 'YOUR_API_KEY';
const apiSecret = 'YOUR_API_SECRET';
const twimlAppSid = 'YOUR_TWIML_APP_SID';

app.get('/token', (req, res) => {
  const identity = req.query.identity || 'user';

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

  res.json({
    identity: identity,
    token: token.toJwt()
  });
});

app.listen(3000, () => {
  console.log('Token server running on port 3000');
});
```

Install dependencies and run the server:

```bash
npm install express twilio
node server.js
```

### 6.2 Get Twilio Credentials

1. Sign up for a Twilio account at https://www.twilio.com/
2. Get your Account SID from the Twilio Console
3. Create an API Key in Console > Account > API Keys
4. Create a TwiML App in Console > Voice > TwiML Apps
5. Configure the TwiML App with a Request URL (your webhook endpoint)

## 7. Implement Voice Calling in Your App

### 7.1 Import the Plugin

In your component (e.g., `home.page.ts`):

```typescript
import { Component } from '@angular/core';
import { TwilioVoice } from 'capacitor-twilio-voice';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  private accessToken: string = '';

  constructor() {
    this.setupEventListeners();
  }

  async ngOnInit() {
    // Fetch access token from your server
    await this.fetchAccessToken();
  }

  async fetchAccessToken() {
    try {
      const response = await fetch('http://localhost:3000/token?identity=user123');
      const data = await response.json();
      this.accessToken = data.token;
      console.log('Access token obtained');
    } catch (error) {
      console.error('Failed to fetch access token:', error);
    }
  }

  setupEventListeners() {
    // Listen for call connected event
    TwilioVoice.addListener('callConnected', () => {
      console.log('Call connected!');
      alert('Call connected!');
    });

    // Listen for call disconnected event
    TwilioVoice.addListener('callDisconnected', () => {
      console.log('Call disconnected');
      alert('Call disconnected');
    });

    // Listen for call failed event
    TwilioVoice.addListener('callFailed', (data) => {
      console.error('Call failed:', data.error);
      alert(`Call failed: ${data.error}`);
    });
  }

  async makeCall() {
    if (!this.accessToken) {
      alert('Access token not available. Please try again.');
      return;
    }

    const phoneNumber = '+1234567890'; // Replace with actual phone number

    try {
      await TwilioVoice.startCall({
        toNumber: phoneNumber,
        accessToken: this.accessToken
      });

      console.log('Call initiated');
    } catch (error) {
      console.error('Failed to start call:', error);
      alert('Failed to start call');
    }
  }

  async endCall() {
    try {
      await TwilioVoice.endCall();
      console.log('Call ended');
    } catch (error) {
      console.error('Failed to end call:', error);
    }
  }

  async toggleMute(enabled: boolean) {
    try {
      await TwilioVoice.setMute({ enabled });
      console.log(`Mute ${enabled ? 'enabled' : 'disabled'}`);
    } catch (error) {
      console.error('Failed to toggle mute:', error);
    }
  }

  async toggleSpeaker(enabled: boolean) {
    try {
      await TwilioVoice.setSpeaker({ enabled });
      console.log(`Speaker ${enabled ? 'enabled' : 'disabled'}`);
    } catch (error) {
      console.error('Failed to toggle speaker:', error);
    }
  }
}
```

### 7.2 Update the Template

In your template (e.g., `home.page.html`):

```html
<ion-header>
  <ion-toolbar>
    <ion-title>Twilio Voice Demo</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <h2>Twilio Voice Call Demo</h2>

  <ion-item>
    <ion-label position="floating">Phone Number (E.164 format)</ion-label>
    <ion-input type="tel" [(ngModel)]="phoneNumber" placeholder="+1234567890"></ion-input>
  </ion-item>

  <ion-button expand="block" (click)="makeCall()" color="primary">
    <ion-icon name="call" slot="start"></ion-icon>
    Start Call
  </ion-button>

  <ion-button expand="block" (click)="endCall()" color="danger">
    <ion-icon name="call" slot="start"></ion-icon>
    End Call
  </ion-button>

  <h3>Call Controls (During Active Call)</h3>

  <ion-button expand="block" (click)="toggleMute(true)">
    Mute
  </ion-button>

  <ion-button expand="block" (click)="toggleMute(false)">
    Unmute
  </ion-button>

  <ion-button expand="block" (click)="toggleSpeaker(true)">
    Speaker On
  </ion-button>

  <ion-button expand="block" (click)="toggleSpeaker(false)">
    Speaker Off
  </ion-button>
</ion-content>
```

## 8. Testing the Demo

### 8.1 On Android Device

1. Connect your Android device via USB
2. Enable USB debugging on the device
3. Run: `npx cap run android`
4. Grant microphone permission when prompted
5. Enter a valid phone number (E.164 format, e.g., +1234567890)
6. Tap "Start Call"
7. A native call UI should appear
8. Test mute, speaker, and end call buttons

### 8.2 On iOS Device

1. Connect your iOS device via USB
2. Open the project in Xcode: `npx cap open ios`
3. Select your device as the build target
4. Configure signing in Xcode (use your Apple Developer account)
5. Build and run the app
6. Grant microphone permission when prompted
7. Enter a valid phone number
8. Tap "Start Call"
9. A native call UI with CallKit integration should appear
10. Test mute, speaker, and end call buttons

## 9. Troubleshooting

### Common Issues

**Issue: "Access token not available"**
- Ensure your token server is running and accessible
- Check network connectivity
- Verify Twilio credentials in your server

**Issue: "Call failed"**
- Verify the phone number is in E.164 format (+1234567890)
- Check your Twilio account balance
- Ensure your TwiML App is configured correctly
- Check Twilio debugger logs in the console

**Issue: "Microphone permission denied"**
- Go to device Settings > Apps > Your App > Permissions
- Enable microphone permission manually
- Restart the app

**Issue: CallKit not working on iOS**
- Ensure you're testing on a physical device (not simulator)
- Check Info.plist has microphone and background mode permissions
- Verify the app is signed with a valid provisioning profile

## 10. Production Considerations

### Security
- Never hardcode access tokens in your app
- Always generate tokens from a secure backend server
- Implement token expiration and refresh mechanisms
- Use HTTPS for all token requests

### Best Practices
- Implement proper error handling for all call states
- Add loading indicators during call connection
- Handle network interruptions gracefully
- Test on various devices and network conditions
- Monitor call quality and log issues

### Twilio Account Setup
- Set up proper call routing in your TwiML App
- Configure webhooks for call status callbacks
- Set up error notifications
- Monitor usage and billing

## 11. Additional Resources

- [Twilio Voice SDK Documentation](https://www.twilio.com/docs/voice/sdks)
- [Capacitor Plugin Documentation](https://capacitorjs.com/docs/plugins)
- [Twilio Access Token Generation](https://www.twilio.com/docs/iam/access-tokens)
- [CallKit Documentation (iOS)](https://developer.apple.com/documentation/callkit)

## Support

For issues with the plugin, please visit:
https://github.com/avinashbhalki/capacitor-twilio-voice/issues
