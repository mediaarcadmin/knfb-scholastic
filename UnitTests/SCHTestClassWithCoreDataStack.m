//
//  BITTestClassWithCoreDataStack.m
//  Scholastic
//
//  Created by Neil Gall on 25/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTestClassWithCoreDataStack.h"


@implementation SCHTestClassWithCoreDataStack

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"] pathForResource:@"Scholastic" ofType:@"mom"];
    NSURL *modelURL = [NSURL fileURLWithPath:path];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    STAssertNotNil(model, @"Failed to load ManagedObjectModel");
    self.managedObjectModel = model;
    [model release];
    
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    self.persistentStoreCoordinator = store;
    [store release];
    
    NSError *error = nil;
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                  configuration:nil
                                                            URL:nil
                                                        options:nil
                                                          error:&error];
    STAssertNil(error, @"Failed to add persistent store: %@", error); 
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    self.managedObjectContext = context;
    [context release];
}

- (void)tearDown
{
    [super tearDown];
    
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
}

@end
