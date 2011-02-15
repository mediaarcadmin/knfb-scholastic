//
//  SCHBookManager.h
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BWKXPSProvider.h"
#import "SCHContentMetadataItem+Extensions.h"

@interface SCHBookManager : NSObject {

}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContextForCurrentThread;

+ (SCHBookManager *)sharedBookManager;

//- (SCHContentMetadataItem *)bookWithID:(NSManagedObjectID *)aBookID;
- (BWKXPSProvider *)checkOutXPSProviderForBook: (SCHBookInfo *) bookInfo;
- (void) checkInXPSProviderForBook: (SCHBookInfo *) bookInfo;

//- (BWKXPSProvider *)checkOutXPSProviderForBookWithID: (NSManagedObjectID *) id;
//- (void)checkInXPSProviderForBookWithID: (NSManagedObjectID *) id;

@end
