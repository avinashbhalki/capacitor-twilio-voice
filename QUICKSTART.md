# Quick Start Guide - Capacitor Twilio Voice Plugin

Get up and running with Twilio Voice calls in your Capacitor app in under 10 minutes!

## Prerequisites

- Node.js 14+ installed
- Ionic CLI installed: `npm install -g @ionic/cli`
- Twilio account with Voice capabilities
- Android Studio (for Android) or Xcode (for iOS)

## Step 1: Create a New Ionic App (Optional)

If you don't have an existing app:

```bash
ionic start my-voice-app blank --type=angular --capacitor
cd my-voice-app
```

## Step 2: Install the Plugin

```bash
npm install @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

## Step 3: Configure Android

### Add Permissions

Edit `android/app/src/main/AndroidManifest.xml` and add:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

## Step 4: Configure iOS

### Add Permissions

Edit `ios/App/App/Info.plist` and add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice calls</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

### Install Pods

```bash
cd ios/App
pod install
cd ../..
```

## Step 5: Set Up Twilio Backend

Create a simple Node.js server to generate access tokens:

```javascript
// server.js
const express = require('express');
const twilio = require('twilio');

const app = express();

const AccessToken = twilio.jwt.AccessToken;
const VoiceGrant = AccessToken.VoiceGrant;

// Your Twilio credentials (from Twilio Console)
const accountSid = 'YOUR_ACCOUNT_SID';
const apiKey = 'YOUR_API_KEY';
const apiSecret = 'YOUR_API_SECRET';
const twimlAppSid = 'YOUR_TWIML_APP_SID';

app.get('/token', (req, res) => {
  const identity = 'user-' + Date.now();
  
  const voiceGrant = new VoiceGrant({
    outgoingApplicationSid: twimlAppSid,
    incomingAllow: true,
  });

  const token = new AccessToken(accountSid, apiKey, apiSecret, {
    identity: identity,
  });
  
  token.addGrant(voiceGrant);

  res.json({ token: token.toJwt() });
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

Install dependencies and run:

```bash
npm install express twilio
node server.js
```

## Step 6: Add Call Functionality to Your App

Edit `src/app/home/home.page.ts`:

```typescript
import { Component } from '@angular/core';
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  phoneNumber = '';

  constructor() {
    this.setupListeners();
  }

  setupListeners() {
    TwilioVoice.addListener('callConnected', () => {
      console.log('✅ Call connected!');
    });

    TwilioVoice.addListener('callDisconnected', () => {
      console.log('📞 Call ended');
    });

    TwilioVoice.addListener('callFailed', (event) => {
      console.error('❌ Call failed:', event.error);
    });
  }

  async makeCall() {
    try {
      // Get token from your backend
      const response = await fetch('http://localhost:3000/token');
      const data = await response.json();

      // Start the call
      await TwilioVoice.startCall({
        toNumber: this.phoneNumber,
        accessToken: data.token
      });

      console.log('📱 Call initiated');
    } catch (error) {
      console.error('Error:', error);
    }
  }

  async endCall() {
    await TwilioVoice.endCall();
  }
}
```

Edit `src/app/home/home.page.html`:

```html
<ion-header>
  <ion-toolbar>
    <ion-title>Twilio Voice</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <ion-item>
    <ion-label position="floating">Phone Number</ion-label>
    <ion-input 
      type="tel" 
      [(ngModel)]="phoneNumber"
      placeholder="+1234567890">
    </ion-input>
  </ion-item>

  <ion-button 
    expand="block" 
    (click)="makeCall()" 
    class="ion-margin-top"
    color="success">
    <ion-icon name="call" slot="start"></ion-icon>
    Make Call
  </ion-button>

  <ion-button 
    expand="block" 
    (click)="endCall()" 
    class="ion-margin-top"
    color="danger">
    <ion-icon name="call" slot="start"></ion-icon>
    End Call
  </ion-button>
</ion-content>
```

Don't forget to import FormsModule in `src/app/home/home.module.ts`:

```typescript
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,  // Add this
    IonicModule,
    HomePageRoutingModule
  ],
  declarations: [HomePage]
})
export class HomePageModule {}
```

## Step 7: Run Your App

### Android

```bash
ionic cap run android
```

### iOS

```bash
ionic cap run ios
```

## Step 8: Make Your First Call!

1. Enter a phone number (e.g., +1234567890)
2. Tap "Make Call"
3. The native call UI will appear
4. Use the mute, speaker, and end call buttons

## What Happens When You Call?

1. **App requests token** from your backend
2. **Plugin initiates call** using Twilio Voice SDK
3. **Native UI appears** with call controls
4. **Call connects** and you can talk
5. **Events fire** (callConnected, etc.)
6. **UI auto-closes** when call ends

## Troubleshooting

### "Permission denied" on Android
- Make sure you added all permissions to AndroidManifest.xml
- Grant microphone permission when prompted

### "Token error"
- Verify your Twilio credentials in server.js
- Make sure your backend server is running
- Check that you created a TwiML App in Twilio Console

### "No audio" on iOS
- Ensure Info.plist has NSMicrophoneUsageDescription
- Grant microphone permission when prompted
- Check that UIBackgroundModes includes 'audio'

### Call UI doesn't appear
- Make sure you ran `npx cap sync`
- Clean and rebuild the native project
- Check console for errors

## Next Steps

- ✅ Add mute/speaker controls in your UI
- ✅ Implement incoming call handling
- ✅ Add call history
- ✅ Customize the call UI
- ✅ Deploy your backend to production

## Production Checklist

Before going to production:

- [ ] Move Twilio credentials to environment variables
- [ ] Add authentication to your token endpoint
- [ ] Use HTTPS for your backend
- [ ] Implement proper error handling
- [ ] Test on real devices
- [ ] Configure TwiML for your use case
- [ ] Set up Twilio phone numbers
- [ ] Review Twilio pricing
- [ ] Add analytics/logging

## Getting Help

- 📖 [Full Documentation](./README.md)
- 💡 [Examples](./EXAMPLE.md)
- 🐛 [Report Issues](https://github.com/avinashbhalki/capacitor-twilio-voice/issues)
- 📚 [Twilio Docs](https://www.twilio.com/docs/voice)

## Congratulations! 🎉

You now have a working Twilio Voice integration in your Capacitor app!

---

**Time to first call**: ~10 minutes ⚡
