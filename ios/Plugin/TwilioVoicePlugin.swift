import Foundation
import Capacitor
import TwilioVoice
import AVFoundation
import CallKit

/**
 * Capacitor plugin for Twilio Voice SDK
 * Provides methods to initiate, manage, and control voice calls
 */
@objc(TwilioVoicePlugin)
public class TwilioVoicePlugin: CAPPlugin {
    
    static var shared: TwilioVoicePlugin?
    
    private var activeCall: Call?
    private var callKitProvider: CXProvider?
    private var callKitCallController: CXCallController?
    private var callViewController: CallViewController?
    
    override public func load() {
        TwilioVoicePlugin.shared = self
        setupCallKit()
    }
    
    /**
     * Start an outgoing call with Twilio Voice
     * Opens a full-screen native call UI
     */
    @objc func startCall(_ call: CAPPluginCall) {
        guard let toNumber = call.getString("toNumber") else {
            call.reject("toNumber is required")
            return
        }
        
        guard let accessToken = call.getString("accessToken") else {
            call.reject("accessToken is required")
            return
        }
        
        let fromNumber = call.getString("fromNumber")
        let customParameters = call.getObject("customParameters") ?? [:]
        
        DispatchQueue.main.async {
            self.initiateCall(toNumber: toNumber, accessToken: accessToken, fromNumber: fromNumber, customParameters: customParameters, call: call)
        }
    }
    
    /**
     * End the current active call
     */
    @objc func endCall(_ call: CAPPluginCall) {
        guard let activeCall = activeCall else {
            call.reject("No active call to end")
            return
        }
        
        activeCall.disconnect()
        self.activeCall = nil
        call.resolve()
    }
    
    /**
     * Mute or unmute the microphone
     */
    @objc func setMute(_ call: CAPPluginCall) {
        guard let activeCall = activeCall else {
            call.reject("No active call")
            return
        }
        
        let enabled = call.getBool("enabled") ?? false
        activeCall.isMuted = enabled
        call.resolve()
    }
    
    /**
     * Enable or disable speaker
     */
    @objc func setSpeaker(_ call: CAPPluginCall) {
        let enabled = call.getBool("enabled") ?? false
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if enabled {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            callViewController?.updateSpeakerButton(enabled: enabled)
            call.resolve()
        } catch {
            call.reject("Failed to set speaker: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCallKit() {
        let configuration = CXProviderConfiguration(localizedName: "Voice Call")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportsVideo = false
        configuration.supportedHandleTypes = [.phoneNumber]
        
        callKitProvider = CXProvider(configuration: configuration)
        callKitCallController = CXCallController()
    }
    
    private func initiateCall(toNumber: String, accessToken: String, fromNumber: String?, customParameters: [String: Any], call: CAPPluginCall) {
        // Setup audio session
        configureAudioSession()
        
        // Build connect options
        var params: [String: String] = ["To": toNumber]
        if let from = fromNumber {
            params["From"] = from
        }
        
        // Add custom parameters
        for (key, value) in customParameters {
            if let stringValue = value as? String {
                params[key] = stringValue
            }
        }
        
        let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
            builder.params = params
        }
        
        // Make the call
        activeCall = TwilioVoiceSDK.connect(options: connectOptions, delegate: self)
        
        // Show call UI
        showCallViewController(toNumber: toNumber, fromNumber: fromNumber)
        
        call.resolve()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func showCallViewController(toNumber: String, fromNumber: String?) {
        DispatchQueue.main.async {
            guard let viewController = self.bridge?.viewController else { return }
            
            let callVC = CallViewController()
            callVC.toNumber = toNumber
            callVC.fromNumber = fromNumber
            callVC.modalPresentationStyle = .fullScreen
            
            self.callViewController = callVC
            viewController.present(callVC, animated: true, completion: nil)
        }
    }
    
    private func dismissCallViewController() {
        DispatchQueue.main.async {
            self.callViewController?.dismiss(animated: true) {
                self.callViewController = nil
            }
        }
    }
    
    func notifyCallEvent(_ eventName: String, data: [String: Any] = [:]) {
        notifyListeners(eventName, data: data)
    }
}

// MARK: - CallDelegate

extension TwilioVoicePlugin: CallDelegate {
    
    public func callDidConnect(call: Call) {
        activeCall = call
        callViewController?.updateCallStatus(.connected)
        notifyListeners("callConnected", data: [:])
    }
    
    public func callDidDisconnect(call: Call, error: Error?) {
        activeCall = nil
        
        if let error = error {
            let errorData: [String: Any] = [
                "error": error.localizedDescription,
                "code": (error as NSError).code
            ]
            notifyListeners("callFailed", data: errorData)
        } else {
            notifyListeners("callDisconnected", data: [:])
        }
        
        dismissCallViewController()
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    public func callDidFailToConnect(call: Call, error: Error) {
        activeCall = nil
        
        let errorData: [String: Any] = [
            "error": error.localizedDescription,
            "code": (error as NSError).code
        ]
        notifyListeners("callFailed", data: errorData)
        
        dismissCallViewController()
    }
    
    public func callDidStartRinging(call: Call) {
        callViewController?.updateCallStatus(.ringing)
    }
}
