//
//  MPKitCarnival.m
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

#import "MPKitCarnival.h"

/* Import your header file here
 */

#ifdef COCOAPODS
#import "Carnival.h"
#else
#import <Carnival/Carnival.h>
#endif

// This is temporary to allow compilation (will be provided by core SDK)  
NSString const *kSDKKey = @"APP_KEY";
NSString const *kInAppNotificationsEnabled = @"IN_APP_NOTIFICATIONS_ENABLED";

@implementation MPKitCarnival

/*
 mParticle will supply a unique kit code for you. Please contact our team
 */
+ (NSNumber *)kitCode {
  return @99;
}

+ (void)load {
  MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Carnival" className:@"MPKitCarnival" startImmediately:YES];
  [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
  self = [super init];
  NSString *appKey = configuration[kSDKKey];

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
    BOOL inAppNotificationsEnabled = [self.configuration[kInAppNotificationsEnabled] boolValue];
    if (!inAppNotificationsEnabled) {
      [Carnival setInAppNotificationsEnabled:inAppNotificationsEnabled];
    }

    [Carnival setAutoIntegrationEnabled:NO];
    [Carnival startEngine:self.configuration[kSDKKey] registerForPushNotifications:NO];
    
    _started = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
      
      [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                          object:nil
                                                        userInfo:userInfo];
    });
  });
}

- (id const)providerKitInstance {
  return nil;
}

#pragma mark Application
- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
  [Carnival handleNotification:userInfo];
  
  MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
  return execStatus;
}

- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
  [Carnival setDeviceTokenInBackground:deviceToken];
  
  MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
  return execStatus;
}

#pragma mark User attributes and identities
- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
  NSError *error;
  MPKitExecStatus *execStatus;
  
  CarnivalAttributes *map = [[CarnivalAttributes alloc] init];
  [map setString:value forKey:key];
  
  [Carnival setAttributes:map error:&error];
  
  if (error) {
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeFail];
  } else {
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
  }
  
  return execStatus;
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
  NSError *error;
  MPKitExecStatus *execStatus;
  
  [Carnival removeAttributeWithKey:key error:&error];
  
  if (error) {
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeFail];
  } else {
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
  }
  
  return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
  MPKitExecStatus *execStatus;
  
  switch (identityType) {
    case MPUserIdentityCustomerId:
      [Carnival setUserId:identityString withResponse:nil];
      execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
      
    case MPUserIdentityEmail:
      [Carnival setUserEmail:identityString withResponse:nil];
      execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
      break;
      
    default:
      execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeUnavailable];
      break;
  }
  
  return execStatus;
}

#pragma mark Events
- (MPKitExecStatus *)logEvent:(MPEvent *)event {
  [Carnival logEvent:[event name]];
  MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCarnival) returnCode:MPKitReturnCodeSuccess];
  return execStatus;
}

@end
