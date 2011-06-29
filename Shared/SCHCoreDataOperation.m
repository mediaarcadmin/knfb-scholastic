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
@synthesize localManagedObjectContext;
@synthesize pendingChanges;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mainThreadManagedObjectContext release], mainThreadManagedObjectContext = nil;
    [localManagedObjectContext release], localManagedObjectContext = nil;
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

- (NSManagedObjectContext *)localManagedObjectContext
{
    if (localManagedObjectContext == nil) {
        NSLog(@"operation %@ creating local managedObjectContext", self);
        
        localManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [localManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        self.pendingChanges = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
    return localManagedObjectContext;
}

- (void)saveLocalChanges
{
    if (!localManagedObjectContext) {
        return;
    }
    
    NSLog(@"operation %@ saving in local managedObjectContext", self);
    
    // first apply any changes which came in from other threads
    NSArray *pending;
    @synchronized(self.pendingChanges) {
        pending = [NSArray arrayWithArray:self.pendingChanges];
        [self.pendingChanges removeAllObjects];
    }    
    for (NSNotification *note in pending) {
        [localManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
    }
    
    NSError *error = nil;
    if (![localManagedObjectContext save:&error]) {
        NSLog(@"failed to save local changes in %@: %@", self, error);
    }
}

- (void)mergeChanges:(NSNotification *)note
{
    if (note.object != self.localManagedObjectContext) {
        @synchronized(self.pendingChanges) {
            [self.pendingChanges addObject:note];
        }
    }
}

@end
