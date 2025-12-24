import { registerPlugin } from '@capacitor/core';
const TwilioVoice = registerPlugin('TwilioVoice', {
    web: () => import('./web').then(m => new m.TwilioVoiceWeb()),
});
export * from './definitions';
export { TwilioVoice };
