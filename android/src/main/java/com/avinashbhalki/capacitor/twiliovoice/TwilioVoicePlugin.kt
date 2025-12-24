package com.avinashbhalki.capacitor.twiliovoice

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.getcapacitor.annotation.Permission
import com.twilio.voice.Call
import com.twilio.voice.CallException
import com.twilio.voice.CallInvite
import com.twilio.voice.ConnectOptions
import com.twilio.voice.Voice

/**
 * Capacitor plugin for Twilio Voice SDK
 * Provides methods to initiate, manage, and control voice calls
 */
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

    companion object {
        private const val PERMISSION_REQUEST_CODE = 1001
        const val EVENT_CALL_CONNECTED = "callConnected"
        const val EVENT_CALL_DISCONNECTED = "callDisconnected"
        const val EVENT_CALL_FAILED = "callFailed"
        
        var activeCall: Call? = null
        var pluginInstance: TwilioVoicePlugin? = null
    }

    private var pendingCall: PluginCall? = null

    override fun load() {
        super.load()
        pluginInstance = this
    }

    /**
     * Start an outgoing call with Twilio Voice
     * Opens a full-screen native call UI
     */
    @PluginMethod
    fun startCall(call: PluginCall) {
        val toNumber = call.getString("toNumber")
        val accessToken = call.getString("accessToken")
        val fromNumber = call.getString("fromNumber")

        if (toNumber.isNullOrEmpty()) {
            call.reject("toNumber is required")
            return
        }

        if (accessToken.isNullOrEmpty()) {
            call.reject("accessToken is required")
            return
        }

        // Check microphone permission
        if (!hasRequiredPermissions()) {
            pendingCall = call
            requestAllPermissions(call, "permissionCallback")
            return
        }

        initiateCall(toNumber, accessToken, fromNumber, call)
    }

    /**
     * End the current active call
     */
    @PluginMethod
    fun endCall(call: PluginCall) {
        activeCall?.let {
            it.disconnect()
            activeCall = null
            call.resolve()
        } ?: run {
            call.reject("No active call to end")
        }
    }

    /**
     * Mute or unmute the microphone
     */
    @PluginMethod
    fun setMute(call: PluginCall) {
        val enabled = call.getBoolean("enabled", false) ?: false
        
        activeCall?.let {
            it.mute(enabled)
            call.resolve()
        } ?: run {
            call.reject("No active call")
        }
    }

    /**
     * Enable or disable speaker
     */
    @PluginMethod
    fun setSpeaker(call: PluginCall) {
        val enabled = call.getBoolean("enabled", false) ?: false
        
        activity?.let { activity ->
            CallActivity.setSpeakerPhone(activity, enabled)
            call.resolve()
        } ?: run {
            call.reject("Activity not available")
        }
    }

    /**
     * Permission callback handler
     */
    @PluginMethod
    fun permissionCallback(call: PluginCall) {
        if (hasRequiredPermissions()) {
            pendingCall?.let { pending ->
                val toNumber = pending.getString("toNumber") ?: ""
                val accessToken = pending.getString("accessToken") ?: ""
                val fromNumber = pending.getString("fromNumber")
                
                initiateCall(toNumber, accessToken, fromNumber, pending)
                pendingCall = null
            }
        } else {
            call.reject("Microphone permission is required")
            pendingCall = null
        }
    }

    /**
     * Initiate the Twilio call and open call UI
     */
    private fun initiateCall(
        toNumber: String,
        accessToken: String,
        fromNumber: String?,
        call: PluginCall
    ) {
        try {
            val params = mutableMapOf<String, String>()
            params["To"] = toNumber
            fromNumber?.let { params["From"] = it }

            // Add any custom parameters
            call.getObject("customParameters")?.let { customParams ->
                customParams.keys().forEach { key ->
                    params[key] = customParams.getString(key) ?: ""
                }
            }

            val connectOptions = ConnectOptions.Builder(accessToken)
                .params(params)
                .build()

            activeCall = Voice.connect(context, connectOptions, callListener)

            // Launch the call activity
            val intent = Intent(context, CallActivity::class.java).apply {
                putExtra("toNumber", toNumber)
                putExtra("fromNumber", fromNumber ?: "")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)

            call.resolve()
        } catch (e: Exception) {
            call.reject("Failed to start call: ${e.message}", e)
        }
    }

    /**
     * Check if required permissions are granted
     */
    private fun hasRequiredPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Call listener for handling call events
     */
    private val callListener = object : Call.Listener {
        override fun onConnectFailure(call: Call, error: CallException) {
            activeCall = null
            
            val data = JSObject().apply {
                put("error", error.message ?: "Unknown error")
                put("code", error.errorCode)
            }
            notifyListeners(EVENT_CALL_FAILED, data)
            
            // Close call activity
            CallActivity.finishActivity()
        }

        override fun onRinging(call: Call) {
            // Call is ringing
        }

        override fun onConnected(call: Call) {
            notifyListeners(EVENT_CALL_CONNECTED, JSObject())
        }

        override fun onReconnecting(call: Call, error: CallException) {
            // Call is reconnecting
        }

        override fun onReconnected(call: Call) {
            // Call reconnected
        }

        override fun onDisconnected(call: Call, error: CallException?) {
            activeCall = null
            
            if (error != null) {
                val data = JSObject().apply {
                    put("error", error.message ?: "Call disconnected with error")
                    put("code", error.errorCode)
                }
                notifyListeners(EVENT_CALL_FAILED, data)
            } else {
                notifyListeners(EVENT_CALL_DISCONNECTED, JSObject())
            }
            
            // Close call activity
            CallActivity.finishActivity()
        }

        override fun onCallQualityWarningsChanged(
            call: Call,
            currentWarnings: MutableSet<Call.CallQualityWarning>,
            previousWarnings: MutableSet<Call.CallQualityWarning>
        ) {
            // Handle quality warnings if needed
        }
    }

    /**
     * Notify JavaScript listeners of events
     */
    internal fun notifyEvent(eventName: String, data: JSObject) {
        notifyListeners(eventName, data)
    }
}
