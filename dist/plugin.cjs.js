'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

const TwilioVoice = core.registerPlugin('TwilioVoice', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.TwilioVoiceWeb()),
});

class TwilioVoiceWeb extends core.WebPlugin {
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

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    TwilioVoiceWeb: TwilioVoiceWeb
});

exports.TwilioVoice = TwilioVoice;
//# sourceMappingURL=plugin.cjs.js.map
