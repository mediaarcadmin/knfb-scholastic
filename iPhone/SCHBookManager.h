//
//  SCHBookManager.h
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BITXPSProvider.h"
#import "SCHContentMetadataItem.h"
#import "SCHProcessingManager.h"

@interface SCHBookManager : NSObject {

}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContextForCurrentThread;

+ (SCHBookManager *)sharedBookManager;

- (SCHAppBook *) bookWithIdentifier: (NSString *) isbn;
- (NSArray *)allBooksAsISBNs;

- (BITXPSProvider *)checkOutXPSProviderForBookIdentifier: (NSString *) isbn;
- (void)checkInXPSProviderForBookIdentifier: (NSString *) isbn;

+ (BOOL) checkAppCompatibilityForFeature: (NSString *) key version: (float) version;
+ (BOOL) appHasFeature: (NSString *) key;

- (void)threadSafeUpdateBookWithISBN: (NSString *) isbn setValue:(id)value forKey:(NSString *)key;
- (void)threadSafeUpdateBookWithISBN: (NSString *) isbn state: (SCHBookCurrentProcessingState) state;


@end
