# DEMO: Using @avinashbhalki/capacitor-twilio-voice in an Ionic + Capacitor App

This guide walks you through integrating the `@avinashbhalki/capacitor-twilio-voice` plugin into an Ionic + Capacitor application.

## Prerequisites

- Node.js (v16 or higher)
- Ionic CLI (`npm install -g @ionic/cli`)
- Capacitor CLI
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- Twilio Account with Voice API enabled

## Step 1: Create a New Ionic App (Optional)

If you don't have an existing Ionic app:

```bash
ionic start myTwilioApp blank --type=angular --capacitor
cd myTwilioApp
```

## Step 2: Install the Plugin

```bash
npm install @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

## Step 3: Add Platform Support

### For Android:

```bash
npx cap add android
```

### For iOS:

```bash
npx cap add ios
```

## Step 4: Android Setup

### 4.1 Update Build Configuration

Open `android/app/build.gradle` and ensure:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 23
        targetSdkVersion 34
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
```

### 4.2 Update Android Project Gradle

Open `android/build.gradle` and ensure you have:

```gradle
buildscript {
    ext {
        buildToolsVersion = "33.0.0"
        minSdkVersion = 23
        compileSdkVersion = 34
        targetSdkVersion = 34
    }
}
```

### 4.3 Permissions

The plugin automatically includes necessary permissions. Verify in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 4.4 Sync Gradle

```bash
cd android
./gradlew clean
./gradlew build
cd ..
```

## Step 5: iOS Setup

### 5.1 Update Info.plist

Open `ios/App/App/Info.plist` and add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice calls</string>
```

### 5.2 Install Pods

```bash
cd ios/App
pod install
cd ../..
```

### 5.3 Enable Background Modes in Xcode

1. Open `ios/App/App.xcworkspace` in Xcode
2. Select your app target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Background Modes"
6. Check:
   - ✅ Audio, AirPlay, and Picture in Picture
   - ✅ Voice over IP

## Step 6: Implement in Your Ionic App

### 6.1 Update Your Component

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
  
  phoneNumber: string = '+919999999999';
  accessToken: string = ''; // Get this from your backend

  constructor() {}

  async makeCall() {
    if (!this.accessToken) {
      alert('Please provide a valid Twilio Access Token');
      return;
    }

    try {
      await TwilioVoice.call({
        toNumber: this.phoneNumber,
        accessToken: this.accessToken
      });
      console.log('Call initiated successfully');
    } catch (error) {
      console.error('Failed to make call:', error);
      alert('Failed to make call: ' + error);
    }
  }

  // Call your backend to get the access token
  async getAccessToken() {
    try {
      const response = await fetch('YOUR_BACKEND_URL/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ identity: 'user123' })
      });
      
      const data = await response.json();
      this.accessToken = data.token;
    } catch (error) {
      console.error('Failed to get access token:', error);
    }
  }
}
```

### 6.2 Update Your Template

Edit `src/app/home/home.page.html`:

```html
<ion-header>
  <ion-toolbar>
    <ion-title>
      Twilio Voice Demo
    </ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <ion-card>
    <ion-card-header>
      <ion-card-title>Make a Call</ion-card-title>
    </ion-card-header>
    
    <ion-card-content>
      <ion-item>
        <ion-label position="stacked">Phone Number</ion-label>
        <ion-input 
          [(ngModel)]="phoneNumber" 
          type="tel"
          placeholder="+1234567890">
        </ion-input>
      </ion-item>
      
      <ion-item>
        <ion-label position="stacked">Access Token</ion-label>
        <ion-input 
          [(ngModel)]="accessToken" 
          type="text"
          placeholder="Twilio Access Token">
        </ion-input>
      </ion-item>
      
      <ion-button 
        expand="block" 
        (click)="getAccessToken()"
        class="ion-margin-top">
        Get Token from Server
      </ion-button>
      
      <ion-button 
        expand="block" 
        color="success"
        (click)="makeCall()"
        class="ion-margin-top">
        <ion-icon slot="start" name="call"></ion-icon>
        Make Call
      </ion-button>
    </ion-card-content>
  </ion-card>
</ion-content>
```

### 6.3 Update Module

Edit `src/app/home/home.module.ts` to include FormsModule:

```typescript
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule } from '@ionic/angular';
import { HomePageRoutingModule } from './home-routing.module';
import { HomePage } from './home.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    HomePageRoutingModule
  ],
  declarations: [HomePage]
})
export class HomePageModule {}
```

## Step 7: Backend Setup for Access Token

You need a backend server to generate Twilio Access Tokens. Here's an example using Node.js + Express:

### 7.1 Install Dependencies

```bash
npm install twilio express cors
```

### 7.2 Create Token Server (server.js)

```javascript
const express = require('express');
const twilio = require('twilio');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Twilio credentials (use environment variables in production!)
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const apiKey = process.env.TWILIO_API_KEY;
const apiSecret = process.env.TWILIO_API_SECRET;
const twimlAppSid = process.env.TWILIO_TWIML_APP_SID;

app.post('/token', (req, res) => {
  const identity = req.body.identity || 'user';
  
  const AccessToken = twilio.jwt.AccessToken;
  const VoiceGrant = AccessToken.VoiceGrant;

  const token = new AccessToken(accountSid, apiKey, apiSecret, {
    identity: identity,
    ttl: 3600 // 1 hour
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Token server listening on port ${PORT}`);
});
```

### 7.3 Run Token Server

```bash
export TWILIO_ACCOUNT_SID=your_account_sid
export TWILIO_API_KEY=your_api_key
export TWILIO_API_SECRET=your_api_secret
export TWILIO_TWIML_APP_SID=your_twiml_app_sid

node server.js
```

## Step 8: Test the App

### For Android:

```bash
npx cap run android
```

Or open in Android Studio:

```bash
npx cap open android
```

### For iOS:

```bash
npx cap run ios
```

Or open in Xcode:

```bash
npx cap open ios
```

## Step 9: Build for Production

### Android:

```bash
cd android
./gradlew assembleRelease
```

The APK will be in `android/app/build/outputs/apk/release/`

### iOS:

1. Open project in Xcode: `npx cap open ios`
2. Select "Any iOS Device" as target
3. Product → Archive
4. Follow the distribution wizard

## Expected Behavior

When you call `TwilioVoice.call()`:

1. **Permission Check**: App requests microphone/audio permissions (if not granted)
2. **Native Screen Opens**: A full-screen native UI appears
3. **Call Status**: Shows "Connecting..." → "Ringing..." → "Connected"
4. **Controls Available**:
   - 🎙️ Mute/Unmute button
   - 🔊 Speaker on/off button
   - 📞 End call button (red)
5. **Auto-Dismiss**: Screen automatically closes when call ends or fails

## Twilio Console Setup

1. **Sign up** at https://www.twilio.com/console
2. **Create a TwiML App**:
   - Console → Voice → TwiML Apps → Create new
   - Set Voice URL to your server endpoint
3. **Get API Keys**:
   - Console → Account → API Keys → Create API Key
4. **Note down**:
   - Account SID
   - API Key SID
   - API Secret
   - TwiML App SID

## Troubleshooting

### "Module not found" Error

```bash
npm install
npx cap sync
```

### Android Build Fails

- Check Java version: `java -version` (should be 17)
- Clean and rebuild: `cd android && ./gradlew clean build`

### iOS Build Fails

- Run `pod install` in `ios/App/`
- Clean build folder in Xcode: Product → Clean Build Folder

### Call Doesn't Connect

- Verify access token is valid
- Check Twilio console for errors
- Ensure phone number is in E.164 format (+1234567890)

## Next Steps

- Implement error handling
- Add call history
- Implement incoming call handling
- Add call recording
- Integrate with your user authentication system

## Support

For issues and questions:
- GitHub: https://github.com/avinashbhalki/capacitor-twilio-voice/issues
- Twilio Docs: https://www.twilio.com/docs/voice

---

**Happy Coding! 🚀**
