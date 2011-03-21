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
#import "SCHContentMetadataItem+Extensions.h"

@interface SCHBookManager : NSObject {

}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContextForCurrentThread;

+ (SCHBookManager *)sharedBookManager;

+ (SCHBookInfo *) bookInfoWithBookIdentifier: (NSString *) isbn;

- (BITXPSProvider *)checkOutXPSProviderForBook: (SCHBookInfo *) bookInfo;
- (void) checkInXPSProviderForBook: (SCHBookInfo *) bookInfo;

+ (BOOL) checkAppCompatibilityForFeature: (NSString *) key version: (float) version;
+ (BOOL) appHasFeature: (NSString *) key;


@end
