//
//  SCHRecommendationISBN.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHRecommendationISBN;

@interface SCHRecommendationISBN : NSManagedObject

@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSDate * fetchDate;
@property (nonatomic, retain) NSSet *recommendationItems;
@end

@interface SCHRecommendationISBN (CoreDataGeneratedAccessors)

- (void)addRecommendationItemsObject:(NSManagedObject *)value;
- (void)removeRecommendationItemsObject:(NSManagedObject *)value;
- (void)addRecommendationItems:(NSSet *)values;
- (void)removeRecommendationItems:(NSSet *)values;
@end
