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

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContextForCurrentThread;

+ (SCHBookManager *)sharedBookManager;

- (SCHAppBook *)bookWithIdentifier:(NSString *)isbn;
- (NSArray *)allBooksAsISBNs;

- (SCHXPSProvider *)checkOutXPSProviderForBookIdentifier:(NSString *)isbn;
- (void)checkInXPSProviderForBookIdentifier:(NSString *)isbn;

- (SCHFlowEucBook *)checkOutEucBookForBookIdentifier:(NSString *)isbn;
- (void)checkInEucBookForBookIdentifier:(NSString *)isbn;

- (SCHTextFlow *)checkOutTextFlowForBookIdentifier:(NSString *)isbn;
- (void)checkInTextFlowForBookIdentifier:(NSString *)isbn;

- (SCHTextFlowParagraphSource *)checkOutParagraphSourceForBookIdentifier:(NSString *)isbn;
- (void)checkInParagraphSourceForBookIdentifier:(NSString *)isbn;

- (SCHSmartZoomBlockSource *)checkOutBlockSourceForBookIdentifier:(NSString *)isbn;
- (void)checkInBlockSourceForBookIdentifier:(NSString *)isbn;

+ (BOOL)checkAppCompatibilityForFeature:(NSString *)key version:(float)version;
+ (BOOL)appHasFeature:(NSString *)key;

- (void)threadSafeUpdateBookWithISBN: (NSString *)isbn setValue:(id)value forKey:(NSString *)key;
- (void)threadSafeUpdateBookWithISBN: (NSString *)isbn state:(SCHBookCurrentProcessingState)state;


@end
