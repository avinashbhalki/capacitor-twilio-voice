import { WebPlugin } from '@capacitor/core';

import type {
  TwilioVoicePlugin,
  StartCallOptions,
  MuteOptions,
  SpeakerOptions,
} from './definitions';

export class TwilioVoiceWeb extends WebPlugin implements TwilioVoicePlugin {
  async startCall(options: StartCallOptions): Promise<void> {
    console.log('TwilioVoice.startCall called on web with:', options);
    throw this.unimplemented('Not implemented on web.');
  }

  async endCall(): Promise<void> {
    console.log('TwilioVoice.endCall called on web');
    throw this.unimplemented('Not implemented on web.');
  }

  async setMute(options: MuteOptions): Promise<void> {
    console.log('TwilioVoice.setMute called on web with:', options);
    throw this.unimplemented('Not implemented on web.');
  }

  async setSpeaker(options: SpeakerOptions): Promise<void> {
    console.log('TwilioVoice.setSpeaker called on web with:', options);
    throw this.unimplemented('Not implemented on web.');
  }
}
