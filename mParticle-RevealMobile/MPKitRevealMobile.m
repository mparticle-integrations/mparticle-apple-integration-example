//
//  MPKitRevealMobile.m
//
//  Copyright 2016 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitRevealMobile.h"
#import "mParticle.h"

// This rather convoluded set of #defines allows you to pass in environment variables
// for buddy build but not require them if you're not.
//
// Do to the XCode mechanism provided, you will get directive defined as empty instead
// of undefined if there is no environment variable defined. This is seems overly complex
// for such a simple task, but it handles all of the cases as far as I can see.
#define STRINGIFY(str) @#str
#define EXPAND_STRING(str) STRINGIFY(str)
#define NO_OTHER_MACRO_STARTS_WITH_THIS_NAME_
#define IS_EMPTY(name) defined(NO_OTHER_MACRO_STARTS_WITH_THIS_NAME_ ## name)
#define EMPTY(name) IS_EMPTY(name)

#define DO_EXPAND(VAL)  VAL ## 1
#define EXPAND(VAL)     DO_EXPAND(VAL)

#if !defined(USE_DEBUG_BEACONS) || (EXPAND(USE_DEBUG_BEACONS) == 1)
#define USE_DEBUG_BEACONS               0
#endif

/* Import your header file here
 */
#import <Reveal/Reveal.h>
//@import Reveal

// This is temporary to allow compilation (will be provided by core SDK)
NSUInteger MPKitInstanceRevealMobile = 112;

@interface MPKitRevealMobile () <RVLBeaconDelegate>

@property( nonatomic, strong) Reveal *sdk;

@end

@implementation MPKitRevealMobile

/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @112;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"RevealMobile" className:@"MPKitRevealMobile" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];

    NSLog( @"MPKitRevealMobile initWithConfiguration:\n%@\nstartImmediatly: %d", configuration, startImmediately );
    NSString *appKey = configuration[@"apiKey"];
    if (!self || !appKey) {
        return nil;
    }

    _configuration = configuration;

    if (startImmediately) {
        [self start];
    }

    return self;
}

- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        /*
            Start your SDK here. The configuration dictionary can be retrieved from self.configuration
         */
        NSString *appKey = self.configuration[@"apiKey"];
        // Get a reference to the SDK object
       self.sdk = [Reveal sharedInstance];
       //self.sdk.locationManager = [RVLAltLocatioManager new];
       
       // Turn on debug logging, not for production
       self.sdk.debug = YES;
       self.sdk.delegate = self;
       
       [self.sdk setupWithAPIKey: apiKey andServiceType: serviceType];

        _started = YES;

        // Override the beacon list for testing with known local beacons.
#if USE_DEBUG_BEACONS == 1
        self.sdk.debugUUIDs = @[
                              @"B9407F30-F5F8-466E-AFF9-25556B57FE6D",
                              @"23538c90-4e4c-4183-a32b-381cfd11c465",
                              @"97faaca4-d7f1-416d-a5a4-e922dc6edb29",
                              @"40A1EB68-883C-45D7-918B-CAB98350B1B1",
                              ];
#endif
    
        // Once the config values are set, start the SDK.
        // The SDK will contact the server for further config info
        // and start monitoring for beacons.
        [self.sdk start];

        NSLog( @"MPKitRevealMobile start completed" );

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

    return self.sdk;
}


#pragma mark Application
/*
    Implement this method if your SDK retrieves deep-linking information from a remote server and returns it to the host app
*/
// - (MPKitExecStatus *)checkForDeferredDeepLinkWithCompletionHandler:(void(^)(NSDictionary<NSString *, NSString *> *linkInfo, NSError *error))completionHandler {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK handles a user interacting with a remote notification action
*/
// - (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK receives and handles remote notifications
*/
// - (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK registers the device token for remote notifications
*/
// - (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK handles continueUserActivity method from the App Delegate
*/
// - (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK handles the iOS 9 and above App Delegate method to open URL with options
*/
// - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK handles the iOS 8 and below App Delegate method open URL
*/
// - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

#pragma mark User attributes and identities
/*
    Implement this method if your SDK sets user attributes. The core mParticle SDK also sets the userAttributes property.
*/
// - (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK allows for incrementing numeric user attributes.
*/
// - (MPKitExecStatus *)incrementUserAttribute:(NSString *)key byValue:(NSNumber *)value {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK resets user attributes.
*/
// - (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK sets user identities.
*/
// - (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
//     /*  Your code goes here.
//         If the execution is not successful, or the identity type is not supported, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//         Please see MPEnums.h > MPUserIdentity for all supported user identities
//      */
//
//      MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess];
//      return execStatus;
// }

#pragma mark e-Commerce
/*
    Implement this method if your SDK supports commerce events.
    If your SDK does support commerce event, but does not support all commerce event actions available in the mParticle SDK,
    expand the received commerce event into regular events and log them accordingly (see sample code below)
    Please see MPCommerceEvent.h > MPCommerceEventAction for complete list
*/
// - (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:MPKitReturnCodeSuccess forwardCount:0];
//
//     // In this example, this SDK only supports the 'Purchase' commerce event action
//     if (commerceEvent.action == MPCommerceEventActionPurchase) {
//             /* Your code goes here. */
//
//             [execStatus incrementForwardCount];
//         }
//     } else { // Other commerce events are expanded and logged as regular events
//         NSArray *expandedInstructions = [commerceEvent expandedInstructions];
//
//         for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
//             [self logEvent:commerceEventInstruction.event];
//             [execStatus incrementForwardCount];
//         }
//     }
//
//     return execStatus;
// }

#pragma mark Events
/*
    Implement this method if your SDK logs user events.
    Please see MPEvent.h
*/
- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    /*  Your code goes here.
        If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
        Please see MPKitExecStatus.h for all exec status codes
     */

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

/*
    Implement this method if your SDK logs screen events
    Please see MPEvent.h
*/
// - (MPKitExecStatus *)logScreen:(MPEvent *)event {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCrittercism) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

#pragma mark Assorted
/*
    Implement this method if your SDK implements an opt out mechanism for users.
*/
// - (MPKitExecStatus *)setOptOut:(BOOL)optOut {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceRevealMobile) returnCode:returnCode];
//     return execStatus;
// }

@end
