import { WebPlugin } from '@capacitor/core';

import type { CallOptions, TwilioVoicePlugin } from './definitions';

export class TwilioVoiceWeb extends WebPlugin implements TwilioVoicePlugin {
    async call(options: CallOptions): Promise<void> {
        console.warn('TwilioVoice.call() is not supported on web platform');
        console.log('Call would be made to:', options.to);
        throw new Error('TwilioVoice is not supported on web. Please use Android or iOS.');
    }
}
