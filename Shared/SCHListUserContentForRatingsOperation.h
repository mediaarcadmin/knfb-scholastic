//
//  SCHListUserContentForRatingsOperation.h
//  Scholastic
//
//  Created by John Eddie on 19/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

@class SCHUserContentItem;

@interface SCHListUserContentForRatingsOperation : SCHSyncComponentOperation

- (void)syncUserContentItems:(NSArray *)userContentList
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHUserContentItem *)addUserContentItem:(NSDictionary *)webUserContentItem
                      managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
