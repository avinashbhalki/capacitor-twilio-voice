import { WebPlugin } from '@capacitor/core';

import type {
    TwilioVoicePlugin,
    StartCallOptions,
    MuteOptions,
    SpeakerOptions,
} from './definitions';

export class TwilioVoiceWeb extends WebPlugin implements TwilioVoicePlugin {
    async startCall(options: StartCallOptions): Promise<void> {
        console.warn('TwilioVoice.startCall is not available on web', options);
        throw this.unavailable('TwilioVoice is not available on web platform');
    }

    async endCall(): Promise<void> {
        console.warn('TwilioVoice.endCall is not available on web');
        throw this.unavailable('TwilioVoice is not available on web platform');
    }

    async setMute(options: MuteOptions): Promise<void> {
        console.warn('TwilioVoice.setMute is not available on web', options);
        throw this.unavailable('TwilioVoice is not available on web platform');
    }

    async setSpeaker(options: SpeakerOptions): Promise<void> {
        console.warn('TwilioVoice.setSpeaker is not available on web', options);
        throw this.unavailable('TwilioVoice is not available on web platform');
    }
}
