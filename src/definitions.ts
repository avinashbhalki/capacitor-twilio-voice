export interface TwilioVoicePlugin {
  /**
   * Start a Twilio Voice call with native UI
   * Opens a full-screen native call interface and initiates the call
   *
   * @param options - Call configuration including access token and destination number
   * @returns Promise that resolves when call is initiated
   */
  startCall(options: StartCallOptions): Promise<void>;

  /**
   * End the current active call
   * Disconnects the call and closes the native call UI
   *
   * @returns Promise that resolves when call is ended
   */
  endCall(): Promise<void>;

  /**
   * Set the microphone mute state
   *
   * @param options - Mute state configuration
   * @returns Promise that resolves when mute state is updated
   */
  setMute(options: MuteOptions): Promise<void>;

  /**
   * Set the speaker state
   *
   * @param options - Speaker state configuration
   * @returns Promise that resolves when speaker state is updated
   */
  setSpeaker(options: SpeakerOptions): Promise<void>;

  /**
   * Add listener for call connected event
   * Fired when the call successfully connects
   *
   * @param eventName - Must be 'callConnected'
   * @param listenerFunc - Callback function to handle the event
   */
  addListener(
    eventName: 'callConnected',
    listenerFunc: () => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Add listener for call disconnected event
   * Fired when the call disconnects (user hung up, remote party hung up, or network issue)
   *
   * @param eventName - Must be 'callDisconnected'
   * @param listenerFunc - Callback function to handle the event
   */
  addListener(
    eventName: 'callDisconnected',
    listenerFunc: () => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Add listener for call failed event
   * Fired when the call fails to connect or encounters an error
   *
   * @param eventName - Must be 'callFailed'
   * @param listenerFunc - Callback function to handle the event with error details
   */
  addListener(
    eventName: 'callFailed',
    listenerFunc: (error: CallFailedEvent) => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Remove all listeners for this plugin
   */
  removeAllListeners(): Promise<void>;
}

/**
 * Options for starting a call
 */
export interface StartCallOptions {
  /**
   * The phone number to call (E.164 format recommended, e.g., +1234567890)
   */
  toNumber: string;

  /**
   * Twilio Voice access token obtained from your server
   * This token authorizes the call and identifies the caller
   */
  accessToken: string;
}

/**
 * Options for setting mute state
 */
export interface MuteOptions {
  /**
   * True to mute the microphone, false to unmute
   */
  enabled: boolean;
}

/**
 * Options for setting speaker state
 */
export interface SpeakerOptions {
  /**
   * True to enable speaker mode, false to disable
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
}

/**
 * Plugin listener handle for removing event listeners
 */
export interface PluginListenerHandle {
  remove: () => Promise<void>;
}
