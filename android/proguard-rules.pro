# Proguard rules for Twilio Voice SDK

# Keep Twilio Voice classes
-keep class com.twilio.voice.** { *; }
-keep interface com.twilio.voice.** { *; }

# Keep WebRTC classes used by Twilio
-keep class org.webrtc.** { *; }

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
