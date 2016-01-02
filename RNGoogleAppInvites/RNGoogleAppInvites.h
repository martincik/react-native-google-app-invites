#ifndef RN_GoogleAppInvites_h
#define RN_GoogleAppInvites_h

#import "RCTBridgeModule.h"
#import <Google/AppInvite.h>
#import <Google/SignIn.h>

@class GGLContext;

@interface RNGoogleAppInvites : NSObject<RCTBridgeModule, GINInviteDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong, nonatomic) id<GINInviteBuilder> inviteDialog;

// Register AppInvites
+ (BOOL)applicationDidFinishLaunching;

// Receive Invitation from outside URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

@end


#endif
