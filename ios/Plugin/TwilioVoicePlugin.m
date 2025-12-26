import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(TwilioVoicePlugin)
public class TwilioVoicePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "TwilioVoicePlugin"
    public let jsName = "TwilioVoice"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "call", returnType: CAPPluginReturnPromise)
    ]
    
    private let implementation = TwilioVoice()

    @objc func call(_ call: CAPPluginCall) {
        implementation.call(call, bridge: self.bridge)
    }
}
