//
//  SCHListBooksAssignmentOperation.h
//  Scholastic
//
//  Created by John Eddie on 19/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

@class SCHBooksAssignment;

@interface SCHListBooksAssignmentOperation : SCHSyncComponentOperation

- (void)syncBooksAssignments:(NSArray *)booksAssignmentList
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHBooksAssignment *)addBooksAssignment:(NSDictionary *)webBooksAssignment
                      managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end
