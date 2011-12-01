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
#import "SCHRightsParsingOperation.h"
#import "SCHAudioPreParseOperation.h"
#import "SCHTextFlowPreParseOperation.h"
#import "SCHSmartZoomPreParseOperation.h"
#import "SCHFlowAnalysisOperation.h"
#import "SCHLicenseAcquisitionOperation.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"
#import "SCHUserDefaults.h"
#import "SCHCoreDataHelper.h"
#import "SCHAppStateManager.h"

// Constants
NSString * const kSCHProcessingManagerConnectionIdle = @"SCHProcessingManagerConnectionIdle";
NSString * const kSCHProcessingManagerConnectionBusy = @"SCHProcessingManagerConnectionBusy";

extern NSString * const kSCHUserDefaultsSpaceSaverModeSetOffNotification;

#pragma mark - Class Extension

@interface SCHProcessingManager()

- (void)checkStateForAllBooks;
- (BOOL)identifierNeedsProcessing:(SCHBookIdentifier *)identifier;

- (void) processIdentifier: (SCHBookIdentifier *) identifier;
- (void) redispatchIdentifier: (SCHBookIdentifier *) identifier;

// fire notifications if there's a change in state between processing and not processing
- (void)checkIfProcessing;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void)enterBackground;
- (void)enterForeground;

// operation queues - local, web service and network (download) operations
@property (readwrite, retain) NSOperationQueue *localProcessingQueue;
@property (readwrite, retain) NSOperationQueue *webServiceOperationQueue;
@property (readwrite, retain) NSOperationQueue *networkOperationQueue;

// the background task ID for background processing
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

// a list of book identifiers that are currently processing
@property (readwrite, retain) NSMutableArray *currentlyProcessingIdentifiers;

@property BOOL connectionIsIdle;
@property BOOL firedFirstBusyIdleNotification;

- (BOOL)spaceSaverMode;
- (void)postBookStateUpdate:(SCHBookIdentifier *)identifier;

@end

#pragma mark - Class

@implementation SCHProcessingManager

@synthesize localProcessingQueue, webServiceOperationQueue, networkOperationQueue;
@synthesize backgroundTask;
@synthesize currentlyProcessingIdentifiers;
@synthesize connectionIsIdle, firedFirstBusyIdleNotification;
@synthesize managedObjectContext;
@synthesize thumbnailAccessQueue;

#pragma mark - Object Lifecycle

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[localProcessingQueue release], localProcessingQueue = nil;
	[webServiceOperationQueue release], webServiceOperationQueue = nil;
	[networkOperationQueue release], networkOperationQueue = nil;
    [currentlyProcessingIdentifiers release], currentlyProcessingIdentifiers = nil;
    [managedObjectContext release], managedObjectContext = nil;
    dispatch_release(thumbnailAccessQueue);
    
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		self.localProcessingQueue = [[[NSOperationQueue alloc] init] autorelease];
		self.webServiceOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		self.networkOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		
		[self.localProcessingQueue setMaxConcurrentOperationCount:2];
		[self.networkOperationQueue setMaxConcurrentOperationCount:3];
		[self.webServiceOperationQueue setMaxConcurrentOperationCount:10];
		
        self.currentlyProcessingIdentifiers = [NSMutableArray array];
		
		self.connectionIsIdle = YES;
        self.firedFirstBusyIdleNotification = NO;
        
        self.thumbnailAccessQueue = dispatch_queue_create("com.scholastic.ThumbnailAccessQueue", NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	        
	}
	
	return self;
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

#pragma mark - Default Manager Object

static SCHProcessingManager *sharedManager = nil;

+ (SCHProcessingManager *)sharedProcessingManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHProcessingManager alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(checkStateForAllBooks) 
													 name:SCHBookshelfSyncComponentDidCompleteNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(checkStateForBook:) 
													 name:SCHBookshelfSyncComponentBookReceivedNotification 
												   object:nil];
		
        [[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(checkStateForBook:) 
													 name:kSCHUserDefaultsSpaceSaverModeSetOffNotification 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterForeground) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];	
    } 
	
	return sharedManager;
}

#pragma mark - Background Processing Methods

- (void)enterBackground
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

- (void)enterForeground
{
	NSLog(@"Entering foreground - quitting background task.");
	if(self.backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
		self.backgroundTask = UIBackgroundTaskInvalid;
	}		
}

#pragma mark - Books State Check

- (void)checkStateForBook: (NSNotification *)notification
{
    NSAssert([NSThread isMainThread], @"checkStateForBook must run on main thread");

    NSArray *identifiers = [[notification userInfo] objectForKey:@"bookIdentifiers"];

    for (SCHBookIdentifier *identifier in identifiers) {
    
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
        
        if (book != nil) {
            // if the book is currently processing, it will already be taken care of 
            // when it finishes processing, so no need to add it for consideration
            if (![book isProcessing] && [self identifierNeedsProcessing:identifier]) {
                [self processIdentifier:identifier];
            }
        }
    }

    [self checkIfProcessing];
}


- (void)checkStateForAllBooks
{
    NSAssert([NSThread isMainThread], @"checkStateForAllBooks must run on main thread");
    
	NSArray *allBooks = [[SCHBookManager sharedBookManager] allBookIdentifiersInManagedObjectContext:self.managedObjectContext];
	
	// FIXME: add prioritisation
    
	// get all the books independent of profile
	for (SCHBookIdentifier *identifier in allBooks) {
		SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
        
        if (book != nil) {
            // if the book is currently processing, it will already be taken care of 
            // when it finishes processing, so no need to add it for consideration
            if (![book isProcessing] && [self identifierNeedsProcessing:identifier]) {
                // FIXME: remove this checkout when the XPS library properly releases the mapped memory
                //[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:isbn];
                [self processIdentifier:identifier];
            }
        }
	}	
    
    [self checkIfProcessing];
}

- (BOOL)identifierNeedsProcessing:(SCHBookIdentifier *)identifier
{
    NSAssert([NSThread isMainThread], @"ISBNNeedsProcessing must run on main thread");
    
    BOOL needsProcessing = YES;
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
    
    if (book != nil) {
        BOOL spaceSaverMode = [self spaceSaverMode];
        
        if (book.processingState == SCHBookProcessingStateReadyToRead) {
            needsProcessing = NO;
        } else if (book.processingState == SCHBookProcessingStateReadyForBookFileDownload
                   && spaceSaverMode == YES) {
            needsProcessing = NO;
        }
    } else {
        needsProcessing = NO;
    }
    
	return needsProcessing;
}

- (BOOL)spaceSaverMode
{
    BOOL ret = YES;
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
    	ret = [[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsSpaceSaverMode];
    }
    
    return(ret);
}

#pragma mark - Processing Book Tracking

- (BOOL)identifierIsProcessing:(SCHBookIdentifier *)identifier
{
    @synchronized(self.currentlyProcessingIdentifiers) {
        return [self.currentlyProcessingIdentifiers containsObject:identifier];
    }
}

- (void)setProcessing:(BOOL)processing forIdentifier:(SCHBookIdentifier *)identifier
{
    @synchronized(self.currentlyProcessingIdentifiers) {
        if (processing) {
            if (![self.currentlyProcessingIdentifiers containsObject:identifier]) {
                [self.currentlyProcessingIdentifiers addObject:identifier];
            }
            
        } else {
            [self.currentlyProcessingIdentifiers removeObject:identifier];
        }
    }
}

- (void)cancelAllOperations
{
    @synchronized(self) {
        [self.webServiceOperationQueue cancelAllOperations];
        [self.networkOperationQueue cancelAllOperations];    
        [self.localProcessingQueue cancelAllOperations];    
        [self.currentlyProcessingIdentifiers removeAllObjects];
    }
}

- (void)cancelAllOperationsForBookIndentifier:(SCHBookIdentifier *)bookIdentifier
{
    @synchronized(self) {
        for (SCHBookOperation *bookOperation in [self.webServiceOperationQueue operations]) {
            if ([bookOperation.identifier isEqual:bookIdentifier] == YES) {
                [bookOperation cancel];
                [bookOperation waitUntilFinished];
                break;
            }
        }
        
        for (SCHBookOperation *bookOperation in [self.networkOperationQueue operations]) {
            if ([bookOperation.identifier isEqual:bookIdentifier] == YES) {
                [bookOperation cancel];
                [bookOperation waitUntilFinished];                
                break;
            }
        }
        
        for (SCHBookOperation *bookOperation in [self.localProcessingQueue operations]) {
            if ([bookOperation.identifier isEqual:bookIdentifier] == YES) {
                [bookOperation cancel];
                [bookOperation waitUntilFinished];                
                break;
            }
        }
        
        [self.currentlyProcessingIdentifiers removeObject:bookIdentifier];
    }
}

#pragma mark - Processing Methods

- (void)processIdentifier:(SCHBookIdentifier *)identifier
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
	
    if (book != nil) {
        NSLog(@"Processing state of %@ is %@", identifier, [book processingStateAsString]);
        switch (book.processingState) {
                
                // *** Book has no URLs ***
            case SCHBookProcessingStateNoURLs:
            { 
                // create URL processing operation
                SCHBookURLRequestOperation *bookURLOp = [[SCHBookURLRequestOperation alloc] init];
                [bookURLOp setMainThreadManagedObjectContext:self.managedObjectContext];
                bookURLOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [bookURLOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the web service queue
                [self.webServiceOperationQueue addOperation:bookURLOp];
                [bookURLOp release];
                return;
            }	
                // *** Book has no full sized cover image ***
            case SCHBookProcessingStateNoCoverImage:
            {	
                // check first for URL expiry
                if (![book bookCoverURLIsValid]) {
                    // if expired, get the URLs again - this won't loop because we check in 
                    // the URL request operation for expired URLs from the service.
                    [book setProcessingState:SCHBookProcessingStateNoURLs];
                    [self redispatchIdentifier:identifier];
                    return;
                }
                
                // create cover image download operation
                SCHDownloadBookFileOperation *downloadImageOp = [[SCHDownloadBookFileOperation alloc] init];
                [downloadImageOp setMainThreadManagedObjectContext:self.managedObjectContext];
                downloadImageOp.fileType = kSCHDownloadFileTypeCoverImage;
                downloadImageOp.identifier = identifier;
                downloadImageOp.resume = NO;
                // the book will be redispatched on completion
                [downloadImageOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                // add the operation to the network download queue
                [self.networkOperationQueue addOperation:downloadImageOp];
                [downloadImageOp release];                
                return;
            }	
                // *** Book file needs downloading ***
            case SCHBookProcessingStateDownloadStarted:
            {
                // check first for URL expiry
                if (![book bookFileURLIsValid]) {
                    // if expired, get the URLs again and force download
                    book.ForceProcess = [NSNumber numberWithBool:YES];
                    [book setProcessingState:SCHBookProcessingStateNoURLs];
                    [self redispatchIdentifier:identifier];
                    return;
                }
                
                // create book file download operation
                SCHDownloadBookFileOperation *bookDownloadOp = [[SCHDownloadBookFileOperation alloc] init];
                [bookDownloadOp setMainThreadManagedObjectContext:self.managedObjectContext];
                bookDownloadOp.fileType = kSCHDownloadFileTypeXPSBook;
                bookDownloadOp.identifier = identifier;
                bookDownloadOp.resume = ![book.ForceProcess boolValue];
                [book setForcedProcessing:NO];
                
                // the book will be redispatched on completion
                [bookDownloadOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the network download queue
                [self.networkOperationQueue addOperation:bookDownloadOp];
                [bookDownloadOp release];
                return;
            }	
                // *** Book file needs license acquisition ***
            case SCHBookProcessingStateReadyForLicenseAcquisition:
            {
                // create rights processing operation
                SCHLicenseAcquisitionOperation *licenseOp = [[SCHLicenseAcquisitionOperation alloc] init];
                [licenseOp setMainThreadManagedObjectContext:self.managedObjectContext];
                licenseOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [licenseOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the local processing queue
                [self.localProcessingQueue addOperation:licenseOp];
                [licenseOp release];
                return;
            }	
                
                // *** Book file needs rights parsed ***
            case SCHBookProcessingStateReadyForRightsParsing:
            {
                // create rights processing operation
                SCHRightsParsingOperation *rightsOp = [[SCHRightsParsingOperation alloc] init];
                [rightsOp setMainThreadManagedObjectContext:self.managedObjectContext];
                rightsOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [rightsOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the local processing queue
                [self.localProcessingQueue addOperation:rightsOp];
                [rightsOp release];
                return;
            }	
                
                // *** Book file needs audio information parsed ***
            case SCHBookProcessingStateReadyForAudioInfoParsing:
            {
                // create audio info processing operation
                SCHAudioPreParseOperation *audioOp = [[SCHAudioPreParseOperation alloc] init];
                [audioOp setMainThreadManagedObjectContext:self.managedObjectContext];
                audioOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [audioOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the local processing queue
                [self.localProcessingQueue addOperation:audioOp];
                [audioOp release];
                return;
            }	
                
                // *** Book file needs textflow pre-parsing ***
            case SCHBookProcessingStateReadyForTextFlowPreParse:
            {
                // create pre-parse operation
                SCHTextFlowPreParseOperation *textflowOp = [[SCHTextFlowPreParseOperation alloc] init];
                [textflowOp setMainThreadManagedObjectContext:self.managedObjectContext];
                textflowOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [textflowOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the local processing queue
                [self.localProcessingQueue addOperation:textflowOp];
                [textflowOp release];
                return;
            }	
                
                // *** Book file needs smart zoom pre-parsing ***
            case SCHBookProcessingStateReadyForSmartZoomPreParse:
            {
                // create pre-parse operation
                SCHSmartZoomPreParseOperation *smartzoomOp = [[SCHSmartZoomPreParseOperation alloc] init];
                [smartzoomOp setMainThreadManagedObjectContext:self.managedObjectContext];
                smartzoomOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [smartzoomOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the local processing queue
                [self.localProcessingQueue addOperation:smartzoomOp];
                [smartzoomOp release];
                return;
            }	
                
                // *** Book file needs pagination ***
            case SCHBookProcessingStateReadyForPagination:
            {
                // create paginate operation
                SCHFlowAnalysisOperation *paginateOp = [[SCHFlowAnalysisOperation alloc] init];
                [paginateOp setMainThreadManagedObjectContext:self.managedObjectContext];
                paginateOp.identifier = identifier;
                
                // the book will be redispatched on completion
                [paginateOp setNotCancelledCompletionBlock:^{
                    [self redispatchIdentifier:identifier];
                }];
                
                // add the operation to the local processing queue
                [self.localProcessingQueue addOperation:paginateOp];
                [paginateOp release];
                return;
            }	
                
            case SCHBookProcessingStateReadyForBookFileDownload:
            {
                // recheck the book state - needs downloading if space saver mode is off
                [self redispatchIdentifier:identifier];
                return;
            }
            case SCHBookProcessingStateError:
            case SCHBookProcessingStateUnableToAcquireLicense:
            case SCHBookProcessingStateCachedCoverError:
            case SCHBookProcessingStateDownloadFailed:
            case SCHBookProcessingStateURLsNotPopulated:
            case SCHBookProcessingStateBookVersionNotSupported:
            case SCHBookProcessingStateDownloadPaused:
            case SCHBookProcessingStateReadyToRead:
            {
                // Do nothing until the sync kicks off again or the user initiates an action
                // Prefer explicitly listing these state to just having a default because it catches
                // Unhandled cases at compile time
                return;
            }
        }
	}
}

- (void)redispatchIdentifier:(SCHBookIdentifier *)identifier
{    
    dispatch_block_t redispatchBlock = ^{
        
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
        
        if (book != nil) {
            // check for space saver mode
            BOOL spaceSaverMode = [self spaceSaverMode];
            BOOL bookFileURLIsBundleURL = [book bookFileURLIsBundleURL];
            
            switch (book.processingState) {
                    // these book states always require additional processing actions
                case SCHBookProcessingStateNoURLs:
                case SCHBookProcessingStateNoCoverImage:
                case SCHBookProcessingStateDownloadStarted:
                case SCHBookProcessingStateReadyForLicenseAcquisition:
                case SCHBookProcessingStateReadyForRightsParsing:
                case SCHBookProcessingStateReadyForAudioInfoParsing:
                case SCHBookProcessingStateReadyForTextFlowPreParse:
                case SCHBookProcessingStateReadyForSmartZoomPreParse:
                case SCHBookProcessingStateReadyForPagination:
                    [self processIdentifier:identifier];
                    break;
                    
                    // if space saver mode is off, bump the book to the download state and start download
                case SCHBookProcessingStateDownloadPaused:
                case SCHBookProcessingStateReadyForBookFileDownload:
                    if (!spaceSaverMode || [[book ForceProcess] boolValue] || bookFileURLIsBundleURL) {
                        [book setProcessingState:SCHBookProcessingStateDownloadStarted];
                        [self processIdentifier:identifier];
                    }
                    break;
                default:
                    break;
            }
            
            [self checkIfProcessing];
        }
    };
    
    if ([NSThread isMainThread]) {
        redispatchBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), redispatchBlock);
    }
}	

- (void)checkIfProcessing
{
    NSAssert([NSThread isMainThread], @"checkIfProcessing must be called on main thread");
    
    // check to see if we're processing
    //	int totalOperations = [[self.networkOperationQueue operations] count] + 
    //	[[self.webServiceOperationQueue operations] count];
    
    int totalBooksProcessing = 0;
    
	NSArray *allBooks = [[SCHBookManager sharedBookManager] allBookIdentifiersInManagedObjectContext:self.managedObjectContext];
	
	// FIXME: add prioritisation
    
	// get all the books independent of profile
	for (SCHBookIdentifier *identifier in allBooks) {
		SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
        
        if (book != nil && [book isProcessing]) {
            totalBooksProcessing++;
        }
	}	
	
	if (totalBooksProcessing == 0) {
		self.connectionIsIdle = YES;
        
		if (!self.connectionIsIdle || !self.firedFirstBusyIdleNotification) {
			[self performSelectorOnMainThread:@selector(sendNotification:) withObject:kSCHProcessingManagerConnectionIdle waitUntilDone:YES];
            self.firedFirstBusyIdleNotification = YES;
		}
        
#ifndef __OPTIMIZE__
        // FIXME: remove this logging when we are satisfied we aren't failing to clean up the vended objects from the shared book manager
        NSLog(@"Processing stopped. SharedBookManager: %@", [SCHBookManager sharedBookManager]);
#endif
        
	} else {
		self.connectionIsIdle = NO;
        
		if (self.connectionIsIdle || !self.firedFirstBusyIdleNotification) {
			[self performSelectorOnMainThread:@selector(sendNotification:) withObject:kSCHProcessingManagerConnectionBusy waitUntilDone:YES];
            self.firedFirstBusyIdleNotification = YES;
		}
	}
}

- (void)sendNotification:(NSString *)name
{
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}	

#pragma mark - User Selection Methods

- (void)userSelectedBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    NSAssert([NSThread isMainThread], @"userSelectedBookWithISBN: must be called on main thread");
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
	
    if (book != nil) {
        // if the book is currently downloading, pause it
        // (changing the state will cause the operation to cancel)
        if (book.processingState == SCHBookProcessingStateDownloadStarted) {
            [book setProcessingState:SCHBookProcessingStateDownloadPaused];
            
            [self postBookStateUpdate:identifier];
            
            return;
        } 
		
        // if the book is currently paused or ready for download, start downloading
        if (book.processingState == SCHBookProcessingStateDownloadPaused ||
            book.processingState == SCHBookProcessingStateReadyForBookFileDownload) {
            [book setProcessingState:SCHBookProcessingStateDownloadStarted];
            
            [self postBookStateUpdate:identifier];
            
            [self processIdentifier:identifier];
        }
        // otherwise ignore the touch
    }
}

- (void)userRequestedRetryForBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    NSAssert([NSThread isMainThread], @"userRequestedRetryForBookWithIdentifier: must be called on main thread");
	
    // if the book is already processing as a result of action taken while the retry was being offered,
    // return - the book will process and update the status of cells etc. 
    if ([self identifierIsProcessing:identifier]) {
        return;
    }
    
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
    
    if (book != nil) {
        switch (book.processingState) {
            case SCHBookProcessingStateURLsNotPopulated:
                book.ForceProcess = [NSNumber numberWithBool:YES];
                [book setProcessingState:SCHBookProcessingStateNoURLs];
                break;
            case SCHBookProcessingStateDownloadFailed:
                book.ForceProcess = [NSNumber numberWithBool:YES];
                if ([book.BookCoverExists boolValue] == NO) {
                    [book setProcessingState:SCHBookProcessingStateNoURLs];
                } else { 
                    [book setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
                }
                break;
            case SCHBookProcessingStateUnableToAcquireLicense:
                [book setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
                break;
            case SCHBookProcessingStateCachedCoverError:
                book.ForceProcess = [NSNumber numberWithBool:NO];
                [book setProcessingState:SCHBookProcessingStateNoURLs];
                break;
            case SCHBookProcessingStateBookVersionNotSupported:
                [book setProcessingState:SCHBookProcessingStateReadyForRightsParsing];
                break;
            case SCHBookProcessingStateError:            
            default:
                if ([book.BookCoverExists boolValue] == NO) {
                    book.ForceProcess = [NSNumber numberWithBool:NO];
                    [book setProcessingState:SCHBookProcessingStateNoURLs];
                } else if ([book.XPSExists boolValue] == NO) { 
                    book.ForceProcess = [NSNumber numberWithBool:YES];
                    [book setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
                } else {
                    [book setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];                    
                }
                break;
        }
        
        [self postBookStateUpdate:identifier];
        [self redispatchIdentifier:identifier];
    }
}

- (void)postBookStateUpdate:(SCHBookIdentifier *)identifier
{
    if (identifier != nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:identifier 
                                                             forKey:@"bookIdentifier"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" 
                                                            object:nil 
                                                          userInfo:userInfo];    
    }
}

@end
