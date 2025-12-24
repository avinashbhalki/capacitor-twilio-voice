# Example Usage

This directory contains example code for using the Capacitor Twilio Voice plugin in your Ionic/Capacitor application.

## Installation in Your App

```bash
npm install @avinashbhalki/capacitor-twilio-voice
npx cap sync
```

## Angular/Ionic Example

### 1. Create a Call Service

Create `src/app/services/twilio-call.service.ts`:

```typescript
import { Injectable } from '@angular/core';
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';
import { BehaviorSubject } from 'rxjs';

export interface CallState {
  isActive: boolean;
  isConnected: boolean;
  isMuted: boolean;
  isSpeakerOn: boolean;
  phoneNumber: string;
  error: string | null;
}

@Injectable({
  providedIn: 'root'
})
export class TwilioCallService {
  private callState = new BehaviorSubject<CallState>({
    isActive: false,
    isConnected: false,
    isMuted: false,
    isSpeakerOn: false,
    phoneNumber: '',
    error: null
  });

  public callState$ = this.callState.asObservable();

  constructor() {
    this.setupEventListeners();
  }

  private setupEventListeners() {
    TwilioVoice.addListener('callConnected', () => {
      this.updateCallState({ isConnected: true, error: null });
    });

    TwilioVoice.addListener('callDisconnected', () => {
      this.updateCallState({
        isActive: false,
        isConnected: false,
        isMuted: false,
        isSpeakerOn: false,
        phoneNumber: '',
        error: null
      });
    });

    TwilioVoice.addListener('callFailed', (event) => {
      this.updateCallState({
        isActive: false,
        isConnected: false,
        error: event.error
      });
    });
  }

  async startCall(phoneNumber: string, accessToken: string, fromNumber?: string) {
    try {
      await TwilioVoice.startCall({
        toNumber: phoneNumber,
        accessToken: accessToken,
        fromNumber: fromNumber
      });

      this.updateCallState({
        isActive: true,
        phoneNumber: phoneNumber,
        error: null
      });
    } catch (error: any) {
      this.updateCallState({
        error: error.message || 'Failed to start call'
      });
      throw error;
    }
  }

  async endCall() {
    try {
      await TwilioVoice.endCall();
    } catch (error: any) {
      console.error('Error ending call:', error);
    }
  }

  async toggleMute() {
    const currentState = this.callState.value;
    const newMuteState = !currentState.isMuted;

    try {
      await TwilioVoice.setMute({ enabled: newMuteState });
      this.updateCallState({ isMuted: newMuteState });
    } catch (error) {
      console.error('Error toggling mute:', error);
    }
  }

  async toggleSpeaker() {
    const currentState = this.callState.value;
    const newSpeakerState = !currentState.isSpeakerOn;

    try {
      await TwilioVoice.setSpeaker({ enabled: newSpeakerState });
      this.updateCallState({ isSpeakerOn: newSpeakerState });
    } catch (error) {
      console.error('Error toggling speaker:', error);
    }
  }

  private updateCallState(updates: Partial<CallState>) {
    this.callState.next({
      ...this.callState.value,
      ...updates
    });
  }

  cleanup() {
    TwilioVoice.removeAllListeners();
  }
}
```

### 2. Create a Call Component

Create `src/app/pages/call/call.page.ts`:

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { TwilioCallService } from '../../services/twilio-call.service';
import { HttpClient } from '@angular/common/http';
import { AlertController, LoadingController } from '@ionic/angular';

@Component({
  selector: 'app-call',
  templateUrl: './call.page.html',
  styleUrls: ['./call.page.scss'],
})
export class CallPage implements OnInit, OnDestroy {
  phoneNumber = '';
  callState$ = this.callService.callState$;

  constructor(
    private callService: TwilioCallService,
    private http: HttpClient,
    private alertController: AlertController,
    private loadingController: LoadingController
  ) {}

  ngOnInit() {
    // Subscribe to call state changes
    this.callState$.subscribe(state => {
      if (state.error) {
        this.showError(state.error);
      }
    });
  }

  async makeCall() {
    if (!this.phoneNumber) {
      await this.showError('Please enter a phone number');
      return;
    }

    const loading = await this.loadingController.create({
      message: 'Getting access token...',
    });
    await loading.present();

    try {
      // Get access token from your backend
      const response = await this.http.get<{ token: string }>(
        'https://your-api.com/twilio/token'
      ).toPromise();

      await loading.dismiss();

      if (response && response.token) {
        await this.callService.startCall(
          this.phoneNumber,
          response.token,
          '+1234567890' // Optional: Your Twilio number
        );
      }
    } catch (error: any) {
      await loading.dismiss();
      await this.showError(error.message || 'Failed to get access token');
    }
  }

  async endCall() {
    await this.callService.endCall();
  }

  async toggleMute() {
    await this.callService.toggleMute();
  }

  async toggleSpeaker() {
    await this.callService.toggleSpeaker();
  }

  private async showError(message: string) {
    const alert = await this.alertController.create({
      header: 'Error',
      message: message,
      buttons: ['OK']
    });
    await alert.present();
  }

  ngOnDestroy() {
    // Cleanup is handled by the service
  }
}
```

Create `src/app/pages/call/call.page.html`:

```html
<ion-header>
  <ion-toolbar>
    <ion-title>Twilio Voice Call</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <div *ngIf="callState$ | async as state">
    <!-- Call Input (shown when no active call) -->
    <div *ngIf="!state.isActive" class="call-input">
      <ion-item>
        <ion-label position="floating">Phone Number</ion-label>
        <ion-input
          type="tel"
          [(ngModel)]="phoneNumber"
          placeholder="+1234567890"
        ></ion-input>
      </ion-item>

      <ion-button
        expand="block"
        color="success"
        (click)="makeCall()"
        class="ion-margin-top"
      >
        <ion-icon name="call" slot="start"></ion-icon>
        Start Call
      </ion-button>
    </div>

    <!-- Call Status (shown during call) -->
    <div *ngIf="state.isActive" class="call-status">
      <div class="status-info">
        <h2>{{ state.phoneNumber }}</h2>
        <p>{{ state.isConnected ? 'Connected' : 'Connecting...' }}</p>
      </div>

      <div class="call-controls">
        <ion-button
          [color]="state.isMuted ? 'danger' : 'medium'"
          (click)="toggleMute()"
        >
          <ion-icon [name]="state.isMuted ? 'mic-off' : 'mic'"></ion-icon>
        </ion-button>

        <ion-button
          [color]="state.isSpeakerOn ? 'primary' : 'medium'"
          (click)="toggleSpeaker()"
        >
          <ion-icon name="volume-high"></ion-icon>
        </ion-button>

        <ion-button color="danger" (click)="endCall()">
          <ion-icon name="call" style="transform: rotate(135deg);"></ion-icon>
        </ion-button>
      </div>
    </div>

    <!-- Error Display -->
    <ion-card *ngIf="state.error" color="danger">
      <ion-card-content>
        {{ state.error }}
      </ion-card-content>
    </ion-card>
  </div>
</ion-content>
```

Create `src/app/pages/call/call.page.scss`:

```scss
.call-input {
  margin-top: 2rem;
}

.call-status {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;

  .status-info {
    text-align: center;
    margin-bottom: 3rem;

    h2 {
      font-size: 2rem;
      margin-bottom: 0.5rem;
    }

    p {
      color: var(--ion-color-medium);
      font-size: 1.1rem;
    }
  }

  .call-controls {
    display: flex;
    gap: 1rem;

    ion-button {
      --border-radius: 50%;
      width: 60px;
      height: 60px;

      ion-icon {
        font-size: 24px;
      }
    }
  }
}
```

## React Example

```typescript
import React, { useState, useEffect } from 'react';
import { TwilioVoice } from '@avinashbhalki/capacitor-twilio-voice';
import {
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
  IonButton,
  IonInput,
  IonItem,
  IonLabel,
  IonIcon,
} from '@ionic/react';
import { call, mic, micOff, volumeHigh } from 'ionicons/icons';

const CallPage: React.FC = () => {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [isCallActive, setIsCallActive] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isSpeakerOn, setIsSpeakerOn] = useState(false);

  useEffect(() => {
    // Setup event listeners
    TwilioVoice.addListener('callConnected', () => {
      setIsConnected(true);
    });

    TwilioVoice.addListener('callDisconnected', () => {
      setIsCallActive(false);
      setIsConnected(false);
      setIsMuted(false);
      setIsSpeakerOn(false);
    });

    TwilioVoice.addListener('callFailed', (event) => {
      console.error('Call failed:', event.error);
      setIsCallActive(false);
    });

    return () => {
      TwilioVoice.removeAllListeners();
    };
  }, []);

  const makeCall = async () => {
    try {
      // Get token from your backend
      const response = await fetch('https://your-api.com/twilio/token');
      const data = await response.json();

      await TwilioVoice.startCall({
        toNumber: phoneNumber,
        accessToken: data.token,
      });

      setIsCallActive(true);
    } catch (error) {
      console.error('Error starting call:', error);
    }
  };

  const endCall = async () => {
    await TwilioVoice.endCall();
  };

  const toggleMute = async () => {
    const newMuteState = !isMuted;
    await TwilioVoice.setMute({ enabled: newMuteState });
    setIsMuted(newMuteState);
  };

  const toggleSpeaker = async () => {
    const newSpeakerState = !isSpeakerOn;
    await TwilioVoice.setSpeaker({ enabled: newSpeakerState });
    setIsSpeakerOn(newSpeakerState);
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Twilio Voice Call</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        {!isCallActive ? (
          <div>
            <IonItem>
              <IonLabel position="floating">Phone Number</IonLabel>
              <IonInput
                type="tel"
                value={phoneNumber}
                onIonChange={(e) => setPhoneNumber(e.detail.value!)}
              />
            </IonItem>
            <IonButton expand="block" onClick={makeCall}>
              <IonIcon icon={call} slot="start" />
              Start Call
            </IonButton>
          </div>
        ) : (
          <div>
            <h2>{phoneNumber}</h2>
            <p>{isConnected ? 'Connected' : 'Connecting...'}</p>
            <div>
              <IonButton onClick={toggleMute}>
                <IonIcon icon={isMuted ? micOff : mic} />
              </IonButton>
              <IonButton onClick={toggleSpeaker}>
                <IonIcon icon={volumeHigh} />
              </IonButton>
              <IonButton color="danger" onClick={endCall}>
                <IonIcon icon={call} />
              </IonButton>
            </div>
          </div>
        )}
      </IonContent>
    </IonPage>
  );
};

export default CallPage;
```

## Backend Example (Node.js/Express)

```javascript
const express = require('express');
const twilio = require('twilio');

const app = express();
const AccessToken = twilio.jwt.AccessToken;
const VoiceGrant = AccessToken.VoiceGrant;

// Twilio credentials
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const apiKey = process.env.TWILIO_API_KEY;
const apiSecret = process.env.TWILIO_API_SECRET;
const outgoingApplicationSid = process.env.TWILIO_TWIML_APP_SID;

// Generate access token
app.get('/twilio/token', (req, res) => {
  const identity = req.user?.id || 'user-' + Date.now();

  const voiceGrant = new VoiceGrant({
    outgoingApplicationSid: outgoingApplicationSid,
    incomingAllow: true,
  });

  const token = new AccessToken(accountSid, apiKey, apiSecret, {
    identity: identity,
    ttl: 3600, // 1 hour
  });

  token.addGrant(voiceGrant);

  res.json({
    token: token.toJwt(),
    identity: identity,
  });
});

// TwiML for outgoing calls
app.post('/twilio/voice', (req, res) => {
  const twiml = new twilio.twiml.VoiceResponse();
  const dial = twiml.dial({ callerId: process.env.TWILIO_PHONE_NUMBER });
  
  // Get the phone number from the request
  const toNumber = req.body.To;
  dial.number(toNumber);

  res.type('text/xml');
  res.send(twiml.toString());
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

## Testing

1. Set up your Twilio account and get credentials
2. Deploy the backend to get access tokens
3. Update the API endpoint in your app
4. Run your app: `ionic cap run android` or `ionic cap run ios`
5. Make a test call

## Notes

- Always get access tokens from your backend, never hardcode them
- Access tokens should have a short TTL (1 hour recommended)
- Test on real devices for best results
- Ensure proper permissions are granted before making calls
