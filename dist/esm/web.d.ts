import { WebPlugin } from '@capacitor/core';
import type { TwilioVoicePlugin, StartCallOptions, MuteOptions, SpeakerOptions } from './definitions';
export declare class TwilioVoiceWeb extends WebPlugin implements TwilioVoicePlugin {
    startCall(options: StartCallOptions): Promise<void>;
    endCall(): Promise<void>;
    setMute(options: MuteOptions): Promise<void>;
    setSpeaker(options: SpeakerOptions): Promise<void>;
}
//# sourceMappingURL=web.d.ts.map