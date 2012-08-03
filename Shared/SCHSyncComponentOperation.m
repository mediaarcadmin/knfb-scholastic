//
//  SCHSyncComponentOperation.m
//  Scholastic
//
//  Created by John Eddie on 14/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

#import "SCHSyncComponent.h"

/*
 * Any sync operations should be used serially and NOT concurrently
 */

@implementation SCHSyncComponentOperation

@synthesize backgroundThreadManagedObjectContext;
@synthesize syncComponent;
@synthesize result;
@synthesize userInfo;

- (id)initWithSyncComponent:(SCHSyncComponent *)aSyncComponent
                     result:(NSDictionary *)aResult
                   userInfo:(NSDictionary *)aUserInfo
{
    self = [super init];
    if (self) {
        syncComponent = [aSyncComponent retain];
        result = [aResult retain];
        userInfo = [aUserInfo retain];
    }

    return self;
}

- (void)dealloc
{
    [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    [syncComponent release], syncComponent = nil;
    [result release], result = nil;
    [userInfo release], userInfo = nil;
    
    [super dealloc];
}

#pragma mark - Accessor methods

- (NSManagedObjectContext *)backgroundThreadManagedObjectContext
{
    if (backgroundThreadManagedObjectContext == nil) {
        backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:syncComponent.managedObjectContext.persistentStoreCoordinator];
        [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    
    return backgroundThreadManagedObjectContext;
}

#pragma mark - SCHSyncComponentOperation methods

- (void)saveWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (self.isCancelled == NO && aManagedObjectContext != nil) {
        NSError *error = nil;
        
        if ([aManagedObjectContext hasChanges] == YES &&
            [aManagedObjectContext save:&error] == NO) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
