//
//  SCHCoreDataHelper.h
//  Scholastic
//
//  Created by John S. Eddie on 04/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
	SCHCoreDataHelperStoreTypeStandard,
    SCHCoreDataHelperStoreTypeSample,
    SCHCoreDataHelperStoreTypeLocalFiles
} SCHCoreDataHelperStoreType;

@interface SCHCoreDataHelper : NSObject 
{
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)setStoreType:(SCHCoreDataHelperStoreType)storeType;

- (void)saveContext;

// remove everything from the CoreData database
- (void)clearDatabase;

- (BOOL)standardStore;
- (BOOL)synchronise;
- (BOOL)downloadBooks;

@end
