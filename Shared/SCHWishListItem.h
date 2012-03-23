//
//  SCHWishListItem.h
//  Scholastic
//
//  Created by John Eddie on 02/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

extern NSString * const kSCHWishListItem;

@class SCHWishListProfile;
@class SCHAppRecommendationItem;

@interface SCHWishListItem : SCHSyncEntity

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * InitiatedBy;
@property (nonatomic, retain) NSString * ISBN;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) SCHWishListProfile *WishListProfile;
@property (nonatomic, retain) SCHAppRecommendationItem *appRecommendationItem;

@property (nonatomic, readonly) NSDate *Timestamp;

- (void)assignAppRecommendationItem;

@end
