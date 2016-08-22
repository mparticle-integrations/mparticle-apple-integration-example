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

@interface MPKitApptimize()
@property (nonatomic, unsafe_unretained) BOOL started;
@end

@implementation MPKitApptimize

static NSString *const APP_MP_KEY = @"appKey";
static NSString *const DEVICE_PAIRING_MP_KEY = @"devicePairing";
static NSString *const DELAY_UNTIL_TESTS_ARE_AVAILABLE_MP_KEY = @"delayUntilTestsAreAvailable";
static NSString *const LOG_LEVEL_MP_KEY = @"logLevel";
static NSString *const INSTALL_TAG = @"install";
static NSString *const LOGOUT_TAG = @"logout";
static NSString *const UPDATE_TAG = @"update";
static NSString *const VIEWED_TAG_FORMAT = @"screenView %@";

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
    NSString *appKey = configuration[APP_MP_KEY];
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
        [Apptimize startApptimizeWithApplicationKey:self.configuration[APP_MP_KEY] options:options];
        self.started = YES;
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
    NSString *pairing = [self configValueForKey:DEVICE_PAIRING_MP_KEY];
    if( pairing ) {
        NSNumber *boxedPairing = [NSNumber numberWithBool:[pairing boolValue]];
        [o setObject:boxedPairing forKey:ApptimizeDevicePairingOption];
    }
}

- (void)configureApptimizeDelayUntilTestsAreAvailable:(NSMutableDictionary*)o {
    NSString *delay = [self configValueForKey:DELAY_UNTIL_TESTS_ARE_AVAILABLE_MP_KEY];
    if( delay ) {
        NSNumber *boxedDelay = [NSNumber numberWithDouble:[delay doubleValue]];
        [o setObject:boxedDelay forKey:ApptimizeDelayUntilTestsAreAvailableOption];
    }
}

- (void)configureApptimizeLogLevel:(NSMutableDictionary*)o {
    NSString *logLevel = [self configValueForKey:LOG_LEVEL_MP_KEY];
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

- (nonnull MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    [Apptimize setUserAttributeString:value forKey:key];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)removeUserAttribute:(NSString *)key {
    [Apptimize removeUserAttributeForKey:key];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

 - (nonnull MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     MPKitReturnCode code;
     switch( identityType ) {
         case MPUserIdentityCustomerId:
         case MPUserIdentityAlias: {
             [Apptimize setPilotTargetingID:identityString];
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

- (nonnull MPKitExecStatus *)logEvent:(MPEvent *)event {
    [Apptimize track:event.name];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logScreen:(MPEvent *)event {
    NSString *screenEvent = [NSString stringWithFormat:VIEWED_TAG_FORMAT, event.name];
    [Apptimize track:screenEvent];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logInstall {
    [Apptimize track:INSTALL_TAG];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logout {
    [Apptimize track:LOGOUT_TAG];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logUpdate {
    [Apptimize track:UPDATE_TAG];
    return [self makeStatus:MPKitReturnCodeSuccess];
}

#pragma mark Assorted

- (nonnull MPKitExecStatus *)setOptOut:(BOOL)optOut {
    if( optOut ) {
        [Apptimize disable];
    }
    return [self makeStatus:MPKitReturnCodeSuccess];
}

@end
