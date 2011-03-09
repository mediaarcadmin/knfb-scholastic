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
	
	NSURL *imagePath = [NSURL URLWithString:bookInfo.coverURL];
	
	NSLog(@"Image path is %@", imagePath);
	
	NSURLResponse *response = nil;
	NSError *error = nil;
		
	NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imagePath]
																			returningResponse:&response 
																						error:&error];
	
	if (!error) {
		[imageData writeToFile:self.localPath atomically:YES];
	}
		
}


@end
