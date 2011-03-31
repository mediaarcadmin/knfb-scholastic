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

@synthesize aspect, size, flip;

- (void)dealloc {
	[super dealloc];
}

// overriding setBookInfo - image operation doesn't set the book as processing
- (void) setIsbn:(NSString *) newIsbn
{
    [self setIsbnWithoutUpdatingProcessingStatus:newIsbn];
}

- (void) beginOperation {
	
	// for testing: insert a random processing delay
	//	int randomValue = (arc4random() % 5) + 3;
	//	[NSThread sleepForTimeInterval:randomValue];

	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	
	NSString *fullImagePath = [book coverImagePath];
	NSString *thumbPath = [book thumbPathForSize:size];
	
	UIImage *thumbImage = nil;
	
    NSFileManager *threadLocalFileManager = [[[NSFileManager alloc] init] autorelease];
    
	if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
		thumbImage = [SCHThumbnailFactory imageWithPath:thumbPath];
	} else {
		thumbImage = [SCHThumbnailFactory thumbnailImageOfSize:self.size 
														  path:fullImagePath
												maintainAspect:self.aspect];
		
		if (thumbImage) {
			NSData *pngData = UIImagePNGRepresentation(thumbImage);
			[pngData writeToFile:thumbPath atomically:YES];
		}
	}
    
	if (thumbImage) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.isbn, @"isbn",
								  [NSValue valueWithCGSize:size], @"thumbSize", 
								  thumbImage, @"image", 
								  nil];
		
		[self performSelectorOnMainThread:@selector(imageReady:) 
							   withObject:userInfo 
							waitUntilDone:YES];
	}
    
    self.executing = NO;
    self.finished = YES;
    
}

- (void)imageReady:(NSDictionary *)userInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHNewImageAvailable" object:nil userInfo:userInfo];
}




@end
