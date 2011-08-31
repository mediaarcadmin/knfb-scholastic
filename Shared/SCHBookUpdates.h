//
//  SCHBookUpdates.h
//  Scholastic
//
//  Created by Neil Gall on 26/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHBookUpdates : NSObject {}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// re-query the database for available book updates
- (void)refresh;

// YES if at least one book update is available
- (BOOL)areBookUpdatesAvailable;

// the set of SCHAppBooks that can be updated
- (NSArray *)availableBookUpdates;

@end
