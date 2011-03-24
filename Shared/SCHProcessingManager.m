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
#import "SCHBookURLRequestOperation.h"
#import "SCHDownloadBookFileOperation.h"
#import "SCHXPSCoverImageOperation.h"
#import "SCHThumbnailOperation.h"
#import "SCHRightsParsingOperation.h"
#import "SCHBookManager.h"
#import "SCHAsyncBookCoverImageView.h"
#import "SCHThumbnailFactory.h"
#import "SCHAppBook.h"

#pragma mark Class Extension

@interface SCHProcessingManager()

- (void) checkStateForAllBooks;
- (BOOL) ISBNNeedsProcessing: (NSString *) isbn;

- (void) processISBN: (NSString *) isbn;
- (void) redispatchISBN: (NSString *) isbn;
- (void) checkAndDispatchThumbsForISBN: (NSString *) isbn;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void) enterBackground;
- (void) enterForeground;

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

@property (readwrite, retain) NSMutableArray *currentlyProcessingISBNs;

@property BOOL connectionIsIdle;

@end

#pragma mark -

@implementation SCHProcessingManager

@synthesize localProcessingQueue, webServiceOperationQueue, networkOperationQueue;
@synthesize backgroundTask;
@synthesize thumbImageRequests, currentlyProcessingISBNs;
@synthesize connectionIsIdle;

#pragma mark -
#pragma mark Object Lifecycle

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.localProcessingQueue = nil;
	self.webServiceOperationQueue = nil;
	self.networkOperationQueue = nil;
	self.thumbImageRequests = nil;
    self.currentlyProcessingISBNs = nil;
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
        self.currentlyProcessingISBNs = [[NSMutableArray alloc] init];
		
		self.connectionIsIdle = YES;
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
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(checkStateForAllBooks) 
													 name:kSCHBookshelfSyncComponentComplete 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterForeground) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];			
		
		//		
	} 
	
	return sharedManager;
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
	NSArray *allBooks = [[SCHBookManager sharedBookManager] allBooksAsISBNs];
	
	// FIXME: add prioritisation

	// get all the books independent of profile
	for (NSString *isbn in allBooks) {
		SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];

		// if the book is currently processing, it will already be taken care of 
		// when it finishes processing, so no need to add it for consideration
		if (![book isProcessing] && [self ISBNNeedsProcessing:isbn]) {
			
			[self processISBN:isbn];
		}
	}	
}

- (BOOL) ISBNNeedsProcessing: (NSString *) isbn
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];

	BOOL needsProcessing = YES;
	BOOL spaceSaverMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];

	if (book.processingState == SCHBookProcessingStateReadyToRead) {
		needsProcessing = NO;
	} else if (book.processingState == SCHBookProcessingStateReadyForBookFileDownload
			   && spaceSaverMode == YES) {
		needsProcessing = NO;
	}
	
	return needsProcessing;
}

#pragma mark -
#pragma mark Processing Book Tracking

- (BOOL) ISBNisProcessing: (NSString *) isbn
{
    @synchronized(self.currentlyProcessingISBNs) {
        return [self.currentlyProcessingISBNs containsObject:isbn];
    }
}

- (void) setProcessing: (BOOL) processing forISBN: (NSString *) isbn {

    @synchronized(self.currentlyProcessingISBNs) {
        if (processing) {
            if (![self.currentlyProcessingISBNs containsObject:isbn]) {
                [self.currentlyProcessingISBNs addObject:isbn];
            }
            
        } else {
            [self.currentlyProcessingISBNs removeObject:isbn];
        }
    }
}


#pragma mark -
#pragma mark Processing Methods

- (void) processISBN: (NSString *) isbn
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];
	
	NSLog(@"Processing state of %@ is %@", book.ContentIdentifier, [book processingStateAsString]);
	switch (book.processingState) {
			
			// *** Book has no URLs ***
		case SCHBookProcessingStateNoURLs:
		{
			// create URL processing operation
			SCHBookURLRequestOperation *bookURLOp = [[SCHBookURLRequestOperation alloc] init];
			bookURLOp.isbn = isbn;

			// the book will be redispatched on completion
			[bookURLOp setCompletionBlock:^{
				[self redispatchISBN:isbn];
			}];

			// add the operation to the web service queue
			[self.webServiceOperationQueue addOperation:bookURLOp];
			[bookURLOp release];
			return;
			break;
		}	
			// *** Book has no full sized cover image ***
		case SCHBookProcessingStateNoCoverImage:
		{	
#ifdef LOCALDEBUG
			// create cover image download operation
			SCHXPSCoverImageOperation *downloadImageOp = [[SCHXPSCoverImageOperation alloc] init];
			downloadImageOp.bookInfo = bookInfo;
			
#else
			// create cover image download operation
			SCHDownloadBookFileOperation *downloadImageOp = [[SCHDownloadBookFileOperation alloc] init];
			downloadImageOp.fileType = kSCHDownloadFileTypeCoverImage;
			downloadImageOp.isbn = isbn;
			downloadImageOp.resume = NO;
#endif		
			// the book will be redispatched on completion
			[downloadImageOp setCompletionBlock:^{
				[self redispatchISBN:isbn];
			}];
			
			// add the operation to the network download queue
			[self.networkOperationQueue addOperation:downloadImageOp];
			[downloadImageOp release];
			return;
			break;
		}	
			// *** Book file needs downloading ***
		case SCHBookProcessingStateDownloadStarted:
		{
			// create book file download operation
			SCHDownloadBookFileOperation *bookDownloadOp = [[SCHDownloadBookFileOperation alloc] init];
			bookDownloadOp.fileType = kSCHDownloadFileTypeXPSBook;
			bookDownloadOp.isbn = isbn;
			bookDownloadOp.resume = YES;
			
			// the book will be redispatched on completion
			[bookDownloadOp setCompletionBlock:^{
				[self redispatchISBN:isbn];
			}];
			
			// add the operation to the network download queue
			[self.networkOperationQueue addOperation:bookDownloadOp];
			[bookDownloadOp release];
			return;
			break;
		}	
			// *** Book file needs rights parsed ***
		case SCHBookProcessingStateReadyForRightsParsing:
		{
			// create book file download operation
			SCHRightsParsingOperation *rightsOp = [[SCHRightsParsingOperation alloc] init];
			rightsOp.isbn = isbn;
			
			// the book will be redispatched on completion
			[rightsOp setCompletionBlock:^{
				[self redispatchISBN:isbn];
			}];
			
			// add the operation to the network download queue
			[self.localProcessingQueue addOperation:rightsOp];
			[rightsOp release];
			return;
			break;
		}	
        case SCHBookProcessingStateReadyForBookFileDownload:
		{
        // FIXME: Gordon - if you process books then switch off space saver and restart teh app this state is received
            NSLog(@"SCHBookProcessingStateReadyForBookFileDownload state");
            return;
            break;
        }
		default:
			[NSException raise:@"SCHProcessingManagerUnknownState" format:@"Unrecognised SCHBookInfo processing state (%d) in SCHProcessingManager.", book.processingState];
			break;
	}
	
}

- (void) redispatchISBN: (NSString *) isbn
{
	
	// FIXME: main thread please!
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];

	// check for space saver mode
	BOOL spaceSaverMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];
	
	switch (book.processingState) {
		// these book states always require additional processing actions
		case SCHBookProcessingStateNoURLs:
		case SCHBookProcessingStateNoCoverImage:
		case SCHBookProcessingStateDownloadStarted:
		case SCHBookProcessingStateReadyForRightsParsing:
			[self processISBN:isbn];
			break;
			
		// if space saver mode is off, bump the book to the download state and start download
		case SCHBookProcessingStateDownloadPaused:
		case SCHBookProcessingStateReadyForBookFileDownload:
			if (!spaceSaverMode) {
//				[bookInfo setProcessingState:SCHBookProcessingStateDownloadStarted];
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:isbn state:SCHBookProcessingStateDownloadStarted];
				[self processISBN:isbn];
			}
		default:
			break;
	}
	
	if (book.processingState == SCHBookProcessingStateReadyForBookFileDownload ||
		book.processingState == SCHBookProcessingStateDownloadStarted ||
		book.processingState == SCHBookProcessingStateDownloadPaused ||
		book.processingState == SCHBookProcessingStateReadyToRead) {
		[self checkAndDispatchThumbsForISBN:isbn];
	}
	
	// check to see if we're processing
	int totalOperations = [[self.networkOperationQueue operations] count] + 
	[[self.webServiceOperationQueue operations] count];
	
	if (totalOperations == 0) {
		if (!self.connectionIsIdle) {
			self.connectionIsIdle = YES;
			
			[self performSelectorOnMainThread:@selector(sendNotification:) withObject:kSCHProcessingManagerConnectionIdle waitUntilDone:YES];
		}
	} else {
		if (self.connectionIsIdle) {
			self.connectionIsIdle = NO;
			
			[self performSelectorOnMainThread:@selector(sendNotification:) withObject:kSCHProcessingManagerConnectionBusy waitUntilDone:YES];
		}
	}
}	

- (void) sendNotification: (NSString *) name
{
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}	

#pragma mark -
#pragma mark User Selection Methods

- (void) userSelectedBookWithISBN: (NSString *) isbn
{
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];
	
	// if the book is currently downloading, pause it
	// (changing the state will cause the operation to cancel)
	if (book.processingState == SCHBookProcessingStateDownloadStarted) {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:isbn state:SCHBookProcessingStateDownloadPaused];
		return;
	} 
		
	// if the book is currently paused or ready for download, start downloading
	if (book.processingState == SCHBookProcessingStateDownloadPaused ||
		book.processingState == SCHBookProcessingStateReadyForBookFileDownload) {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:isbn state:SCHBookProcessingStateDownloadStarted];
		[self processISBN:isbn];
	}
	// otherwise ignore the touch

}

#pragma mark -
#pragma mark Image Thumbnail Requests

// FIXME: could be moved to SCHBookInfo? 
- (BOOL) requestThumbImageForBookCover:(SCHAsyncBookCoverImageView *)bookCover size:(CGSize)size
{	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:bookCover.isbn];
	
//	NSLog(@"Requesting thumb for %@, size %@", book.bookIdentifier, NSStringFromCGSize(size));
	@synchronized(self.thumbImageRequests) {
		
		// check for an existing file
		NSString *thumbPath = [book thumbPathForSize:size];
		
		// FIXME: non thread safe!
		if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
			bookCover.image = [SCHThumbnailFactory imageWithPath:thumbPath];
			return YES;
		}
			
		// check for an existing request
		NSMutableArray *sizes = [self.thumbImageRequests objectForKey:book.ContentIdentifier];
		
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
			[self.thumbImageRequests setObject:sizes forKey:bookCover.isbn];
			[sizes release];
		}
		
		if (book.processingState == SCHBookProcessingStateReadyForBookFileDownload ||
			book.processingState == SCHBookProcessingStateDownloadStarted ||
			book.processingState == SCHBookProcessingStateDownloadPaused ||
			book.processingState == SCHBookProcessingStateReadyToRead) {
			[self checkAndDispatchThumbsForISBN:book.ContentIdentifier];
		}
		
		return NO;
	}
}

- (void) checkAndDispatchThumbsForISBN: (NSString *) isbn
{
	// check if we have any outstanding requests for cover image thumbs
	NSMutableArray *sizes = [self.thumbImageRequests objectForKey:isbn];
	if (sizes) {
		@synchronized(self.thumbImageRequests) {
			for (NSValue *val in sizes) {
				CGSize size = [val CGSizeValue];
				SCHThumbnailOperation *thumbOp = [[SCHThumbnailOperation alloc] init];
				thumbOp.isbn = isbn;
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

@end
