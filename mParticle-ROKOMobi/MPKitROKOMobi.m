//
//  MPKitROKOMobi.m
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

#import "MPKitROKOMobi.h"

@interface MPKitROKOMobi() <ROKOLinkManagerDelegate>

@property (nonatomic, strong) ROKOPush *pusher;
@property (nonatomic, strong) ROKOLinkManager *linkManager;

@property (nonatomic, strong) ROKOInstaBot *instabot;

@end

@implementation MPKitROKOMobi

@synthesize instabot = _instabot;

- (ROKOInstaBot *)instabot {
    if (!_instabot) {
        _instabot = [ROKOInstaBot new];
    }
    return _instabot;
}

/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @123;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"ROKOMobi" className:@"MPKitROKOMobi" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
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
        
        _started = YES;
        
        self.linkManager = [[ROKOLinkManager alloc] init];
        self.linkManager.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    return [self started] ? self.instabot : nil;
}


#pragma mark Application
/*
    Implement this method if your SDK retrieves deep-linking information from a remote server and returns it to the host app
*/
//- (MPKitExecStatus *)checkForDeferredDeepLinkWithCompletionHandler:(void(^)(NSDictionary *linkInfo, NSError *error))completionHandler {
//    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
//    return execStatus;
//}

/*
    Implement this method if your SDK handles continueUserActivity method from the App Delegate
*/
- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    [_linkManager  continueUserActivity:userActivity];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

/*
    Implement this method if your SDK handles the iOS 9 and above App Delegate method to open URL with options
*/
- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
    [_linkManager handleDeepLink:url];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

/*
    Implement this method if your SDK handles the iOS 8 and below App Delegate method open URL
*/
// - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

#pragma mark Push

/*
 Implement this method if your SDK handles a user interacting with a remote notification action
 */
- (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

/*
 Implement this method if your SDK receives and handles remote notifications
 */
- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    
    if (_pusher) {
        [_pusher handleNotification:userInfo];
    }
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

/*
 Implement this method if your SDK registers the device token for remote notifications
 */
- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    
    _pusher = [[ROKOPush alloc]init];
    [_pusher registerWithAPNToken:deviceToken withCompletion:^(id responseObject, NSError *error) {
        if (error){
            NSLog(@"Failed to register with error - %@", error);
        } else {
            NSLog(@"Success registration for push - %@", responseObject);
        }
    }];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

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
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
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
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
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
//     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
//     return execStatus;
// }

/*
    Implement this method if your SDK sets user identities.
*/
 - (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     
     ROKOPortalManager *portalManager = [ROKOComponentManager sharedManager].portalManager;
     
     [portalManager setUserWithName:identityString referralCode:nil linkShareChannel:nil completionBlock:^(NSError * _Nullable error) {
         NSLog(@"%@", error);
     }];
     
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }

#pragma mark Events
/*
    Implement this method if your SDK logs user events.
    Please see MPEvent.h
*/
 - (MPKitExecStatus *)logEvent:(MPEvent *)event {

     [ROKOLogger addEvent:event.name];
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }


#pragma mark ROKOLinkManagerDelegate proxy

- (void)linkManager:(ROKOLinkManager *)manager didOpenDeepLink:(ROKOLink *)link {
    if (self.linkManagerDelegate && [self.linkManagerDelegate respondsToSelector:@selector(linkManager:didOpenDeepLink:)]) {
        [self.linkManagerDelegate linkManager:manager didOpenDeepLink:link];
    }
}

- (void)linkManager:(ROKOLinkManager *)manager didFailToOpenDeepLinkWithError:(NSError *)error {
    if (self.linkManagerDelegate && [self.linkManagerDelegate respondsToSelector:@selector(linkManager:didFailToOpenDeepLinkWithError:)]) {
        [self.linkManagerDelegate linkManager:manager didFailToOpenDeepLinkWithError:error];
    }
}

@end
