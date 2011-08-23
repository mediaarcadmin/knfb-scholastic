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

// Constants
extern NSString * const SCHSyncManagerDidCompleteNotification;

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

- (void)clear;
- (BOOL)havePerformedFirstSyncUpToBooks;

- (void)firstSync:(BOOL)syncNow;
- (void)changeProfile;
- (void)updateBookshelf;
- (void)openDocument:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID;
- (void)closeDocument:(SCHUserContentItem *)userContentItem forProfile:(NSNumber *)profileID;

// for populating Sample Store
- (void)populateSampleStore;
- (void)populateLocalDebugSampleStore;

@end
