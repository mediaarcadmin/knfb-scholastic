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
#import "SCHXPSCoverImageOperation.h"
#import "SCHDownloadBookFile.h"

@interface SCHProcessingManager()

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect;

@end

@implementation SCHProcessingManager

@synthesize processingQueue, imageCache;

static SCHProcessingManager *sharedManager = nil;

#pragma mark -
#pragma mark Memory Management

- (id) init
{
	if (self = [super init]) {
		self.processingQueue = [[NSOperationQueue alloc] init];
		[self.processingQueue setMaxConcurrentOperationCount:3];
		self.imageCache = [[BlioTimeOrderedCache alloc] init];
		self.imageCache.countLimit = 50; // Arbitrary 30 object limit
        self.imageCache.totalCostLimit = (1024*1024) * 5; // Arbitrary 5MB limit. This may need wteaked or set on a per-device basis
	}
	
	return self;
}

- (void) dealloc
{
	self.processingQueue = nil;
	self.imageCache = nil;
	[super dealloc];
}


- (bool) updateThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo size:(CGSize)size rect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL)placeholder {
	
	NSString *cacheDir  = [SCHProcessingManager cacheDirectory];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", bookInfo.contentMetadata.ContentIdentifier];
	NSString *imagePath = [cacheDir stringByAppendingPathComponent:imageName];
	
	if (CGRectIsNull(thumbRect)) {
		UIImage *image = [SCHThumbnailFactory imageWithPath:imagePath];
		CGSize imageSize = image.size;
		
		thumbRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
	}
	
//	NSString *thumbName = [NSString stringWithFormat:@"%@_%d_%d_%d_%d", imageName, (int)size.width, (int)size.height, (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	NSString *thumbName = [NSString stringWithFormat:@"%@_%d_%d", imageName, (int)size.width, (int)size.height];
	NSString *thumbPath = [cacheDir stringByAppendingPathComponent:thumbName];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
		return [SCHThumbnailFactory updateThumbView:imageView withSize:size path:thumbPath];
	} else {
		return [[SCHProcessingManager defaultManager] updateAsyncThumbView:imageView withBook: bookInfo imageOfInterest:thumbName size:size rect:thumbRect maintainAspect:aspect usePlaceHolder:placeholder];
	}
	
	return nil;
}

#pragma mark -
#pragma mark Update asyncThumbView

- (BOOL) updateAsyncThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo imageOfInterest: (NSString *) imageOfInterest
				   size: (CGSize) size rect:(CGRect) thumbRect maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL) placeholder
{
	[imageView prepareForReuse];

	if (placeholder) {
		UIImage *missingImage = [UIImage imageNamed:@"PlaceholderBook"];
		CGSize missingImageSize = missingImage.size;
		
		// check for scale, for retina display
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			CGFloat scale = [[UIScreen mainScreen] scale];
			missingImageSize = CGSizeMake(missingImageSize.width * scale, missingImageSize.height * scale);
		}
		
		imageView.image = missingImage;
	}
	
	imageView.imageOfInterest = imageOfInterest;
	
	imageView.operations = [self processBookCoverImage:bookInfo size:size rect:thumbRect flip:NO maintainAspect:aspect];
	
	return NO;
}



// This method does the following:
// - if necessary, fetches the book cover image URL
// - if necessary, downloads the book cover image data
// - if necessary, processes the book cover and creates thumbs
// - returns an array of operations enqueued, if any

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect
{
	NSLog(@"processing book: %@", bookInfo.contentMetadata);
	NSString *coverURL = bookInfo.contentMetadata.CoverURL;
	
	if (!coverURL) {
		// get the cover URL 
		// FIXME: actually get the cover URL
		coverURL = @"http://gordonchristie.com/storage/bookcover-test.png";
	}
	
	NSString *cacheDir  = [SCHProcessingManager cacheDirectory];
	NSString *cacheImageItem = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", bookInfo.contentMetadata.ContentIdentifier]];
	
	NSOperation *imageOp = nil;
	
	// check for the full-sized cover image
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheImageItem]) {
		// if it doesn't exist, queue up the appropriate operation

#ifdef LOCALDEBUG
		// grab the file from the XPS
		SCHXPSCoverImageOperation *xpsImageOp = [[SCHXPSCoverImageOperation alloc] init];
		xpsImageOp.bookInfo = bookInfo;
		xpsImageOp.localPath = cacheImageItem;
		imageOp = xpsImageOp;
#else
		// download image from the server
		SCHDownloadImageOperation *downloadImageOp = [[SCHDownloadImageOperation alloc] init];
		downloadImageOp.imagePath = [NSURL URLWithString:coverURL];
		downloadImageOp.localPath = cacheImageItem;
		imageOp = downloadImageOp;
#endif
		
	} else {
		NSLog(@"Full sized image already exists.");
	}
	
	SCHThumbnailOperation *thumbOp = nil;
	
//	NSString *thumbPath = [NSString stringWithFormat:@"%@_%d_%d_%d_%d", [cacheImageItem lastPathComponent], (int)size.width, (int)size.height, (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	NSString *thumbPath = [NSString stringWithFormat:@"%@_%d_%d", [cacheImageItem lastPathComponent], (int)size.width, (int)size.height];
	NSString *thumbFullPath = [NSString stringWithFormat:@"%@/%@", cacheDir, thumbPath];
	
	// check for the thumb image
	if (![[NSFileManager defaultManager] fileExistsAtPath:thumbFullPath]) {
		// if it doesn't exist, queue up an image processing operation
			
		thumbOp = [SCHThumbnailFactory thumbOperationAtPath:thumbPath
												   fromPath:cacheImageItem
													   rect:thumbRect
													   size:size
													   flip:YES
											 maintainAspect:YES];
		if (imageOp) {
			[thumbOp addDependency:imageOp];
		}
	} else {
		NSLog(@"Thumb already exists.");
	}
	
	NSMutableArray *operations = [[[NSMutableArray alloc] init] autorelease];
	
	if (thumbOp) {
		[operations addObject:thumbOp];
		[[SCHProcessingManager defaultManager].processingQueue addOperation:thumbOp];
	}
	
	if (imageOp) {
		[operations addObject:imageOp];
		[[SCHProcessingManager defaultManager].processingQueue addOperation:imageOp];
	}
	
	return [NSArray arrayWithArray:operations];
}

- (void) downloadBookFile: (SCHBookInfo *) bookInfo
{
	SCHDownloadBookFile *bookDownloadOp = nil;
	
#ifndef LOCALDEBUG
	
	NSLog(@"Checking book status.");
	
	BookFileProcessingState state = [bookInfo processingState];
	
	if (state == bookFileProcessingStateCurrentlyDownloading) {
		NSLog(@"Book is already downloading...");
		return;
	} else if (state == bookFileProcessingStateNoFileDownloaded || state == bookFileProcessingStatePartiallyDownloaded) {
		NSLog(@"XPS file %@ needs downloading (%@)...", [bookInfo xpsPath], (state == bookFileProcessingStateNoFileDownloaded)?@"No file":@"Partial File");
		
		// if it needs downloaded, queue up a book download operation
		bookDownloadOp = [[SCHDownloadBookFile alloc] init];
		bookDownloadOp.bookInfo = bookInfo;
		bookDownloadOp.resume = YES;
	} else if (state == bookFileProcessingStateFullyDownloaded) {
		NSLog(@"XPS file %@ has been downloaded already.");
	} else if (state == bookFileProcessingStateError) {
		NSLog(@"Error while attempting to process XPS file.");
	} else {
		NSLog(@"Unknown book processing state (%d).", state);
	}
	
	
#endif
	
	NSMutableArray *operations = [[[NSMutableArray alloc] init] autorelease];
	
	if (bookDownloadOp) {
		[operations addObject:bookDownloadOp];
		[[SCHProcessingManager defaultManager].processingQueue addOperation:bookDownloadOp];
	}
	
}

+ (NSString *)cacheDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Singleton methods

// Singleton methods are copied directly from http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html%23//apple_ref/doc/uid/TP40002974-CH4-SW32
// These denote a singleton that cannot be separately allocated alongside the sharedFactory

+(SCHProcessingManager*) defaultManager
{
    if (sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [[self defaultManager] retain];
}

-(id) copyWithZone:(NSZone *)zone 
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount 
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


@end
