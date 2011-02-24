//
//  SCHSyncManager.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SCHComponentDelegate.h"

@class SCHUserContentItem;

@interface SCHSyncManager : NSObject <SCHComponentDelegate>
{	

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) BOOL isSynchronizing;
@property (readonly, nonatomic) BOOL isQueueEmpty;

+ (SCHSyncManager *)sharedSyncManager;

- (void)start;
- (void)stop;

- (void)firstSync;
- (void)openDocument:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID;
- (void)closeDocument:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID;
- (void)exitParentalTools:(BOOL)syncNow;

@end
