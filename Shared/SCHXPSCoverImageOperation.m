//
//  SCHXPSCoverImageOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHXPSCoverImageOperation.h"
#import "BWKXPSProvider.h"
#import "SCHBookManager.h"

@implementation SCHXPSCoverImageOperation

@synthesize bookInfo;

- (void)dealloc {
	self.bookInfo = nil;
	
	[super dealloc];
}


- (void) main
{
    if ([self isCancelled]) {
		return;
	}
	
	if (!(self.bookInfo)) {
		return;
	}
	
	[self.bookInfo setProcessing:YES];
	
	BWKXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:self.bookInfo];
	NSData *imageData = [xpsProvider coverThumbData];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:self.bookInfo];
	
	[imageData writeToFile:[self.bookInfo coverImagePath] atomically:YES];
	
	[self.bookInfo setProcessing:NO];
	[self.bookInfo setProcessingState:SCHBookInfoProcessingStateReadyForRightsParsing];
}




@end
