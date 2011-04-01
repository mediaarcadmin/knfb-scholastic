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

@property (readwrite, retain) NSString *localPath;

@end

@implementation SCHDictionaryFileParseOperation

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
		self.localPath = [[SCHDictionaryManager dictionaryDirectory] 
						  stringByAppendingFormat:@"/dictionary-%@.zip", 
						  [[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion]];
		
		[self performParsing];
	}
    
    [SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateDone;    
}

- (void)performParsing
{
    
}

@end
