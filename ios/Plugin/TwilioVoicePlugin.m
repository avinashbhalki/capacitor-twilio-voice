#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin with the JS name and methods
// This makes the 'call' method visible to the Capacitor bridge
CAP_PLUGIN(TwilioVoicePlugin, "TwilioVoice",
           CAP_PLUGIN_METHOD(call, CAPPluginReturnPromise);
)
