//
//  SCHRetrieveRecommendationsForBooksOperation.h
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

// Constants
extern NSString * const SCHRetrieveRecommendationsForBooksOperationCreateOrUpdateBooksNotification;
extern NSString * const SCHRetrieveRecommendationsForBooksOperationBookIdentifiers;

@interface SCHRetrieveRecommendationsForBooksOperation : SCHSyncComponentOperation

- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
