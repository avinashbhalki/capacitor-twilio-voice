package com.example.twiliovoice

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView

class CallingActivity : Activity() {

    private lateinit var btnMute: Button
    private lateinit var btnSpeaker: Button
    private lateinit var btnEndCall: Button
    private lateinit var tvStatus: TextView

    private var isMuted = false
    private var isSpeakerOn = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(resources.getIdentifier("activity_calling", "layout", packageName))

        val idMute = resources.getIdentifier("btnMute", "id", packageName)
        val idSpeaker = resources.getIdentifier("btnSpeaker", "id", packageName)
        val idEndCall = resources.getIdentifier("btnEndCall", "id", packageName)
        val idStatus = resources.getIdentifier("callerStatus", "id", packageName)

        btnMute = findViewById(idMute)
        btnSpeaker = findViewById(idSpeaker)
        btnEndCall = findViewById(idEndCall)
        tvStatus = findViewById(idStatus)

        btnMute.setOnClickListener {
            isMuted = !isMuted
            btnMute.text = if (isMuted) "Unmute" else "Mute"
            sendAction("MUTE")
        }

        btnSpeaker.setOnClickListener {
            isSpeakerOn = !isSpeakerOn
            btnSpeaker.text = if (isSpeakerOn) "Phone" else "Speaker"
            sendAction("SPEAKER")
        }

        btnEndCall.setOnClickListener {
            sendAction("HANGUP")
            finish()
        }
    }

    private fun sendAction(action: String) {
        val intent = Intent("com.example.twiliovoice.ACTION_CONTROL")
        intent.putExtra("ACTION", action)
        sendBroadcast(intent)
    }
}
