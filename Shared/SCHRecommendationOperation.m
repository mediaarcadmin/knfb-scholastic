//
//  SCHRecommendationOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationOperation.h"
#import "SCHAppRecommendationItem.h"

@implementation SCHRecommendationOperation

@synthesize isbn;
@synthesize executing;
@synthesize finished;

// Note, this is a clone of SCHBookOperation

- (void)dealloc 
{
	[isbn release], isbn = nil;
    [super dealloc];
}

- (void)setIsbn:(NSString *)newIsbn
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    if (newIsbn != isbn) {
        [isbn release];
        isbn = [newIsbn copy];
    }
}

#pragma mark - Operation Methods

- (void)start
{
	if (self.isbn && ![self isCancelled]) {
        [[SCHRecommendationManager sharedManager] setProcessing:YES forIsbn:self.isbn];
		[self beginOperation];
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
	
    NSLog(@"SCHRecommendationOperation: using default operation. Please override correctly!");
    
    [self endOperation];
}

- (void)endOperation
{
    [[SCHRecommendationManager sharedManager] setProcessing:NO forIsbn:self.isbn];
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - thread safe access to book object

- (void)performWithRecommendation:(void (^)(SCHAppRecommendationItem *item))block;
{
    if (self.isCancelled || !self.isbn || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        SCHAppRecommendationItem *recommendation = [[SCHRecommendationManager sharedManager] appRecommendationForIsbn:self.isbn];
        block(recommendation);
    };
    
    if ([NSThread isMainThread]) {
        accessBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), accessBlock);
    }
}

- (void)performWithRecommendationAndSave:(void (^)(SCHAppRecommendationItem *))block;
{
    if (self.isCancelled || !self.isbn) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        if (block) {
            SCHAppRecommendationItem *recommendation = [[SCHRecommendationManager sharedManager] appRecommendationForIsbn:self.isbn];
            block(recommendation);
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

- (void)setProcessingState:(SCHAppRecommendationProcessingState)state
{
    [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
        item.state = [NSNumber numberWithInt: (int) state];
    }];
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

// Used to track if a cover url expires. We repeat the url request 3 times and 
// then set an error state if it is still expired. The state is stored in the 
// app recommendation item entity and is shared between the url request and 
// download cover operations to avoid any endless url request scenarios between
// them.
- (void)setCoverURLExpiredState
{
    [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
        NSInteger newCoverURLExpiredCount = [item.coverURLExpiredCount integerValue] + 1;
        
        NSLog(@"Warning: URLs from the server were already invalid for %@![%i]", item.ContentIdentifier, newCoverURLExpiredCount);
        
        if (newCoverURLExpiredCount >= 3) {
            item.state = [NSNumber numberWithInt:kSCHAppRecommendationProcessingStateURLsNotPopulated];            
            item.coverURLExpiredCount = [NSNumber numberWithInteger:0];
        } else {
            item.state = [NSNumber numberWithInt:kSCHAppRecommendationProcessingStateNoMetadata];
            item.coverURLExpiredCount = [NSNumber numberWithInteger:newCoverURLExpiredCount];
        }
    }];
}

- (void)resetCoverURLExpiredState
{
    [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
            item.coverURLExpiredCount = [NSNumber numberWithInteger:0];
    }];    
}

@end
