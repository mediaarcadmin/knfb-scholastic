//
//  SCHBookURLRequestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookURLRequestOperation.h"
#import "SCHURLManager.h"
#import "SCHLibreAccessWebService.h"
#import "SCHProcessingManager.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

@interface SCHBookURLRequestOperation ()

@property BOOL executing;
@property BOOL finished;

- (void) beginConnection;

@end

@implementation SCHBookURLRequestOperation

@synthesize isbn, executing, finished;

- (void)dealloc {
	self.isbn = nil;
	
	[super dealloc];
}


- (void) setBookInfo:(NSString *) newIsbn
{
	
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
	NSString *oldIsbn = newIsbn;
	isbn = [newIsbn retain];
	[oldIsbn release];
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	[book setProcessing:YES];
}

- (void) start
{
	if (self.isbn && ![self isCancelled]) {
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
	
	[[SCHURLManager sharedURLManager] requestURLForISBN:self.isbn];

	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	[book setProcessing:NO];
	
	return;
	
}

- (void) urlSuccess: (NSNotification *) notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSLog(@"Thread: %@ Main Thread: %@", [NSThread currentThread], [NSThread mainThread]);
	NSDictionary *userInfo = [notification userInfo];
	
	NSString *completedISBN = [userInfo valueForKey:kSCHLibreAccessWebServiceContentIdentifier];

	if ([completedISBN compare:self.isbn] == NSOrderedSame) {
	
		//self.bookInfo.coverURL = [userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL];
		//self.bookInfo.bookFileURL = [userInfo valueForKey:kSCHLibreAccessWebServiceContentURL];
		
//		[self.bookInfo setString:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] 
//				  forMetadataKey:kSCHBookInfoCoverURL];
//		[self.bookInfo setString:[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] 
//				  forMetadataKey:kSCHBookInfoContentURL];
		
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL]
																  forKey:kSCHAppBookCoverURL];
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL]
																  forKey:kSCHAppBookFileURL];
		
		NSLog(@"Successful URL retrieval for %@!", completedISBN);
		
//		[self.bookInfo setProcessingState:SCHBookProcessingStateNoCoverImage];
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateNoCoverImage];
		
		self.executing = NO;
		self.finished = YES;
	}
}

- (void) urlFailure: (NSNotification *) notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedISBN = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
	
	if ([completedISBN compare:self.isbn] == NSOrderedSame) {
		NSLog(@"Failure for ISBN %@", completedISBN);
//		[self.bookInfo setProcessingState:SCHBookProcessingStateError];
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];

		self.executing = NO;
		self.finished = YES;
	}
}

@end