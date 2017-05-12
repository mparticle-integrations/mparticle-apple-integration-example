//
//  MPKitIterable.m
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

#import "MPKitIterable.h"

NSString *const destinationDeeplinkURL = @"destinationURL";
NSString *const clickedDeeplinkURL = @"clickedURL";

@interface MPKitIterable() {
    NSDictionary *getAndTrackParams;
}

@end

@implementation MPKitIterable

+ (NSNumber *)kitCode {
    return @1003;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Iterable" className:@"MPKitIterable" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    if (!self) {
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

        _started = YES;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

#pragma mark Application
 - (MPKitExecStatus *)checkForDeferredDeepLinkWithCompletionHandler:(void(^)(NSDictionary *linkInfo, NSError *error))completionHandler {
     completionHandler(getAndTrackParams, nil);
     
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[MPKitIterable kitCode] returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }

 - (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
     NSURL *clickedURL = userActivity.webpageURL;
     
     getAndTrackParams = nil;
     ITEActionBlock callbackBlock = ^(NSString* destinationURL) {
        getAndTrackParams = [[NSDictionary alloc] initWithObjectsAndKeys: destinationURL, destinationDeeplinkURL, clickedURL, clickedDeeplinkURL, nil];
     };
     [IterableAPI getAndTrackDeeplink:clickedURL callbackBlock:callbackBlock];

     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[MPKitIterable kitCode] returnCode:MPKitReturnCodeSuccess];
     return execStatus;
 }

@end
