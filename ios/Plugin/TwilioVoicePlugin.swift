import Foundation
import Capacitor
import TwilioVoice

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(TwilioVoicePlugin)
public class TwilioVoicePlugin: CAPPlugin {
    
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
