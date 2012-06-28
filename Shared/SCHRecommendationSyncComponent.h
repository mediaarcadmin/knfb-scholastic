//
//  SCHRecommendationSyncComponent.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

extern NSString * const SCHRecommendationSyncComponentISBNs;
extern NSString * const SCHRecommendationSyncComponentDidCompleteNotification;
extern NSString * const SCHRecommendationSyncComponentDidFailNotification;

@interface SCHRecommendationSyncComponent : SCHSyncComponent

- (void)retrieveRecommendationsForProfileCompletionResult:(NSDictionary *)result
                                                 userInfo:(NSDictionary *)userInfo;
- (void)retrieveRecommendationsForBooksResult:(NSDictionary *)result 
                                     userInfo:(NSDictionary *)userInfo;
- (NSMutableArray *)localFilteredBooksForDRMQualifier:(NSNumber *)drmQualifier 
                                               asISBN:(BOOL)asISBN
                                 managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
                     insertInto:(id)recommendation
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
