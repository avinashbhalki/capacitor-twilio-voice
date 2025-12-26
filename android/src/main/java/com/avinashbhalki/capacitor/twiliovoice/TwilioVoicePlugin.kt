package com.avinashbhalki.capacitor.twiliovoice

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "TwilioVoice")
class TwilioVoicePlugin : Plugin() {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 1001
        private val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS
        )
    }

    private var pendingCall: PluginCall? = null

    @PluginMethod
    fun call(call: PluginCall) {
        val to = call.getString("to")
        val accessToken = call.getString("accessToken")

        if (to.isNullOrEmpty()) {
            call.reject("to is required")
            return
        }

        if (accessToken.isNullOrEmpty()) {
            call.reject("accessToken is required")
            return
        }

        // Check permissions
        if (!hasRequiredPermissions()) {
            pendingCall = call
            requestPermissions()
            return
        }

        // Start call activity
        startCallActivity(to, accessToken, call)
    }

    override fun hasRequiredPermissions(): Boolean {
        return REQUIRED_PERMISSIONS.all { permission ->
            ContextCompat.checkSelfPermission(
                context,
                permission
            ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestPermissions() {
        ActivityCompat.requestPermissions(
            activity,
            REQUIRED_PERMISSIONS,
            PERMISSION_REQUEST_CODE
        )
    }

    override fun handleRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.handleRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }

            if (allGranted) {
                pendingCall?.let { call ->
                    val to = call.getString("to") ?: ""
                    val accessToken = call.getString("accessToken") ?: ""
                    startCallActivity(to, accessToken, call)
                }
            } else {
                pendingCall?.reject("Permissions denied")
            }
            pendingCall = null
        }
    }

    private fun startCallActivity(to: String, accessToken: String, call: PluginCall) {
        try {
            val intent = Intent(context, CallActivity::class.java).apply {
                putExtra("to", to)
                putExtra("accessToken", accessToken)
            }
            activity.startActivity(intent)
            call.resolve()
        } catch (e: Exception) {
            call.reject("Failed to start call: ${e.message}", e)
        }
    }
}
