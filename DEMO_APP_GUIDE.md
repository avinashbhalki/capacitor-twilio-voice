# How to Use This Plugin in a Sample Demo App (NgModule Edition)

This guide shows you how to integrate the **Twilio Voice Plugin** into an Ionic Angular application using **NgModules**.

---

## Step 1: Prepare the Plugin

First, ensure the plugin is built:

```bash
cd /Users/Avinash/Documents/Office/Projects/Athena/Cloud9/Plugin
npm install
npm run build
```

---

## Step 2: Create a New Ionic App (NgModule)

Create a new Ionic app specifically with the NgModule structure (if using a newer Ionic version that defaults to Standalone):

```bash
ionic start twilio-demo blank --type=angular --capacitor --standalone=false
cd twilio-demo
```

---

## Step 3: Install the Plugin

```bash
npm install /Users/Avinash/Documents/Office/Projects/Athena/Cloud9/Plugin
npx cap sync
```

---

## Step 4: Configure App Module

Import the `TwilioVoiceModule` in your `src/app/app.module.ts`:

```typescript
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { RouteReuseStrategy } from '@angular/router';
import { IonicModule, IonicRouteStrategy } from '@ionic/angular';
import { HttpClientModule } from '@angular/common/http';

import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';

// Import the Twilio Voice Module from the plugin
import { TwilioVoiceModule } from '@avinashbhalki/capacitor-twilio-voice/ngx';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule, 
    IonicModule.forRoot(), 
    AppRoutingModule,
    HttpClientModule,
    TwilioVoiceModule // Add this line
  ],
  providers: [{ provide: RouteReuseStrategy, useClass: IonicRouteStrategy }],
  bootstrap: [AppComponent],
})
export class AppModule {}
```

---

## Step 5: Update Home Page Component

Modify `src/app/home/home.page.ts` to use the `TwilioVoiceService`:

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { TwilioVoiceService } from '@avinashbhalki/capacitor-twilio-voice/ngx';
import { AlertController, LoadingController } from '@ionic/angular';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage implements OnInit, OnDestroy {
  phoneNumber = '';
  isCallActive = false;
  isConnected = false;
  
  private subscriptions: Subscription = new Subscription();

  constructor(
    private twilioVoice: TwilioVoiceService,
    private alertController: AlertController,
    private loadingController: LoadingController
  ) {}

  ngOnInit() {
    // Listen for call events using Observables
    this.subscriptions.add(
      this.twilioVoice.callConnected$.subscribe(() => {
        console.log('Call connected!');
        this.isConnected = true;
      })
    );

    this.subscriptions.add(
      this.twilioVoice.callDisconnected$.subscribe(() => {
        console.log('Call ended');
        this.resetState();
      })
    );

    this.subscriptions.add(
      this.twilioVoice.callFailed$.subscribe((event) => {
        this.showAlert('Call Failed', event.error);
        this.resetState();
      })
    );
  }

  async startCall() {
    if (!this.phoneNumber) {
      await this.showAlert('Error', 'Enter a phone number');
      return;
    }

    const loading = await this.loadingController.create({
      message: 'Calling...',
    });
    await loading.present();

    try {
      // Step: Get token from your backend 
      // (Example: const res = await http.get('...').toPromise();)
      const accessToken = 'YOUR_TEST_TOKEN'; 

      await this.twilioVoice.startCall({
        toNumber: this.phoneNumber,
        accessToken: accessToken
      });

      this.isCallActive = true;
      await loading.dismiss();
    } catch (error: any) {
      await loading.dismiss();
      this.showAlert('Error', error.message);
    }
  }

  async endCall() {
    await this.twilioVoice.endCall();
  }

  private resetState() {
    this.isCallActive = false;
    this.isConnected = false;
  }

  private async showAlert(header: string, message: string) {
    const alert = await this.alertController.create({
      header,
      message,
      buttons: ['OK']
    });
    await alert.present();
  }

  ngOnDestroy() {
    this.subscriptions.unsubscribe();
  }
}
```

---

## Step 6: Update Home Page Module

Ensure `FormsModule` is imported in `src/app/home/home.module.ts`:

```typescript
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule } from '@ionic/angular';
import { FormsModule } from '@angular/forms';
import { HomePage } from './home.page';

import { HomePageRoutingModule } from './home-page-routing.module';

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

---

## Step 7: Platform Configuration

### Android (AndroidManifest.xml)
Add to `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

### iOS (Info.plist)
Add keys:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Need microphone for calls</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
  <string>voip</string>
</array>
```

---

## Step 8: Run

```bash
npx cap sync
ionic cap run android
```

---

## Summary of Changes

- **NgModule Support**: Using `TwilioVoiceModule` in `AppModule`.
- **Observable Events**: The `TwilioVoiceService` provides clean RxJS streams (`callConnected$`, etc.).
- **Standalone Disabled**: The demo app is configured specifically for `NgModule` architecture.
