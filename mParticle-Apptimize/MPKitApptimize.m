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
static NSString *const APP_KEY = @"appKey";
static NSString *const DEVICE_PAIRING_KEY = @"devicePairing";
static NSString *const DELAY_UNTIL_TESTS_ARE_AVAILABLE_KEY = @"delayUntilTestsAreAvailable";
static NSString *const LOG_LEVEL_KEY = @"logLevel";

+ (NSNumber *)kitCode {
    return @105;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Apptimize" className:@"MPKitApptimize" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus*) makeStatus:(MPKitReturnCode)code {
    return [[MPKitExecStatus alloc]
            initWithSDKCode:@(MPKitInstanceApptimize)
            returnCode:code];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    NSString *appKey = configuration[APP_KEY];
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
    NSDictionary *options = [self buildApptimizeOptions];
    void(^start_block)(void) = ^{
        [Apptimize startApptimizeWithApplicationKey:self.configuration[APP_KEY] options:options];
        _started = YES;
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    };
    static dispatch_once_t kitPredicate;
    dispatch_once( &kitPredicate, ^{
        if( [NSThread isMainThread] ) {
            start_block();
        } else {
            dispatch_async( dispatch_get_main_queue(), start_block );
        }
    } );
}

- (nonnull NSDictionary*)buildApptimizeOptions {
    NSMutableDictionary *o = [NSMutableDictionary new];
    [o setObject:[NSNumber numberWithBool:FALSE] forKey:ApptimizeEnableThirdPartyEventImportingOption];
    [self configureApptimizeDevicePairing:o];
    [self configureApptimizeDelayUntilTestsAreAvailable:o];
    [self configureApptimizeLogLevel:o];
    return o;
}

- (void)configureApptimizeDevicePairing:(NSMutableDictionary*)o {
    NSString *pairing = [self configValueForKey:DEVICE_PAIRING_KEY];
    if( pairing ) {
        [o setObject:[NSNumber numberWithBool:[pairing boolValue]] forKey:ApptimizeDevicePairingOption];
    }
}

- (void)configureApptimizeDelayUntilTestsAreAvailable:(NSMutableDictionary*)o {
    NSString *delay = [self configValueForKey:DELAY_UNTIL_TESTS_ARE_AVAILABLE_KEY];
    if( delay ) {
        [o setObject:[NSNumber numberWithDouble:[delay doubleValue]] forKey:ApptimizeDelayUntilTestsAreAvailableOption];
    }
}

- (void)configureApptimizeLogLevel:(NSMutableDictionary*)o {
    NSString *logLevel = [self configValueForKey:LOG_LEVEL_KEY];
    if( logLevel ) {
        [o setObject:logLevel forKey:ApptimizeLogLevelOption];
    }
}

- (nullable NSString*) configValueForKey:(NSString*)key {
    NSString *value = [self.launchOptions objectForKey:key];
    if( value == nil ) {
        value = [self.configuration objectForKey:key];
    }
    return value;
}

#pragma mark User attributes and identities

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    [Apptimize setUserAttributeString:value forKey:key];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
    [Apptimize removeUserAttributeForKey:key];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

 - (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     MPKitReturnCode code;
     switch( identityType ) {
         case MPUserIdentityCustomerId: {
             [Apptimize setUserAttributeString:identityString forKey:CUSTOMER_ID_KEY];
             code = MPKitReturnCodeSuccess;
             break;
         }
         case MPUserIdentityAlias: {
             [Apptimize setUserAttributeString:identityString forKey:ALIAS_KEY];
             code = MPKitReturnCodeSuccess;
             break;
         }
         default: {
             code = MPKitReturnCodeUnavailable;
             break;
         }
     }
     return [self makeStatus:code];
 }

#pragma mark Events

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    [Apptimize track:event.name];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    NSString *screenEvent = [NSString stringWithFormat:VIEWED_EVENT_FORMAT, event.name];
    [Apptimize track:screenEvent];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

#pragma mark Assorted
- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    if( optOut ) {
        [Apptimize disable];
    }
    return [self makeStatus:MPKitReturnCodeSuccess];
}

@end
