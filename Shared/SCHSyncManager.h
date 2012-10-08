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

@class SCHBooksAssignment;

@interface SCHSyncManager : NSObject <SCHComponentDelegate>
{	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) BOOL isSynchronizing;
@property (nonatomic, readonly) BOOL isQueueEmpty;
@property (nonatomic, assign, getter=isSuspended) BOOL suspended;

+ (SCHSyncManager *)sharedSyncManager;

- (void)startHeartbeat;
- (void)stopHeartbeat;

- (void)resetSync;
- (void)flushSyncQueue;
- (BOOL)havePerformedAccountSync;

- (void)accountSyncForced:(BOOL)syncNow
requireDeviceAuthentication:(BOOL)requireAuthentication;
- (void)performFlushSaves;
- (void)passwordSync;
- (void)bookshelfSyncForced:(BOOL)syncNow;
- (void)openBookSyncForced:(BOOL)syncNow
           booksAssignment:(SCHBooksAssignment *)booksAssignment
                forProfile:(NSNumber *)profileID
       requestReadingStats:(BOOL)requestReadingStats;
- (void)closeBookSyncForced:(BOOL)syncNow
            booksAssignment:(SCHBooksAssignment *)booksAssignment
                 forProfile:(NSNumber *)profileID;
- (void)recommendationSync;
- (void)wishListSyncForced:(BOOL)syncNow;

// for populating Sample Store
- (void)populateTestSampleStore;
- (void)populateSampleStore;
- (BOOL)populateSampleStoreFromManifestEntries:(NSArray *)entries;
- (BOOL)populateSampleStoreFromImport;

@end
