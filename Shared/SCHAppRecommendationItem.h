//
//  SCHAppRecommendationItem.h
//  Scholastic
//
//  Created by John Eddie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHContentItem.h"

@class SCHRecommendationItem;
@class SCHWishListItem;

// Constants
extern NSString * const kSCHAppRecommendationItem;

@interface SCHAppRecommendationItem : SCHContentItem

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * AverageRating;
@property (nonatomic, retain) NSString * ContentURL;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSNumber * Enhanced;
@property (nonatomic, retain) NSString * FileName;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSSet *recommendationItems;
@property (nonatomic, retain) NSSet *wishListItems;

- (NSNumber *)AverageRatingAsNumber;
- (UIImage *)bookCover;
- (BOOL)isInUse;

@end

@interface SCHAppRecommendationItem (CoreDataGeneratedAccessors)

- (void)addRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItems:(NSSet *)values;
- (void)removeRecommendationItems:(NSSet *)values;

- (void)addWishListItemsObject:(SCHWishListItem *)value;
- (void)removeWishListItemsObject:(SCHWishListItem *)value;
- (void)addWishListItems:(NSSet *)values;
- (void)removeWishListItems:(NSSet *)values;

@end
