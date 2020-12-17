#import "MPKitExample.h"

/* Import your header file here
*/
//#if defined(__has_include) && __has_include(<Example/Example.h>)
//#import <Example/Example.h>
//#else
//#import "Example.h"
//#endif

@implementation MPKitExample

/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @123;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Example" className:@"MPKitExample"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *apiKey = configuration[@"<dictionary key to retrieve API Key>"];
    if (!apiKey) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }

    _configuration = configuration;

    [self start];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        /*
            Start your SDK here. The configuration dictionary can be retrieved from self->_configuration
         */

        self->_started = YES;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    if (![self started]) {
        return nil;
    }

    /*
        If your company SDK instance is available and is applicable (Please return nil if your SDK is based on class methods)
     */
    BOOL kitInstanceAvailable = NO;
    if (kitInstanceAvailable) {
        /* Return an instance of your company's SDK (if applicable) */
        return nil;
    } else {
        return nil;
    }
}


#pragma mark Application
/*
    Implement this method if your SDK handles a user interacting with a remote notification action
*/
 - (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK receives and handles remote notifications
*/
 - (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK registers the device token for remote notifications
*/
 - (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK handles continueUserActivity method from the App Delegate
*/
 - (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK handles the iOS 9 and above App Delegate method to open URL with options
*/
 - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK handles the iOS 8 and below App Delegate method open URL
*/
 - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

#pragma mark User attributes
/*
    Implement this method if your SDK allows for incrementing numeric user attributes.
*/
- (MPKitExecStatus *)onIncrementUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK resets user attributes.
*/
- (MPKitExecStatus *)onRemoveUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK sets user attributes.
*/
- (MPKitExecStatus *)onSetUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK supports setting value-less attributes
*/
- (MPKitExecStatus *)onSetUserTag:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark Identity
/*
    Implement this method if your SDK should be notified any time the mParticle ID (MPID) changes. This will occur on initial install of the app, and potentially after a login or logout.
*/
- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK should be notified when the user logs in
*/
- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK should be notified when the user logs out
*/
- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK should be notified when user identities change
*/
- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark Events
/*
    Implement this method if your SDK wants to log any kind of events.
    Please see MPBaseEvent.h
*/
- (nonnull MPKitExecStatus *)logBaseEvent:(nonnull MPBaseEvent *)event {
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else if ([event isKindOfClass:[MPCommerceEvent class]]) {
        return [self routeCommerceEvent:(MPCommerceEvent *)event];
    } else {
        return [self execStatus:MPKitReturnCodeUnavailable];
    }
}
/*
    Implement this method if your SDK logs user events.
    This requires logBaseEvent to be implemented as well.
    Please see MPEvent.h
*/
 - (MPKitExecStatus *)routeEvent:(MPEvent *)event {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }
/*
    Implement this method if your SDK logs screen events
    Please see MPEvent.h
*/
 - (MPKitExecStatus *)logScreen:(MPEvent *)event {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

#pragma mark e-Commerce
/*
    Implement this method if your SDK supports commerce events.
    This requires logBaseEvent to be implemented as well.
    If your SDK does support commerce event, but does not support all commerce event actions available in the mParticle SDK,
    expand the received commerce event into regular events and log them accordingly (see sample code below)
    Please see MPCommerceEvent.h > MPCommerceEventAction for complete list
*/
 - (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
     MPKitExecStatus *execStatus = [self execStatus:MPKitReturnCodeSuccess];

     // In this example, this SDK only supports the 'Purchase' commerce event action
     if (commerceEvent.action == MPCommerceEventActionPurchase) {
             /* Your code goes here. */

             [execStatus incrementForwardCount];
     } else { // Other commerce events are expanded and logged as regular events
         NSArray *expandedInstructions = [commerceEvent expandedInstructions];

         for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
             [self routeEvent:commerceEventInstruction.event];
             [execStatus incrementForwardCount];
         }
     }

     return execStatus;
 }

#pragma mark Assorted
/*
    Implement this method if your SDK implements an opt out mechanism for users.
*/
 - (MPKitExecStatus *)setOptOut:(BOOL)optOut {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */

     return [self execStatus:MPKitReturnCodeSuccess];
 }

@end
