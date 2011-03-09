//
//  SCHProcessingManager.m
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProcessingManager.h"
#import "SCHThumbnailFactory.h"
#import "SCHBookURLRequestOperation.h"
#import "SCHDownloadImageOperation.h"
#import "SCHXPSCoverImageOperation.h"
#import "SCHDownloadBookFile.h"

@interface SCHProcessingManager()

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation SCHProcessingManager

@synthesize processingQueue, bookURLQueue, imageCache, currentDownloadingItems, currentWaitingItems, backgroundTask;

static SCHProcessingManager *sharedManager = nil;

#pragma mark -
#pragma mark Memory Management

- (id) init
{
	if (self = [super init]) {
		self.processingQueue = [[NSOperationQueue alloc] init];
		[self.processingQueue setMaxConcurrentOperationCount:3];
		self.bookURLQueue = [[NSOperationQueue alloc] init];
		[self.bookURLQueue setMaxConcurrentOperationCount:10];
		self.imageCache = [[BlioTimeOrderedCache alloc] init];
		self.imageCache.countLimit = 50; // Arbitrary 30 object limit
        self.imageCache.totalCostLimit = (1024*1024) * 5; // Arbitrary 5MB limit. This may need wteaked or set on a per-device basis
		self.currentDownloadingItems = [[NSMutableDictionary alloc] init];
		self.currentWaitingItems = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	self.processingQueue = nil;
	self.bookURLQueue = nil;
	self.imageCache = nil;
	self.currentDownloadingItems = nil;
	self.currentWaitingItems = nil;
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
//		CGSize missingImageSize = missingImage.size;
		
		// check for scale, for retina display
//		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//			CGFloat scale = [[UIScreen mainScreen] scale];
//			missingImageSize = CGSizeMake(missingImageSize.width * scale, missingImageSize.height * scale);
//		}
		
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
/*	NSString *coverURL = bookInfo.contentMetadata.CoverURL;
	
	if (!coverURL) {
		// get the cover URL 
		// FIXME: actually get the cover URL
		coverURL = @"http://gordonchristie.com/storage/bookcover-test.png";
	}
*/
	
	NSOperation *urlOp = nil;
	
	if (!bookInfo.coverURL | !bookInfo.bookFileURL) {
		SCHBookURLRequestOperation *bookURLOp = [[SCHBookURLRequestOperation alloc] init];
		bookURLOp.bookInfo = bookInfo;
		urlOp = bookURLOp;
	} else {
		NSLog(@"Already have URLs.");
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
		downloadImageOp.bookInfo = bookInfo;
		downloadImageOp.localPath = cacheImageItem;
		[downloadImageOp setQueuePriority:NSOperationQueuePriorityHigh];
		imageOp = downloadImageOp;
		
		if (urlOp) {
			[imageOp addDependency:urlOp];
		}
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
		[thumbOp setQueuePriority:NSOperationQueuePriorityHigh];

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
		[imageOp release];
	}
	
	if (urlOp) {
		[operations addObject:urlOp];
		[[SCHProcessingManager defaultManager].bookURLQueue addOperation:urlOp];
		[urlOp release];
	}
	
	return [NSArray arrayWithArray:operations];
}

- (void) downloadBookFile: (SCHBookInfo *) bookInfo
{
	SCHDownloadBookFile *bookDownloadOp = nil;
	
#ifndef LOCALDEBUG
	
	NSLog(@"DOWNLOADBOOKFILE: Checking book status.");
	
	BookFileProcessingState state = [bookInfo processingState];
	
	if ([bookInfo isCurrentlyDownloading] || [bookInfo isWaitingForDownload]) {
		NSLog(@"Book already queued for download.");
		return;
	}
	
	if (state == bookFileProcessingStateNoFileDownloaded || state == bookFileProcessingStatePartiallyDownloaded) {
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
		[bookDownloadOp release];
	}
	
}

+ (NSString *)cacheDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Queue Management methods

- (void) setBookWaiting: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentWaitingItems allKeys] containsObject:bookInfo]) {
		return;
	}
	
	@synchronized(self) {
		if ([[self.currentDownloadingItems allKeys] containsObject:bookInfo]) {
			[self.currentDownloadingItems removeObjectForKey:bookInfo];
		}

		[self.currentWaitingItems setObject:operation forKey:bookInfo];
	}
}

- (void) setBookDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentDownloadingItems allKeys] containsObject:bookInfo]) {
		return;
	}
	
	@synchronized(self) {
		if ([[self.currentWaitingItems allKeys] containsObject:bookInfo]) {
			[self.currentWaitingItems removeObjectForKey:bookInfo];
		}

		[self.currentDownloadingItems setObject:operation forKey:bookInfo];
	}
}

- (void) removeBookFromDownload: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		if ([[self.currentDownloadingItems allKeys] containsObject:bookInfo]) {
			
			SCHDownloadBookFile *op = [self.currentDownloadingItems objectForKey:bookInfo];
			[op cancel];
			
			[self.currentDownloadingItems removeObjectForKey:bookInfo];
		}
		
		if ([[self.currentWaitingItems allKeys] containsObject:bookInfo]) {
			NSOperation *op = [self.currentWaitingItems objectForKey:bookInfo];
			[op cancel];
			
			[self.currentWaitingItems removeObjectForKey:bookInfo];
		}
	}
}

- (BOOL) isCurrentlyWaiting: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentWaitingItems allKeys] containsObject:bookInfo];
	}
}

- (BOOL) isCurrentlyDownloading: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentDownloadingItems allKeys] containsObject:bookInfo];
	}
}

- (void) enterBackground
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
		if ((self.processingQueue && [self.processingQueue operationCount]) || (self.bookURLQueue && [self.bookURLQueue operationCount])) {
			NSLog(@"Background processing needs more time - going into the background.");
			
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.backgroundTask != UIBackgroundTaskInvalid) {
						NSLog(@"Ran out of time. Pausing queue.");
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
			
            dispatch_queue_t taskcompletion = dispatch_get_global_queue(
															   DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

			dispatch_async(taskcompletion, ^{
				NSLog(@"Emptying operation queues...");
                if(self.backgroundTask != UIBackgroundTaskInvalid) {
					[self.bookURLQueue waitUntilAllOperationsAreFinished];
                    [self.processingQueue waitUntilAllOperationsAreFinished];    
					NSLog(@"operation queues are finished!");
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }
            });
        }
	}
}

- (void) enterForeground
{
	NSLog(@"Entering foreground - quitting background task.");
	if(self.backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
		self.backgroundTask = UIBackgroundTaskInvalid;
	}		
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
