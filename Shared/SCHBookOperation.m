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
@end


@implementation SCHBookOperation

@synthesize isbn;
@synthesize executing;
@synthesize finished;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
	[isbn release], isbn = nil;
	
	[super dealloc];
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

- (void)setProcessingState:(SCHBookCurrentProcessingState)state forBook:(NSString *)aIsbn
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
