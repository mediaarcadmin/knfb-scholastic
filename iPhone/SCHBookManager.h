//
//  SCHBookManager.h
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SCHProcessingManager.h"

@class SCHXPSProvider;
@class SCHTextFlow;
@class SCHFlowEucBook;
@class SCHTextFlowParagraphSource;
@class SCHAppBook;
@class SCHSmartZoomBlockSource;

@interface SCHBookManager : NSObject 
{
}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SCHBookManager *)sharedBookManager;

- (SCHAppBook *)bookWithIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)allBooksAsISBNsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (SCHXPSProvider *)checkOutXPSProviderForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInXPSProviderForBookIdentifier:(NSString *)isbn;

// like checkOutXPSProviderForBookIdentifier:inManagedObjectContext: except synchronously
// jumps to the main thread to do core data access
- (SCHXPSProvider *)threadSafeCheckOutXPSProviderForBookIdentifier:(NSString *)isbn;

- (SCHFlowEucBook *)checkOutEucBookForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInEucBookForBookIdentifier:(NSString *)isbn;

- (SCHTextFlow *)checkOutTextFlowForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInTextFlowForBookIdentifier:(NSString *)isbn;

- (SCHTextFlowParagraphSource *)checkOutParagraphSourceForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInParagraphSourceForBookIdentifier:(NSString *)isbn;

+ (BOOL)checkAppCompatibilityForFeature:(NSString *)key version:(float)version;
+ (BOOL)appHasFeature:(NSString *)key;


@end
