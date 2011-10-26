//
//  BITTestClassWithCoreDataStack.m
//  Scholastic
//
//  Created by Neil Gall on 25/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTestFixtureWithCoreDataStack.h"

@implementation SCHTestFixtureWithCoreDataStack

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

- (id)initWithPersistentStoreConfiguration:(NSString *)configuration
{
    if ((self = [super init])) {
        NSString *path = [[NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"] pathForResource:@"Scholastic" ofType:@"mom"];
        NSURL *modelURL = [NSURL fileURLWithPath:path];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSAssert(model != nil, @"Failed to load ManagedObjectModel");
        self.managedObjectModel = model;
        [model release];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        self.persistentStoreCoordinator = coordinator;
        [coordinator release];
        
        NSError *error = nil;
        NSPersistentStore *store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                                 configuration:configuration
                                                                                           URL:nil
                                                                                       options:nil
                                                                                         error:&error];
        NSAssert(store != nil, @"Failed to add persistent store: %@", error); 
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        self.managedObjectContext = context;
        [context release];
    }
    return self;
}

- (void)dealloc
{
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
    [super dealloc];
}

@end
