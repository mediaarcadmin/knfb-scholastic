//
//  SCHBookURLRequestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookURLRequestOperation.h"
#import "BWKXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHURLManager.h"
#import "SCHLibreAccessWebService.h"
#import "SCHProcessingManager.h"

@interface SCHBookURLRequestOperation ()

@property BOOL executing;
@property BOOL finished;
@property BOOL waitingForAnotherOperation;

- (void) beginConnection;

@end

@implementation SCHBookURLRequestOperation

@synthesize bookInfo, executing, finished, waitingForAnotherOperation;

- (void)dealloc {
	self.bookInfo = nil;
	
	[super dealloc];
}


- (void) setBookInfo:(SCHBookInfo *) newBookInfo
{
	
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
	SCHBookInfo *oldInfo = bookInfo;
	bookInfo = [newBookInfo retain];
	[oldInfo release];
	[self.bookInfo setProcessing:YES];
}

- (void) start
{
//	if (!(self.bookInfo)) {
//		NSLog(@"No book info!");
//	} else if ([self isCancelled]) {
//		NSLog(@"********** Operation already cancelled.");
//	} else {
	if (self.bookInfo && ![self isCancelled]) {
		[self beginConnection];
	}
	
}

- (void) cancel
{
	self.finished = YES;
	self.executing = NO;
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

- (void) beginConnection
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
	
	[[SCHURLManager sharedURLManager] requestURLForISBN:self.bookInfo.bookIdentifier];

	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.bookInfo setProcessing:NO];
	return;
	
}

- (void) urlSuccess: (NSNotification *) notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	NSString *completedISBN = [userInfo valueForKey:kSCHLibreAccessWebServiceContentIdentifier];

	if ([completedISBN compare:self.bookInfo.bookIdentifier] == NSOrderedSame) {
	
		self.bookInfo.coverURL = [userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL];
		self.bookInfo.bookFileURL = [userInfo valueForKey:kSCHLibreAccessWebServiceContentURL];
		NSLog(@"Successful URL retrieval for %@!", completedISBN);
		
		[self.bookInfo setProcessingState:SCHBookInfoProcessingStateNoCoverImage];
		
		self.executing = NO;
		self.finished = YES;
	}
}

- (void) urlFailure: (NSNotification *) notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedISBN = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
	
	if ([completedISBN compare:self.bookInfo.bookIdentifier] == NSOrderedSame) {
		NSLog(@"Failure for ISBN %@", completedISBN);
		[self.bookInfo setProcessingState:SCHBookInfoProcessingStateError];

		self.executing = NO;
		self.finished = YES;
	}
}

@end