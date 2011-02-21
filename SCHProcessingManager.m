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

@interface SCHProcessingManager()

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect;

@end

@implementation SCHProcessingManager

@synthesize processingQueue;

static SCHProcessingManager *sharedManager = nil;


- (id) init
{
	if (self = [super init]) {
		self.processingQueue = [[NSOperationQueue alloc] init];
	}
	
	return self;
}

// This method does the following:
// - if necessary, fetches the book cover image URL
// - if necessary, downloads the book cover image data
// - if necessary, processes the book cover and creates thumbs
// - returns an array of operations enqueued, if any

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect
{
	NSString *coverURL = bookInfo.contentMetadata.CoverURL;
	
	if (!coverURL) {
		// get the cover URL 
		// FIXME: actually get the cover URL
		coverURL = @"http://bitwink.com/images/macbook.png";
	}
	
	NSString *cacheDir  = [SCHThumbnailFactory cacheDirectory];
	NSString *cacheImageItem = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"image-%@.png", bookInfo.contentMetadata.ContentIdentifier]];
	
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
	
	NSString *thumbPath = [NSString stringWithFormat:@"%@_%d_%d_%d_%d", [cacheImageItem lastPathComponent], (int)floor(CGRectGetMinX(thumbRect)), (int)floor(CGRectGetMinY(thumbRect)), (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	NSLog(@"Thumbpath: SCHProcessingManager, 88: %@", thumbPath);
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

- (UIImageView *) thumbImageForBook: (SCHBookInfo *) bookInfo frame: (CGRect) frame rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect usePlaceholder: (BOOL) placeholder
{
	
//	NSLog(@"Frame: %@", NSStringFromCGRect(frame));
//	NSLog(@"Thumb rect: %@", NSStringFromCGRect(thumbRect));
	NSString *cacheDir  = [SCHThumbnailFactory cacheDirectory];
	NSString *thumbPath = [NSString stringWithFormat:@"image-%@.png_%d_%d_%d_%d", bookInfo.contentMetadata.ContentIdentifier, (int)floor(CGRectGetMinX(thumbRect)), (int)floor(CGRectGetMinY(thumbRect)), (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	NSLog(@"Thumbpath: SCHProcessingManager, 132: %@", thumbPath);
	NSString *cachePath = [cacheDir stringByAppendingPathComponent:thumbPath];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		UIImage *thumbImage = [SCHThumbnailFactory imageWithPath:cachePath];
		if (thumbImage) {
			UIImageView *aImageView = [[UIImageView alloc] initWithImage:thumbImage];
			aImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
			return [aImageView autorelease];
		}
	} else {
		UIImage *missingImage = [UIImage imageNamed:@"PlaceholderBook"];
		CGSize missingImageSize = missingImage.size;
		
		// check for scale, for retina display
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			CGFloat scale = [[UIScreen mainScreen] scale];
			missingImageSize = CGSizeMake(missingImageSize.width * scale, missingImageSize.height * scale);
		}
		
		UIImage *placeholderImage = nil;
		if (placeholder) {
			placeholderImage = [SCHThumbnailFactory thumbnailImageOfSize:frame.size 
																   image:missingImage 
															   thumbRect:CGRectMake(0, 0, missingImageSize.width, missingImageSize.height) 
																	flip:NO 
														  maintainAspect:aspect];
		}
		
		SCHAsyncImageView *aAsyncImageView = [[SCHAsyncImageView alloc] initWithImage:placeholderImage];
		aAsyncImageView.frame = frame;
		NSLog(@"Thumb path: %@", thumbPath);
		aAsyncImageView.imageOfInterest = thumbPath;
		aAsyncImageView.contentMode = UIViewContentModeScaleToFill;

		aAsyncImageView.operations = [self processBookCoverImage:bookInfo size:frame.size rect:thumbRect flip:flip maintainAspect:aspect];
		
		return [aAsyncImageView autorelease];
	}
	
	return nil;
}

#pragma mark -
#pragma mark Update asyncThumbView

- (BOOL) asyncThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo size: (CGSize) size srcPath:(NSString *) path dstPath:(NSString *)thumbPath rect:(CGRect) thumbRect maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL) placeholder
{
	UIImage *missingImage = [UIImage imageNamed:@"PlaceholderBook"];
	CGSize missingImageSize = missingImage.size;
	
	// check for scale, for retina display
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		CGFloat scale = [[UIScreen mainScreen] scale];
		missingImageSize = CGSizeMake(missingImageSize.width * scale, missingImageSize.height * scale);
	}
	
	// FIXME: use placeholder image correctly!
	UIImage *placeholderImage = nil;
	if (placeholder) {
		placeholderImage = [SCHThumbnailFactory thumbnailImageOfSize:size
															   image:missingImage 
														   thumbRect:thumbRect 
																flip:NO 
													  maintainAspect:aspect];
	}
	
	[imageView prepareForReuse];
	imageView.frame = thumbRect;
	NSLog(@"Setting imageOfInterest to %@", thumbPath);
	imageView.imageOfInterest = thumbPath;
	imageView.contentMode = UIViewContentModeScaleToFill;

	imageView.operations = [self processBookCoverImage:bookInfo size:size rect:thumbRect flip:NO maintainAspect:aspect];
	
	return NO;
}


- (bool) updateThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo size:(CGSize)size rect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL)placeholder {

	
	NSString *cacheDir  = [SCHThumbnailFactory cacheDirectory];
	NSString *imageName = [NSString stringWithFormat:@"image-%@.png", bookInfo.contentMetadata.ContentIdentifier];
	NSString *imagePath = [cacheDir stringByAppendingPathComponent:imageName];
	
	if (CGRectIsNull(thumbRect)) {
		NSData *imageData = [[NSData alloc] initWithContentsOfMappedFile:imagePath];
		UIImage *image = nil;
		
		if (imageData) {
			image = [[UIImage alloc] initWithData:imageData];
		}
		
		CGSize imageSize = image.size;
		[imageData release];
		[image release];
		
		thumbRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
	}
	
	NSString *thumbName = [NSString stringWithFormat:@"image-%@.png_%d_%d_%d_%d", bookInfo.contentMetadata.ContentIdentifier, (int)floor(CGRectGetMinX(thumbRect)), (int)floor(CGRectGetMinY(thumbRect)), (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	NSLog(@"Thumbname: SCHProcessingManager, 233: %@", thumbName);
	NSString *thumbPath = [cacheDir stringByAppendingPathComponent:thumbName];

	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
		return [SCHThumbnailFactory updateThumbView:imageView withSize:size path:thumbPath];
	} else {
		return [[SCHProcessingManager defaultManager] asyncThumbView:imageView withBook: bookInfo size:size srcPath:imagePath dstPath:thumbName rect:thumbRect maintainAspect:aspect usePlaceHolder:placeholder];
	}
	
	return nil;
}


- (void) dealloc
{
	self.processingQueue = nil;
	[super dealloc];
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
