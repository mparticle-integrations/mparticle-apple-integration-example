#import "MPKitCleverTap.h"


#if defined(__has_include) && __has_include(<CleverTapSDK/CleverTap.h>)
#import <CleverTapSDK/CleverTap.h>
#else
#import "CleverTap.h"
#endif

NSString *const ctAccountID = @"AccountID";
NSString *const ctAccountToken = @"AccountToken";
NSString *const ctRegion = @"Region";
NSString *const ctCleverTapIdIntegrationKey = @"clevertap_id_integration_setting";

@implementation MPKitCleverTap

+ (NSNumber *)kitCode {
    return @135;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"CleverTap" className:@"MPKitCleverTap"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *accountID = [configuration objectForKey:ctAccountID ];
    NSString *accountToken = [configuration objectForKey:ctAccountToken];
    if (![accountID isKindOfClass:[NSString class]] || [accountID length] == 0 || ![accountToken isKindOfClass:[NSString class]] || [accountToken length] == 0) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    _configuration = configuration;
    [self start];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)start {
    static dispatch_once_t kitPredicate;
    dispatch_once(&kitPredicate, ^{
        NSString *accountID = [self->_configuration objectForKey:ctAccountID ];
        NSString *accountToken = [self->_configuration objectForKey:ctAccountToken];
        NSString *region = [self->_configuration objectForKey:ctRegion];
        [CleverTap setCredentialsWithAccountID:accountID token:accountToken region:region];
        [[CleverTap sharedInstance] notifyApplicationLaunchedWithOptions:nil];

        self->_started = YES;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
        
        NSString *cleverTapID = [[CleverTap sharedInstance] profileGetCleverTapID];
        if (cleverTapID){
            NSDictionary<NSString *, NSString *> *integrationAttributes = @{ctCleverTapIdIntegrationKey:cleverTapID};
            [[MParticle sharedInstance] setIntegrationAttributes:integrationAttributes forKit:[[self class] kitCode]];
        }
    });
}

- (id const)providerKitInstance {
    if (![self started]) {
        return nil;
    }
    return [CleverTap sharedInstance];
}


#pragma mark Application
#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (nonnull MPKitExecStatus *)userNotificationCenter:(nonnull UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response  API_AVAILABLE(ios(10.0)){
    [CleverTap handlePushNotification:response.notification.request.content.userInfo openDeepLinksInForeground:YES];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppboy) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}
#endif
 - (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
     [[CleverTap sharedInstance] handleNotificationWithData:userInfo];
     return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)handleActionWithIdentifier:(nullable NSString *)identifier
                                  forRemoteNotification:(nonnull NSDictionary *)userInfo
                                       withResponseInfo:(nonnull NSDictionary *)responseInfo {
    [[CleverTap sharedInstance] handleNotificationWithData:userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    [[CleverTap sharedInstance] handleNotificationWithData:userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

 - (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
     [[CleverTap sharedInstance] setPushToken:deviceToken];
     return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
     [[CleverTap sharedInstance] handleOpenURL:url sourceApplication:nil];
     return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    [[CleverTap sharedInstance] handleOpenURL:url sourceApplication:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark Location tracking
#if TARGET_OS_IOS == 1
- (nonnull MPKitExecStatus *)setLocation:(nonnull CLLocation *)location {
    [CleverTap setLocation:location.coordinate];
    return [self execStatus:MPKitReturnCodeSuccess];
}
#endif

#pragma mark User attributes
- (nonnull MPKitExecStatus *)removeUserAttribute:(nonnull NSString *)key {
    [[CleverTap sharedInstance] profileRemoveValueForKey:key];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)setUserAttribute:(nonnull NSString *)key value:(nonnull id)value {
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    
    NSMutableDictionary *profile = [NSMutableDictionary new];
    
    if ([key isEqualToString:@"name"]) {
        profile[@"Name"] = value;
    } else if ([key isEqualToString:mParticleUserAttributeMobileNumber] || [key isEqualToString:@"$MPUserMobile"] || [key isEqualToString:@"phone"]) {
        profile[@"Phone"] =  [NSString stringWithFormat:@"%@", value];
        profile[key] = value;
    } else if ([key isEqualToString:mParticleUserAttributeGender]) {
        profile[@"Gender"] = [value isEqualToString:mParticleGenderMale] ? @"M" : @"F";
    } else if ([key isEqualToString:@"birthday"] && [value isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        profile[@"DOB"] = [dateFormatter dateFromString:value];
    } else {
        profile[key] = value;
    }
    
    if ([profile count] <= 0) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    
    [[CleverTap sharedInstance] profilePush:profile];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)setUserAttribute:(nonnull NSString *)key values:(nonnull NSArray *)values {
    [[CleverTap sharedInstance] profileAddMultiValues:values forKey:key];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)setUserIdentity:(nullable NSString *)identityString identityType:(MPUserIdentity)identityType {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    return [self updateUser:user request:request isLogin:YES];
}

- (nonnull MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     return [self updateUser:user request:request isLogin:NO];
}

- (nonnull MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    return [self updateUser:user request:request isLogin:NO];
}

- (nonnull MPKitExecStatus *)updateUser:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request isLogin:(Boolean)isLogin {
    
    NSMutableDictionary *userIDsCopy = (request.userIdentities != nil) ? [request.userIdentities copy] : [NSDictionary new];
    NSMutableDictionary *profile = [NSMutableDictionary new];
    
    if (userIDsCopy[@(MPUserIdentityCustomerId)]) {
        profile[@"Identity"] = userIDsCopy[@(MPUserIdentityCustomerId)];
    }
    if (userIDsCopy[@(MPUserIdentityEmail)]) {
        profile[@"Email"] = userIDsCopy[@(MPUserIdentityEmail)];
    }
    if (userIDsCopy[@(MPUserIdentityFacebook)]) {
        profile[@"FBID"] = userIDsCopy[@(MPUserIdentityFacebook)];
    }
    if (userIDsCopy[@(MPUserIdentityGoogle)]) {
        profile[@"GPID"] = userIDsCopy[@(MPUserIdentityGoogle)];
    }
    if ([profile count] <= 0) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    if (isLogin) {
        [[CleverTap sharedInstance] onUserLogin:profile];
    } else {
        [[CleverTap sharedInstance] profilePush:profile];
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark e-Commerce
- (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
     if (commerceEvent.action == MPCommerceEventActionPurchase) {
         NSMutableDictionary *details = [NSMutableDictionary new];
         NSMutableArray *items = [NSMutableArray new];
         
         NSDictionary *transactionAttributes = [commerceEvent.transactionAttributes beautifiedDictionaryRepresentation];
         if (transactionAttributes) {
             [details addEntriesFromDictionary:transactionAttributes];
         }
         NSDictionary *commerceEventAttributes = [commerceEvent beautifiedAttributes];
         NSArray *keys = @[kMPExpCECheckoutOptions, kMPExpCECheckoutStep, kMPExpCEProductListName, kMPExpCEProductListSource];
         
         for (NSString *key in keys) {
             if (commerceEventAttributes[key]) {
                 details[key] = commerceEventAttributes[key];
             }
         }
         
         NSArray *products = commerceEvent.products;
         for (MPProduct *product in products) {
             [items addObject: [product beautifiedAttributes]];
         }
    
         [[CleverTap sharedInstance] recordChargedEventWithDetails:details andItems:items];
         [execStatus incrementForwardCount];
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
    [[CleverTap sharedInstance] recordEvent:event.name withProps:event.info];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    NSString *screenName = event.name;
    if (!screenName) {
         return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    [[CleverTap sharedInstance] recordScreenView:screenName];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark Assorted
- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    [[CleverTap sharedInstance] setOptOut:optOut];
    return [self execStatus:MPKitReturnCodeSuccess];
}

@end
