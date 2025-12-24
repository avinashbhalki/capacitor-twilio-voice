package com.capacitor.twilio.voice

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.ImageButton
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.twilio.voice.Call
import com.twilio.voice.CallException
import com.twilio.voice.CallInvite
import com.twilio.voice.ConnectOptions
import com.twilio.voice.Voice

class CallActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "TwilioCallActivity"
        const val ACTION_END_CALL = "com.capacitor.twilio.voice.END_CALL"
        const val ACTION_SET_MUTE = "com.capacitor.twilio.voice.SET_MUTE"
        const val ACTION_SET_SPEAKER = "com.capacitor.twilio.voice.SET_SPEAKER"
    }

    private var activeCall: Call? = null
    private var accessToken: String? = null
    private var toNumber: String? = null
    private var audioManager: AudioManager? = null
    private var previousAudioMode = 0

    // UI elements
    private lateinit var statusTextView: TextView
    private lateinit var phoneNumberTextView: TextView
    private lateinit var muteButton: ImageButton
    private lateinit var speakerButton: ImageButton
    private lateinit var endCallButton: ImageButton

    private var isMuted = false
    private var isSpeakerOn = false

    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_END_CALL -> {
                    disconnect()
                }
                ACTION_SET_MUTE -> {
                    val enabled = intent.getBooleanExtra("enabled", false)
                    setMute(enabled)
                }
                ACTION_SET_SPEAKER -> {
                    val enabled = intent.getBooleanExtra("enabled", false)
                    setSpeaker(enabled)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_call)

        // Initialize audio manager
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        previousAudioMode = audioManager?.mode ?: AudioManager.MODE_NORMAL

        // Get intent data
        accessToken = intent.getStringExtra("accessToken")
        toNumber = intent.getStringExtra("toNumber")

        // Initialize UI
        initializeUI()

        // Register broadcast receiver
        val filter = IntentFilter().apply {
            addAction(ACTION_END_CALL)
            addAction(ACTION_SET_MUTE)
            addAction(ACTION_SET_SPEAKER)
        }
        registerReceiver(broadcastReceiver, filter)

        // Start the call
        initiateCall()
    }

    private fun initializeUI() {
        statusTextView = findViewById(R.id.statusTextView)
        phoneNumberTextView = findViewById(R.id.phoneNumberTextView)
        muteButton = findViewById(R.id.muteButton)
        speakerButton = findViewById(R.id.speakerButton)
        endCallButton = findViewById(R.id.endCallButton)

        phoneNumberTextView.text = toNumber

        muteButton.setOnClickListener {
            toggleMute()
        }

        speakerButton.setOnClickListener {
            toggleSpeaker()
        }

        endCallButton.setOnClickListener {
            disconnect()
        }

        updateUI()
    }

    private fun initiateCall() {
        if (accessToken == null || toNumber == null) {
            updateStatus("Error: Missing parameters")
            TwilioVoicePlugin.currentPlugin?.notifyCallFailed("Missing access token or phone number")
            finish()
            return
        }

        updateStatus("Connecting...")

        try {
            val connectOptions = ConnectOptions.Builder(accessToken!!)
                .params(mapOf("To" to toNumber!!))
                .build()

            activeCall = Voice.connect(this, connectOptions, callListener)

            // Configure audio for call
            configureAudioForCall()

        } catch (e: Exception) {
            Log.e(TAG, "Error starting call", e)
            updateStatus("Failed to start call")
            TwilioVoicePlugin.currentPlugin?.notifyCallFailed(e.message ?: "Unknown error")
            finish()
        }
    }

    private val callListener = object : Call.Listener {
        override fun onConnectFailure(call: Call, error: CallException) {
            Log.e(TAG, "Call connect failure: ${error.message}")
            runOnUiThread {
                updateStatus("Call failed")
                TwilioVoicePlugin.currentPlugin?.notifyCallFailed(error.message ?: "Connection failed")
                finish()
            }
        }

        override fun onRinging(call: Call) {
            Log.d(TAG, "Call is ringing")
            runOnUiThread {
                updateStatus("Ringing...")
            }
        }

        override fun onConnected(call: Call) {
            Log.d(TAG, "Call connected")
            runOnUiThread {
                updateStatus("Connected")
                TwilioVoicePlugin.currentPlugin?.notifyCallConnected()
            }
        }

        override fun onReconnecting(call: Call, error: CallException) {
            Log.d(TAG, "Call reconnecting: ${error.message}")
            runOnUiThread {
                updateStatus("Reconnecting...")
            }
        }

        override fun onReconnected(call: Call) {
            Log.d(TAG, "Call reconnected")
            runOnUiThread {
                updateStatus("Connected")
            }
        }

        override fun onDisconnected(call: Call, error: CallException?) {
            Log.d(TAG, "Call disconnected")
            runOnUiThread {
                updateStatus("Disconnected")
                TwilioVoicePlugin.currentPlugin?.notifyCallDisconnected()
                finish()
            }
        }

        override fun onCallQualityWarningsChanged(
            call: Call,
            currentWarnings: MutableSet<Call.CallQualityWarning>,
            previousWarnings: MutableSet<Call.CallQualityWarning>
        ) {
            // Handle quality warnings if needed
        }
    }

    private fun disconnect() {
        activeCall?.disconnect()
        activeCall = null
    }

    private fun toggleMute() {
        setMute(!isMuted)
    }

    private fun setMute(mute: Boolean) {
        isMuted = mute
        activeCall?.mute(isMuted)
        updateUI()
    }

    private fun toggleSpeaker() {
        setSpeaker(!isSpeakerOn)
    }

    private fun setSpeaker(enabled: Boolean) {
        isSpeakerOn = enabled
        audioManager?.isSpeakerphoneOn = isSpeakerOn
        updateUI()
    }

    private fun configureAudioForCall() {
        audioManager?.apply {
            mode = AudioManager.MODE_IN_COMMUNICATION
            isSpeakerphoneOn = isSpeakerOn
        }
    }

    private fun restoreAudioSettings() {
        audioManager?.apply {
            mode = previousAudioMode
            isSpeakerphoneOn = false
        }
    }

    private fun updateStatus(status: String) {
        statusTextView.text = status
    }

    private fun updateUI() {
        // Update mute button appearance
        muteButton.alpha = if (isMuted) 1.0f else 0.5f

        // Update speaker button appearance
        speakerButton.alpha = if (isSpeakerOn) 1.0f else 0.5f
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(broadcastReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver", e)
        }
        disconnect()
        restoreAudioSettings()
    }
}
