import Foundation
import Capacitor
import TwilioVoice

@objc public class TwilioVoice: NSObject {
    
    @objc public func call(_ call: CAPPluginCall, bridge: CAPBridgeProtocol?) {
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
            
            bridge?.viewController?.present(callViewController, animated: true) {
                call.resolve()
            }
        }
    }
}
