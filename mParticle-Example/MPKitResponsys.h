//
//  MPKitResponsys.h
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

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

FOUNDATION_EXPORT NSString * _Nonnull const CUSTOM_FLAG_IAM;
FOUNDATION_EXPORT NSString * _Nonnull const ENGAGEMENT_METRIC_PREMIUM_CONTENT;
FOUNDATION_EXPORT NSString * _Nonnull const ENGAGEMENT_METRIC_INAPP_PURCHASE;
FOUNDATION_EXPORT NSString * _Nonnull const ENGAGEMENT_METRIC_OTHER;
FOUNDATION_EXPORT NSString * _Nonnull const ENGAGEMENT_METRIC_SOCIAL;

@interface MPKitResponsys : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;


@end
