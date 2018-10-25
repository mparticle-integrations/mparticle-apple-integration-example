//
//  MPKitResponsys.m
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


#import "MPKitResponsys.h"
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
#import <PushIOManager/PushIOManager.h>

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#endif

NSString * const PIOConfigurationAPIKey = @"apiKey";
NSString * const PIOConfigurationAccountToken = @"accountToken";
NSString * const ResponsysEventTypeIAMPremium = @"ResponsysEventTypeIAMPremium";
NSString * const ResponsysEventTypeIAMSocial = @"ResponsysEventTypeIAMSocial";
NSString * const ResponsysEventTypeIAMPurchase = @"ResponsysEventTypeIAMPurchase";
NSString * const ResponsysEventTypeIAMOther = @"ResponsysEventTypeIAMOther";

NSString * const ResponsysEventTypePreference = @"ResponsysEventTypePreference";
NSString * const ResponsysEvent = @"ResponsysEvent";

@interface MPKitResponsys(){
    PushIOManager *_pioManager;
}

@end

@implementation MPKitResponsys

+(void) load{
    MPKitRegister *pioKitRegister = [[MPKitRegister alloc] initWithName:@"Oracle Responsys" className: @"MPKitResponsys"];
    [MParticle registerExtension:pioKitRegister];
}

- (instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately{
    self = [super init];
    NSString *apiKey = nil;
    NSString *accountToken = nil;
    if (self) {
        apiKey = configuration[PIOConfigurationAPIKey];
        accountToken = configuration[PIOConfigurationAccountToken];
    }
    
    if ((NSNull *)apiKey == [NSNull null] || (NSNull *)accountToken == [NSNull null])
    {
        return nil;
    } else {
        return self;
    }
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    self.configuration = configuration;
    [self start];
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[MPKitResponsys kitCode] returnCode:MPKitReturnCodeSuccess];
    [self start];
    return execStatus;
}

-(void) start{
    static dispatch_once_t kitPredicate;
    
    dispatch_once(&kitPredicate, ^{
        self->_started = YES;
    NSString *apiKey = self.configuration[PIOConfigurationAPIKey];
    NSString *accountToken = self.configuration[PIOConfigurationAccountToken];
        NSError *error = nil;
        BOOL configured = [[self pushIOManager] configureWithAPIKey:apiKey accountToken:accountToken error:&error];
        if (configured) {
            [[self pushIOManager] setLogLevel:PIOLogLevelVerbose];
            [[self pushIOManager] registerForAllRemoteNotificationTypes:^(NSError *error, NSString *response) {
                //Error populated if failed to register.
            }];
        }else{
            //Failed to configure. No retrial needed. Check the APIKey and AccountToken and try again.
        }
    });
}

+ (nonnull NSNumber *)kitCode {
    return @102;
}

- (id const)providerKitInstance {
    return [self started] ? [self pushIOManager] : nil;
}

- (id const)kitInstance {
    return self.started ? [self pushIOManager] : nil;
}


-(PushIOManager *)pushIOManager{
    if (nil == _pioManager) {
        _pioManager = [PushIOManager sharedInstance];
    }
    return _pioManager;
}
#pragma mark - MPKitInstanceProtocol Lifecycle Methods

- (instancetype _Nonnull) init {
    self = [super init];
    self.configuration = @{};
    self.launchOptions = @{};
    return self;
}



#pragma mark - MPKitInstanceProtocol Methods

- (MPKitExecStatus*_Nonnull)setKitAttribute:(nonnull NSString *)key value:(nullable id)value {
    [self.kitApi logError:@"Unrecognized key attibute '%@'.", key];
    return [self execStatus:MPKitReturnCodeUnavailable];
}

- (MPKitExecStatus*_Nonnull)setOptOut:(BOOL)optOut {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString
                        identityType:(MPUserIdentity)identityType {
    if (identityType == MPUserIdentityCustomerId && identityString.length > 0) {
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
}

- (MPKitExecStatus*_Nonnull)logout {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logEvent:(MPEvent *)mpEvent {
    NSString *eventName = mpEvent.name;

    if(nil != eventName ){
        NSArray *inAppEvents = @[ResponsysEventTypeIAMPremium, ResponsysEventTypeIAMSocial, ResponsysEventTypeIAMPurchase, ResponsysEventTypeIAMOther];
        if([inAppEvents containsObject:eventName]){
            [self trackEngagementMetric: eventName];
        }else if ([eventName isEqualToString:ResponsysEventTypePreference]){
            NSDictionary *eventInfo = [mpEvent.info copy];
            [self savePreference: eventInfo];
        }
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent{
    NSString *commerceEventAction = nil;
    switch (commerceEvent.action) {
        case MPCommerceEventActionPurchase:
            commerceEventAction = @"$PurchasedCart";
            break;
        case MPCommerceEventActionAddToCart:
            commerceEventAction = @"$AddedItemToCart";
            break;
        case MPCommerceEventActionRemoveFromCart:
            commerceEventAction = @"$RemovedItemFromCart";
            break;
        case MPCommerceEventActionViewDetail:
            commerceEventAction = @"$Browsed";
            break;
        case MPCommerceEventActionCheckout:
            commerceEventAction = @"$UpdatedStageOfCart";
            break;
        default:
            break;
    }
    if(nil != commerceEventAction){
        [self trackResponsysEvent: commerceEventAction products:commerceEvent.products];
    }
    return [self execStatus:MPKitReturnCodeSuccess];

}


- (MPKitExecStatus *)logScreen:(MPEvent *)mpEvent {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler{
    [[self pushIOManager] continueUserActivity:userActivity restorationHandler:restorationHandler];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)didUpdateUserActivity:(nonnull NSUserActivity *)userActivity{
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)didBecomeActive{
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)failedToRegisterForUserNotifications:(nullable NSError *)error{
    [[self pushIOManager] didFailToRegisterForRemoteNotificationsWithError:error];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)handleActionWithIdentifier:(nonnull NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo{
    [[self pushIOManager] handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo{
    [[self pushIOManager] handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options{
    [[self pushIOManager] openURL:url sourceApplication:nil annotation:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation{
    [[self pushIOManager] openURL:url sourceApplication:sourceApplication annotation:annotation];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)receivedUserNotification:(nonnull NSDictionary *)userInfo{
    [[self pushIOManager] didReceiveRemoteNotification:userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)setDeviceToken:(nonnull NSData *)deviceToken{
    [[self pushIOManager] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus*) execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark Events

-(void) savePreference:(NSDictionary *)preferences{
    for (NSString* prefKey in preferences){
        NSLog(@"Key: %@", prefKey);
        NSString *prefValue = preferences[prefKey];
        NSError *prefError = nil;
        [[self pushIOManager] declarePreference:prefKey label:prefKey type:PIOPreferenceTypeString error:&prefError];
        [[self pushIOManager] setStringPreference:prefValue forKey:prefKey];
    }
}

-(void)trackResponsysEvent: (NSString *)eventName products:(NSArray *)products{
    if (nil != eventName && products.count > 0) {
        for (MPProduct *product in products) {
            NSDictionary *productProperties = product.dictionaryRepresentation;
            if(nil != productProperties){
                [[self pushIOManager] trackEvent:eventName properties:productProperties];
            }
        }
    }
}

-(void) trackEngagementMetric:(NSString *)engagementMetric{
    PushIOEngagementMetrics engagementType = PUSHIO_ENGAGEMENT_METRIC_ACTIVE_SESSION;
    if ([engagementMetric isEqualToString:ResponsysEventTypeIAMPremium]) {
        engagementType = PUSHIO_ENGAGEMENT_METRIC_PREMIUM_CONTENT;
    } else if ([engagementMetric isEqualToString:ResponsysEventTypeIAMSocial]) {
        engagementType = PUSHIO_ENGAGEMENT_METRIC_SOCIAL;
    } else if ([engagementMetric isEqualToString:ResponsysEventTypeIAMPurchase]) {
        engagementType = PUSHIO_ENGAGEMENT_METRIC_INAPP_PURCHASE;
    } else if ([engagementMetric isEqualToString:ResponsysEventTypeIAMOther]) {
        engagementType = PUSHIO_ENGAGEMENT_METRIC_OTHER;
    }
    [[self pushIOManager] trackEngagementMetric:engagementType];
}

@end
