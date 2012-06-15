//
//  SCHSyncComponentOperation.m
//  Scholastic
//
//  Created by John Eddie on 14/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

#import "SCHSyncComponent.h"

@interface SCHSyncComponentOperation ()

// state for isExecuting and isFinished
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;

@end

@implementation SCHSyncComponentOperation

@synthesize backgroundThreadManagedObjectContext;
@synthesize syncComponent;
@synthesize result;
@synthesize userInfo;
@synthesize executing;
@synthesize finished;

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

#pragma mark - NSOperation subclassing methods

- (void)start
{
	if (self.isCancelled == NO) {
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];  
                
		[self beginOperation];
	} else {
        [self saveAndEndOperation];
    }
}

- (BOOL)isConcurrent 
{
	return YES;
}

- (BOOL)isExecuting 
{
	return self.executing;
}

- (BOOL)isFinished 
{
	return self.finished;
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

- (void)beginOperation
{
    NSAssert(NO, @"SCHSyncComponentOperation:beginOperation needs to be overidden in sub-classes");    
}

- (void)save
{
    NSError *error = nil;
    
    if ([self.backgroundThreadManagedObjectContext hasChanges] == YES &&
        [self.backgroundThreadManagedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
}

- (void)saveAndEndOperation
{
    // we purposefully don't call the self.accessor here as we don't want to 
    // create the managed object context if it's not been used    
    if (self.isCancelled == NO &&
        backgroundThreadManagedObjectContext != nil) {
        [self save];
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];  
}

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
