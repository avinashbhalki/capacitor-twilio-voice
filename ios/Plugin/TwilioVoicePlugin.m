#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(TwilioVoicePlugin, "TwilioVoice",
           CAP_PLUGIN_METHOD(startCall, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(endCall, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setMute, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setSpeaker, CAPPluginReturnPromise);
)
