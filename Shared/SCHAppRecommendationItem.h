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

- (NSNumber *)AverageRatingAsNumber;

@end

@interface SCHAppRecommendationItem (CoreDataGeneratedAccessors)

- (void)addRecommendationItemObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItem:(NSSet *)values;
- (void)removeRecommendationItem:(NSSet *)values;
@end
