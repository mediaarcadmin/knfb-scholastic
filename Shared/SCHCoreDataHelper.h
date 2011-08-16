//
//  SCHCoreDataHelper.h
//  Scholastic
//
//  Created by John S. Eddie on 04/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHAppState;

// Constants
extern NSString * const SCHCoreDataHelperManagedObjectContextDidChangeNotification;
extern NSString * const SCHCoreDataHelperManagedObjectContext;

typedef enum {
	SCHCoreDataHelperStandardStore,
    SCHCoreDataHelperSampleStore,
} SCHCoreDataHelperStoreType;

@interface SCHCoreDataHelper : NSObject 
{
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)setupSampleStore;
- (void)setStoreType:(SCHCoreDataHelperStoreType)storeType;

- (void)saveContext;

@end
