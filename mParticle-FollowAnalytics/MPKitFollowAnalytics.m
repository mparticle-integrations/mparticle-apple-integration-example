#import "MPKitFollowAnalytics.h"

#if defined(__has_include) && __has_include(<FollowAnalytics/FollowAnalytics.h>)
#import <FollowAnalytics/FollowAnalytics.h>
#else
#import "FollowAnalytics.h"
#endif

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    #import <UserNotifications/UserNotifications.h>
    #import <UserNotifications/UNUserNotificationCenter.h>
#endif

@implementation MPKitFollowAnalytics

+ (NSNumber *)kitCode {
    return @132;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"FollowAnalytics"
                                                           className:@"MPKitFollowAnalytics"];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        FollowAnalyticsConfiguration* faConfiguration = [FollowAnalyticsConfiguration
                                                         configurationWith:^(FollowAnalyticsMutableConfiguration * _Nonnull c) {
                                                             c.apiKey = self.configuration[FollowAnalyticsAPIKey];
                                                             c.appGroup = self.configuration[FollowAnalyticsAppGroup];
                                                             c.debug = self.configuration[FollowAnalyticsDebugMode];
                                                             c.isDataWalletEnabled = YES;
                                                             c.onDataWalletPolicyChange = ^{
                                                                 nil;
                                                             };
                                                         }];
        [FollowAnalytics startWithConfiguration:faConfiguration startupOptions:nil];

        _started = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (nonnull MPKitExecStatus *)didFinishLaunchingWithConfiguration:(nonnull NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;

    Class klass = NSClassFromString(@"FollowAnalytics");
    if (!klass) {
        NSLog(@"The FollowAnalytics SDK was not detected. Please refer to https://dev.followanalytics.com/sdks/ios/documentation.");
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }

    [self start];

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}


- (id const)providerKitInstance {
    return nil;
}


#pragma mark Application
#pragma mark User attributes and identities
 - (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
     [FollowAnalytics.userAttributes setString:value
                                        forKey:key];

     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }

 - (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
     [FollowAnalytics.userAttributes clear:key];

     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }

 - (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
     switch (identityType) {
         case MPUserIdentityCustomerId:
             [FollowAnalytics setUserId:identityString];
             break;
         default:
             break;
     }

      MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
      return execStatus;
 }

#pragma mark e-Commerce
#pragma mark Events
- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    [FollowAnalytics logEvent:event.name
                      details:event.info];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logError:(NSString *)message eventInfo:(NSDictionary *)eventInfo {
    [FollowAnalytics logError:message details:eventInfo];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logException:(NSException *)exception {
    [FollowAnalytics logError:[exception name] details:[exception reason]];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}


#pragma mark Assorted
 - (MPKitExecStatus *)setOptOut:(BOOL)optOut {
     [FollowAnalytics setOptInAnalytics:!optOut];
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFollowAnalytics) returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }

@end
