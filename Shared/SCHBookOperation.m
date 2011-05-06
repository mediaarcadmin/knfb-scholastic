//
//  SCHBookOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

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

- (void)setIsbn:(NSString *) newIsbn
{
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
    [isbn release];
    isbn = [newIsbn copy];
	
    if (isbn) {
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];
        [book setProcessing:YES];
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
    
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	[book setProcessing:NO];
	
	return;
	
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

@end
