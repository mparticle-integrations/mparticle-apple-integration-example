//
//  IterableMPHelper.h
//  Pods
//
//  Created by David Truong on 4/21/17.
//
//

#ifndef IterableMPHelper_h
#define IterableMPHelper_h

typedef void (^ITEActionBlock)(NSString *);

#define ITBL_DEEPLINK_IDENTIFIER @"/a/[a-zA-Z0-9]+"

/**
 `IterableAPI` contains all the essential functions for communicating with Iterable's API
 */
@interface IterableAPI : NSObject

/*!
 @method
 
 @abstract tracks a link click and passes the redirected URL to the callback
 
 @param webpageURL      the URL that was clicked
 @param callbackBlock   the callback to send after the webpageURL is called
 
 @discussion            passes the string of the redirected URL to the callback
 */+(void) getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock;

@end

#endif 

/* IterableMPHelper_h */
