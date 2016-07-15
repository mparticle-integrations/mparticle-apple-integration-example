//
//  MPKitPrimer.m
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

#import "MPKitPrimer.h"
#import "mParticle.h"
#import <Primer/Primer.h>

@implementation MPKitPrimer

#pragma mark - Class methods

+ (NSNumber *)kitCode {
    return @(100);
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Primer" className:@"MPKitPrimer" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - Kit instance and lifecycle

- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSString *token = configuration[@"apiKey"];
    if (token.length < 1) {
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
        
        NSString *token = self.configuration[@"apiKey"];
        
        [Primer startWithToken:token];

        _started = YES;
        
        BOOL automaticPresentation = [self.configuration[@"autoPresent"] boolValue];
        if (automaticPresentation) {
            [Primer presentExperience];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey: [[self class] kitCode]}
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification object:nil userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    
    return nil;
}

#pragma mark - Application

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    
    [Primer continueUserActivity:userActivity];
    
    return [self statusWithCode:MPKitReturnCodeSuccess];
}

#pragma mark - User attributes and identities

- (nonnull MPKitExecStatus *)setUserAttribute:(nonnull NSString *)key value:(nullable NSString *)value {
    
    if (!value) {
        return [self statusWithCode:MPKitReturnCodeFail];
    }
    
    NSString *prefixedKey = [NSString stringWithFormat:@"mParticle.%@", key];
    [Primer appendUserProperties:@{prefixedKey: value}];
    
    return [self statusWithCode:MPKitReturnCodeSuccess];
}

#pragma mark - e-Commerce

- (nonnull MPKitExecStatus *)logCommerceEvent:(nonnull MPCommerceEvent *)commerceEvent {
    
    MPKitExecStatus *status = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
    
    NSArray *expandedInstructions = [commerceEvent expandedInstructions];
    for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
        [self logEvent:commerceEventInstruction.event];
        [status incrementForwardCount];
    }
    
    return status;
}

#pragma mark - Events

- (nonnull MPKitExecStatus *)logEvent:(nonnull MPEvent *)event {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@"mParticle" forKey:@"pmr_event_api"];
    
    if (event.info) {
        [parameters addEntriesFromDictionary:event.info];
    }
    
    [Primer trackEventWithName:event.name parameters:parameters];
    
    return [self statusWithCode:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logScreen:(nonnull MPEvent *)event {
    
    MPKitExecStatus *status = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
    
    [self logEvent:event];
    [status incrementForwardCount];
    
    return status;
}

- (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
    
    MPKitExecStatus *status = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
    
    NSArray *expandedInstructions = [commerceEvent expandedInstructions];
    for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
        [self logEvent:commerceEventInstruction.event];
        [status incrementForwardCount];
    }
    
    return status;
}

#pragma mark - Assorted

- (nonnull MPKitExecStatus *)setDebugMode:(BOOL)debugMode {
    
    PMRLoggingLevel loggingLevel = debugMode ? PMRLoggingLevelWarning : PMRLoggingLevelNone;
    [Primer setLoggingLevel:loggingLevel];
    
    return [self statusWithCode:MPKitReturnCodeSuccess];
}

#pragma mark - Utilities

- (nonnull MPKitExecStatus *)statusWithCode:(MPKitReturnCode)code {
    
    return [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:code];
}

@end
