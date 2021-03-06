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

@interface SCHCoreDataHelper : NSObject 
{
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithError:(NSError **)error;

- (void)saveContext;
- (void)resetMainStore;
- (void)resetDictionaryStore;

@end
