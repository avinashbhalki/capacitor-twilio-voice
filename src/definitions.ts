export interface TwilioVoicePlugin {
    /**
     * Initiate a Twilio Voice call with native UI
     * @param options - Call options including recipient number and access token
     */
    call(options: CallOptions): Promise<void>;
}

export interface CallOptions {
    /**
     * The phone number to call (E.164 format recommended)
     */
    toNumber: string;

    /**
     * Twilio Access Token for authentication
     */
    accessToken: string;
}
