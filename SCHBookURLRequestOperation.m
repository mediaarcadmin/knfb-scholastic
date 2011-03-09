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

@interface SCHBookURLRequestOperation ()

@property BOOL executing;
@property BOOL finished;

- (void) beginConnection;

@end


@implementation SCHBookURLRequestOperation

@synthesize bookInfo, executing, finished;

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
}

- (void) start
{
	NSLog(@"Starting URL process.");
	if (!(self.bookInfo) || [self isCancelled]) {
		NSLog(@"No book info or cancelled.");
	} else {
		[self beginConnection];
	}
	
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
	
/*	if ([self.bookInfo isCurrentlyDownloading]) {
		NSLog(@"Operation: already downloading the file.");
		return;
	}
*/	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:@"kSCHURLManagerSuccess" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:@"kSCHURLManagerFailure" object:nil];
	
	[[SCHURLManager sharedURLManager] requestURLForISBN:self.bookInfo.bookIdentifier];
	
	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	return;
	
}

- (void) urlSuccess: (NSNotification *) notification
{
	
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedISBN = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];

	if ([completedISBN compare:self.bookInfo.bookIdentifier] == NSOrderedSame) {
	
		self.bookInfo.coverURL = [userInfo objectForKey:kSCHLibreAccessWebServiceCoverURL];
		self.bookInfo.bookFileURL = [userInfo objectForKey:kSCHLibreAccessWebServiceContentURL];

		self.executing = NO;
		self.finished = YES;
	}
}

- (void) urlFailure: (NSNotification *) notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedISBN = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
	
	if ([completedISBN compare:self.bookInfo.bookIdentifier] == NSOrderedSame) {
		self.executing = NO;
		self.finished = YES;
	}
}

@end