//
//  MPKitApptimize.m
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

#import "MPKitApptimize.h"
#import "mParticle.h"

#import "Apptimize/Apptimize.h"

@implementation MPKitApptimize

static NSString *const ALIAS_KEY = @"mparticleAlias";
static NSString *const CUSTOMER_ID_KEY = @"mparticleCustomerId";
static NSString *const VIEWED_EVENT_FORMAT = @"Viewed %@ Screen";

+ (NSNumber *)kitCode {
    return @105;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Apptimize" className:@"MPKitApptimize" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    NSString *appKey = configuration[@"appKey"];
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
        [Apptimize startApptimizeWithApplicationKey:self.configuration[@"appkey"]];
        
        _started = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

#pragma mark User attributes and identities

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    [Apptimize setUserAttributeString:value forKey:key];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
    [Apptimize removeUserAttributeForKey:key];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

 - (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     if (identityType == MPUserIdentityCustomerId) {
         [Apptimize setUserAttributeString:identityString forKey:CUSTOMER_ID_KEY];
     } else if (identityType == MPUserIdentityCustomerId) {
         [Apptimize setUserAttributeString:identityString forKey:ALIAS_KEY];
     } else {
         // didn't do anything
         MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeUnavailable];
         return execStatus;
     }
     
     
      MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeSuccess];
      return execStatus;
 }

#pragma mark Events

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    [Apptimize track:event.name];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    NSString *screenEvent = [NSString stringWithFormat:VIEWED_EVENT_FORMAT, event.name];
    [Apptimize track:screenEvent];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Assorted
- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    [Apptimize disable];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptimize) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

@end
