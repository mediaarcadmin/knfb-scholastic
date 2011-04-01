//
//  SCHDictionaryFileUnarchiveOperation.m
//  Scholastic
//
//  Created by John S. Eddie on 29/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileUnarchiveOperation.h"

#import "SCHDictionaryManager.h"
#import "SCHAppBook.h"

@interface SCHDictionaryFileUnarchiveOperation ()

- (void)performUnarchive;

@property BOOL executing;
@property BOOL finished;

@property (readwrite, retain) NSString *localPath;

@end

@implementation SCHDictionaryFileUnarchiveOperation

@synthesize executing;
@synthesize finished;
@synthesize localPath;

#pragma mark -
#pragma mark Memory Management

- (void) dealloc
{
	self.localPath = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Startup methods

- (void)start
{
    if ([self isCancelled]) {
		NSLog(@"Cancelled.");
	} else {
		self.localPath = [[SCHAppBook cacheDirectory] 
						  stringByAppendingFormat:@"/dictionary-%@.zip", 
						  [[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion]];
		
		[self performUnarchive];
	}
}

- (void)performUnarchive
{
    [SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateNeedsParsing;    
}

#pragma mark -
#pragma mark NSOperation methods

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return self.executing;
}

- (BOOL)isFinished {
	return self.finished;
}

- (void) cancel
{
	NSLog(@"%%%% cancelling unarchiving operation");
	self.finished = YES;
	self.executing = NO;
    
	[super cancel];
}

@end
