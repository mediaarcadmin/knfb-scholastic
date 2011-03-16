//
//  SCHProcessingManager.m
//  Scholastic
//
//  Created by Gordon Christie on 14/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <pthread.h>
#import "SCHBookshelfSyncComponent.h"
#import "SCHProcessingManager.h"
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHBookInfo.h"
#import "SCHBookURLRequestOperation.h"
#import "SCHDownloadFileOperation.h"
#import "SCHThumbnailOperation.h"
#import "SCHBookManager.h"
#import "SCHAsyncBookCoverImageView.h"
#import "SCHThumbnailFactory.h"

#pragma mark Class Extension

@interface SCHProcessingManager()

- (void) checkStateForAllBooks;
- (BOOL) bookNeedsProcessing: (SCHBookInfo *) bookInfo;

- (void) processBook: (SCHBookInfo *) bookInfo;
- (void) redispatchBook: (SCHBookInfo *) bookInfo;
- (void) checkAndDispatchThumbsForBook: (SCHBookInfo *) bookInfo;

- (NSArray *) fetchContentMetadataForAllBooks;

// operation queues - local, web service and network (download) operations
@property (readwrite, retain) NSOperationQueue *localProcessingQueue;
@property (readwrite, retain) NSOperationQueue *webServiceOperationQueue;
@property (readwrite, retain) NSOperationQueue *networkOperationQueue;

// the background task ID for background processing
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

// a dictionary holding the current thumbImageRequests
// values are NSMutableArray objects holding multiple NSValue objects corresponding
// to the size of the requested thumbnail
@property (readwrite, retain) NSMutableDictionary *thumbImageRequests;

@end

#pragma mark -

@implementation SCHProcessingManager

@synthesize localProcessingQueue, webServiceOperationQueue, networkOperationQueue;
@synthesize backgroundTask;
@synthesize thumbImageRequests;

#pragma mark -
#pragma mark Object Lifecycle

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.localProcessingQueue = nil;
	self.webServiceOperationQueue = nil;
	self.networkOperationQueue = nil;
	self.thumbImageRequests = nil;
	[super dealloc];
}

- (id) init
{
	if ((self = [super init])) {
		self.localProcessingQueue = [[NSOperationQueue alloc] init];
		self.webServiceOperationQueue = [[NSOperationQueue alloc] init];
		self.networkOperationQueue = [[NSOperationQueue alloc] init];
		
		[self.localProcessingQueue setMaxConcurrentOperationCount:2];
		[self.networkOperationQueue setMaxConcurrentOperationCount:3];
		[self.webServiceOperationQueue setMaxConcurrentOperationCount:10];
		
		self.thumbImageRequests = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

#pragma mark -
#pragma mark Default Manager Object

static SCHProcessingManager *sharedManager = nil;

+ (SCHProcessingManager *) sharedProcessingManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHProcessingManager alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager selector:@selector(checkStateForAllBooks) name:kSCHBookshelfSyncComponentComplete object:nil];			
	} 
	
	return sharedManager;
}

#pragma mark -
#pragma mark Cache Directory

+ (NSString *)cacheDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Background Processing Methods

- (void) enterBackground
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
		if ((self.localProcessingQueue && [self.localProcessingQueue operationCount]) 
			|| (self.networkOperationQueue && [self.networkOperationQueue operationCount])
			|| (self.webServiceOperationQueue && [self.webServiceOperationQueue operationCount])
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
					[self.webServiceOperationQueue waitUntilAllOperationsAreFinished];
                    [self.networkOperationQueue waitUntilAllOperationsAreFinished];    
                    [self.localProcessingQueue waitUntilAllOperationsAreFinished];    
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
#pragma mark Books State Check

- (void) checkStateForAllBooks
{
	NSMutableArray *booksNeedingProcessing = [[NSMutableArray alloc] init];
	NSArray *allBooks = [self fetchContentMetadataForAllBooks];
	
	// get all the books independent of profile
	for (SCHContentMetadataItem *metadataItem in allBooks) {
		SCHBookInfo *bookInfo = [SCHBookInfo bookInfoWithContentMetadataItem:metadataItem];
		
		// if the book is currently processing, it will already be taken care of 
		// when it finishes processing, so no need to add it for consideration
		if (![bookInfo isProcessing] && [self bookNeedsProcessing:bookInfo]) {
			
			[booksNeedingProcessing addObject:bookInfo];
		}
	}
	
	// FIXME: add prioritisation
	
	for (SCHBookInfo *bookInfo in booksNeedingProcessing) {
		[self processBook:bookInfo];
	}
}

- (BOOL) bookNeedsProcessing: (SCHBookInfo *) bookInfo
{
	BOOL needsProcessing = YES;
	BOOL spaceSaverMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];

	if (bookInfo.processingState == SCHBookInfoProcessingStateReadyToRead) {
		needsProcessing = NO;
	} else if (bookInfo.processingState == SCHBookInfoProcessingStateReadyForBookFileDownload
			   && spaceSaverMode == YES) {
		needsProcessing = NO;
	}
	
	return needsProcessing;
}

#pragma mark -
#pragma mark Processing Methods

- (void) processBook: (SCHBookInfo *) bookInfo
{
	switch (bookInfo.processingState) {
			
			// *** Book has no URLs ***
		case SCHBookInfoProcessingStateNoURLs:
		{
			// create URL processing operation
			SCHBookURLRequestOperation *bookURLOp = [[SCHBookURLRequestOperation alloc] init];
			bookURLOp.bookInfo = bookInfo;

			// the book will be redispatched on completion
			[bookURLOp setCompletionBlock:^{
				[self redispatchBook:bookInfo];
			}];

			// add the operation to the web service queue
			[self.webServiceOperationQueue addOperation:bookURLOp];
			[bookURLOp release];
			return;
			break;
		}	
			// *** Book has no full sized cover image ***
		case SCHBookInfoProcessingStateNoCoverImage:
		{	
			// create cover image download operation
			SCHDownloadFileOperation *downloadImageOp = [[SCHDownloadFileOperation alloc] init];
			downloadImageOp.fileType = kSCHDownloadFileTypeCoverImage;
			downloadImageOp.bookInfo = bookInfo;
			downloadImageOp.resume = NO;
			
			// the book will be redispatched on completion
			[downloadImageOp setCompletionBlock:^{
				[self redispatchBook:bookInfo];
			}];
			
			// add the operation to the network download queue
			[self.networkOperationQueue addOperation:downloadImageOp];
			return;
			break;
		}	
			// *** Book file needs downloading ***
		case SCHBookInfoProcessingStateDownloadStarted:
		{
			// create book file download operation
			SCHDownloadFileOperation *bookDownloadOp = [[SCHDownloadFileOperation alloc] init];
			bookDownloadOp.fileType = kSCHDownloadFileTypeXPSBook;
			bookDownloadOp.bookInfo = bookInfo;
			bookDownloadOp.resume = YES;
			
			// the book will be redispatched on completion
			[bookDownloadOp setCompletionBlock:^{
				[self redispatchBook:bookInfo];
			}];
			
			// add the operation to the network download queue
			[self.networkOperationQueue addOperation:bookDownloadOp];
			[bookDownloadOp release];
			return;
			break;
		}	
		default:
			[NSException raise:@"SCHProcessingManagerUnknownState" format:@"Unrecognised SCHBookInfo processing state (%d) in SCHProcessingManager.", bookInfo.processingState];
			break;
	}
}

- (void) redispatchBook: (SCHBookInfo *) bookInfo
{
	
	// fIXME: main thread please!
	
	// check for space saver mode
	BOOL spaceSaverMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];
	
	switch (bookInfo.processingState) {
		// these book states always require additional processing actions
		case SCHBookInfoProcessingStateNoURLs:
		case SCHBookInfoProcessingStateNoCoverImage:
		case SCHBookInfoProcessingStateDownloadStarted:
			[self processBook:bookInfo];
			break;
			
		// if space saver mode is off, bump the book to the download state and start download
		case SCHBookInfoProcessingStateDownloadPaused:
		case SCHBookInfoProcessingStateReadyForBookFileDownload:
			if (!spaceSaverMode) {
				[bookInfo setProcessingState:SCHBookInfoProcessingStateDownloadStarted];
				[self processBook:bookInfo];
			}
		default:
			break;
	}
	
	if (bookInfo.processingState == SCHBookInfoProcessingStateReadyForBookFileDownload ||
		bookInfo.processingState == SCHBookInfoProcessingStateDownloadStarted ||
		bookInfo.processingState == SCHBookInfoProcessingStateDownloadPaused ||
		bookInfo.processingState == SCHBookInfoProcessingStateReadyToRead) {
		[self checkAndDispatchThumbsForBook:bookInfo];
	}
}	

#pragma mark -
#pragma mark User Selection Methods

- (void) userSelectedBookInfo: (SCHBookInfo *) bookInfo
{
	// if the book is currently downloading, pause it
	// (changing the state will cause the operation to cancel)
	if (bookInfo.processingState == SCHBookInfoProcessingStateDownloadStarted) {
		[bookInfo setProcessingState:SCHBookInfoProcessingStateDownloadPaused];
		return;
	} 
		
	// if the book is currently paused or ready for download, start downloading
	if (bookInfo.processingState == SCHBookInfoProcessingStateDownloadPaused ||
		bookInfo.processingState == SCHBookInfoProcessingStateReadyForBookFileDownload) {
		[bookInfo setProcessingState:SCHBookInfoProcessingStateDownloadStarted];
		[self processBook:bookInfo];
	}
	// otherwise ignore the touch
}

#pragma mark -
#pragma mark Image Thumbnail Requests

// FIXME: could be moved to SCHBookInfo? 
- (BOOL) requestThumbImageForBookCover:(SCHAsyncBookCoverImageView *)bookCover size:(CGSize)size
{	
	SCHBookInfo *book = bookCover.bookInfo;
	
	NSLog(@"Requesting thumb for %@, size %@", book.bookIdentifier, NSStringFromCGSize(size));
	@synchronized(self.thumbImageRequests) {
		
		// check for an existing file
		NSString *thumbPath = [book thumbPathForSize:size];
		
		// FIXME: non thread safe!
		if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
			bookCover.image = [SCHThumbnailFactory imageWithPath:thumbPath];
			return YES;
		}
			
		// check for an existing request
		NSMutableArray *sizes = [self.thumbImageRequests objectForKey:book.bookIdentifier];
		
		if (sizes) {
			for (NSValue *value in sizes) {
				CGSize tmpSize = [value CGSizeValue];
				
				if (tmpSize.width == size.width && tmpSize.height == size.height) {
					// found an existing request - don't need to enqueue another one
					return NO;
				}
			}
		}
		
		// if we didn't find an existing request, add a new one
		NSValue *sizeValue = [NSValue valueWithCGSize:size];
		
		if (sizes) {
			[sizes addObject:sizeValue];
		} else {
			sizes = [[NSMutableArray alloc] init];
			[sizes addObject:sizeValue];
			[self.thumbImageRequests setObject:sizes forKey:book.bookIdentifier];
			[sizes release];
		}
		
		if (book.processingState == SCHBookInfoProcessingStateReadyForBookFileDownload ||
			book.processingState == SCHBookInfoProcessingStateDownloadStarted ||
			book.processingState == SCHBookInfoProcessingStateDownloadPaused ||
			book.processingState == SCHBookInfoProcessingStateReadyToRead) {
			[self checkAndDispatchThumbsForBook:book];
		}
		
		return NO;
	}
}

- (void) checkAndDispatchThumbsForBook: (SCHBookInfo *) bookInfo
{
	// check if we have any outstanding requests for cover image thumbs
	NSMutableArray *sizes = [self.thumbImageRequests objectForKey:bookInfo.bookIdentifier];
	if (sizes) {
		@synchronized(self.thumbImageRequests) {
			for (NSValue *val in sizes) {
				CGSize size = [val CGSizeValue];
				SCHThumbnailOperation *thumbOp = [[SCHThumbnailOperation alloc] init];
				thumbOp.bookInfo = bookInfo;
				thumbOp.size = size;
				thumbOp.flip = NO;
				thumbOp.aspect = YES;
				
				// add the operation to the local processing queue
				[self.localProcessingQueue addOperation:thumbOp];
				[thumbOp release];
				
			}
			
			// remove all items from the tracking dictionary
			[self.thumbImageRequests removeAllObjects];
		}
	}
}	


#pragma mark -
#pragma mark Core Data Fetch
// FIXME: probably will remove this after talking with John
- (NSArray *) fetchContentMetadataForAllBooks
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
	
	NSError *error = nil;				
	NSArray *allBooks = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
	if (!error) {
		return allBooks;
	} else {
		return nil;
	}
	
}

@end
