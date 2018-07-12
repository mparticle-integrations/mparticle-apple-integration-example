//
//  MPKitCompanyName.m
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

#import "MPKitTaplytics.h"

/* Import your header file here
*/
//#if defined(__has_include) && __has_include(<CompanyName/CompanyName.h>)
//#import <CompanyName/CompanyName.h>
//#else
//#import "CompanyName.h"
//#endif

// This is temporary to allow compilation (will be provided by core SDK)
NSUInteger MPKitInstanceCompanyName = 999;

@implementation MPKitCompanyName

static const NSString * API_KEY = @"apiKey";
static const NSString * EventViewAppeared = @"viewAppeared";

/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @999;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Taplytics" className:@"MPKitTaplytics" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    NSString *apiKey = configuration[API_KEY];
    
    if (!self || !apiKey) {
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
        
        [Taplytics startTaplytics:configuration[API_KEY]];

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
    if (![self started]) {
        return nil;
    }

    BOOL kitInstanceAvailable = NO;
    if (kitInstanceAvailable) {
        
        return nil;
    } else {
        return nil;
    }
}

- (MPKitExecStatus*) createStatus:(MPKitReturnCode)code {
    return [[MPKitExecStatus alloc]
            initWithSDKCode:@(MPKitInstanceTaplytics)
            returnCode:code];
}

#pragma mark User attributes and identities
/*
    Implement this method if your SDK sets user attributes. The core mParticle SDK also sets the userAttributes property.
*/
 - (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [Taplytics setUserAttributes:@{key:value}];
     return [self createStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK sets user identities.
*/
 - (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     /*  Your code goes here.
         If the execution is not successful, or the identity type is not supported, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
         Please see MPEnums.h > MPUserIdentity for all supported user identities
      */
     MPKitReturnCode code;
     switch( identityType ) {
         case MPUserIdentityCustomerId: {
             code = [self setUserAttribute:@"user_id" value:identityString];
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
/*
    Implement this method if your SDK supports commerce events.
    If your SDK does support commerce event, but does not support all commerce event actions available in the mParticle SDK,
    expand the received commerce event into regular events and log them accordingly (see sample code below)
    Please see MPCommerceEvent.h > MPCommerceEventAction for complete list
*/
 - (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceCompanyName) returnCode:MPKitReturnCodeSuccess forwardCount:0];

     // In this example, this SDK only supports the 'Purchase' commerce event action
     if (commerceEvent.action == MPCommerceEventActionPurchase) {
         /* Your code goes here. */
         [Taplytics logRevenue:commerceEvent.productListName value:commerceEvent.checkoutStep];
         [execStatus incrementForwardCount];
         
     } else { // Other commerce events are expanded and logged as regular events
         NSArray *expandedInstructions = [commerceEvent expandedInstructions];

         for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
             [self logEvent:commerceEventInstruction.event];
             [execStatus incrementForwardCount];
         }
     }

     return execStatus;
 }

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
     
     NSString * eventName = event.name;
     [Taplytics logEvent:eventName];

     return [self createStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK logs screen events
    Please see MPEvent.h
*/
 - (MPKitExecStatus *)logScreen:(MPEvent *)event {
     
     NSString * screenName = event.name;
     [Taplytics logEvent:EventViewAppeared value:screenName];
     
     return [self createStatus:MPKitReturnCodeSuccess];
 }

#pragma mark Assorted
/*
    Implement this method if your SDK implements an opt out mechanism for users.
*/
 - (MPKitExecStatus *)setOptOut:(BOOL)optOut {
     BOOL hasOptedOut = [Taplytics hasUserOptedOutTracking];

     if (!hasOptedOut && optOut) {
         [Taplytics optOutTracking];
     } else if (hasOptedOut && !optOut) {
         [Taplytics optInTracking];
     }
     return [self createStatus:MPKitReturnCodeSuccess];
 }

@end
