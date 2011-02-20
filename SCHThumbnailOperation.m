//
//  SCHThumbnailOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 11/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThumbnailOperation.h"
#import "SCHThumbnailFactory.h"

@implementation SCHThumbnailOperation

@synthesize aspect, thumbPath, path, thumbRect, size, flip;

- (void)dealloc {
	self.thumbPath = nil;
	self.path = nil;
	
	[super dealloc];
}

- (void)imageReady:(NSDictionary *)userInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHNewImageAvailable" object:nil userInfo:userInfo];
}

- (void)main {
	
    if ([self isCancelled]) {
		return;
	}
	
	if (!(self.thumbPath && self.path && !CGRectIsNull(self.thumbRect))) {
		return;
	}
	
	NSString *cacheDir  = [SCHThumbnailFactory cacheDirectory];
	NSString *cachePath = [cacheDir stringByAppendingPathComponent:self.thumbPath];
	
	UIImage *thumbImage = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		thumbImage = [SCHThumbnailFactory imageWithPath:self.thumbPath];
	} else {
		thumbImage = [SCHThumbnailFactory thumbnailImageOfSize:self.size 
														 path:self.path 
													thumbRect:self.thumbRect 
														 flip:self.flip 
											   maintainAspect:self.aspect];
		if (thumbImage) {
			NSData *pngData = UIImagePNGRepresentation(thumbImage);
			NSLog(@"Writing to cachepath: %@", cachePath);
			[pngData writeToFile:cachePath atomically:YES];
		}
	}
	
	if (thumbImage) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  self.thumbPath, @"imagePath", 
								  thumbImage, @"image", 
								  nil];
		
		[self performSelectorOnMainThread:@selector(imageReady:) 
							   withObject:userInfo 
							waitUntilDone:YES];
	}
}




@end
