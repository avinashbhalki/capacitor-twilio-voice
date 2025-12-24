package com.example.twiliovoice

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.getcapacitor.annotation.Permission

@CapacitorPlugin(
    name = "TwilioVoice",
    permissions = [
        Permission(
            strings = [Manifest.permission.RECORD_AUDIO],
            alias = "microphone"
        )
    ]
)
class TwilioVoicePlugin : Plugin() {

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.getStringExtra("ACTION")
            when(action) {
                "MUTE" -> handleMute()
                "SPEAKER" -> handleSpeaker()
                "HANGUP" -> handleHangup()
            }
        }
    }

    override fun load() {
        super.load()
        val filter = IntentFilter("com.example.twiliovoice.ACTION_CONTROL")
        context.registerReceiver(receiver, filter)
    }

    override fun handleOnDestroy() {
         super.handleOnDestroy()
         try {
             context.unregisterReceiver(receiver)
         } catch(e: Exception) {
             // ignore
         }
    }

    @PluginMethod
    fun makeCall(call: PluginCall) {
        val to = call.getString("to")
        // Logic to start Twilio call to 'to' would go here.
        
        // Launch UI
        val intent = Intent(context, CallingActivity::class.java)
        intent.putExtra("to", to)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        
        call.resolve()
    }

    @PluginMethod
    fun endCall(call: PluginCall) {
        // Logic to end call would go here
        
        // If we want to close the UI programmatically, we'd need another broadcast to the Activity.
        // For now, we resolve.
        call.resolve()
    }

    private fun handleMute() {
        // TODO: Integrate with Twilio Voice SDK mute
        notifyListeners("log", JSObject().put("message", "Mute requested from UI"))
    }

    private fun handleSpeaker() {
        // TODO: Integrate with Audio Manager
        notifyListeners("log", JSObject().put("message", "Speaker requested from UI"))
    }

    private fun handleHangup() {
        // TODO: Integrate with Twilio Voice SDK disconnect
        notifyListeners("callEnded", JSObject())
        // The Activity calls finish() itself, so no need to sending close intent unless we failed to hangup.
    }
}