//
//  SCHBookOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "SCHBookOperation.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

#pragma mark - Class Extension

@interface SCHBookOperation ()
@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSMutableArray *pendingChanges;
@end


@implementation SCHBookOperation

@synthesize isbn;
@synthesize executing;
@synthesize finished;
@synthesize persistentStoreCoordinator;
@synthesize mainThreadManagedObjectContext;
@synthesize localManagedObjectContext;
@synthesize pendingChanges;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[isbn release], isbn = nil;
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
    
    // first apply any changes which came in from other threads
    @synchronized(self.pendingChanges) {
        for (NSNotification *note in self.pendingChanges) {
            [localManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
        }
        [self.pendingChanges removeAllObjects];
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

#pragma mark - common operation properties

- (void)setIsbn:(NSString *) newIsbn
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    [isbn release];
    isbn = [newIsbn copy];
	
    if (isbn) {        
        [self withBook:isbn perform:^(SCHAppBook *book) {
            [book setProcessing:YES];
        }];
    }
}

- (void)setIsbnWithoutUpdatingProcessingStatus: (NSString *) newIsbn
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    [isbn release];
    isbn = [newIsbn copy];
}

#pragma mark - Operation Methods

- (void)start
{
	if (self.isbn && ![self isCancelled]) {
		[self beginOperation];
	}
}

- (void)cancel
{
    [self endOperation];
	[super cancel];
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return self.executing;
}

- (BOOL)isFinished {
	return self.finished;
}

- (void)beginOperation
{
    // default method; to be overridden
    // this simply sets the book to "not processing" and ends the operation
	
    NSLog(@"SCHBookOperation: using default operation. Please override correctly!");

    [self endOperation];
    [self setBook:self.isbn isProcessing:NO];
}

- (void)endOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];  
}

#pragma mark - thread safe access to book object

- (void)withBook:(NSString *)aIsbn perform:(void (^)(SCHAppBook *))block
{
    if (!aIsbn || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:aIsbn inManagedObjectContext:self.mainThreadManagedObjectContext];
        block(book);
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), accessBlock);
    }
}

- (void)withBook:(NSString *)aIsbn performAndSave:(void (^)(SCHAppBook *))block
{
    if (!aIsbn) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        if (block) {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:aIsbn inManagedObjectContext:self.mainThreadManagedObjectContext];
            block(book);
        }
        NSError *error = nil;
        if (![self.mainThreadManagedObjectContext save:&error]) {
            NSLog(@"failed to save: %@", error);
        }
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), accessBlock);
    }
}

- (void)threadSafeUpdateBookWithISBN:(NSString *)aIsbn state:(SCHBookCurrentProcessingState)state 
{
    [self withBook:aIsbn performAndSave:^(SCHAppBook *book) {
        book.State = [NSNumber numberWithInt: (int) state];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  aIsbn, @"isbn",
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
    }];
}

- (SCHBookCurrentProcessingState)processingStateForBook:(NSString *)aIsbn
{
    __block SCHBookCurrentProcessingState state;
    [self withBook:aIsbn perform:^(SCHAppBook *book) {
        state = [book processingState];
    }];
    return state;
}

- (void)setBook:(NSString *)aIsbn isProcessing:(BOOL)isProcessing
{
    [self withBook:aIsbn performAndSave:^(SCHAppBook *book) {
        [book setProcessing:isProcessing];
    }];
}


@end
