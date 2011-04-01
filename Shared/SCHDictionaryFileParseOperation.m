//
//  SCHDictionaryFileParseOperation.m
//  Scholastic
//
//  Created by John S. Eddie on 29/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileParseOperation.h"

#import "SCHDictionaryManager.h"

@interface SCHDictionaryFileParseOperation ()

- (void)performParsing;

@property BOOL executing;
@property BOOL finished;

@end

@implementation SCHDictionaryFileParseOperation

@synthesize executing;
@synthesize finished;

#pragma mark -
#pragma mark Startup methods

- (void)start
{
    if (self.isCancelled == YES) {
		NSLog(@"Cancelled.");
	} else {
		[self performParsing];
	}
}

- (void)performParsing
{
    [SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateDone;      
    self.executing = NO;
	self.finished = YES;
}

#pragma mark -
#pragma mark NSOperation methods

- (BOOL)isConcurrent {
	return(YES);
}

- (BOOL)isExecuting {
	return(self.executing);
}

- (BOOL)isFinished {
	return(self.finished);
}

- (void)cancel
{
	NSLog(@"%%%% cancelling parsing operation");
	self.finished = YES;
	self.executing = NO;
    
	[super cancel];
}

@end
