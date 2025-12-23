export interface TwilioVoicePlugin {
  initialize(options: { accessToken: string; deviceToken?: string }): Promise<void>;
  makeCall(options: { to: string }): Promise<void>;
  endCall(): Promise<void>;
  mute(): Promise<void>;
  unmute(): Promise<void>;
  hold(): Promise<void>;
  unhold(): Promise<void>;
  speakerOn(): Promise<void>;
  speakerOff(): Promise<void>;
}