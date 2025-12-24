import { NgModule } from '@angular/core';
import { TwilioVoiceService } from './voice.service';

/**
 * Angular Module for Twilio Voice Plugin
 */
@NgModule({
    providers: [TwilioVoiceService]
})
export class TwilioVoiceModule { }
