//
//  MPKitAppsee.m
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

#import "MPKitAppsee.h"
#import <Appsee/Appsee.h>

// This is temporary to allow compilation (will be provided by core SDK)
NSUInteger MPKitInstanceAppsee = 126;

@implementation MPKitAppsee


// Kit code (supplied by mParticle team)
+ (NSNumber *)kitCode
{
    return @126;
}

+ (void)load
{
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Appsee" className:@"MPKitAppsee"];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration
{
    MPKitExecStatus *execStatus = nil;
    
    NSString *apiKey = configuration[@"apiKey"];
    if (!apiKey)
    {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }
    
    [Appsee start:apiKey];
    
    self->_started = YES;
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}


- (id const)providerKitInstance
{
    return nil;
}

#pragma mark User attributes and identities

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType
{
    // Set user id only in case of "CustomerId" identity
    if (identityType == MPUserIdentityCustomerId)
    {
        [Appsee setUserID:identityString];
    }
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsee) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark e-Commerce

#pragma mark Events

- (MPKitExecStatus *)logEvent:(MPEvent *)event
{
    NSMutableDictionary *eventProps = [NSMutableDictionary dictionary];
    
    // Add the event type as event property
    [eventProps setObject:event.typeName forKey:@"type"];
    
    // Add the event category (if exist) as event property
    if (event.category)
    {
        [eventProps setObject:event.category forKey:@"category"];
    }
    
    // Add the event info items (if exist) as event properties
    if (event.info)
    {
        for (id key in event.info)
        {
            [eventProps setObject:[event.info objectForKey:key] forKey:key];
        }
    }

    // Add the event to appsee
    [Appsee addEvent:[event name] withProperties:eventProps];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsee) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event
{
    [Appsee startScreen:[event name]];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsee) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setLocation:(nonnull CLLocation *)location
{
    [Appsee setLocation:location.coordinate.latitude longitude:location.coordinate.longitude horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsee) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Assorted

- (MPKitExecStatus *)setOptOut:(BOOL)optOut
{
    [Appsee setOptOutStatus:optOut];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsee) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

@end

