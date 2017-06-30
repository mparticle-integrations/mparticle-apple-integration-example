//
//  IterableMPHelper.m
//  Pods
//
//  Created by David Truong on 4/21/17.
//
//

#import <Foundation/Foundation.h>
#import "IterableMPHelper.h"

NSString *const IterableDestinationURLKey = @"IterableDestinationURLKey";
NSString *const IterableClickedURLKey = @"IterableClickedURLKey";

@interface IterableAPI () {
}

@end

@implementation IterableAPI {
}

+(void) getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock
{
    if ([self isIterableDeeplink:webpageURL]) {
        NSURLSessionDataTask *trackAndRedirectTask = [[NSURLSession sharedSession]
                                                      dataTaskWithURL:webpageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          callbackBlock(response.URL.absoluteString);
                                                      }];
        [trackAndRedirectTask resume];
    } else {
        callbackBlock(webpageURL.absoluteString);
    }
}

+(BOOL) isIterableDeeplink:(NSURL *)webpageURL
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ITBL_DEEPLINK_IDENTIFIER options:0 error:NULL];
    NSString *urlString = webpageURL.absoluteString;
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    
    return match != NULL;
}

@end
