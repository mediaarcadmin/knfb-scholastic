//
//  SCHThumbnailOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 11/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThumbnailOperation.h"
#import "SCHThumbnailFactory.h"
#import "SCHProcessingManager.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

@implementation SCHThumbnailOperation

@synthesize isbn, aspect, size, flip;

- (void)dealloc {
	
	[super dealloc];
}

- (void)imageReady:(NSDictionary *)userInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHNewImageAvailable" object:isbn userInfo:userInfo];
}

- (void)main {
	
    if ([self isCancelled]) {
		return;
	}
	
	if (!self.isbn) {
		return;
	}
	
	// for testing: insert a random processing delay
	//	int randomValue = (arc4random() % 5) + 3;
	//	[NSThread sleepForTimeInterval:randomValue];

	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	
	NSString *fullImagePath = [book coverImagePath];
	NSString *thumbPath = [book thumbPathForSize:size];
	
	UIImage *thumbImage = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
		thumbImage = [SCHThumbnailFactory imageWithPath:thumbPath];
	} else {
		thumbImage = [SCHThumbnailFactory thumbnailImageOfSize:self.size 
														  path:fullImagePath
												maintainAspect:self.aspect];
		
		if (thumbImage) {
			NSData *pngData = UIImagePNGRepresentation(thumbImage);
//			NSLog(@"Writing to cachepath: %@", cachePath);
			[pngData writeToFile:thumbPath atomically:YES];
		}
	}
	
	if (thumbImage) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSValue valueWithCGSize:size], @"thumbSize", 
								  thumbImage, @"image", 
								  nil];
		
		[self performSelectorOnMainThread:@selector(imageReady:) 
							   withObject:userInfo 
							waitUntilDone:YES];
	}
}

- (void) cancel
{
	NSLog(@"Cancelling Thumbnail op.");
	[super cancel];
}




@end
