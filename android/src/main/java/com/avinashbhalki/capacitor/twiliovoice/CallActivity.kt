package com.avinashbhalki.capacitor.twiliovoice

import android.app.Activity
import android.content.Context
import android.media.AudioManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.ImageButton
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.twilio.voice.Call

/**
 * Full-screen call activity with native UI controls
 * Displays mute, speaker, and end call buttons
 */
class CallActivity : AppCompatActivity() {

    companion object {
        private var currentActivity: CallActivity? = null
        
        fun finishActivity() {
            currentActivity?.finish()
        }
        
        fun setSpeakerPhone(context: Context, enabled: Boolean) {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.isSpeakerphoneOn = enabled
            currentActivity?.updateSpeakerButton(enabled)
        }
    }

    private lateinit var tvCallStatus: TextView
    private lateinit var tvPhoneNumber: TextView
    private lateinit var tvCallDuration: TextView
    private lateinit var btnMute: ImageButton
    private lateinit var btnSpeaker: ImageButton
    private lateinit var btnEndCall: ImageButton

    private var isMuted = false
    private var isSpeakerOn = false
    private var callStartTime: Long = 0
    private val handler = Handler(Looper.getMainLooper())
    private var isCallConnected = false

    private val durationRunnable = object : Runnable {
        override fun run() {
            if (isCallConnected) {
                val duration = (System.currentTimeMillis() - callStartTime) / 1000
                val minutes = duration / 60
                val seconds = duration % 60
                tvCallDuration.text = String.format("%02d:%02d", minutes, seconds)
                handler.postDelayed(this, 1000)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        currentActivity = this
        
        // Create UI programmatically
        createUI()
        
        // Get call details from intent
        val toNumber = intent.getStringExtra("toNumber") ?: "Unknown"
        val fromNumber = intent.getStringExtra("fromNumber") ?: ""
        
        tvPhoneNumber.text = toNumber
        tvCallStatus.text = "Calling..."
        
        // Setup audio
        setupAudio()
        
        // Setup button listeners
        setupButtons()
        
        // Monitor call state
        monitorCallState()
    }

    private fun createUI() {
        // Create root layout
        val rootLayout = android.widget.RelativeLayout(this).apply {
            setBackgroundColor(android.graphics.Color.parseColor("#1E1E1E"))
            layoutParams = android.widget.RelativeLayout.LayoutParams(
                android.widget.RelativeLayout.LayoutParams.MATCH_PARENT,
                android.widget.RelativeLayout.LayoutParams.MATCH_PARENT
            )
        }

        // Call status text
        tvCallStatus = TextView(this).apply {
            id = View.generateViewId()
            text = "Calling..."
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#B0B0B0"))
            gravity = android.view.Gravity.CENTER
        }
        val statusParams = android.widget.RelativeLayout.LayoutParams(
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT,
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            addRule(android.widget.RelativeLayout.CENTER_HORIZONTAL)
            topMargin = dpToPx(100)
        }
        rootLayout.addView(tvCallStatus, statusParams)

        // Phone number text
        tvPhoneNumber = TextView(this).apply {
            id = View.generateViewId()
            text = ""
            textSize = 28f
            setTextColor(android.graphics.Color.WHITE)
            gravity = android.view.Gravity.CENTER
        }
        val phoneParams = android.widget.RelativeLayout.LayoutParams(
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT,
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            addRule(android.widget.RelativeLayout.CENTER_HORIZONTAL)
            addRule(android.widget.RelativeLayout.BELOW, tvCallStatus.id)
            topMargin = dpToPx(16)
        }
        rootLayout.addView(tvPhoneNumber, phoneParams)

        // Call duration text
        tvCallDuration = TextView(this).apply {
            id = View.generateViewId()
            text = "00:00"
            textSize = 18f
            setTextColor(android.graphics.Color.parseColor("#B0B0B0"))
            gravity = android.view.Gravity.CENTER
            visibility = View.GONE
        }
        val durationParams = android.widget.RelativeLayout.LayoutParams(
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT,
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            addRule(android.widget.RelativeLayout.CENTER_HORIZONTAL)
            addRule(android.widget.RelativeLayout.BELOW, tvPhoneNumber.id)
            topMargin = dpToPx(16)
        }
        rootLayout.addView(tvCallDuration, durationParams)

        // Button container
        val buttonContainer = android.widget.LinearLayout(this).apply {
            id = View.generateViewId()
            orientation = android.widget.LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER
        }
        val containerParams = android.widget.RelativeLayout.LayoutParams(
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT,
            android.widget.RelativeLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            addRule(android.widget.RelativeLayout.CENTER_IN_PARENT)
        }
        rootLayout.addView(buttonContainer, containerParams)

        // Mute button
        btnMute = createRoundButton("#4A4A4A")
        btnMute.setImageResource(android.R.drawable.ic_btn_speak_now)
        buttonContainer.addView(btnMute, createButtonLayoutParams())

        // Speaker button
        btnSpeaker = createRoundButton("#4A4A4A")
        btnSpeaker.setImageResource(android.R.drawable.stat_sys_speakerphone)
        buttonContainer.addView(btnSpeaker, createButtonLayoutParams())

        // End call button
        btnEndCall = createRoundButton("#E74C3C")
        btnEndCall.setImageResource(android.R.drawable.ic_menu_call)
        buttonContainer.addView(btnEndCall, createButtonLayoutParams())

        setContentView(rootLayout)
    }

    private fun createRoundButton(color: String): ImageButton {
        return ImageButton(this).apply {
            val drawable = android.graphics.drawable.GradientDrawable().apply {
                shape = android.graphics.drawable.GradientDrawable.OVAL
                setColor(android.graphics.Color.parseColor(color))
            }
            background = drawable
            scaleType = android.widget.ImageView.ScaleType.CENTER
            setPadding(dpToPx(20), dpToPx(20), dpToPx(20), dpToPx(20))
        }
    }

    private fun createButtonLayoutParams(): android.widget.LinearLayout.LayoutParams {
        return android.widget.LinearLayout.LayoutParams(
            dpToPx(70),
            dpToPx(70)
        ).apply {
            setMargins(dpToPx(16), 0, dpToPx(16), 0)
        }
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    private fun setupAudio() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
        audioManager.isSpeakerphoneOn = false
        volumeControlStream = AudioManager.STREAM_VOICE_CALL
    }

    private fun setupButtons() {
        btnMute.setOnClickListener {
            isMuted = !isMuted
            TwilioVoicePlugin.activeCall?.mute(isMuted)
            updateMuteButton()
        }

        btnSpeaker.setOnClickListener {
            isSpeakerOn = !isSpeakerOn
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.isSpeakerphoneOn = isSpeakerOn
            updateSpeakerButton(isSpeakerOn)
        }

        btnEndCall.setOnClickListener {
            endCall()
        }
    }

    private fun updateMuteButton() {
        if (isMuted) {
            btnMute.setColorFilter(android.graphics.Color.parseColor("#E74C3C"))
        } else {
            btnMute.clearColorFilter()
        }
    }

    fun updateSpeakerButton(enabled: Boolean) {
        isSpeakerOn = enabled
        if (isSpeakerOn) {
            btnSpeaker.setColorFilter(android.graphics.Color.parseColor("#3498DB"))
        } else {
            btnSpeaker.clearColorFilter()
        }
    }

    private fun monitorCallState() {
        handler.postDelayed({
            TwilioVoicePlugin.activeCall?.let { call ->
                when (call.state) {
                    Call.State.CONNECTED -> {
                        if (!isCallConnected) {
                            isCallConnected = true
                            callStartTime = System.currentTimeMillis()
                            tvCallStatus.text = "Connected"
                            tvCallDuration.visibility = View.VISIBLE
                            handler.post(durationRunnable)
                        }
                    }
                    Call.State.CONNECTING -> {
                        tvCallStatus.text = "Connecting..."
                    }
                    Call.State.RINGING -> {
                        tvCallStatus.text = "Ringing..."
                    }
                    Call.State.DISCONNECTED -> {
                        finish()
                    }
                    else -> {}
                }
                monitorCallState()
            } ?: finish()
        }, 500)
    }

    private fun endCall() {
        TwilioVoicePlugin.activeCall?.disconnect()
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(durationRunnable)
        currentActivity = null
        
        // Reset audio
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.mode = AudioManager.MODE_NORMAL
        audioManager.isSpeakerphoneOn = false
    }

    override fun onBackPressed() {
        // Prevent back button from closing call
    }
}
