//
//  PIOMediaAttachmentServiceExtension.h
//  PIOMediaAttachmentExtension
//
//  Copyright © 2017 Oracle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>


@interface PIOMediaAttachmentServiceExtension : UNNotificationServiceExtension

-(void)enableLogging;
-(void)disableLogging;
-(BOOL)isLoggingEnabled;

@end
