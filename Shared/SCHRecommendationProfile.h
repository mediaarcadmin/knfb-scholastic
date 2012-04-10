//
//  SCHRecommendationProfile.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHRecommendationItem;

// Constants
extern NSString * const kSCHRecommendationProfile;

@interface SCHRecommendationProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDate * fetchDate;
@property (nonatomic, retain) NSSet *recommendationItems;
@end

@interface SCHRecommendationProfile (CoreDataGeneratedAccessors)

- (void)addRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemsObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItems:(NSSet *)values;
- (void)removeRecommendationItems:(NSSet *)values;

@end
