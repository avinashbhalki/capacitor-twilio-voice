# Quick Start Guide

## For Plugin Developers (You)

### Publishing to NPM

```bash
# 1. Verify you're logged in to npm
npm whoami

# 2. If not logged in, log in
npm login

# 3. Publish the package
npm publish --access public
```

### Local Testing (Before Publishing)

```bash
# In the plugin directory
npm link

# In your test Ionic/Capacitor app
cd /path/to/your/ionic/app
npm link @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

---

## For Plugin Users

### Installation

```bash
npm install @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

### Android Setup

1. Ensure Java 17:
```bash
java -version  # Should show version 17
```

2. Update `android/build.gradle` if needed:
```gradle
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
```

### iOS Setup

1. Add to `Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for voice calls</string>
```

2. Install pods:
```bash
cd ios/App
pod install
```

3. In Xcode: Add Background Modes capability
   - ✅ Audio, AirPlay, and Picture in Picture
   - ✅ Voice over IP

### Basic Usage

```typescript
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';

async function makeCall() {
  try {
    await TwilioVoice.call({
      to: '+1234567890',
      accessToken: 'YOUR_TWILIO_TOKEN'
    });
  } catch (error) {
    console.error('Call failed:', error);
  }
}
```

---

## Token Server Example

```javascript
// server.js
const express = require('express');
const twilio = require('twilio');

const app = express();
app.use(express.json());

app.post('/token', (req, res) => {
  const AccessToken = twilio.jwt.AccessToken;
  const VoiceGrant = AccessToken.VoiceGrant;

  const token = new AccessToken(
    process.env.TWILIO_ACCOUNT_SID,
    process.env.TWILIO_API_KEY,
    process.env.TWILIO_API_SECRET,
    { identity: req.body.identity }
  );

  const voiceGrant = new VoiceGrant({
    outgoingApplicationSid: process.env.TWILIO_TWIML_APP_SID,
    incomingAllow: true
  });

  token.addGrant(voiceGrant);
  res.json({ token: token.toJwt() });
});

app.listen(3000);
```

---

## Testing

### Android
```bash
npx cap run android
```

### iOS
```bash
npx cap run ios
```

---

## What Happens When You Call

1. Permission check (microphone, audio)
2. Native screen opens (full screen)
3. Twilio connection initiated
4. Status updates: Connecting → Ringing → Connected
5. Controls enabled: Mute, Speaker, End Call
6. On disconnect: Screen auto-closes

---

## File Structure Created

```
✅ TypeScript source (src/)
✅ Android native code (android/)
✅ iOS native code (ios/)
✅ Build output (dist/)
✅ Documentation (README.md, DEMO.md)
✅ Package config (package.json)
✅ Git config (.gitignore)
✅ NPM config (.npmignore)
```

---

## Support

- Issues: https://github.com/avinashbhalki/capacitor-twilio-voice/issues
- Twilio Docs: https://www.twilio.com/docs/voice
- Capacitor Docs: https://capacitorjs.com/docs

---

**Ready to go! 🚀**
