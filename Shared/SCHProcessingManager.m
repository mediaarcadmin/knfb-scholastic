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
#import "SCHXPSCoverImageOperation.h"
#import "SCHDownloadFileOperation.h"

@interface SCHProcessingManager()

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation SCHProcessingManager

@synthesize processingQueue, downloadQueue, bookURLQueue, imageCache, 
currentDownloadingBookFileItems, currentWaitingBookFileItems, currentWaitingForURLItems, currentWaitingCoverImages, currentDownloadingCoverImages, 
backgroundTask;

static SCHProcessingManager *sharedManager = nil;

#pragma mark -
#pragma mark Memory Management

- (id) init
{
	if (self = [super init]) {
		self.processingQueue = [[NSOperationQueue alloc] init];
		[self.processingQueue setMaxConcurrentOperationCount:3];
		self.downloadQueue = [[NSOperationQueue alloc] init];
		[self.downloadQueue setMaxConcurrentOperationCount:3];
		self.bookURLQueue = [[NSOperationQueue alloc] init];
		[self.bookURLQueue setMaxConcurrentOperationCount:10];
		self.imageCache = [[BlioTimeOrderedCache alloc] init];
		self.imageCache.countLimit = 50; // Arbitrary 30 object limit
        self.imageCache.totalCostLimit = (1024*1024) * 5; // Arbitrary 5MB limit. This may need wteaked or set on a per-device basis
		self.currentDownloadingBookFileItems = [[NSMutableDictionary alloc] init];
		self.currentWaitingBookFileItems = [[NSMutableDictionary alloc] init];
		self.currentWaitingForURLItems = [[NSMutableDictionary alloc] init];
		self.currentDownloadingCoverImages = [[NSMutableDictionary alloc] init];
		self.currentWaitingCoverImages = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	self.processingQueue = nil;
	self.downloadQueue = nil;
	self.bookURLQueue = nil;
	self.imageCache = nil;
	self.currentDownloadingBookFileItems = nil;
	self.currentWaitingBookFileItems = nil;
	self.currentWaitingForURLItems = nil;
	self.currentDownloadingCoverImages = nil;
	self.currentWaitingCoverImages = nil;
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
	
	NSString *thumbName = [NSString stringWithFormat:@"%@_%d_%d", imageName, (int)size.width, (int)size.height];
	NSString *thumbPath = [cacheDir stringByAppendingPathComponent:thumbName];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
		return [SCHThumbnailFactory updateThumbView:imageView withSize:size path:thumbPath];
//	} else if ([[SCHProcessingManager defaultManager] hasExistingAsyncImageViewForThumbName:thumbName]) {
//		return NO;
	} else {
		return [[SCHProcessingManager defaultManager] updateAsyncThumbView:imageView withBook: bookInfo imageOfInterest:thumbName size:size rect:thumbRect maintainAspect:aspect usePlaceHolder:placeholder];
	}
	
	return nil;
}

#pragma mark -
#pragma mark asyncThumbView

- (BOOL) updateAsyncThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo imageOfInterest: (NSString *) imageOfInterest
				   size: (CGSize) size rect:(CGRect) thumbRect maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL) placeholder
{
	//[imageView prepareForReuse];

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
	
/*	if (imageView.operations && [imageView.operations count] > 0) {
		NSString *imageName = [NSString stringWithFormat:@"%@.png", bookInfo.contentMetadata.ContentIdentifier];
		NSString *thumbName = [NSString stringWithFormat:@"%@_%d_%d", imageName, (int)size.width, (int)size.height];
		[self.currentProcessingAsyncImageViews setObject:imageView forKey:thumbName];
	}
*/	
	return NO;
}

// This method does the following:
// - if necessary, fetches the book cover image URL
// - if necessary, downloads the book cover image data
// - if necessary, processes the book cover and creates thumbs
// - returns an array of operations enqueued, if any

- (NSArray *) processBookCoverImage: (SCHBookInfo *) bookInfo size: (CGSize) size rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect
{
	NSAssert(bookInfo != nil, @"processBookCoverImage must have a valid bookInfo object.");

	NSString *cacheDir  = [SCHProcessingManager cacheDirectory];
	NSString *cacheImageItem = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", bookInfo.bookIdentifier]];
	
	NSOperation *imageOp = nil;
	
	// check for the full-sized cover image
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheImageItem]) {

		// check for an operation already downloading the image from currentWaitingCoverImages
		NSOperation *existingOp = nil; 
		
		for (SCHDownloadFileOperation *op in [self.downloadQueue operations]) {
			
			if ([op.bookInfo.bookIdentifier compare:bookInfo.bookIdentifier] == NSOrderedSame 
				&& op.fileType == kSCHDownloadFileTypeCoverImage) {
				NSLog(@"***** ===== Image Download, existing op! Book ID: %@", op.bookInfo.bookIdentifier);
				
				existingOp = op;
				break;
			}
		}
		
		if (existingOp) {
			imageOp = existingOp;
		} else {
			NSLog(@"***** ===== Image Download, new op! Book ID: %@", bookInfo.bookIdentifier);
			// if it doesn't exist, queue up the appropriate operation
			
#ifdef LOCALDEBUG
			// grab the file from the XPS
			SCHXPSCoverImageOperation *xpsImageOp = [[SCHXPSCoverImageOperation alloc] init];
			xpsImageOp.bookInfo = bookInfo;
			xpsImageOp.localPath = cacheImageItem;
			imageOp = xpsImageOp;
#else
			// download image from the server
			SCHDownloadFileOperation *downloadImageOp = [[SCHDownloadFileOperation alloc] init];
			downloadImageOp.fileType = kSCHDownloadFileTypeCoverImage;
			downloadImageOp.bookInfo = bookInfo;
			downloadImageOp.resume = NO;
			[downloadImageOp setQueuePriority:NSOperationQueuePriorityHigh];
			imageOp = downloadImageOp;
			
#endif
		}
	} else {
		NSLog(@"Full sized image already exists.");
	}
	
	NSOperation *urlOp = nil;
	
	if (imageOp && !bookInfo.coverURL || !bookInfo.bookFileURL) {
		NSOperation *existingOp = [self.currentWaitingForURLItems objectForKey:bookInfo.bookIdentifier];
		
		if (existingOp) {
			urlOp = existingOp;
		} else {
			SCHBookURLRequestOperation *bookURLOp = [[SCHBookURLRequestOperation alloc] init];
			bookURLOp.bookInfo = bookInfo;
			urlOp = bookURLOp;
		}
		
		[imageOp addDependency:urlOp];
	}
	
	SCHThumbnailOperation *thumbOp = nil;
	
//	NSString *thumbPath = [NSString stringWithFormat:@"%@_%d_%d_%d_%d", [cacheImageItem lastPathComponent], (int)size.width, (int)size.height, (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	NSString *thumbPath = [NSString stringWithFormat:@"%@_%d_%d", [cacheImageItem lastPathComponent], (int)size.width, (int)size.height];
	NSString *thumbFullPath = [NSString stringWithFormat:@"%@/%@", cacheDir, thumbPath];
	
	// check for the thumb image
	if (![[NSFileManager defaultManager] fileExistsAtPath:thumbFullPath]) {
		
		BOOL addNewOperation = YES;
		
		for (SCHThumbnailOperation *existingOp in [self.processingQueue operations]) {
			if ([thumbPath compare:existingOp.thumbPath] == NSOrderedSame) {
				addNewOperation = NO;
				break;
			}
		}
		
		// if it doesn't exist, queue up an image processing operation
		if (addNewOperation) {
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
		}
	} else {
		NSLog(@"Thumb already exists.");
	}
	
	NSMutableArray *operations = [[[NSMutableArray alloc] init] autorelease];

	if (thumbOp) {
		if (![[[SCHProcessingManager defaultManager].processingQueue operations] containsObject:thumbOp]) {
			[operations addObject:thumbOp];
			[[SCHProcessingManager defaultManager].processingQueue addOperation:thumbOp];
		}
	}
	
	if (imageOp) {
		if (![[[SCHProcessingManager defaultManager].downloadQueue operations] containsObject:imageOp]) {
			[operations addObject:imageOp];
			[[SCHProcessingManager defaultManager].downloadQueue addOperation:imageOp];
			[imageOp release];
		}
		
	}
	
	if (urlOp) {
		if (![[[SCHProcessingManager defaultManager].bookURLQueue operations] containsObject:urlOp]) {
			[operations addObject:urlOp];
			[[SCHProcessingManager defaultManager].bookURLQueue addOperation:urlOp];
			[urlOp release];
		}
	}
	


	NSLog(@"Op counts: URLs:%d Download:%d Processing:%d", 
		  [[self.bookURLQueue operations] count], [[self.downloadQueue operations] count], [[self.processingQueue operations] count]);
	
	return [NSArray arrayWithArray:operations];
}

- (void) downloadBookFile: (SCHBookInfo *) bookInfo
{
	SCHDownloadFileOperation *bookDownloadOp = nil;
	NSOperation *urlOp = nil;
	
#ifndef LOCALDEBUG
	
//	NSLog(@"DOWNLOADBOOKFILE: Checking book status.");
	
	BookFileProcessingState state = [bookInfo processingState];
	
	if ([bookInfo isCurrentlyDownloadingBookFile] || [bookInfo isWaitingForBookFileDownload]) {
		NSLog(@"Book already queued for download.");
		return;
	}
	
	if (state == bookFileProcessingStateNoFileDownloaded || state == bookFileProcessingStatePartiallyDownloaded) {
		NSLog(@"XPS file %@ needs downloading (%@)...", [bookInfo xpsPath], (state == bookFileProcessingStateNoFileDownloaded)?@"No file":@"Partial File");
		
		if (!bookInfo || !bookInfo.coverURL || !bookInfo.bookFileURL) {
			SCHBookURLRequestOperation *bookURLOp = [[SCHBookURLRequestOperation alloc] init];
			bookURLOp.bookInfo = bookInfo;
			urlOp = bookURLOp;
		} else {
			//		NSLog(@"Already have URLs.");
		}
		
		// if it needs downloaded, queue up a book download operation
		bookDownloadOp = [[SCHDownloadFileOperation alloc] init];
		bookDownloadOp.fileType = kSCHDownloadFileTypeXPSBook;
		bookDownloadOp.bookInfo = bookInfo;
		bookDownloadOp.resume = YES;
		if (urlOp) {
			[bookDownloadOp addDependency:urlOp];
		}
		
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
		[[SCHProcessingManager defaultManager].downloadQueue addOperation:bookDownloadOp];
		[bookDownloadOp release];
	}
	
	if (urlOp) {
		[operations addObject:urlOp];
		[[SCHProcessingManager defaultManager].bookURLQueue addOperation:urlOp];
		[urlOp release];
	}
	
/*	NSLog(@"Book downloading. Operation count: %d", [self.downloadQueue operationCount]);
	
	for (id obj in [self.downloadQueue operations]) {
		NSOperation *op = (NSOperation *) obj;
		NSLog(@"Op: %@, Cancelled %@, Executing %@, Finished %@", op, [op isCancelled]?@"Yes":@"No", [op isExecuting]?@"Yes":@"No",  [op isFinished]?@"Yes":@"No");
		if ([obj class] == [SCHDownloadFileOperation class]) {
			SCHDownloadFileOperation *dfop = (SCHDownloadFileOperation *) op;
			NSLog(@"DFOP for %@, type %d", dfop.bookInfo, dfop.fileType);
			
		}
		
	}
*/
	
	NSLog(@"Op counts: URLs:%d Download:%d Processing:%d", 
		  [[self.bookURLQueue operations] count], [[self.downloadQueue operations] count], [[self.processingQueue operations] count]);

	
}

+ (NSString *)cacheDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Queue Management methods

- (void) setBookFileWaiting: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentWaitingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier]) {
		return;
	}
	
	@synchronized(self) {
		if ([[self.currentDownloadingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier]) {
			[self.currentDownloadingBookFileItems removeObjectForKey:bookInfo.bookIdentifier];
		}

		[self.currentWaitingBookFileItems setObject:operation forKey:bookInfo.bookIdentifier];
		
	}

	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
}

- (void) setBookFileDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentDownloadingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier]) {
		return;
	}
	
	@synchronized(self) {
		if ([[self.currentWaitingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier]) {
			[self.currentWaitingBookFileItems removeObjectForKey:bookInfo.bookIdentifier];
		}

		[self.currentDownloadingBookFileItems setObject:operation forKey:bookInfo.bookIdentifier];
		
	}
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
}

- (BOOL) setBookWaitingForURLs: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentWaitingForURLItems allKeys] containsObject:bookInfo.bookIdentifier]) {
		return NO;
	}
	
	@synchronized(self) {
		[self.currentWaitingForURLItems setObject:operation forKey:bookInfo.bookIdentifier];
	}
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
	return YES;
}

- (void) setCoverImageWaiting: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentWaitingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
		return;
	}
	
	@synchronized(self) {
		if ([[self.currentDownloadingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
			[self.currentDownloadingCoverImages removeObjectForKey:bookInfo.bookIdentifier];
		}
		
		[self.currentWaitingCoverImages setObject:operation forKey:bookInfo.bookIdentifier];
		
	}
/*	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];*/
}

- (void) setCoverImageDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation
{
	if ([[self.currentDownloadingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
		return;
	}
	
	@synchronized(self) {
		if ([[self.currentWaitingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
			[self.currentWaitingCoverImages removeObjectForKey:bookInfo.bookIdentifier];
		}
		
		[self.currentDownloadingCoverImages setObject:operation forKey:bookInfo.bookIdentifier];
		
	}
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
}



- (void) removeBookFromDownload: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		if ([[self.currentDownloadingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier]) {
			
//			SCHDownloadFileOperation *op = [self.currentDownloadingBookFileItems objectForKey:bookInfo.bookIdentifier];
//			if (![op isFinished]) {
//				[op cancel];
//			}
			
			[self.currentDownloadingBookFileItems removeObjectForKey:bookInfo.bookIdentifier];
		}
		
		if ([[self.currentWaitingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier]) {
//			SCHDownloadFileOperation *op = [self.currentWaitingBookFileItems objectForKey:bookInfo.bookIdentifier];
//			if (![op isFinished]) {
//				[op cancel];
//			}
			
			[self.currentWaitingBookFileItems removeObjectForKey:bookInfo.bookIdentifier];
		}
	}
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
	
}

- (void) removeCoverImageFromDownload: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		if ([[self.currentDownloadingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
			
//			SCHDownloadFileOperation *op = [self.currentDownloadingCoverImages objectForKey:bookInfo.bookIdentifier];
//			if (![op isFinished]) {
//				[op cancel];
//			}
			
			[self.currentDownloadingCoverImages removeObjectForKey:bookInfo.bookIdentifier];
		}
		
		if ([[self.currentWaitingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
//			SCHDownloadFileOperation *op = [self.currentWaitingCoverImages objectForKey:bookInfo.bookIdentifier];
//			if (![op isFinished]) {
//				[op cancel];
//			}
			
			[self.currentWaitingCoverImages removeObjectForKey:bookInfo.bookIdentifier];
		}
	}
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
	
}



/*
- (void) removeCoverImageFromDownload: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		if ([[self.currentDownloadingCoverImages allKeys] containsObject:bookInfo.bookIdentifier]) {
			
			NSLog(@"***** removing book for URLs: %@", bookInfo.bookIdentifier);
//			SCHDownloadFileOperation *op = [self.currentDownloadingCoverImages objectForKey:bookInfo.bookIdentifier];
//			if (![op isFinished]) {
//				[op cancel];
//			}
			
			[self.currentDownloadingCoverImages removeObjectForKey:bookInfo.bookIdentifier];
		}
	}	
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
	
}
*/

- (void) removeBookWaitingForURLs: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		if ([[self.currentWaitingForURLItems allKeys] containsObject:bookInfo.bookIdentifier]) {
			
			NSLog(@"***** removing book for URLs: %@", bookInfo.bookIdentifier);
//			SCHBookURLRequestOperation *op = [self.currentWaitingForURLItems objectForKey:bookInfo.bookIdentifier];
//			if (![op isFinished]) {
//				[op cancel];
//			}
			
			[self.currentWaitingForURLItems removeObjectForKey:bookInfo.bookIdentifier];
		}
		
	}	

	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:bookInfo
						waitUntilDone:YES];
	
	
}


- (BOOL) isCurrentlyWaitingForBookFile: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentWaitingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier];
	}
}

- (BOOL) isCurrentlyDownloading: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentDownloadingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier];
	}
}

- (BOOL) isCurrentlyWaitingForCoverImage: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentWaitingBookFileItems allKeys] containsObject:bookInfo.bookIdentifier];
	}
}


- (BOOL) isCurrentlyDownloadingCoverImage: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentDownloadingCoverImages allKeys] containsObject:bookInfo.bookIdentifier];
	}
}

- (BOOL) isCurrentlyWaitingForURLs: (SCHBookInfo *) bookInfo
{
	@synchronized(self) {
		return [[self.currentWaitingForURLItems allKeys] containsObject:bookInfo.bookIdentifier];
	}
}

- (void) bookUpdate: (SCHBookInfo *) sentBookInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadStatusUpdate" object:sentBookInfo userInfo:nil];
}

- (void) enterBackground
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
		if ((self.processingQueue && [self.processingQueue operationCount]) 
			|| (self.processingQueue && [self.processingQueue operationCount])
			|| (self.bookURLQueue && [self.bookURLQueue operationCount])
			) {
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
                    [self.downloadQueue waitUntilAllOperationsAreFinished];    
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
