//
//  SCHBookBatchOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 19/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookBatchOperation.h"

@implementation SCHBookBatchOperation

@synthesize identifiers;

#pragma mark - Object Lifecycle

- (void)dealloc
{
	[identifiers release], identifiers = nil;
	[super dealloc];
}

- (void)setIdentifier:(SCHBookIdentifier *)identifier
{
    NSAssert(identifier != nil, @"Should not set identifier on batch operation", identifier);
    [super setIdentifier:identifier];
}

- (void)setIdentifiers:(NSArray *)array
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    NSArray *newIdentifiers = [array copy];
    [identifiers release];
    identifiers = newIdentifiers;
    
    
    for (SCHBookIdentifier *identifier in identifiers) {
        [self setIsProcessing:YES forBookWithIdentifier:identifier];
    }	
}

#pragma mark - Operation Methods

- (void)start
{
	if ([self.identifiers count] && ![self isCancelled]) {
		[self beginOperation];
	} else {
        [self endOperation];
    }
}

- (void)endOperation
{
    for (SCHBookIdentifier *identifier in self.identifiers) {
        [self setIsProcessing:NO forBookWithIdentifier:identifier];
    }

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
