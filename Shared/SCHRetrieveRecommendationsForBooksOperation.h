//
//  SCHRetrieveRecommendationsForBooksOperation.h
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

@interface SCHRetrieveRecommendationsForBooksOperation : SCHSyncComponentOperation

- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
