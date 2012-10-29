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
	} else {
        [self endOperation];
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

- (void)beginOperation
{
    // default method; to be overridden
    // this simply sets the book to "not processing" and ends the operation
	
    NSLog(@"SCHBookOperation: using default operation. Please override correctly!");

    [self setIsProcessing:NO];    
    [self endOperation];
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
    [self performWithBook:block forBookWithIdentifier:self.identifier];
}

- (void)performWithBook:(void (^)(SCHAppBook *))block forBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    if (self.isCancelled || !bookIdentifier || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:bookIdentifier inManagedObjectContext:self.mainThreadManagedObjectContext];
        block(book);
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (![self isCancelled]) {
                accessBlock();
            } else {
                NSLog(@"dispatch_sync performWithBook discarded due to operation being cancelled");
            }
        });
    }
}

- (void)performWithBookAndSave:(void (^)(SCHAppBook *))block
{
    [self performWithBook:block forBookWithIdentifier:self.identifier];
}

- (void)performWithBookAndSave:(void (^)(SCHAppBook *))block forBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    if (self.isCancelled || !bookIdentifier) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        if (block) {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:bookIdentifier inManagedObjectContext:self.mainThreadManagedObjectContext];
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
    [self setProcessingState:state forBookWithIdentifier:self.identifier];
}

- (void)setProcessingState:(SCHBookCurrentProcessingState)state forBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
        book.State = [NSNumber numberWithInt: (int) state];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (bookIdentifier == nil ? (id)[NSNull null] : bookIdentifier), @"bookIdentifier",
                                  (book.State == nil ? (id)[NSNull null] : book.State), @"bookState",
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
    } forBookWithIdentifier:bookIdentifier];
}

- (SCHBookCurrentProcessingState)processingState
{
    return [self processingStateForBookWithIdentifier:self.identifier];
}

- (SCHBookCurrentProcessingState)processingStateForBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    __block SCHBookCurrentProcessingState state = SCHBookProcessingStateError;
    [self performWithBook:^(SCHAppBook *book) {
        state = [book processingState];
    } forBookWithIdentifier:bookIdentifier];
    return state;
}

- (void)setIsProcessing:(BOOL)isProcessing
{
    [self setIsProcessing:isProcessing forBookWithIdentifier:self.identifier];
}

- (void)setIsProcessing:(BOOL)isProcessing forBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    // Doesn't need to be called on main thread as processing manager synchronises this
    [[SCHProcessingManager sharedProcessingManager] setProcessing:isProcessing forIdentifier:bookIdentifier];
}

- (void)setNotCancelledCompletionBlock:(void (^)(void))block
{
    __block NSOperation *selfPtr = self;
    
    [self setCompletionBlock:^{
        if (![selfPtr isCancelled]) {
            block();
        }
    }];
}

// Used to track if a url expires. We repeat the url request 3 times and then
// set an error state if it is still expired. The state is stored in the app 
// book entity and is shared between the url request and download book 
// operations to avoid any endless url request scenarios between them.

- (void)setCoverURLExpiredStateForBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
        NSInteger newURLExpiredCount = [book.urlExpiredCount integerValue] + 1;
        
        NSLog(@"Warning: URLs from the server are invalid for %@![%i]", book.ContentIdentifier, newURLExpiredCount);
        
        if (newURLExpiredCount >= 3) {
            book.State = [NSNumber numberWithInt:SCHBookProcessingStateURLsNotPopulated];            
            book.urlExpiredCount = [NSNumber numberWithInteger:0];
        } else {
            book.State = [NSNumber numberWithInt:SCHBookProcessingStateNoURLs];
            book.urlExpiredCount = [NSNumber numberWithInteger:newURLExpiredCount];
        }
    } forBookWithIdentifier:bookIdentifier];
}

// NOTE: SCHBookURLRequestOperation.m performs the same operation in it's own
// performWithRecommendationAndSave
- (void)resetCoverURLExpiredStateForBookWithIdentifier:(SCHBookIdentifier *)bookIdentifier
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
            book.urlExpiredCount = [NSNumber numberWithInteger:0];
    } forBookWithIdentifier:bookIdentifier];
}

@end
