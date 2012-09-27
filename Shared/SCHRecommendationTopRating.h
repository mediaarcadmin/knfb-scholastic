//
//  SCHAppRecommendationTopRating.h
//  Scholastic
//
//  Created by John S. Eddie on 27/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHRecommendationItem;

// Constants
extern NSString * const kSCHAppRecommendationTopRating;

@interface SCHAppRecommendationTopRating : NSManagedObject

@property (nonatomic, retain) NSString * categoryClass;
@property (nonatomic, retain) NSDate * fetchDate;
@property (nonatomic, retain) NSSet *recommendationItems;

+ (BOOL)isValidCategoryClass:(NSString *)categoryClass;

@end

@interface SCHAppRecommendationTopRating (CoreDataGeneratedAccessors)

- (void)addRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItems:(NSSet *)values;
- (void)removeRecommendationItems:(NSSet *)values;
@end
