//
//  MPKitApptentive.m
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

#import "MPKitApptentive.h"

#import "MPEvent.h"
#import "MPProduct.h"
#import "MPProduct+Dictionary.h"
#import "MPCommerceEvent.h"
#import "MPCommerceEvent+Dictionary.h"
#import "MPCommerceEventInstruction.h"
#import "MPTransactionAttributes.h"
#import "MPTransactionAttributes+Dictionary.h"
#import "MPIHasher.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import "NSDictionary+MPCaseInsensitive.h"
#import "MPDateFormatter.h"
#import "MPEnums.h"

#warning remove once we are integrated
NSInteger const MPKitInstanceApptentive = 97;

/* Import your header file here
*/
#import <Apptentive.h>

NSString * const APIKeyKey = @"APIKey";

@interface MPKitApptentive ()

// iOS 8 and earlier
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;

// iOS 9 and later
@property (strong, nonatomic) NSPersonNameComponents *nameComponents;
@property (strong, nonatomic) NSPersonNameComponentsFormatter *nameFormatter;

@end

@implementation MPKitApptentive

/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @(97);
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Apptentive" className:@"MPKitApptentive" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    NSString *appKey = configuration[APIKeyKey];
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
        NSString *APIKey = self.configuration[APIKeyKey];

        [Apptentive sharedConnection].APIKey = APIKey;

        _started = YES;

		if ([NSPersonNameComponents class]) {
			_nameFormatter = [[NSPersonNameComponentsFormatter alloc] init];
			_nameComponents = [[NSPersonNameComponents alloc] init];
		}

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
    } else {
        return [Apptentive sharedConnection];
    }
}


#pragma mark Application

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
   [[Apptentive sharedConnection] didReceiveRemoteNotification:userInfo fromViewController:nil];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptentive) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    [[Apptentive sharedConnection] setPushNotificationIntegration:ApptentivePushProviderApptentive withDeviceToken:deviceToken];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptentive) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark User attributes and identities

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
	if ([key isEqualToString:mParticleUserAttributeFirstName]) {
		if (self.nameComponents) {
			self.nameComponents.givenName = value;
		} else {
			self.firstName = value;
		}
	} else if ([key isEqualToString:mParticleUserAttributeLastName]) {
		if (self.nameComponents) {
			self.nameComponents.familyName = value;
		} else {
			self.lastName = value;
		}
	} else {
		[[Apptentive sharedConnection] addCustomPersonData:value withKey:key];
	}

	NSString *name;
	if (self.nameComponents) {
		name = [self.nameFormatter stringFromPersonNameComponents:self.nameComponents];
	} else {
		if (self.firstName.length && self.lastName.length) {
			name = [@[ self.firstName, self.lastName ] componentsJoinedByString:@" "];
		} else if (self.firstName.length) {
			name = self.firstName;
		} else if (self.lastName.length) {
			name = self.lastName;
		}
	}

	[Apptentive sharedConnection].personName = name;

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptentive) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
	[[Apptentive sharedConnection] removeCustomPersonDataWithKey:key];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
	if (identityType == MPUserIdentityEmail) {
		[Apptentive sharedConnection].personEmailAddress = identityString;
	} else if (identityType == MPUserIdentityCustomerId) {
		if ([Apptentive sharedConnection].personName.length == 0) {
			[Apptentive sharedConnection].personName == identityString;
		}
	}

     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptentive) returnCode:MPKitReturnCodeSuccess];
     return execStatus;
}

#pragma mark e-Commerce

 - (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
	 MPTransactionAttributes *transactionAttributes = commerceEvent.transactionAttributes;
		NSMutableArray *commerceItems = [NSMutableArray arrayWithCapacity:commerceEvent.products.count];

		for (MPProduct *product in commerceEvent.products) {
			NSDictionary *item = [Apptentive extendedDataCommerceItemWithItemID:product.sku name:product.name category:product.category price:product.price quantity:product.quantity currency:commerceEvent.currency];

			[commerceItems addObject:item];
		}

		NSDictionary *commerceData = [Apptentive extendedDataCommerceWithTransactionID:transactionAttributes.transactionId affiliation:transactionAttributes.affiliation revenue:transactionAttributes.revenue shipping:transactionAttributes.shipping tax:transactionAttributes.tax currency:commerceEvent.currency commerceItems:commerceItems];

	 MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptentive) returnCode:MPKitReturnCodeSuccess forwardCount:0];

     return execStatus;
 }

#pragma mark Events

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
#warning get front view controller
    UIViewController *viewController = nil;

    BOOL success = [[Apptentive sharedConnection] engage:event.name fromViewController:viewController];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceApptentive) returnCode:success ? MPKitReturnCodeSuccess : MPKitReturnCodeRequirementsNotMet];
    return execStatus;
}

@end
