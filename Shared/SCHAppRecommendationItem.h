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
#import "SCHRecommendationManager.h"

@class SCHRecommendationItem;
@class SCHWishListItem;

// Constants
extern NSString * const kSCHAppRecommendationItem;
extern NSString * const kSCHAppRecommendationItemIsbn;

@interface SCHAppRecommendationItem : NSManagedObject

@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * AverageRating;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSSet *recommendationItems;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSSet *wishListItems;

- (NSNumber *)AverageRatingAsNumber;
- (SCHAppRecommendationProcessingState)processingState;
- (void)setProcessingState:(SCHAppRecommendationProcessingState)processingState;
- (UIImage *)bookCover;
- (BOOL)isInUse;

- (NSString *)coverImagePath;
- (NSString *)thumbPathForSize:(CGSize)size;
- (NSString *)recommendationDirectory;

+ (NSString *)recommendationsDirectory;

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
