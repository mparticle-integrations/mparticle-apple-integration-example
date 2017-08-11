//
//  MPKitROKOMobi.h
//
//  Copyright 2017 ROKO Labs, Inc.
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

#if defined(__has_include) && __has_include(<ROKOMobi/ROKOMobi.h>)
#import <ROKOMobi/ROKOMobi.h>
#else
#import "ROKOMobi.h"
#endif

@protocol MPKitROKOMobiProvider

/**
 * Provides direct access to ROKOInstaBot object.
 * 
 * @return ROKOInstaBot instance.
 */
- (nullable ROKOInstaBot *)getInstaBot;

/**
 * Provides direct access to ROKOLinkManager object.
 *
 * @return ROKOLinkManager instance. 
 */
- (nullable ROKOLinkManager *)getLinkManager;

@end

@interface MPKitROKOMobi : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *userAttributes;
@property (nonatomic, strong, nullable) NSArray<NSDictionary<NSString *, id> *> *userIdentities;

@end
