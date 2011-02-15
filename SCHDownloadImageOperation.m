//
//  SCHDownloadImageOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadImageOperation.h"
#import "SCHThumbnailFactory.h"

@implementation SCHDownloadImageOperation

@synthesize imagePath, localPath;

- (void)dealloc {
	self.imagePath = nil;
	self.localPath = nil;
	
	[super dealloc];
}

- (void) main
{
    if ([self isCancelled]) {
		return;
	}
	
	if (!(self.imagePath && self.localPath)) {
		return;
	}
	
	NSURLResponse *response = nil;
	NSError *error = nil;
		
	NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:self.imagePath]
																			returningResponse:&response 
																						error:&error];
	
	if (!error) {
		[imageData writeToFile:self.localPath atomically:YES];
	}
		
}


@end
