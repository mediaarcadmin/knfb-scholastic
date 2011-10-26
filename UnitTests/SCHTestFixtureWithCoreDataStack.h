//
//  BITTestClassWithCoreDataStack.h
//  Scholastic
//
//  Created by Neil Gall on 25/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SCHTestFixtureWithCoreDataStack : NSObject {}

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (id)initWithPersistentStoreConfiguration:(NSString *)configuration;

@end
