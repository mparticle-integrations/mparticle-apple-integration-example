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
#import <PushIOManager/PushIOManager.h>

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#endif

NSString * const PIOConfigurationAPIKey = @"apiKey";
NSString * const PIOConfigurationAccountToken = @"accountToken";
NSString * const PIOConfigurationConversionURL = @"conversionUrl";
NSString * const PIOConfigurationRIAppID = @"riAppId";

NSString * const CUSTOM_FLAG_IAM = @"Responsys.Custom.iam";
NSString * const CUSTOM_FLAG_ENGAGEMENT = @"Responsys.Custom.e";

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
    NSString *conversionURL = nil;
    NSString *riAppID = nil;

    if (self) {
        apiKey = configuration[PIOConfigurationAPIKey];
        accountToken = configuration[PIOConfigurationAccountToken];
        conversionURL = configuration[PIOConfigurationConversionURL];
        riAppID = configuration[PIOConfigurationRIAppID];
    }
    
    if ((NSNull *)apiKey == [NSNull null] || (NSNull *)accountToken == [NSNull null] || (NSNull *)conversionURL == [NSNull null] || (NSNull *)riAppID == [NSNull null])
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
        NSString *coversionURLString = self.configuration[PIOConfigurationConversionURL];
        NSString *riAppID = self.configuration[PIOConfigurationRIAppID];
        NSError *error = nil;
        BOOL configured = [[self pushIOManager] configureWithAPIKey:apiKey accountToken:accountToken error:&error];
        if (configured) {
            [[self pushIOManager] setConversionURL:[NSURL URLWithString:coversionURLString]];
            [[self pushIOManager] setRIAppID: riAppID];
            [[self pushIOManager] setLogLevel:(([MParticle sharedInstance].environment == MPEnvironmentDevelopment) ? PIOLogLevelVerbose : PIOLogLevelError)];
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
    [self.kitApi logError:@"Unrecognized key attribute '%@'.", key];
    return [self execStatus:MPKitReturnCodeUnavailable];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString
                        identityType:(MPUserIdentity)identityType {
    if (identityType == MPUserIdentityCustomerId && identityString.length > 0) {
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
}

- (MPKitExecStatus *)logEvent:(MPEvent *)mpEvent {
    NSDictionary *customFlags = mpEvent.customFlags;
    NSString *eventName = mpEvent.name;
    if (nil != customFlags) {
        if(nil != customFlags[CUSTOM_FLAG_IAM]) {
            [[self pushIOManager] trackEvent:eventName];
        }
        
        NSArray<NSString *> *values = customFlags[CUSTOM_FLAG_ENGAGEMENT];
        if(nil != values && values.count) {
            NSString *engagementType = values[0];
            if([engagementType intValue]) {
                [[self pushIOManager] trackEngagementMetric:[engagementType intValue]];
            }
        }
    }
    
    MPEventType eventType = mpEvent.type;
    NSDictionary *eventInfo = mpEvent.info;
    switch (eventType) {
        case MPEventTypeSearch:
            [[self pushIOManager] trackEvent:@"$Searched"];
            break;
        case MPEventTypeUserPreference:
            if (nil != eventInfo) {
                NSError *error = nil;
                for (NSString *key in eventInfo) {
                    [[self pushIOManager] declarePreference:key label:key type:PIOPreferenceTypeString error:&error];
                    [[self pushIOManager] setStringPreference:eventInfo[key] forKey:key];
                }
            }
            break;
        default:
            break;
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
    NSArray *products = commerceEvent.products;
    if(nil != commerceEventAction && products.count > 0){
        for (MPProduct *product in products) {
            NSString *pCategory = product.category;
            NSString *pIdentifier = product.sku;
            if (pCategory.length && pIdentifier.length) {
                NSDictionary *productProperties = @{@"Pid": pIdentifier,@"Pc":pCategory};
                if(nil != productProperties){
                    [[self pushIOManager] trackEvent:commerceEventAction properties:productProperties];
                }
            }
            
            if (commerceEvent.action == MPCommerceEventActionPurchase) {
                [[self pushIOManager] trackEngagementMetric:PUSHIO_ENGAGEMENT_METRIC_PURCHASE];
            }
        }
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler{
    [[self pushIOManager] continueUserActivity:userActivity restorationHandler:restorationHandler];
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

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request{
    NSNumber *customerIdentifier = [NSNumber numberWithInteger:MPUserIdentityCustomerId];
    NSString *userId = user.userIdentities[customerIdentifier];
    if (nil != userId && userId.length) {
        [[self pushIOManager] registerUserID:userId];
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request{
    [[self pushIOManager] registerUserID:nil];
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

@end
