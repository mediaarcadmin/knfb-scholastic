//
//  SCHXPSCoverImageOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHXPSCoverImageOperation.h"
#import "BITXPSProvider.h"
#import "SCHBookManager.h"

@implementation SCHXPSCoverImageOperation

@synthesize isbn;

- (void)dealloc {
	self.isbn = nil;
	
	[super dealloc];
}


- (void) main
{
    if ([self isCancelled]) {
		return;
	}
	
	if (!(self.isbn)) {
		return;
	}
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	[book setProcessing:YES];
	
	BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	NSData *imageData = [xpsProvider coverThumbData];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifer:self.isbn];
	
	[imageData writeToFile:[book coverImagePath] atomically:YES];
	
	[book setProcessing:NO];
//	[self.bookInfo setProcessingState:SCHBookProcessingStateReadyForRightsParsing];
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForRightsParsing];

}




@end
