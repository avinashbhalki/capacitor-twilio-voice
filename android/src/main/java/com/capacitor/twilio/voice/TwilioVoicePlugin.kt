package com.capacitor.twilio.voice

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
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
            strings = [
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_CONNECT
            ],
            alias = "audio"
        )
    ]
)
class TwilioVoicePlugin : Plugin() {

    companion object {
        var currentPlugin: TwilioVoicePlugin? = null
        const val PERMISSIONS_REQUEST_CODE = 1001
    }

    override fun load() {
        currentPlugin = this
    }

    @PluginMethod
    fun startCall(call: PluginCall) {
        val toNumber = call.getString("toNumber")
        val accessToken = call.getString("accessToken")

        if (toNumber == null || toNumber.isEmpty()) {
            call.reject("toNumber is required")
            return
        }

        if (accessToken == null || accessToken.isEmpty()) {
            call.reject("accessToken is required")
            return
        }

        // Check for required permissions
        if (!hasRequiredPermissions()) {
            requestAllPermissions(call, "PERMISSIONS_REQUEST_CODE")
            return
        }

        // Start the call activity
        val intent = Intent(activity, CallActivity::class.java).apply {
            putExtra("toNumber", toNumber)
            putExtra("accessToken", accessToken)
        }

        activity.startActivity(intent)
        call.resolve()
    }

    @PluginMethod
    fun endCall(call: PluginCall) {
        val intent = Intent(CallActivity.ACTION_END_CALL)
        activity.sendBroadcast(intent)
        call.resolve()
    }

    @PluginMethod
    fun setMute(call: PluginCall) {
        val enabled = call.getBoolean("enabled", false) ?: false
        val intent = Intent(CallActivity.ACTION_SET_MUTE).apply {
            putExtra("enabled", enabled)
        }
        activity.sendBroadcast(intent)
        call.resolve()
    }

    @PluginMethod
    fun setSpeaker(call: PluginCall) {
        val enabled = call.getBoolean("enabled", false) ?: false
        val intent = Intent(CallActivity.ACTION_SET_SPEAKER).apply {
            putExtra("enabled", enabled)
        }
        activity.sendBroadcast(intent)
        call.resolve()
    }

    /**
     * Notify JavaScript listeners about call events
     */
    fun notifyCallConnected() {
        notifyListeners("callConnected", JSObject())
    }

    fun notifyCallDisconnected() {
        notifyListeners("callDisconnected", JSObject())
    }

    fun notifyCallFailed(error: String) {
        val data = JSObject()
        data.put("error", error)
        notifyListeners("callFailed", data)
    }

    /**
     * Check if all required permissions are granted
     */
    private fun hasRequiredPermissions(): Boolean {
        val context = activity.applicationContext
        val permissions = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_CONNECT
        )

        return permissions.all {
            ActivityCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    override fun handleOnDestroy() {
        super.handleOnDestroy()
        currentPlugin = null
    }
}
