package com.avinashbhalki.capacitor.twiliovoice

import android.media.AudioManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.ImageButton
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.twilio.voice.Call
import com.twilio.voice.CallException
import com.twilio.voice.ConnectOptions
import com.twilio.voice.Voice

class CallActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "CallActivity"
    }

    private var activeCall: Call? = null
    private var accessToken: String = ""
    private var toNumber: String = ""
    
    private var isMuted = false
    private var isSpeakerOn = false
    
    private lateinit var tvStatus: TextView
    private lateinit var tvNumber: TextView
    private lateinit var btnMute: ImageButton
    private lateinit var btnSpeaker: ImageButton
    private lateinit var btnEndCall: ImageButton
    
    private val callListener = object : Call.Listener {
        override fun onConnectFailure(call: Call, error: CallException) {
            Log.e(TAG, "Call failed: ${error.message}")
            runOnUiThread {
                tvStatus.text = "Call Failed"
                Toast.makeText(this@CallActivity, "Call failed: ${error.message}", Toast.LENGTH_SHORT).show()
                finish()
            }
        }

        override fun onRinging(call: Call) {
            Log.d(TAG, "Call ringing")
            runOnUiThread {
                tvStatus.text = "Ringing..."
            }
        }

        override fun onConnected(call: Call) {
            Log.d(TAG, "Call connected")
            runOnUiThread {
                tvStatus.text = "Connected"
                enableCallControls()
            }
        }

        override fun onReconnecting(call: Call, error: CallException) {
            Log.d(TAG, "Call reconnecting: ${error.message}")
            runOnUiThread {
                tvStatus.text = "Reconnecting..."
            }
        }

        override fun onReconnected(call: Call) {
            Log.d(TAG, "Call reconnected")
            runOnUiThread {
                tvStatus.text = "Connected"
            }
        }

        override fun onDisconnected(call: Call, error: CallException?) {
            Log.d(TAG, "Call disconnected")
            runOnUiThread {
                if (error != null) {
                    tvStatus.text = "Disconnected: ${error.message}"
                } else {
                    tvStatus.text = "Call Ended"
                }
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_call)

        // Get intent extras
        toNumber = intent.getStringExtra("toNumber") ?: ""
        accessToken = intent.getStringExtra("accessToken") ?: ""

        if (toNumber.isEmpty() || accessToken.isEmpty()) {
            Toast.makeText(this, "Invalid call parameters", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        initializeViews()
        setupClickListeners()
        initiateCall()
    }

    private fun initializeViews() {
        tvStatus = findViewById(R.id.tvStatus)
        tvNumber = findViewById(R.id.tvNumber)
        btnMute = findViewById(R.id.btnMute)
        btnSpeaker = findViewById(R.id.btnSpeaker)
        btnEndCall = findViewById(R.id.btnEndCall)

        tvNumber.text = toNumber
        tvStatus.text = "Connecting..."
        
        // Disable controls initially
        btnMute.isEnabled = false
        btnSpeaker.isEnabled = false
    }

    private fun setupClickListeners() {
        btnMute.setOnClickListener {
            toggleMute()
        }

        btnSpeaker.setOnClickListener {
            toggleSpeaker()
        }

        btnEndCall.setOnClickListener {
            endCall()
        }
    }

    private fun initiateCall() {
        try {
            val params = hashMapOf("To" to toNumber)
            val connectOptions = ConnectOptions.Builder(accessToken)
                .params(params)
                .build()

            activeCall = Voice.connect(this, connectOptions, callListener)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error initiating call: ${e.message}")
            Toast.makeText(this, "Failed to initiate call", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    private fun enableCallControls() {
        btnMute.isEnabled = true
        btnSpeaker.isEnabled = true
    }

    private fun toggleMute() {
        activeCall?.let { call ->
            isMuted = !isMuted
            call.mute(isMuted)
            
            if (isMuted) {
                btnMute.setImageResource(android.R.drawable.ic_lock_silent_mode)
                btnMute.alpha = 1.0f
            } else {
                btnMute.setImageResource(android.R.drawable.ic_btn_speak_now)
                btnMute.alpha = 0.6f
            }
        }
    }

    private fun toggleSpeaker() {
        isSpeakerOn = !isSpeakerOn
        
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        audioManager.isSpeakerphoneOn = isSpeakerOn
        
        if (isSpeakerOn) {
            btnSpeaker.alpha = 1.0f
        } else {
            btnSpeaker.alpha = 0.6f
        }
    }

    private fun endCall() {
        activeCall?.disconnect()
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        activeCall?.disconnect()
        activeCall = null
    }
}
