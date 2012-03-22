//
//  SCHRecommendationSyncComponent.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

extern NSString * const SCHRecommendationSyncComponentDidInsertNotification;
extern NSString * const SCHRecommendationSyncComponentWillDeleteNotification;
extern NSString * const SCHRecommendationSyncComponentISBNs;
extern NSString * const SCHRecommendationSyncComponentDidCompleteNotification;
extern NSString * const SCHRecommendationSyncComponentDidFailNotification;

@interface SCHRecommendationSyncComponent : SCHSyncComponent

@end
