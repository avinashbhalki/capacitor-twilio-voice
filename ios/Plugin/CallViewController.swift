import Foundation
import UIKit
import TwilioVoice
import CallKit
import AVFoundation
import Capacitor

public class CallViewController: UIViewController {
    
    // MARK: - Properties
    var to: String = ""
    var accessToken: String = ""
    
    private var activeCall: Call?
    private var callKitProvider: CXProvider?
    private var callKitCallController: CXCallController?
    private var currentCallUUID: UUID?
    
    private var isMuted = false
    private var isSpeakerOn = false
    
    // MARK: - UI Elements
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Connecting..."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.alpha = 0.7
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var muteButton: UIButton = {
        let button = createRoundButton(
            imageName: "mic.fill",
            title: "Mute",
            backgroundColor: UIColor(white: 0.2, alpha: 1.0)
        )
        button.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.6
        return button
    }()
    
    private lazy var speakerButton: UIButton = {
        let button = createRoundButton(
            imageName: "speaker.wave.2.fill",
            title: "Speaker",
            backgroundColor: UIColor(white: 0.2, alpha: 1.0)
        )
        button.addTarget(self, action: #selector(toggleSpeaker), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.6
        return button
    }()
    
    private lazy var endCallButton: UIButton = {
        let button = createRoundButton(
            imageName: "phone.down.fill",
            title: "End Call",
            backgroundColor: UIColor(red: 1.0, green: 0.33, blue: 0.33, alpha: 1.0)
        )
        button.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        numberLabel.text = to
        
        setupUI()
        setupCallKit()
        initiateCall()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(statusLabel)
        view.addSubview(numberLabel)
        view.addSubview(muteButton)
        view.addSubview(speakerButton)
        view.addSubview(endCallButton)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            numberLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            numberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            muteButton.bottomAnchor.constraint(equalTo: endCallButton.topAnchor, constant: -40),
            muteButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            
            speakerButton.bottomAnchor.constraint(equalTo: endCallButton.topAnchor, constant: -40),
            speakerButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),
            
            endCallButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            endCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createRoundButton(imageName: String, title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 64),
            button.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        return button
    }
    
    // MARK: - CallKit Setup
    private func setupCallKit() {
        let configuration = CXProviderConfiguration(localizedName: "Twilio Voice")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportsVideo = false
        configuration.supportedHandleTypes = [.generic, .phoneNumber]
        
        callKitProvider = CXProvider(configuration: configuration)
        callKitProvider?.setDelegate(self, queue: nil)
        
        callKitCallController = CXCallController()
    }
    
    // MARK: - Call Management
    private func initiateCall() {
        let uuid = UUID()
        currentCallUUID = uuid
        
        // Configure audio session
        configureAudioSession()
        
        // Connect with Twilio
        let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
            builder.params = ["to": self.to]
            builder.uuid = uuid
        }
        
        activeCall = TwilioVoiceSDK.connect(options: connectOptions, delegate: self)
        
        // Report call to CallKit
        let handle = CXHandle(type: .generic, value: to)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        let transaction = CXTransaction(action: startCallAction)
        
        print("Requesting CallKit transaction for UUID: \(uuid)")
        callKitCallController?.request(transaction) { error in
            if let error = error {
                print("Error starting call (CallKit Error 1 usually means missing Background Modes or incorrect handle): \(error.localizedDescription)")
            } else {
                print("CallKit transaction requested successfully")
            }
        }
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
    
    @objc private func toggleMute() {
        guard let call = activeCall else { return }
        
        isMuted = !isMuted
        call.isMuted = isMuted
        
        muteButton.alpha = isMuted ? 1.0 : 0.6
    }
    
    @objc private func toggleSpeaker() {
        isSpeakerOn = !isSpeakerOn
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if isSpeakerOn {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            speakerButton.alpha = isSpeakerOn ? 1.0 : 0.6
        } catch {
            print("Error toggling speaker: \(error.localizedDescription)")
        }
    }
    
    @objc private func endCall() {
        if let call = activeCall {
            call.disconnect()
        } else {
            dismiss(animated: true)
        }
    }
    
    private func enableCallControls() {
        muteButton.isEnabled = true
        speakerButton.isEnabled = true
    }
}

// MARK: - CallKit Delegate
extension CallViewController: CXProviderDelegate {
    public func providerDidReset(_ provider: CXProvider) {
        activeCall?.disconnect()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        configureAudioSession()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        configureAudioSession()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        activeCall?.disconnect()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        activeCall?.isMuted = action.isMuted
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        (TwilioVoiceSDK.audioDevice as? DefaultAudioDevice)?.isEnabled = true
        
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        (TwilioVoiceSDK.audioDevice as? DefaultAudioDevice)?.isEnabled = false
        
    }
}

// MARK: - Twilio Call Delegate
extension CallViewController: CallDelegate {
    public func callDidConnect(call: Call) {
        print("Call connected")
        DispatchQueue.main.async {
            self.statusLabel.text = "Connected"
            self.enableCallControls()
        }
    }
    
    public func callDidFailToConnect(call: Call, error: Error) {
        print("Call failed to connect: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusLabel.text = "Call Failed"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.dismiss(animated: true)
            }
        }
        
        if let uuid = currentCallUUID {
            let endCallAction = CXEndCallAction(call: uuid)
            let transaction = CXTransaction(action: endCallAction)
            callKitCallController?.request(transaction, completion: { _ in })
        }
    }
    
    public func callDidDisconnect(call: Call, error: Error?) {
        print("Call disconnected")
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Call Ended"
            self.dismiss(animated: true)
        }
        
        if let uuid = currentCallUUID {
            let endCallAction = CXEndCallAction(call: uuid)
            let transaction = CXTransaction(action: endCallAction)
            callKitCallController?.request(transaction, completion: { _ in })
        }
    }
    
    public func callDidStartRinging(call: Call) {
        print("Call ringing")
        DispatchQueue.main.async {
            self.statusLabel.text = "Ringing..."
        }
    }
}
