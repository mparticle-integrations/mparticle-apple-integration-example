//
//  AppDelegate.m
//  mParticle-Responsys
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

#import "AppDelegate.h"
#import "mParticle.h"
#import "MPKitResponsys.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString* const appKey = @"app_key";
NSString* const appSecret = @"app_secret";
NSString* const emailAddress = @"email_address";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MParticleOptions *mParticleOptions = [MParticleOptions optionsWithKey:appKey
                                                                   secret:appSecret];
    
    MPIdentityApiRequest *request = [MPIdentityApiRequest requestWithEmptyUser];
    request.email = emailAddress;
    mParticleOptions.identifyRequest = request;
    mParticleOptions.onIdentifyComplete = ^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
        NSLog(@"Identify complete. userId = %@ error = %@", apiResult.user.userId, error);
    };
    [[MParticle sharedInstance] startWithOptions:mParticleOptions];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self trackInAppMessageEvent];
    [self setUserPreferences];
    [self setCommerceEvent];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void) trackInAppMessageEvent{
    MPEvent *premiumEvent = [[MPEvent alloc] initWithName:ResponsysEventTypeIAMPremium type:MPEventTypeTransaction];
    MPEvent *socialEvent = [[MPEvent alloc] initWithName:ResponsysEventTypeIAMSocial type:MPEventTypeSocial];
    MPEvent *iapEvent = [[MPEvent alloc] initWithName:ResponsysEventTypeIAMPurchase type:MPEventTypeTransaction];
    MPEvent *otherEvent = [[MPEvent alloc] initWithName:ResponsysEventTypeIAMOther type:MPEventTypeOther];
    [[MParticle sharedInstance] logEvent:premiumEvent];
    [[MParticle sharedInstance] logEvent:socialEvent];
    [[MParticle sharedInstance] logEvent:iapEvent];
    [[MParticle sharedInstance] logEvent:otherEvent];
}

-(void) setUserPreferences{
    NSDictionary *preferences = @{@"Sports":@"Cricket",@"News":@"Tech"};
    MPEvent *preferenceEvent = [[MPEvent alloc] initWithName:ResponsysEventTypePreference type:MPEventTypeOther];
    preferenceEvent.info = preferences;
    [[MParticle sharedInstance] logEvent:preferenceEvent];
}

-(void) setCommerceEvent{
    MPProduct *product = [[MPProduct alloc] init];
    product.brand = @"Sample brand";
    product.category = @"Sample Category";
    product.couponCode = @"Sample CouponCode";
    product.name = @"Sample Name";
    product.price = @100;
    product.sku = @"Sample SKU";
    product.variant = @"Sample Variant";
    product.quantity = @10;
    MPTransactionAttributes *attributes = [[MPTransactionAttributes alloc] init];
    attributes.transactionId = @"Sample-Transaction-Identifier";
    MPCommerceEvent *commerceEvent = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase product:product];
    commerceEvent.transactionAttributes = attributes;
    [[MParticle sharedInstance] logCommerceEvent:commerceEvent];
}

@end
