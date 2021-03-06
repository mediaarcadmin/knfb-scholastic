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

@class SCHTextFlow;
@class SCHAppBook;
@class SCHSmartZoomBlockSource;
@class SCHBookIdentifier;

@protocol KNFBParagraphSource;
@protocol SCHEucBookmarkPointTranslation;
@protocol EucBook;
@protocol SCHBookPackageProvider;
@protocol SCHRecommendationDataSource;

@interface SCHBookManager : NSObject 
{
}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SCHBookManager *)sharedBookManager;

- (SCHAppBook *)bookWithIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)removeBookIdentifierFromCache:(SCHBookIdentifier *)identifier;
- (void)clearBookIdentifierCache;
- (NSArray *)allBookIdentifiersInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (id <SCHBookPackageProvider>)checkOutBookPackageProviderForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (id <SCHBookPackageProvider>)checkOutBookPackageProviderForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error;
- (void)checkInBookPackageProviderForBookIdentifier:(SCHBookIdentifier *)identifier;

- (id<EucBook, SCHEucBookmarkPointTranslation, SCHRecommendationDataSource>)checkOutEucBookForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInEucBookForBookIdentifier:(SCHBookIdentifier *)identifier;

- (SCHTextFlow *)checkOutTextFlowForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInTextFlowForBookIdentifier:(SCHBookIdentifier *)identifier;

- (id<KNFBParagraphSource>)checkOutParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)checkInParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier;

// these are like the normal checkout method but synchronously jump to the main thread to do core data access
- (id<KNFBParagraphSource>)threadSafeCheckOutParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier;
- (id <SCHBookPackageProvider>)threadSafeCheckOutBookPackageProviderForBookIdentifier:(SCHBookIdentifier *)identifier;
- (id <SCHBookPackageProvider>)threadSafeCheckOutBookPackageProviderForBookIdentifier:(SCHBookIdentifier *)identifier error:(NSError **)error;
- (id<EucBook, SCHEucBookmarkPointTranslation, SCHRecommendationDataSource>)threadSafeCheckOutEucBookForBookIdentifier:(SCHBookIdentifier *)identifier;


+ (BOOL)checkAppCompatibilityForFeature:(NSString *)key version:(float)version;
+ (BOOL)appHasFeature:(NSString *)key;


@end
