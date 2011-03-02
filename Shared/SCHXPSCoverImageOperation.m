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

@synthesize bookInfo, localPath;

- (void)dealloc {
	self.bookInfo = nil;
	self.localPath = nil;
	
	[super dealloc];
}


- (void) main
{
    if ([self isCancelled]) {
		return;
	}
	
	if (!(self.bookInfo && self.localPath)) {
		return;
	}
	
	BWKXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:self.bookInfo];
	NSData *imageData = [xpsProvider coverThumbData];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:self.bookInfo];
	
	[imageData writeToFile:self.localPath atomically:YES];
	
}




@end
