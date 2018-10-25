//
//  PushIOManager+ExceptionHandling.h
//  PushIOManager
//
//  Copyright © 2018 Oracle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushIOManager.h"

@interface PushIOManager (ExceptionHandling)


/**
 Log the exception in file if crashLogging is enabled.
 
 @param exception logs the given exception
 */
- (void)handleException:(NSException *)exception;


@end
