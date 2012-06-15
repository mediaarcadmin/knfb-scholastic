//
//  SCHWishListSyncComponent.h
//  Scholastic
//
//  Created by John Eddie on 23/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

extern NSString * const SCHWishListSyncComponentDidInsertNotification;
extern NSString * const SCHWishListSyncComponentISBNs;
extern NSString * const SCHWishListSyncComponentDidCompleteNotification;
extern NSString * const SCHWishListSyncComponentDidFailNotification;

@interface SCHWishListSyncComponent : SCHSyncComponent

@end
