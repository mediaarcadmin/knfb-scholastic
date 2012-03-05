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

@interface SCHWishListItem : SCHSyncEntity

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * initiatedBy;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) SCHWishListProfile *wishListProfile;

@end
