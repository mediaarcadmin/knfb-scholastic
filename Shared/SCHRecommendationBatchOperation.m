//
//  SCHRecommendationBatchOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 20/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationBatchOperation.h"

@implementation SCHRecommendationBatchOperation

@synthesize isbns;

- (void)dealloc
{
	[isbns release], isbns = nil;
	[super dealloc];
}

- (void)setIsbn:(NSString *)isbn
{
    NSAssert(isbn != nil, @"Should not set isbn on batch operation", isbn);
    [super setIsbn:isbn];
}

- (void)setIsbns:(NSArray *)array
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    NSArray *newIsbns = [array copy];
    [isbns release];
    isbns = newIsbns;    
}

#pragma mark - Operation Methods

- (void)start
{
	if ([self.isbns count] && ![self isCancelled]) {
        for (NSString *isbn in self.isbns) {
            [[SCHRecommendationManager sharedManager] setProcessing:YES forIsbn:isbn];

        }
		[self beginOperation];
	} else {
        [self endOperation];
    }
}

- (void)endOperation
{
    for (NSString *isbn in self.isbns) {
        [[SCHRecommendationManager sharedManager] setProcessing:NO forIsbn:isbn];
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
