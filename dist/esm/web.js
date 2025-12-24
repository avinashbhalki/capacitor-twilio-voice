import { WebPlugin } from '@capacitor/core';
export class TwilioVoiceWeb extends WebPlugin {
    async startCall(options) {
        console.log('TwilioVoice.startCall called on web with:', options);
        throw this.unimplemented('Not implemented on web.');
    }
    async endCall() {
        console.log('TwilioVoice.endCall called on web');
        throw this.unimplemented('Not implemented on web.');
    }
    async setMute(options) {
        console.log('TwilioVoice.setMute called on web with:', options);
        throw this.unimplemented('Not implemented on web.');
    }
    async setSpeaker(options) {
        console.log('TwilioVoice.setSpeaker called on web with:', options);
        throw this.unimplemented('Not implemented on web.');
    }
}
