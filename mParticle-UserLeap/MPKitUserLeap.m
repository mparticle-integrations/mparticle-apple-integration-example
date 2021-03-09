#import "MPKitUserLeap.h"

/* Import your header file here
*/
#if defined(__has_include) && __has_include(<UserLeapKit/UserLeapKit.h>)
#import <UserLeapKit/UserLeapKit.h>
#import <UserLeapKit/UserLeapKit-Swift.h>
#else
#import "UserLeapKit.h"
#import "UserLeapKit-Swift.h"
#endif

@implementation MPKitUserLeap
/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @1169;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"UserLeap" className:@"MPKitUserLeap"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *environmentId = configuration[@"environmentId"];
    if (!environmentId || ![environmentId isKindOfClass:[NSString class]] || environmentId.length == 0) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }

    _configuration = configuration;

    [self start];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        [[UserLeap shared] configureWithEnvironment:self->_configuration[@"environmentId"]];
        
        self->_started = YES;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    return [self started] ? UserLeap.shared : nil;
}

#pragma mark Application

//we currently don't need to handle any of these

#pragma mark User attributes

- (nonnull MPKitExecStatus *)setUserAttribute:(nonnull NSString *)key value:(nonnull id)value {
    //only handle numbers and strings
    //arrays and dicts will be handled in a later version
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        [[UserLeap shared] setVisitorAttributeWithKey:key value:[NSString stringWithFormat:@"%@",value]];
        return [self execStatus:MPKitReturnCodeSuccess];
    }
    return [self execStatus:MPKitReturnCodeUnavailable];
}

- (nonnull MPKitExecStatus *)setUserIdentity:(nullable NSString *)identityString identityType:(MPUserIdentity)identityType {
    MPKitReturnCode returnCode;
    switch (identityType) {
        case MPUserIdentityEmail:
            [[UserLeap shared] setEmailAddress:identityString];
            returnCode = MPKitReturnCodeSuccess;
            break;
        case MPUserIdentityCustomerId:
        case MPUserIdentityAlias:
            [[UserLeap shared] setUserIdentifier:identityString];
            returnCode = MPKitReturnCodeSuccess;
            break;
        default:
            returnCode = MPKitReturnCodeRequirementsNotMet;
            break;
    }
    return [self execStatus:returnCode];
}

- (nonnull MPKitExecStatus *)setUserTag:(nonnull NSString *)tag {
    [[UserLeap shared] setVisitorAttributeWithKey:tag value:@"1"];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)onIdentifyComplete:(nonnull FilteredMParticleUser *)user
                                        request:(nonnull FilteredMPIdentityApiRequest *)request {
    return [self _handleLogin:user request:request];
}

- (nonnull MPKitExecStatus *)onLoginComplete:(nonnull FilteredMParticleUser *)user
                                     request:(nonnull FilteredMPIdentityApiRequest *)request {
    return [self _handleLogin:user request:request];
}

- (nonnull MPKitExecStatus *)_handleLogin:(nonnull FilteredMParticleUser *)user
                                  request:(nonnull FilteredMPIdentityApiRequest *)request {
    if (request.customerId) [[UserLeap shared] setUserIdentifier:request.customerId];
    if (request.email) [[UserLeap shared] setEmailAddress:request.email];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user
                                      request:(FilteredMPIdentityApiRequest *)request {
    if (request.email) [[UserLeap shared] setEmailAddress:request.email];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)onLogoutComplete:(nonnull FilteredMParticleUser *)user
                                      request:(nonnull FilteredMPIdentityApiRequest *)request {
    [[UserLeap shared] logout];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark Events

NSString *commerceNameFromEvent(MPCommerceEvent *event) {
    switch (event.action) {
        case MPCommerceEventActionClick:
            return @"click";
        case MPCommerceEventActionRefund:
            return @"refund";
        case MPCommerceEventActionCheckout:
            return @"checkout";
        case MPCommerceEventActionPurchase:
            return @"purchase";
        case MPCommerceEventActionViewDetail:
            return @"view detail";
        case MPCommerceEventActionAddToCart:
            return @"add to cart";
        case MPCommerceEventActionCheckoutOptions:
            return @"checkout options";
        case MPCommerceEventActionRemoveFromCart:
            return @"remove from cart";
        case MPCommerceEventActionRemoveFromWishlist:
            return @"remove from wishlist";
        case MPCommerceEventActionAddToWishList:
            return @"add to wishlist";
        default:
            break;
    }
    return nil;
}

- (nonnull MPKitExecStatus *)logBaseEvent:(MPBaseEvent *)event {
    NSString *name = nil;
    if ([event isKindOfClass:[MPEvent class]]) name = ((MPEvent *)event).name;
    else if ([event isKindOfClass:[MPCommerceEvent class]]) name = commerceNameFromEvent((MPCommerceEvent *)event);
    if (!name) return [self execStatus:MPKitReturnCodeUnavailable];
    
    BOOL showSurvey = [event.timestamp timeIntervalSinceNow] > -5;
    if (event.customAttributes[@"userleap_dont_show_survey"]) showSurvey = NO;
    void (^surveyDisplayer)(enum SurveyState state) = showSurvey ? ^void(enum SurveyState state) {
        if (state == SurveyStateReady) {
            [[UserLeap shared] presentSurveyFrom:[self topViewController]];
        }
    } : nil;
    [[UserLeap shared] trackWithEventName:name handler:surveyDisplayer];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logout {
    [[UserLeap shared] logout];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark - Utilities

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navContObj = (UINavigationController *)viewController;
        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
        UIViewController *presentedViewController = viewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        for (UIView *view in [viewController.view subviews])
        {
            id subViewController = [view nextResponder];
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
            {
                if ([(UIViewController *)subViewController presentedViewController]  && ![subViewController presentedViewController].isBeingDismissed) {
                    return [self topViewControllerWithRootViewController:[(UIViewController *)subViewController presentedViewController]];
                }
            }
        }
        return viewController;
    }
}

@end
