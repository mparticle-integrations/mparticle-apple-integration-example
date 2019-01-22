#import "MPKitPilgrim.h"
#import <Pilgrim/Pilgrim.h>

NSString *const PILGRIM_SDK_KEY = @"pilgrim_sdk_key";
NSString *const PILGRIM_SDK_SECRET = @"pilgrim_sdk_secret";
NSString *const PERSIST_LOGS = @"pilgrim_sdk_persistent_logs";
NSString *const MPARTICLE_USER_ID = @"mParticleUserId";

NS_ASSUME_NONNULL_BEGIN
@interface MPKitPilgrim()

@property(nonatomic, nullable) FSQPPilgrimManager *pilgrimManager;

@end
NS_ASSUME_NONNULL_END

@implementation MPKitPilgrim
+ (NSNumber *)kitCode {
    return @211;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Pilgrim" className:@"MPKitPilgrim"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *consumerKey = [self stringOrNil:configuration[PILGRIM_SDK_KEY]];
    NSString *secretKey = [self stringOrNil:configuration[PILGRIM_SDK_SECRET]];
    BOOL persistLogs = [configuration[PERSIST_LOGS] boolValue];

    if (!consumerKey || !secretKey) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }

    self.pilgrimManager = [FSQPPilgrimManager sharedManager];

    if (!self.pilgrimManager) {
        return nil;
    }

    [self.pilgrimManager configureWithConsumerKey:consumerKey secret:secretKey delegate:nil completion:nil];
    self.pilgrimManager.debugLogsEnabled = persistLogs;

    _configuration = configuration;

    [self start];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (NSString *) stringOrNil:(id _Nullable)value {
    return [value isKindOfClass:[NSString class]] ? (NSString *)value : nil;
}

- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        self->_started = YES;

        [self.pilgrimManager start];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (void)updateUserWithMParticleUser:(FilteredMParticleUser *)mparticleUser {
    FSQPUserInfo *userInfo = [self.pilgrimManager userInfo];
    NSString *mParticleUserId = [mparticleUser.userId stringValue];
    NSString *customerId = [mparticleUser.userIdentities objectForKey:@(MPUserIdentityCustomerId)];

    if (customerId) {
        [userInfo setUserId:customerId];
    }

    [userInfo setUserInfo:mParticleUserId forKey:MPARTICLE_USER_ID];
}

- (id const)providerKitInstance {
    return nil;
}

#pragma mark Identity
- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [self updateUserWithMParticleUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [self updateUserWithMParticleUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [self updateUserWithMParticleUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark User attributes
/*
 Implement this method if your SDK allows for incrementing numeric user attributes.
 */
//- (MPKitExecStatus *)onIncrementUserAttribute:(FilteredMParticleUser *)user {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

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
//- (MPKitExecStatus *)onSetUserAttribute:(FilteredMParticleUser *)user {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

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
#pragma mark Events
/*
 Implement this method if your SDK logs user events.
 Please see MPEvent.h
 */
// - (MPKitExecStatus *)logEvent:(MPEvent *)event {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

/*
 Implement this method if your SDK logs screen events
 Please see MPEvent.h
 */
// - (MPKitExecStatus *)logScreen:(MPEvent *)event {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

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
