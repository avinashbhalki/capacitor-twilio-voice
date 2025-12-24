import UIKit
import AVFoundation

/**
 * Call status enum
 */
enum CallStatus {
    case connecting
    case ringing
    case connected
    case disconnected
}

/**
 * Full-screen call view controller with native UI controls
 * Displays mute, speaker, and end call buttons
 */
class CallViewController: UIViewController {
    
    var toNumber: String?
    var fromNumber: String?
    
    private var callStatus: CallStatus = .connecting
    private var isMuted = false
    private var isSpeakerOn = false
    private var callStartTime: Date?
    private var durationTimer: Timer?
    
    // UI Elements
    private let callStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Calling..."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let muteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "mic.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    private let speakerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    private let endCallButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image = UIImage(systemName: "phone.down.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        
        setupUI()
        setupButtons()
        
        phoneNumberLabel.text = toNumber ?? "Unknown"
    }
    
    private func setupUI() {
        // Add subviews
        view.addSubview(callStatusLabel)
        view.addSubview(phoneNumberLabel)
        view.addSubview(durationLabel)
        view.addSubview(muteButton)
        view.addSubview(speakerButton)
        view.addSubview(endCallButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Call status label
            callStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            callStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Phone number label
            phoneNumberLabel.topAnchor.constraint(equalTo: callStatusLabel.bottomAnchor, constant: 16),
            phoneNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneNumberLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            phoneNumberLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Duration label
            durationLabel.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 16),
            durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Mute button
            muteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            muteButton.trailingAnchor.constraint(equalTo: speakerButton.leadingAnchor, constant: -32),
            muteButton.widthAnchor.constraint(equalToConstant: 70),
            muteButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Speaker button
            speakerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            speakerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speakerButton.widthAnchor.constraint(equalToConstant: 70),
            speakerButton.heightAnchor.constraint(equalToConstant: 70),
            
            // End call button
            endCallButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            endCallButton.leadingAnchor.constraint(equalTo: speakerButton.trailingAnchor, constant: 32),
            endCallButton.widthAnchor.constraint(equalToConstant: 70),
            endCallButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupButtons() {
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(speakerButtonTapped), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)
    }
    
    @objc private func muteButtonTapped() {
        isMuted.toggle()
        
        if let plugin = TwilioVoicePlugin.shared {
            if let activeCall = plugin.value(forKey: "activeCall") as? NSObject {
                activeCall.setValue(isMuted, forKey: "isMuted")
            }
        }
        
        updateMuteButton()
    }
    
    @objc private func speakerButtonTapped() {
        isSpeakerOn.toggle()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if isSpeakerOn {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            updateSpeakerButton(enabled: isSpeakerOn)
        } catch {
            print("Failed to toggle speaker: \(error)")
        }
    }
    
    @objc private func endCallButtonTapped() {
        if let plugin = TwilioVoicePlugin.shared {
            if let activeCall = plugin.value(forKey: "activeCall") as? NSObject {
                activeCall.perform(NSSelectorFromString("disconnect"))
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func updateMuteButton() {
        if isMuted {
            muteButton.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0)
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            let image = UIImage(systemName: "mic.slash.fill", withConfiguration: config)
            muteButton.setImage(image, for: .normal)
        } else {
            muteButton.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            let image = UIImage(systemName: "mic.fill", withConfiguration: config)
            muteButton.setImage(image, for: .normal)
        }
    }
    
    func updateSpeakerButton(enabled: Bool) {
        isSpeakerOn = enabled
        if isSpeakerOn {
            speakerButton.backgroundColor = UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0)
        } else {
            speakerButton.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        }
    }
    
    func updateCallStatus(_ status: CallStatus) {
        callStatus = status
        
        switch status {
        case .connecting:
            callStatusLabel.text = "Connecting..."
        case .ringing:
            callStatusLabel.text = "Ringing..."
        case .connected:
            callStatusLabel.text = "Connected"
            durationLabel.isHidden = false
            startDurationTimer()
        case .disconnected:
            callStatusLabel.text = "Disconnected"
            stopDurationTimer()
        }
    }
    
    private func startDurationTimer() {
        callStartTime = Date()
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
        }
    }
    
    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
    
    private func updateDuration() {
        guard let startTime = callStartTime else { return }
        
        let duration = Int(Date().timeIntervalSince(startTime))
        let minutes = duration / 60
        let seconds = duration % 60
        
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        stopDurationTimer()
    }
}
