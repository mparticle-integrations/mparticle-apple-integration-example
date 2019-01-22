#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

@interface MPKitPilgrim : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
NS_ASSUME_NONNULL_END
@property (nonatomic, unsafe_unretained, readonly) BOOL started;

@end
