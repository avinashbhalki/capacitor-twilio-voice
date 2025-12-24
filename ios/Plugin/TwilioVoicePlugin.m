import Foundation
import Capacitor

/**
 * Plugin registration with Capacitor
 */
@objc(TwilioVoicePlugin)
public class TwilioVoicePluginBridge: CAPPlugin {
    @objc func startCall(_ call: CAPPluginCall) {
        // Implemented in TwilioVoicePlugin.swift
    }
    
    @objc func endCall(_ call: CAPPluginCall) {
        // Implemented in TwilioVoicePlugin.swift
    }
    
    @objc func setMute(_ call: CAPPluginCall) {
        // Implemented in TwilioVoicePlugin.swift
    }
    
    @objc func setSpeaker(_ call: CAPPluginCall) {
        // Implemented in TwilioVoicePlugin.swift
    }
}
