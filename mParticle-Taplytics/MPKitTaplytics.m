//
//  MPKitTaplytics.m
//
//  Copyright 2018 mParticle, Inc.
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

#import "MPKitTaplytics.h"

#if defined(__has_include) && __has_include(<Taplytics/Taplytics.h>)
#import <Taplytics/Taplytics.h>
#else
#import "Taplytics.h"
#endif

@implementation MPKitTaplytics

static NSDictionary * _Nullable taplyticsOptions;

static NSString * const API_KEY = @"apiKey";
static NSString * const DELAY_LOAD = @"TaplyticsOptionDelayLoad";
static NSString * const SHOW_LAUNCH_IMAGE = @"TaplyticsOptionShowLaunchImage";
static NSString * const SHOW_LAUNCH_IMAGE_TYPE = @"TaplyticsOptionShowLaunchImageType";

#pragma mark Static Methods

+ (NSNumber *)kitCode {
    return @129;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Taplytics" className:@"MPKitTaplytics"];
    [MParticle registerExtension:kitRegister];
}

+ (NSDictionary *)tlOptions {
    if (taplyticsOptions == nil) {
        taplyticsOptions = [NSDictionary dictionary];
    }
    return taplyticsOptions;
}

+ (void)setTLOptions:(NSDictionary *)options {
    if (options != nil) {
        taplyticsOptions = options;
    }
}

+ (NSArray *)userAttributeKeys {
    return @[
             @"user_id",
             @"email",
             @"firstName",
             @"lastName",
             @"name",
             @"age",
             @"gender"
             ];
}

+ (NSDictionary *)mergeOptions:(NSDictionary *)configuration withTLOptions:(NSDictionary *)tlOptions {
    NSMutableDictionary *merged = [NSMutableDictionary dictionary];
    [merged addEntriesFromDictionary:configuration];
    for (NSString *key in tlOptions) {
        merged[key] = tlOptions[key];
    }
    return merged;
}


#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *apiKey = configuration[API_KEY];
    
    if (!self || !apiKey) {
        return [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
    }
    
    if (taplyticsOptions == nil) {
        taplyticsOptions = [NSDictionary dictionary];
        
    }
    
    _configuration = configuration;
    [self start];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
}

- (void)start {
    static dispatch_once_t kitPredicate;
    NSDictionary *options = [MPKitTaplytics mergeOptions:[self getTaplyticsOptionsFromConfiguration] withTLOptions:taplyticsOptions];
    
    dispatch_once(&kitPredicate, ^{
        
        NSString * apiKey = self->_configuration[API_KEY];
        
        if ([options count] == 0) {
            [Taplytics startTaplyticsAPIKey:apiKey];
        } else {
            [Taplytics startTaplyticsAPIKey:apiKey options:options];
        }
        
        self->_started = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (NSDictionary *)getTaplyticsOptionsFromConfiguration {
    NSMutableDictionary *options = [NSMutableDictionary new];
    [self setDelayLoadOption:options];
    [self setShowLaunchImage:options];
    [self setLaunchImageType:options];
    return options;
}

- (void)setDelayLoadOption:(NSMutableDictionary *)dic {
    NSString *delayLoadValue = [self getValueFromConfigurationOptions:DELAY_LOAD];
    if (delayLoadValue) {
        NSNumber *delay = @([delayLoadValue intValue]);
        [dic setObject:delay forKey:TaplyticsOptionDelayLoad];
    }
}

- (void)setShowLaunchImage:(NSMutableDictionary *)dic {
    NSString *showLaunchImageValue = [self getValueFromConfigurationOptions:SHOW_LAUNCH_IMAGE];
    if (showLaunchImageValue) {
        NSNumber *showLaunchImage = @([showLaunchImageValue isEqualToString:@"True"]);
        [dic setObject:showLaunchImage forKey:TaplyticsOptionShowLaunchImage];
    }
}

- (void)setLaunchImageType:(NSMutableDictionary *)dic {
    NSString *launchImageType = [self getValueFromConfigurationOptions:SHOW_LAUNCH_IMAGE_TYPE];
    if ([launchImageType isEqualToString:@"True"]) {
        [dic setObject:@"xib" forKey:TaplyticsOptionLaunchImageType];
    }
}

- (NSString *)getValueFromConfigurationOptions:(NSString *)key {
    NSString * value = [self.configuration objectForKey:key];
    return value;
}

- (id const)providerKitInstance {
    return nil;
}

- (MPKitExecStatus*) createStatus:(MPKitReturnCode)code {
    return [[MPKitExecStatus alloc]
            initWithSDKCode:[[self class] kitCode]
            returnCode:code];
}

#pragma mark User attributes and identities
- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    NSArray *userAttributeKeys = [MPKitTaplytics userAttributeKeys];
    NSString *attrKey = key;
    NSObject *attrValue = value;
    if (![userAttributeKeys containsObject:key]) {
        NSDictionary *customData = @{key:value};
        attrKey = @"customData";
        attrValue = customData;
    }
    [Taplytics setUserAttributes:@{attrKey:attrValue}];
    return [self createStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    MPKitReturnCode code;
    switch( identityType ) {
        case MPUserIdentityCustomerId: {
            code = [[self setUserAttribute:@"user_id" value:identityString] returnCode];
            break;
        }
        case MPUserIdentityEmail: {
            code = [[self setUserAttribute:@"email" value:identityString] returnCode];
            break;
        }
        default: {
            code = MPKitReturnCodeUnavailable;
            break;
        }
    }
    return [self createStatus:code];
}

#pragma mark e-Commerce
- (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
    
    if (commerceEvent.action == MPCommerceEventActionPurchase) {
        MPTransactionAttributes *transaction = commerceEvent.transactionAttributes;
        if (transaction != nil && transaction.revenue != nil && transaction.transactionId != nil) {
            [Taplytics logRevenue:transaction.transactionId revenue:transaction.revenue];
            [execStatus incrementForwardCount];
        }
        
    } else {
        NSArray *expandedInstructions = [commerceEvent expandedInstructions];
        
        for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
            [self logEvent:commerceEventInstruction.event];
            [execStatus incrementForwardCount];
        }
    }
    
    return execStatus;
}

#pragma mark Events
- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    NSString * eventName = event.name;
    NSDictionary * metaData = event.info;
    if (metaData != nil) {
        [Taplytics logEvent:eventName value:nil metaData:metaData];
    }
    
    return [self createStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    NSString * screenName = event.name;
    [Taplytics logEvent:screenName];
    
    return [self createStatus:MPKitReturnCodeSuccess];
}

#pragma mark Assorted
- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    BOOL hasOptedOut = [Taplytics hasUserOptedOutTracking];
    
    if (!hasOptedOut && optOut) {
        [Taplytics optOutUserTracking];
    } else if (hasOptedOut && !optOut) {
        [Taplytics optInUserTracking];
    }
    return [self createStatus:MPKitReturnCodeSuccess];
}

@end
