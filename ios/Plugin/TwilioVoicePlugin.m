#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// This registers the plugin and the 'call' method with Capacitor
CAP_PLUGIN(TwilioVoicePlugin, "TwilioVoice",
           CAP_PLUGIN_METHOD(call, CAPPluginReturnPromise);
)
