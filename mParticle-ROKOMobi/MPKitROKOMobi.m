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

@interface MPKitROKOMobiProxy ()

@property (nonatomic, strong) ROKOInstaBot *instabot;

@end

@implementation MPKitROKOMobiProxy

@synthesize instabot = _instabot;

- (ROKOInstaBot *)getInstaBot {
    if (!_instabot) {
        _instabot = [ROKOInstaBot new];
    }
    return _instabot;
}

@end

@interface MPKitROKOMobi() <ROKOLinkManagerDelegate>

@property (nonatomic, strong) ROKOPush *pusher;
@property (nonatomic, strong) ROKOLinkManager *linkManager;
@property (nonatomic, strong) id <MPKitROKOMobiProvider> proxy;

@end

@implementation MPKitROKOMobi

@synthesize proxy = _proxy;

- (id <MPKitROKOMobiProvider>)proxy {
    if (!_proxy) {
        _proxy = [MPKitROKOMobiProxy new];
    }
    return _proxy;
}
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
    return [self started] ? self.proxy : nil;
}


#pragma mark Application

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    [_linkManager  continueUserActivity:userActivity];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
    [_linkManager handleDeepLink:url];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    [_linkManager handleDeepLink:url];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Push

- (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    
    if (_pusher) {
        [_pusher handleNotification:userInfo];
    }
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

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

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    ROKOPortalManager *portalManager = [ROKOComponentManager sharedManager].portalManager;
    
    [portalManager setUserCustomProperty:value forKey:key completionBlock:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     
    ROKOPortalManager *portalManager = [ROKOComponentManager sharedManager].portalManager;
     
    [portalManager setUserWithName:identityString referralCode:nil linkShareChannel:nil completionBlock:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
     
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceROKOMobi) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Events

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
