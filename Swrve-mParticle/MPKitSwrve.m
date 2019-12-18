#import "MPKitSwrve.h"

/* Import your header file here
*/
#if defined(__has_include) && __has_include(<SwrveSDK/SwrveSDK.h>)
#import <SwrveSDK/SwrveSDK.h>
#else
#import "SwrveSDK.h"
#endif

NSString *const SwrveMParticleVersionNumber = @"0.1.0";

@implementation MPKitSwrve
/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @216;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Swrve" className:@"MPKitSwrve"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *appId = configuration[@"app_id"];
    NSString *apiKey = configuration[@"api_key"];
    if (!apiKey || !appId) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    
    _configuration = configuration;
    _started=NO;
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)start {
    _init_called=NO;
    static dispatch_once_t swrvePredicate;
    
    dispatch_once(&swrvePredicate, ^{
        /*
         Start your SDK here. The configuration dictionary can be retrieved from self->_configuration
         */
        int appId = [self.configuration[@"app_id"] intValue];
        NSString *apiKey = self.configuration[@"api_key"];
        SwrveConfig* config = [[SwrveConfig alloc] init];
        MPKitAPI *kitAPI = [[MPKitAPI alloc] init];
        FilteredMParticleUser *currentUser = [kitAPI getCurrentUserWithKit:self];
        //MPIdentityApi* currentId = [[MParticle sharedInstance] identity];
        NSNumber *mpid = currentUser.userId;
        config.pushResponseDelegate = self;
        config.pushEnabled = YES;
        config.autoCollectDeviceToken = NO;
        config.pushNotificationEvents = [[NSSet alloc] init];
        config.appGroupIdentifier = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        self->_started=YES;
        
        config.userId = mpid.stringValue;
        if ([config.userId isEqual:@"0"]){
            return;
        }
        
        //        _configuration = self->_configuration;
        [SwrveSDK sharedInstanceWithAppID: appId
                                   apiKey: apiKey
                                   config: config];
        self->_init_called=YES;
        [SwrveSDK userUpdate:@{@"swrve.mparticle_ios_integration_version":SwrveMParticleVersionNumber}];
        
//        self->_started = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    return [self init_called] ? [SwrveSDK sharedInstance] : nil;
}


#pragma mark Application
/*
    Implement this method if your SDK handles a user interacting with a remote notification action
*/
 - (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK pushNotificationReceived:userInfo];
     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK receives and handles remote notifications
*/
 - (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK pushNotificationReceived:userInfo];
     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK registers the device token for remote notifications
*/
 - (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK setDeviceToken:deviceToken];
    return [self execStatus:MPKitReturnCodeSuccess];
 }

/** SwrvePushResponseDelegate
    Implement the following methods if you want to interact with a push action reponse
 **/

- (void) processNotificationResponse:(UNNotificationResponse *)response  API_AVAILABLE(ios(10.0)){
    [SwrveSDK processNotificationResponseWithIdentifier:response.actionIdentifier andUserInfo:response.notification.request.content.userInfo];
}

- (void) didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSLog(@"MPKitSwrve : didRecieveNotificationResponse was fired with the following push response: %@", response.actionIdentifier);
    
    if(completionHandler) {
        completionHandler();
    }
}

/** SwrvePushResponseDelegate
 Implement the following method if you want to determine the display type of a push in the foreground
 **/

- (void) willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    
    if(completionHandler) {
        completionHandler(UNNotificationPresentationOptionNone);
    }
}


/*
    Implement this method if your SDK handles continueUserActivity method from the App Delegate
*/
// - (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

/*
    Implement this method if your SDK handles the iOS 9 and above App Delegate method to open URL with options
*/
 - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK handleDeeplink:url];
     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK handles the iOS 8 and below App Delegate method open URL
*/
 - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK handleDeeplink:url];
     return [self execStatus:MPKitReturnCodeSuccess];
 }

#pragma mark User attributes
/*
    Implement this method if your SDK allows for incrementing numeric user attributes.
*/
-(MPKitExecStatus *)incrementUserAttribute:(NSString *)key byValue:(NSNumber *)value {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIncrementUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    return [SwrveSDK userUpdate: user.userAttributes] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
}

/*
    Implement this method if your SDK resets user attributes.
*/
//- (MPKitExecStatus *)onRemoveUserAttribute:(FilteredMParticleUser *)user {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

/*
    Implement this method if your SDK sets user attributes.
*/


//no-op due to bug in mParticle callback
- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(id)value {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
    NSDictionary* props=@{key:@""};
    return [SwrveSDK userUpdate:props] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
}

- (MPKitExecStatus *)onSetUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    return [SwrveSDK userUpdate: user.userAttributes] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
}

/*
    Implement this method if your SDK supports setting value-less attributes
*/
//- (MPKitExecStatus *)onSetUserTag:(FilteredMParticleUser *)user {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

#pragma mark Identity
/*
    Implement this method if your SDK should be notified any time the mParticle ID (MPID) changes. This will occur on initial install of the app, and potentially after a login or logout.
*/

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    if ([self init_called]){
        return [self execStatus:MPKitReturnCodeSuccess];
    }
    static dispatch_once_t swrvePredicate;
    
    dispatch_once(&swrvePredicate, ^{
        SwrveConfig *config = [[SwrveConfig alloc] init];
        MPKitAPI *kitAPI = [[MPKitAPI alloc] init];
        FilteredMParticleUser *currentUser = [kitAPI getCurrentUserWithKit:self];
        NSNumber *mpid = currentUser.userId;
        config.pushResponseDelegate = self;
        config.pushEnabled = YES;
        config.autoCollectDeviceToken = NO;
        config.pushNotificationEvents = [[NSSet alloc] init];
    
        config.userId = mpid.stringValue;
        [SwrveSDK sharedInstanceWithAppID:[self.configuration[@"app_id"] intValue] apiKey:self.configuration[@"api_key"] config:config];
        self->_init_called=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK should be notified when the user logs in
*/
//- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

/*
    Implement this method if your SDK should be notified when the user logs out
*/
//- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

/*
    Implement this method if your SDK should be notified when user identities change
*/
//- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

#pragma mark e-Commerce
/*
    Implement this method if your SDK supports commerce events.
    If your SDK does support commerce event, but does not support all commerce event actions available in the mParticle SDK,
    expand the received commerce event into regular events and log them accordingly (see sample code below)
    Please see MPCommerceEvent.h > MPCommerceEventAction for complete list
*/
 - (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
     NSString* currency = commerceEvent.currency ? : @"USD";

     // In this example, this SDK only supports the 'Purchase' commerce event action
     if (commerceEvent.action == MPCommerceEventActionPurchase) {
             /* Your code goes here. */
         
         for (MPProduct *product in commerceEvent.products) {
             SwrveIAPRewards* rewards = [[SwrveIAPRewards alloc] init];
             [SwrveSDK unvalidatedIap:rewards localCost:[product.price doubleValue] localCurrency:currency productId:product.sku productIdQuantity:[product.quantity intValue]];
             [execStatus incrementForwardCount];
         }
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
     if (event.type == MPEventTypeOther) {
         if ( [event.info valueForKey:@"given_currency"] && [event.info valueForKey:@"given_amount"] ) {
             NSString* givenCurrency = [event.info valueForKey:@"given_currency"];
             NSNumber* givenAmount = [event.info valueForKey:@"given_amount"];
             return [SwrveSDK currencyGiven:givenCurrency givenAmount:[givenAmount doubleValue]] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
         }
     }
     return [SwrveSDK event:[NSString stringWithFormat:@"%@.%@", [event.typeName lowercaseString], event.name] payload:event.info] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
 }

/*
    Implement this method if your SDK logs screen events
    Please see MPEvent.h
*/
 - (MPKitExecStatus *)logScreen:(MPEvent *)event {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     NSString* screen_name=event.name;
     NSString* event_name=[NSString stringWithFormat:@"screen_view.%@", screen_name];
     return [SwrveSDK event:event_name payload:event.info] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
 }

#pragma mark Assorted
/*
    Implement this method if your SDK implements an opt out mechanism for users.
*/
// - (MPKitExecStatus *)setOptOut:(BOOL)optOut {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

@end
