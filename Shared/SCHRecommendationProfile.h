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

@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) NSDate * fetchDate;
@property (nonatomic, retain) NSSet *recommendationItem;
@end

@interface SCHRecommendationProfile (CoreDataGeneratedAccessors)

- (void)addRecommendationItemObject:(SCHRecommendationItem *)value;
- (void)removeRecommendationItemObject:(SCHRecommendationItem *)value;
- (void)addRecommendationItem:(NSSet *)values;
- (void)removeRecommendationItem:(NSSet *)values;
@end
