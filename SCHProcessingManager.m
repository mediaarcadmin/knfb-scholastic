//
//  SCHProcessingManager.m
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProcessingManager.h"
#import "SCHThumbnailFactory.h"
#import "SCHDownloadImageOperation.h"

@implementation SCHProcessingManager

@synthesize processingQueue;


- (id) init
{
	if (self = [super init]) {
		self.processingQueue = [[NSOperationQueue alloc] init];
	}
	
	return self;
}

- (void) enqueueBookInfoItems: (NSArray *) bookInfoItems
{
	NSLog(@"Enqueueing items: %@", bookInfoItems);
	for (SCHBookInfo *infoItem in bookInfoItems) {
		[self enqueueBookInfoItem:infoItem];
	}
}

// This method does the following:
// - if necessary, fetches the book cover image URL
// - if necessary, downloads the book cover image data
// - if necessary, processes the book cover and creates thumbs
- (void) enqueueBookInfoItem: (SCHBookInfo *) bookInfo
{
	NSString *coverURL = bookInfo.contentMetadata.CoverURL;
	
	if (!coverURL) {
		// get the cover URL 
		// FIXME: actually get the cover URL
		// FIXME: add local file mode!
		coverURL = @"http://bitwink.com/images/macbook.png";
	}
	
	NSLog(@"Cover item is: %@", coverURL);
		
	NSString *cacheDir  = [SCHThumbnailFactory cacheDirectory];
	NSString *cacheImageItem = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"image-%@.png", bookInfo.contentMetadata.ContentIdentifier]];
	
	NSLog(@"Cache image item is: %@", cacheImageItem);

	SCHDownloadImageOperation *imageOp = nil;
	
	// check for the main image
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheImageItem]) {
		// if it doesn't exist, queue up a download operation
		NSLog(@"File does not exist. Enqueueing download operation...");
		imageOp = [[SCHDownloadImageOperation alloc] init];
		imageOp.imagePath = [NSURL URLWithString:coverURL];
		imageOp.localPath = cacheImageItem;
		
	} else {
		NSLog(@"File already exists.");
	}
	
	SCHThumbnailOperation *thumbOp = nil;
	
	NSString *cacheThumbItem = [NSString stringWithFormat:@"thumb-%@.png", bookInfo.contentMetadata.ContentIdentifier];
	
	// check for the thumb image
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheThumbItem]) {
		// if it doesn't exist, queue up an image processing operation
			
		NSLog(@"CacheThumbItem: %@", cacheThumbItem);
		NSLog(@"CacheImageItem: %@\n", cacheImageItem);
		
		thumbOp = [SCHThumbnailFactory thumbOperationAtPath:cacheThumbItem
												   fromPath:cacheImageItem
													   rect:CGRectMake(0, 0, 100, 100)
													   size:CGSizeMake(100, 100)
													   flip:YES
											 maintainAspect:YES];
		if (imageOp) {
			[thumbOp addDependency:imageOp];
		}
	}
	
	
	if (thumbOp) {
		[self.processingQueue addOperation:thumbOp];
	}
	
	if (imageOp) {
		[self.processingQueue addOperation:imageOp];
	}
	
}

- (void) dealloc
{
	self.processingQueue = nil;
	[super dealloc];
}


@end
