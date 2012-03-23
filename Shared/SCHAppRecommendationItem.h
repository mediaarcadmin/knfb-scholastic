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

// Constants
extern NSString * const kSCHAppRecommendationItem;

@interface SCHAppRecommendationItem : SCHContentItem

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * AverageRating;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSSet *recommendationItems;
@property (nonatomic, retain) NSNumber * state;

- (NSNumber *)AverageRatingAsNumber;
- (SCHAppRecommendationProcessingState)processingState;
- (void)setProcessingState:(SCHAppRecommendationProcessingState)processingState;

- (NSString *)coverImagePath;
- (NSString *)thumbPathForSize:(CGSize)size;
- (NSString *)recommendationDirectory;

+ (NSString *)recommendationsDirectory;

@end

@interface SCHAppRecommendationItem (CoreDataGeneratedAccessors)

- (void)addRecommendationItemObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItem:(NSSet *)values;
- (void)removeRecommendationItem:(NSSet *)values;
@end
