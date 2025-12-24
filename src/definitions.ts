export interface TwilioVoicePlugin {
    /**
     * Start an outgoing call with the specified options.
     * Opens a full-screen native call UI.
     * 
     * @param options - Call configuration options
     * @returns Promise that resolves when the call is initiated
     */
    startCall(options: StartCallOptions): Promise<void>;

    /**
     * End the current active call.
     * Closes the call UI automatically.
     * 
     * @returns Promise that resolves when the call is ended
     */
    endCall(): Promise<void>;

    /**
     * Mute or unmute the microphone during an active call.
     * 
     * @param options - Mute configuration
     * @returns Promise that resolves when mute state is changed
     */
    setMute(options: MuteOptions): Promise<void>;

    /**
     * Enable or disable speaker mode during an active call.
     * 
     * @param options - Speaker configuration
     * @returns Promise that resolves when speaker state is changed
     */
    setSpeaker(options: SpeakerOptions): Promise<void>;

    /**
     * Add a listener for call events.
     * 
     * @param eventName - The event to listen for
     * @param listenerFunc - Callback function to handle the event
     * @returns Promise with a remove function to unsubscribe
     */
    addListener(
        eventName: 'callConnected',
        listenerFunc: () => void,
    ): Promise<PluginListenerHandle>;

    addListener(
        eventName: 'callDisconnected',
        listenerFunc: () => void,
    ): Promise<PluginListenerHandle>;

    addListener(
        eventName: 'callFailed',
        listenerFunc: (error: CallFailedEvent) => void,
    ): Promise<PluginListenerHandle>;

    /**
     * Remove all listeners for this plugin.
     * 
     * @returns Promise that resolves when all listeners are removed
     */
    removeAllListeners(): Promise<void>;
}

/**
 * Options for starting a call
 */
export interface StartCallOptions {
    /**
     * The phone number or SIP address to call
     */
    toNumber: string;

    /**
     * Twilio access token for authentication
     */
    accessToken: string;

    /**
     * Optional caller ID to display (if supported by Twilio)
     */
    fromNumber?: string;

    /**
     * Optional custom parameters to pass to TwiML
     */
    customParameters?: { [key: string]: string };
}

/**
 * Options for muting/unmuting the microphone
 */
export interface MuteOptions {
    /**
     * True to mute, false to unmute
     */
    enabled: boolean;
}

/**
 * Options for enabling/disabling speaker
 */
export interface SpeakerOptions {
    /**
     * True to enable speaker, false to use earpiece
     */
    enabled: boolean;
}

/**
 * Event data for call failed event
 */
export interface CallFailedEvent {
    /**
     * Error message describing why the call failed
     */
    error: string;

    /**
     * Error code if available
     */
    code?: number;
}

/**
 * Plugin listener handle for removing event listeners
 */
export interface PluginListenerHandle {
    remove: () => Promise<void>;
}
