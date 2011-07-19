//
//  SCHCoreDataOperation.m
//  Scholastic
//
//  Created by Neil Gall on 29/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCoreDataOperation.h"

@interface SCHCoreDataOperation ()
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSMutableArray *pendingChanges;
@end

@implementation SCHCoreDataOperation

@synthesize persistentStoreCoordinator;
@synthesize mainThreadManagedObjectContext;
@synthesize pendingChanges;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mainThreadManagedObjectContext release], mainThreadManagedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [pendingChanges release], pendingChanges = nil;

    [super dealloc];
}

#pragma mark - Core Data access

- (NSManagedObjectContext *)mainThreadManagedObjectContext
{
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"can only access mainThreadManagedObjectContext on main thread");
    return mainThreadManagedObjectContext;
}

- (void)setMainThreadManagedObjectContext:(NSManagedObjectContext *)aMainThreadManagedObjectContext
{
    if (aMainThreadManagedObjectContext != mainThreadManagedObjectContext) {
        [mainThreadManagedObjectContext release];
        mainThreadManagedObjectContext = [aMainThreadManagedObjectContext retain];
        self.persistentStoreCoordinator = [aMainThreadManagedObjectContext persistentStoreCoordinator];
    }
}

@end
