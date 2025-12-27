import Foundation
import Capacitor

/**
 * Twilio Voice Plugin for Capacitor 6
 */
@objc(TwilioVoicePlugin)
public class TwilioVoicePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "TwilioVoicePlugin"
    public let jsName = "TwilioVoice"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "call", returnType: CAPPluginReturnPromise)
    ]

    @objc func call(_ call: CAPPluginCall) {
        guard let to = call.getString("to") else {
            call.reject("to is required")
            return
        }
        
        guard let accessToken = call.getString("accessToken") else {
            call.reject("accessToken is required")
            return
        }
        
        DispatchQueue.main.async {
            let callViewController = CallViewController()
            callViewController.to = to
            callViewController.accessToken = accessToken
            callViewController.modalPresentationStyle = .fullScreen
            
            self.bridge?.viewController?.present(callViewController, animated: true) {
                call.resolve()
            }
        }
    }
}
