import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(TwilioVoicePlugin)
public class TwilioVoicePlugin: CAPPlugin {

    static var shared: TwilioVoicePlugin?
    private var callViewController: CallViewController?

    override public func load() {
        TwilioVoicePlugin.shared = self
    }

    @objc func startCall(_ call: CAPPluginCall) {
        guard let toNumber = call.getString("toNumber") else {
            call.reject("toNumber is required")
            return
        }

        guard let accessToken = call.getString("accessToken") else {
            call.reject("accessToken is required")
            return
        }

        DispatchQueue.main.async {
            self.presentCallViewController(toNumber: toNumber, accessToken: accessToken)
        }

        call.resolve()
    }

    @objc func endCall(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.callViewController?.endCall()
        }
        call.resolve()
    }

    @objc func setMute(_ call: CAPPluginCall) {
        let enabled = call.getBool("enabled") ?? false
        DispatchQueue.main.async {
            self.callViewController?.setMute(enabled)
        }
        call.resolve()
    }

    @objc func setSpeaker(_ call: CAPPluginCall) {
        let enabled = call.getBool("enabled") ?? false
        DispatchQueue.main.async {
            self.callViewController?.setSpeaker(enabled)
        }
        call.resolve()
    }

    private func presentCallViewController(toNumber: String, accessToken: String) {
        let callVC = CallViewController()
        callVC.toNumber = toNumber
        callVC.accessToken = accessToken
        callVC.modalPresentationStyle = .fullScreen

        self.callViewController = callVC

        self.bridge?.viewController?.present(callVC, animated: true, completion: nil)
    }

    // Event notification methods
    func notifyCallConnected() {
        notifyListeners("callConnected", data: [:])
    }

    func notifyCallDisconnected() {
        notifyListeners("callDisconnected", data: [:])
    }

    func notifyCallFailed(error: String) {
        notifyListeners("callFailed", data: ["error": error])
    }

    deinit {
        TwilioVoicePlugin.shared = nil
    }
}
