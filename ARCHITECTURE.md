# Plugin Architecture

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Ionic/Capacitor App                      │
│                     (TypeScript/JavaScript)                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Import & Use
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              @avinashbhalki/capacitor-twilio-voice          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  src/index.ts (Plugin Registration)                  │  │
│  │  src/definitions.ts (TypeScript Interfaces)          │  │
│  └─────────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌──────────────────┐          ┌──────────────────┐
│   Android        │          │      iOS         │
│   (Kotlin)       │          │    (Swift)       │
└──────────────────┘          └──────────────────┘
```

## Detailed Architecture

### Layer 1: JavaScript/TypeScript Interface

```typescript
// src/definitions.ts
export interface TwilioVoicePlugin {
  startCall(options: StartCallOptions): Promise<void>;
  endCall(): Promise<void>;
  setMute(options: MuteOptions): Promise<void>;
  setSpeaker(options: SpeakerOptions): Promise<void>;
  addListener(event, callback): Promise<PluginListenerHandle>;
}

// src/index.ts
const TwilioVoice = registerPlugin<TwilioVoicePlugin>('TwilioVoice');
```

### Layer 2: Capacitor Bridge

```
JavaScript Call → Capacitor Bridge → Native Platform
                                    ↓
                        ┌───────────┴───────────┐
                        │                       │
                    Android                   iOS
```

### Layer 3: Native Implementation

#### Android Stack

```
TwilioVoicePlugin.kt
    ├── @PluginMethod startCall()
    │   ├── Check permissions
    │   ├── Create ConnectOptions
    │   ├── Voice.connect()
    │   └── Launch CallActivity
    │
    ├── @PluginMethod endCall()
    │   └── activeCall.disconnect()
    │
    ├── @PluginMethod setMute()
    │   └── activeCall.mute()
    │
    ├── @PluginMethod setSpeaker()
    │   └── AudioManager.setSpeakerphoneOn()
    │
    └── CallListener
        ├── onConnected() → notifyListeners("callConnected")
        ├── onDisconnected() → notifyListeners("callDisconnected")
        └── onConnectFailure() → notifyListeners("callFailed")

CallActivity.kt
    ├── UI Components
    │   ├── tvCallStatus (TextView)
    │   ├── tvPhoneNumber (TextView)
    │   ├── tvCallDuration (TextView)
    │   ├── btnMute (ImageButton)
    │   ├── btnSpeaker (ImageButton)
    │   └── btnEndCall (ImageButton)
    │
    ├── Audio Management
    │   └── AudioManager (MODE_IN_COMMUNICATION)
    │
    └── Call State Monitoring
        └── Handler with Runnable (duration timer)
```

#### iOS Stack

```
TwilioVoicePlugin.swift
    ├── @objc startCall()
    │   ├── Configure AVAudioSession
    │   ├── Create ConnectOptions
    │   ├── TwilioVoiceSDK.connect()
    │   └── Present CallViewController
    │
    ├── @objc endCall()
    │   └── activeCall.disconnect()
    │
    ├── @objc setMute()
    │   └── activeCall.isMuted = enabled
    │
    ├── @objc setSpeaker()
    │   └── AVAudioSession.overrideOutputAudioPort()
    │
    └── CallDelegate
        ├── callDidConnect() → notifyListeners("callConnected")
        ├── callDidDisconnect() → notifyListeners("callDisconnected")
        └── callDidFailToConnect() → notifyListeners("callFailed")

CallViewController.swift
    ├── UI Components
    │   ├── callStatusLabel (UILabel)
    │   ├── phoneNumberLabel (UILabel)
    │   ├── durationLabel (UILabel)
    │   ├── muteButton (UIButton)
    │   ├── speakerButton (UIButton)
    │   └── endCallButton (UIButton)
    │
    ├── Audio Management
    │   └── AVAudioSession
    │
    └── Call State Monitoring
        └── Timer (duration updates)
```

## Data Flow

### Starting a Call

```
1. User Action
   └─> App calls TwilioVoice.startCall({...})

2. JavaScript Layer
   └─> Capacitor serializes parameters

3. Capacitor Bridge
   └─> Routes to native platform

4. Native Plugin
   ├─> Android: TwilioVoicePlugin.startCall()
   └─> iOS: TwilioVoicePlugin.startCall()

5. Twilio SDK
   ├─> Android: Voice.connect(connectOptions)
   └─> iOS: TwilioVoiceSDK.connect(options)

6. Native UI
   ├─> Android: Launch CallActivity
   └─> iOS: Present CallViewController

7. Call Events
   └─> Native → Capacitor Bridge → JavaScript
       ├─> callConnected
       ├─> callDisconnected
       └─> callFailed
```

### Call State Management

```
┌─────────────────────────────────────────────────┐
│              Call State Machine                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  IDLE → CONNECTING → RINGING → CONNECTED       │
│           │            │          │             │
│           └────────────┴──────────┴→ DISCONNECTED
│                                                 │
│  Events:                                        │
│  • CONNECTING: UI shows "Calling..."            │
│  • RINGING: UI shows "Ringing..."               │
│  • CONNECTED: Start duration timer              │
│  • DISCONNECTED: Close UI, cleanup              │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Component Interaction

### Android

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ MainActivity │───▶│TwilioVoice   │───▶│ Twilio Voice │
│   (Ionic)    │    │Plugin.kt     │    │   SDK        │
└──────────────┘    └──────┬───────┘    └──────┬───────┘
                           │                    │
                           │                    │
                           ▼                    ▼
                    ┌──────────────┐    ┌──────────────┐
                    │ CallActivity │◀───│ Call Object  │
                    │     .kt      │    │              │
                    └──────────────┘    └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │AudioManager  │
                    │              │
                    └──────────────┘
```

### iOS

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ViewController│───▶│TwilioVoice   │───▶│ Twilio Voice │
│   (Ionic)    │    │Plugin.swift  │    │   SDK        │
└──────────────┘    └──────┬───────┘    └──────┬───────┘
                           │                    │
                           │                    │
                           ▼                    ▼
                    ┌──────────────┐    ┌──────────────┐
                    │CallView      │◀───│ Call Object  │
                    │Controller    │    │              │
                    └──────────────┘    └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │AVAudioSession│
                    │              │
                    └──────────────┘
```

## Permission Flow

### Android

```
1. App calls startCall()
   ↓
2. Plugin checks RECORD_AUDIO permission
   ↓
3. If not granted:
   ├─> Request permission
   └─> Wait for user response
   ↓
4. If granted:
   └─> Proceed with call
```

### iOS

```
1. App calls startCall()
   ↓
2. iOS checks NSMicrophoneUsageDescription
   ↓
3. If first time:
   ├─> Show permission dialog
   └─> Wait for user response
   ↓
4. If granted:
   └─> Proceed with call
```

## Event System

```
┌─────────────────────────────────────────────────┐
│              Event Flow                         │
├─────────────────────────────────────────────────┤
│                                                 │
│  Native Event                                   │
│      ↓                                          │
│  CallListener/CallDelegate                      │
│      ↓                                          │
│  notifyListeners(eventName, data)               │
│      ↓                                          │
│  Capacitor Bridge                               │
│      ↓                                          │
│  JavaScript Event                               │
│      ↓                                          │
│  App Callback                                   │
│                                                 │
└─────────────────────────────────────────────────┘

Example:
  Twilio: Call Connected
    → Android: callListener.onConnected()
    → Plugin: notifyListeners("callConnected", {})
    → Bridge: Serialize and send to JS
    → JS: TwilioVoice.addListener("callConnected", callback)
    → App: callback() executed
```

## Audio Routing

### Android

```
AudioManager Configuration:
  ├─> Mode: MODE_IN_COMMUNICATION
  ├─> Stream: STREAM_VOICE_CALL
  └─> Speaker:
      ├─> OFF: Audio to earpiece
      └─> ON: Audio to loudspeaker
```

### iOS

```
AVAudioSession Configuration:
  ├─> Category: playAndRecord
  ├─> Mode: voiceChat
  ├─> Options: allowBluetooth, allowBluetoothA2DP
  └─> Output:
      ├─> Default: Earpiece
      └─> Override: Speaker
```

## Build Process

```
1. TypeScript Compilation
   src/*.ts → dist/esm/*.js + *.d.ts

2. Rollup Bundling
   dist/esm/index.js → dist/plugin.js (IIFE)
                    → dist/plugin.cjs.js (CommonJS)

3. Android Build
   *.kt → *.class → *.dex → .aar

4. iOS Build
   *.swift → *.o → Framework

5. NPM Package
   dist/ + android/ + ios/ → .tgz
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────┐
│                  NPM Registry                   │
│      @avinashbhalki/capacitor-twilio-voice      │
└─────────────────────┬───────────────────────────┘
                      │
                      │ npm install
                      ▼
┌─────────────────────────────────────────────────┐
│              Developer's Project                │
│                                                 │
│  node_modules/@avinashbhalki/                   │
│    capacitor-twilio-voice/                      │
│      ├── dist/ (JS bundles)                     │
│      ├── android/ (Gradle module)               │
│      └── ios/ (CocoaPod)                        │
└─────────────────────┬───────────────────────────┘
                      │
                      │ npx cap sync
                      ▼
┌─────────────────────────────────────────────────┐
│            Native Project                       │
│                                                 │
│  Android:                                       │
│    app/build.gradle includes plugin             │
│                                                 │
│  iOS:                                           │
│    Podfile includes plugin                      │
└─────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────┐
│              Security Layers                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. Backend Server (Your API)                   │
│     ├─> User Authentication                     │
│     ├─> Generate Twilio Access Token            │
│     └─> Return token to app                     │
│                                                 │
│  2. Mobile App                                  │
│     ├─> Request token from backend              │
│     ├─> Use token for single call               │
│     └─> Token expires after TTL                 │
│                                                 │
│  3. Twilio Voice SDK                            │
│     ├─> Validate access token                   │
│     ├─> Establish secure connection             │
│     └─> Handle call encryption                  │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Summary

This architecture provides:

✅ **Clean Separation** - TypeScript, Android, iOS layers  
✅ **Type Safety** - Full TypeScript definitions  
✅ **Native UI** - Platform-specific call interfaces  
✅ **Event System** - Real-time call state updates  
✅ **Audio Management** - Proper routing and focus  
✅ **Permission Handling** - Runtime permission requests  
✅ **Error Handling** - Comprehensive error reporting  
✅ **Lifecycle Management** - Proper cleanup and state  

The plugin follows Capacitor best practices and official plugin patterns.
