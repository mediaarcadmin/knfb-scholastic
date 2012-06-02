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
    if (self.isCancelled || !self.identifier || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:self.mainThreadManagedObjectContext];
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
    if (self.isCancelled || !self.identifier) {
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
                                  (self.identifier == nil ? (id)[NSNull null] : self.identifier), @"bookIdentifier",
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
    }];
}

- (SCHBookCurrentProcessingState)processingState
{
    __block SCHBookCurrentProcessingState state = SCHBookProcessingStateError;
    [self performWithBook:^(SCHAppBook *book) {
        state = [book processingState];
    }];
    return state;
}

- (void)setIsProcessing:(BOOL)isProcessing
{
    // Doesn't need to be called on main thread as processing manager synchronises this
    [[SCHProcessingManager sharedProcessingManager] setProcessing:isProcessing forIdentifier:[self identifier]];
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
- (void)setCoverURLExpiredState
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
    }];
}

- (void)resetCoverURLExpiredState
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
            book.urlExpiredCount = [NSNumber numberWithInteger:0];
    }];
}

// Used to track if a download fails. We repeat the download request 3 times and 
// then set an error state if it is still erroring. The state is stored in the 
// app book entity.
- (void)setDownloadFailedState
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
        NSInteger newDownloadFailedCount = [book.downloadFailedCount integerValue] + 1;
        
        NSLog(@"Warning: download failed for %@![%i]", book.ContentIdentifier, newDownloadFailedCount);
        
        if (newDownloadFailedCount >= 3) {
            book.State = [NSNumber numberWithInt:SCHBookProcessingStateDownloadFailed];            
            book.downloadFailedCount = [NSNumber numberWithInteger:0];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (self.identifier == nil ? (id)[NSNull null] : self.identifier), @"bookIdentifier",
                                      nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
        } else {
            // the current download operation will go to the end of the queue and repeat
            book.downloadFailedCount = [NSNumber numberWithInteger:newDownloadFailedCount];
        }
    }];
}

- (void)resetDownloadFailedState
{
    [self performWithBookAndSave:^(SCHAppBook *book) {
        book.downloadFailedCount = [NSNumber numberWithInteger:0];
    }];
}

@end
