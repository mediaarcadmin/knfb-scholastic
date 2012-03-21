//
//  SCHRecommendationOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationOperation.h"
#import "SCHAppRecommendationItem.h"
#import "SCHRecommendationItem.h"

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
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];  
}

#pragma mark - thread safe access to book object

- (SCHAppRecommendationItem *)appRecommendation
{
    NSAssert([NSThread isMainThread], @"appRecommendation called not on main thread");
    
    SCHAppRecommendationItem *ret = nil;

    if (self.isbn) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationItem 
                                            inManagedObjectContext:self.mainThreadManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recommendationISBN.isbn = %@", self.isbn]];
        
        NSError *error = nil;
        NSArray *result = [self.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
        if (result == nil) {
            NSLog(@"Unresolved error fetching recommendation %@, %@", error, [error userInfo]);
        } else if ([result count] == 0) {
            NSLog(@"Could not fetch recoomendation with isbn %@", self.isbn);
        } else {
            ret = [result lastObject];
        }
    }
    
    return ret;
}

- (void)performWithRecommendation:(void (^)(SCHAppRecommendationItem *item))block;
{
    if (self.isCancelled || !self.isbn || !block) {
        return;
    }
    
    dispatch_block_t accessBlock = ^{
        SCHAppRecommendationItem *recommendation = [self appRecommendation];
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
            SCHAppRecommendationItem *recommendation = [self appRecommendation];
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

- (void)setNotCancelledCompletionBlock:(void (^)(void))block
{
    __block NSOperation *selfPtr = self;
    
    [self setCompletionBlock:^{
        if (![selfPtr isCancelled]) {
            block();
        }
    }];
}

@end
