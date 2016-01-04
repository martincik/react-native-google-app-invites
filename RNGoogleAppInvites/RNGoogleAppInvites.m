#import "RNGoogleAppInvites.h"
#import "RCTEventDispatcher.h"

@implementation RNGoogleAppInvites

static NSString* kTrackingID = @"YOUR_TRACKING_ID";

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

RCT_EXPORT_METHOD(invite:(NSString *) message
               withTitle:(NSString *) title
            withDeepLink:(NSString *) deepLink)
{
  self.inviteDialog = [GINInvite inviteDialog];
  [self.inviteDialog setInviteDelegate: self];

  // A message hint for the dialog. Note this manifests differently depending on the
  // received invation type. For example, in an email invite this appears as the subject.
  [self.inviteDialog setMessage: message];

  // Title for the dialog, this is what the user sees before sending the invites.
  [self.inviteDialog setTitle: title];
  [self.inviteDialog setDeepLink: deepLink];
  [self.inviteDialog open];
}

RCT_EXPORT_METHOD(configure:(NSString *)clientID withScopes:(NSArray *)scopes)
{
  [GIDSignIn sharedInstance].delegate = self;
  [GIDSignIn sharedInstance].uiDelegate = self;

  [GIDSignIn sharedInstance].clientID = clientID;
  [GIDSignIn sharedInstance].scopes = scopes;

  [GIDSignIn sharedInstance].allowsSignInWithBrowser = NO;
}

RCT_EXPORT_METHOD(signIn)
{
  [[GIDSignIn sharedInstance] signIn];
}

RCT_EXPORT_METHOD(signOut)
{
  [[GIDSignIn sharedInstance] signOut];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)applicationDidFinishLaunching {
  NSError* configureError;
  [[GGLContext sharedInstance] configureWithError:&configureError];
  NSAssert(!configureError, @"Error configuring Google services: %@", configureError);

  [GINInvite applicationDidFinishLaunching];

  if ([kTrackingID compare:@"YOUR_TRACKING_ID"] != NSOrderedSame) {
    [GINInvite setGoogleAnalyticsTrackingId: kTrackingID];
  }

  return YES;
}

// This is called whenever the user get's invite URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

  GINReceivedInvite *invite = [GINInvite handleURL:url
                                 sourceApplication:sourceApplication
                                        annotation:annotation];
  if (invite) {
    [GINInvite completeInvitation];

    NSString *matchType =
        (invite.matchType == kGINReceivedInviteMatchTypeWeak) ? @"Weak" : @"Strong";
    NSDictionary *body = @{
                           @"matchType": matchType,
                           @"deepLinkFrom": sourceApplication,
                           @"inviteId": invite.inviteId,
                           @"appURL": invite.deepLink,
                           };
    [self.bridge.eventDispatcher sendAppEventWithName:@"googleAppInviteConvertion" body:body];

    [GINInvite convertInvitation:invite.inviteId];

    return YES;
  }

  return [[GIDSignIn sharedInstance] handleURL:url
                             sourceApplication:sourceApplication
                                    annotation:annotation];
}

// This is called when the inviteTapped method is done
- (void)inviteFinishedWithInvitations:(NSArray *)invitationIds
                                error:(NSError *)error {
  NSDictionary *body = @{
                         @"error": error ? error.localizedDescription : [NSNull null],
                         @"invitationIds": invitationIds ? invitationIds : [NSNull null]
                        };

  [self.bridge.eventDispatcher sendAppEventWithName:@"googleAppInviteIds" body:body];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {

  if (error != Nil) {
    return [self.bridge.eventDispatcher sendAppEventWithName:@"googleSignInError"
                                                        body:@{@"error": error.description}];
  }

  NSDictionary *body = @{
                         @"name": user.profile.name,
                         @"email": user.profile.email,
                         @"accessToken": user.authentication.accessToken,
                         @"accessTokenExpirationDate": [NSNumber numberWithDouble:user.authentication.accessTokenExpirationDate.timeIntervalSinceNow]
                         };

  return [self.bridge.eventDispatcher sendAppEventWithName:@"googleSignIn" body:body];
}

- (void) signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
  return [self.bridge.eventDispatcher sendAppEventWithName:@"googleSignInWillDispatch"
                                                      body:@{}];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
  NSLog(@"Disconnect");
}

- (void) signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
  UIViewController *rootViewController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
  [rootViewController presentViewController:viewController animated:true completion:nil];
}

- (void) signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
  [viewController dismissViewControllerAnimated:true completion:nil];
}

@end
