export interface TwilioVoicePlugin {
    call(options: CallOptions): Promise<void>;
}

export interface CallOptions {
    /**
     * The phone number to call (E.164 format recommended)
     */
    to: string;

    /**
     * Twilio Access Token for authentication
     */
    accessToken: string;
}
