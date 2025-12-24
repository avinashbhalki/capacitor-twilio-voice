import Foundation
import UIKit
import TwilioVoice
import CallKit
import AVFoundation

class CallViewController: UIViewController {

    // MARK: - Properties
    var toNumber: String?
    var accessToken: String?

    private var activeCall: Call?
    private var callKitProvider: CXProvider?
    private var callKitCallController: CXCallController?
    private var callUUID: UUID?

    private var isMuted = false
    private var isSpeakerOn = false

    // MARK: - UI Elements
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Connecting..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(white: 0.8, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let muteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 32
        button.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.5
        return button
    }()

    private let speakerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 32
        button.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.5
        return button
    }()

    private let endCallButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 36
        button.setImage(UIImage(systemName: "phone.down.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallKit()
        configureAudioSession()
        initiateCall()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        phoneNumberLabel.text = toNumber

        view.addSubview(statusLabel)
        view.addSubview(phoneNumberLabel)
        view.addSubview(muteButton)
        view.addSubview(speakerButton)
        view.addSubview(endCallButton)

        NSLayoutConstraint.activate([
            // Status label
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Phone number label
            phoneNumberLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            phoneNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Mute button
            muteButton.widthAnchor.constraint(equalToConstant: 64),
            muteButton.heightAnchor.constraint(equalToConstant: 64),
            muteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            muteButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),

            // Speaker button
            speakerButton.widthAnchor.constraint(equalToConstant: 64),
            speakerButton.heightAnchor.constraint(equalToConstant: 64),
            speakerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            speakerButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),

            // End call button
            endCallButton.widthAnchor.constraint(equalToConstant: 72),
            endCallButton.heightAnchor.constraint(equalToConstant: 72),
            endCallButton.bottomAnchor.constraint(equalTo: muteButton.topAnchor, constant: -40),
            endCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Add button actions
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(speakerButtonTapped), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)
    }

    // MARK: - CallKit Setup
    private func setupCallKit() {
        let configuration = CXProviderConfiguration(localizedName: "Twilio Voice")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportsVideo = false
        configuration.supportedHandleTypes = [.phoneNumber]

        callKitProvider = CXProvider(configuration: configuration)
        callKitProvider?.setDelegate(self, queue: nil)

        callKitCallController = CXCallController()
    }

    // MARK: - Audio Session
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Call Management
    private func initiateCall() {
        guard let accessToken = accessToken, let toNumber = toNumber else {
            updateStatus("Error: Missing parameters")
            TwilioVoicePlugin.shared?.notifyCallFailed(error: "Missing access token or phone number")
            dismiss(animated: true, completion: nil)
            return
        }

        updateStatus("Connecting...")

        let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
            builder.params = ["To": toNumber]
        }

        activeCall = TwilioVoiceSDK.connect(options: connectOptions, delegate: self)

        // Report call to CallKit
        callUUID = UUID()
        reportOutgoingCall(uuid: callUUID!, handle: toNumber)
    }

    @objc func endCall() {
        if let call = activeCall {
            call.disconnect()
        } else {
            dismiss(animated: true, completion: nil)
        }

        if let uuid = callUUID {
            let endCallAction = CXEndCallAction(call: uuid)
            let transaction = CXTransaction(action: endCallAction)
            callKitCallController?.request(transaction) { error in
                if let error = error {
                    print("EndCallAction transaction request failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func setMute(_ mute: Bool) {
        isMuted = mute
        activeCall?.isMuted = isMuted
        updateMuteButton()
    }

    func setSpeaker(_ enabled: Bool) {
        isSpeakerOn = enabled

        do {
            let audioSession = AVAudioSession.sharedInstance()
            if isSpeakerOn {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(.none)
            }
            updateSpeakerButton()
        } catch {
            print("Failed to set speaker mode: \(error.localizedDescription)")
        }
    }

    private func reportOutgoingCall(uuid: UUID, handle: String) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = false

        let transaction = CXTransaction(action: startCallAction)

        callKitCallController?.request(transaction) { error in
            if let error = error {
                print("StartCallAction transaction request failed: \(error.localizedDescription)")
            } else {
                print("StartCallAction transaction request successful")
            }
        }
    }

    // MARK: - UI Updates
    private func updateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = status
        }
    }

    private func updateMuteButton() {
        DispatchQueue.main.async {
            self.muteButton.alpha = self.isMuted ? 1.0 : 0.5
        }
    }

    private func updateSpeakerButton() {
        DispatchQueue.main.async {
            self.speakerButton.alpha = self.isSpeakerOn ? 1.0 : 0.5
        }
    }

    // MARK: - Button Actions
    @objc private func muteButtonTapped() {
        setMute(!isMuted)
    }

    @objc private func speakerButtonTapped() {
        setSpeaker(!isSpeakerOn)
    }

    @objc private func endCallButtonTapped() {
        endCall()
    }
}

// MARK: - CallDelegate
extension CallViewController: CallDelegate {
    func callDidConnect(call: Call) {
        print("Call connected")
        updateStatus("Connected")
        TwilioVoicePlugin.shared?.notifyCallConnected()

        if let uuid = callUUID {
            callKitProvider?.reportOutgoingCall(with: uuid, connectedAt: Date())
        }
    }

    func callDidFailToConnect(call: Call, error: Error) {
        print("Call failed to connect: \(error.localizedDescription)")
        updateStatus("Call failed")
        TwilioVoicePlugin.shared?.notifyCallFailed(error: error.localizedDescription)

        if let uuid = callUUID {
            callKitProvider?.reportCall(with: uuid, endedAt: Date(), reason: .failed)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func callDidDisconnect(call: Call, error: Error?) {
        print("Call disconnected")
        updateStatus("Disconnected")
        TwilioVoicePlugin.shared?.notifyCallDisconnected()

        if let uuid = callUUID {
            let reason: CXCallEndedReason = error != nil ? .failed : .remoteEnded
            callKitProvider?.reportCall(with: uuid, endedAt: Date(), reason: reason)
        }

        activeCall = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func callDidStartRinging(call: Call) {
        print("Call is ringing")
        updateStatus("Ringing...")
    }
}

// MARK: - CXProviderDelegate
extension CallViewController: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Provider perform start call action")

        configureAudioSession()

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("Provider perform answer call action")

        configureAudioSession()

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("Provider perform end call action")

        activeCall?.disconnect()

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("Provider perform set held call action")
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("Provider perform set muted call action")
        setMute(action.isMuted)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Provider did activate audio session")
        TwilioVoiceSDK.audioDevice?.isEnabled = true
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Provider did deactivate audio session")
        TwilioVoiceSDK.audioDevice?.isEnabled = false
    }
}
