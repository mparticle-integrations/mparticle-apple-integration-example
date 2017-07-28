//
//  MPKitROKOMobiProvider.h
//  Pods
//
//  Created by zakatnov on 28/07/2017.
//
//

#import <Foundation/Foundation.h>

#if defined(__has_include) && __has_include(<ROKOMobi/ROKOMobi.h>)
#import <ROKOMobi/ROKOMobi.h>
#else
#import "ROKOMobi.h"
#endif


@protocol MPKitROKOMobiProvider

- (ROKOInstaBot *)getInstaBot;

@end
