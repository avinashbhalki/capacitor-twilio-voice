import { Injectable, NgZone } from '@angular/core';
import { TwilioVoice, StartCallOptions, MuteOptions, SpeakerOptions, CallFailedEvent } from '../index';
import { Observable, Subject } from 'rxjs';

/**
 * Angular Service for Twilio Voice Plugin
 * Provides an Observable-based interface for call events
 */
@Injectable({
    providedIn: 'root'
})
export class TwilioVoiceService {
    private callConnectedSubject = new Subject<void>();
    private callDisconnectedSubject = new Subject<void>();
    private callFailedSubject = new Subject<CallFailedEvent>();

    /**
     * Observable that emits when a call is successfully connected
     */
    public callConnected$: Observable<void> = this.callConnectedSubject.asObservable();

    /**
     * Observable that emits when a call is disconnected
     */
    public callDisconnected$: Observable<void> = this.callDisconnectedSubject.asObservable();

    /**
     * Observable that emits when a call fails, with error details
     */
    public callFailed$: Observable<CallFailedEvent> = this.callFailedSubject.asObservable();

    constructor(private zone: NgZone) {
        this.initListeners();
    }

    private initListeners() {
        TwilioVoice.addListener('callConnected', () => {
            this.zone.run(() => {
                this.callConnectedSubject.next();
            });
        });

        TwilioVoice.addListener('callDisconnected', () => {
            this.zone.run(() => {
                this.callDisconnectedSubject.next();
            });
        });

        TwilioVoice.addListener('callFailed', (event: CallFailedEvent) => {
            this.zone.run(() => {
                this.callFailedSubject.next(event);
            });
        });
    }

    /**
     * Start an outgoing call
     * @param options Call configuration
     */
    async startCall(options: StartCallOptions): Promise<void> {
        return TwilioVoice.startCall(options);
    }

    /**
     * End the current active call
     */
    async endCall(): Promise<void> {
        return TwilioVoice.endCall();
    }

    /**
     * Mute or unmute the microphone
     * @param enabled True to mute
     */
    async setMute(enabled: boolean): Promise<void> {
        return TwilioVoice.setMute({ enabled });
    }

    /**
     * Enable or disable speaker
     * @param enabled True for speaker
     */
    async setSpeaker(enabled: boolean): Promise<void> {
        return TwilioVoice.setSpeaker({ enabled });
    }

    /**
     * Remove all listeners
     */
    async removeAllListeners(): Promise<void> {
        return TwilioVoice.removeAllListeners();
    }
}
