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
#import "SCHBookIdentifier.h"

#pragma mark - Class Extension

@interface SCHBookOperation ()
@end


@implementation SCHBookOperation

@synthesize identifier;
@synthesize executing;
@synthesize finished;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
	[identifier release], identifier = nil;
	
	[super dealloc];
}

#pragma mark - common operation properties

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    [identifier release];
    identifier = [newIdentifier retain];
	
    if (identifier) { 
        [self setIsProcessing:YES];
    }
}

- (void)setIdentifierWithoutUpdatingProcessingStatus: (SCHBookIdentifier *) newIdentifier
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}

	[identifier release];
    identifier = [newIdentifier retain];
}

#pragma mark - Operation Methods

- (void)start
{
	if (self.identifier && ![self isCancelled]) {
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
    [self setIsProcessing:NO];
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

- (void)performWithBook:(void (^)(SCHAppBook *))block
{
    if (!self.identifier || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:self.mainThreadManagedObjectContext];
        block(book);
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), accessBlock);
    }
}

- (void)performWithBookAndSave:(void (^)(SCHAppBook *))block
{
    if (!self.identifier) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        if (block) {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:self.mainThreadManagedObjectContext];
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

- (void)setProcessingState:(SCHBookCurrentProcessingState)state
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
        book.State = [NSNumber numberWithInt: (int) state];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.identifier, @"bookIdentifier",
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
    }];
}

- (SCHBookCurrentProcessingState)processingState
{
    __block SCHBookCurrentProcessingState state;
    [self performWithBook:^(SCHAppBook *book) {
        state = [book processingState];
    }];
    return state;
}

- (void)setIsProcessing:(BOOL)isProcessing
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
        [book setProcessing:isProcessing];
    }];
}


@end
