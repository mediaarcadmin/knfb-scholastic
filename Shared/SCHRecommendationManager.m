//
//  SCHRecommendationManager.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationManager.h"
#import "SCHCoreDataHelper.h"
#import "SCHRecommendationOperation.h"
#import "SCHRecommendationURLRequestOperation.h"
#import "SCHRecommendationDownloadCoverOperation.h"
#import "SCHRecommendationThumbnailOperation.h"
#import "SCHAppRecommendationItem.h"
#import "SCHRecommendationSyncComponent.h"
#import "SCHTopRatingsSyncComponent.h"
#import "SCHWishListSyncComponent.h"
#import "NSURL+Extensions.h"
#import "NSDate+ServerDate.h"

static const NSUInteger kSCHRecommendationsManagerBatchSize = 10;
NSString * const kSCHRecommendationStateUpdateNotification = @"SCHRecommendationStateUpdateNotification";


@interface SCHRecommendationManager()

- (void)createProcessingQueues;
- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification;
- (BOOL)isbnIsProcessing:(NSString *)isbn;
- (BOOL)recommendationNeedsProcessing:(SCHAppRecommendationItem *)recommendationItem batch:(BOOL *)batchProcess;
- (BOOL)isbnNeedsProcessing:(NSString *)isbn;
- (void)processIsbn:(NSString *)isbn;
- (void)processIsbns:(NSArray *)isbns;
- (void)redispatchIsbn:(NSString *)isbn;
- (void)processRecommendationItems:(NSArray *)recommendationItems forcePendingItemsToProcess:(BOOL)force;
- (void)postRecommendationStateUpdate:(NSString *)isbn;
+ (BOOL)urlHasExpired:(NSString *)urlString;

@property (readwrite, retain) NSOperationQueue *processingQueue;
@property (readwrite, retain) NSOperationQueue *downloadQueue;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (readwrite, retain) NSMutableSet *currentlyProcessingIsbns;

@end

static SCHRecommendationManager *sharedManager = nil;

@implementation SCHRecommendationManager

@synthesize managedObjectContext;
@synthesize processingQueue;
@synthesize downloadQueue;
@synthesize backgroundTask;
@synthesize currentlyProcessingIsbns;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [managedObjectContext release], managedObjectContext = nil;
    [processingQueue release], processingQueue = nil;
    [downloadQueue release], downloadQueue = nil;
    [currentlyProcessingIsbns release], currentlyProcessingIsbns = nil;
    [super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		[self createProcessingQueues];
        
        currentlyProcessingIsbns = [[NSMutableSet set] retain];
		        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	        
	}
	
	return self;
}

- (void)createProcessingQueues
{
    self.processingQueue = [[[NSOperationQueue alloc] init] autorelease];
    [self.processingQueue setMaxConcurrentOperationCount:2];
    
    self.downloadQueue = [[[NSOperationQueue alloc] init] autorelease];
    [self.downloadQueue setMaxConcurrentOperationCount:2];
}

- (void)cancelAllOperationsWaitUntilFinished:(BOOL)waitUntilFinished
{
    // The current architecture will deadlock if we attempt to wait until done. There are multiple points of failure. 2 in particular are 
    // the URL manager which will not be able to notify the waiting operation that it has a result (because the main thread is blocked waiting)
    // and the fact that performWithBook does a dispatch_sync to the main thread.
    // Because of these issues here and in the recommendations manager, waitUntilFinished is disabled. The correct pattern is to
    // Allow opeations to complete concurrently but since the core data stack may have been cleaned up, any managed object acces
    // *Must* be wrapped in a check for cancellation
    NSAssert(waitUntilFinished == NO, @"The current architecture doesn't support waitUntilFinished");
    
    @synchronized(self) {
        [self.processingQueue cancelAllOperations];    
        [self.downloadQueue cancelAllOperations];
        
        if (waitUntilFinished) {
            [self.processingQueue waitUntilAllOperationsAreFinished];
            [self.downloadQueue waitUntilAllOperationsAreFinished];
        }
        
        self.processingQueue = nil;
        self.downloadQueue = nil;
        
        [self createProcessingQueues];
        
        [self.currentlyProcessingIsbns removeAllObjects];
    }
}

- (void)cancelAllOperationsForIsbn:(NSString *)isbn
                 waitUntilFinished:(BOOL)waitUntilFinished
{
    @synchronized(self) {
        if (isbn) {
            NSArray *allOps = [[self.processingQueue operations] arrayByAddingObjectsFromArray:[self.downloadQueue operations]];
            
            for (SCHRecommendationOperation *op in allOps) {
                if ([op.isbn isEqual:isbn] == YES) {
                    [op cancel];
                    if (waitUntilFinished == YES) {
                        [op waitUntilFinished];
                    }                
                    break;
                }
            }
            
            
            if ([self.currentlyProcessingIsbns containsObject:isbn]) {
                [self.currentlyProcessingIsbns removeObject:isbn];
            }
        }
    }
}

#pragma mark - Recommendation State Check

- (void)beginProcessingForRecommendationItems:(NSArray *)recommendationItems
{
    dispatch_block_t processBlock = ^{
        [self processRecommendationItems:recommendationItems forcePendingItemsToProcess:YES];
    };
    
    if ([NSThread isMainThread]) {
        processBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), processBlock);
    }
}

- (void)processRecommendationItems:(NSArray *)recommendationItems forcePendingItemsToProcess:(BOOL)force
{
    NSAssert([NSThread isMainThread], @"processRecommendationItems must run on main thread");

    NSMutableSet *isbnsToBeIndividuallyProcessed = [NSMutableSet set];
    NSMutableSet *isbnsToBeBatchProcessed = [NSMutableSet set];
    
	for (SCHAppRecommendationItem *recommendationItem in recommendationItems) {
        BOOL batchProcess = NO;
        
        if (force && ![self isbnIsProcessing:[recommendationItem ContentIdentifier]] && ([recommendationItem processingState] == kSCHAppRecommendationProcessingStateWaitingOnUserAction)) {
            [recommendationItem setProcessingState:kSCHAppRecommendationProcessingStateNoMetadata];
        }
        
        if ([self recommendationNeedsProcessing:recommendationItem batch:&batchProcess]) {
            if (batchProcess) {
                [isbnsToBeBatchProcessed addObject:[recommendationItem ContentIdentifier]];
            } else {
                [isbnsToBeIndividuallyProcessed addObject:[recommendationItem ContentIdentifier]];
            }
        }
    }
    
    NSArray *allIsbnsToBeBatchProcessed = [isbnsToBeBatchProcessed allObjects];
    
    if ([allIsbnsToBeBatchProcessed count]) {
        NSMutableArray *batchedIsbns = [NSMutableArray arrayWithCapacity:kSCHRecommendationsManagerBatchSize];
        for (int i = 0; i < [allIsbnsToBeBatchProcessed count]; i++) {
            [batchedIsbns addObject:[allIsbnsToBeBatchProcessed objectAtIndex:i]];
            
            if ((i != 0) && (i % kSCHRecommendationsManagerBatchSize == 0)) {
                [self processIsbns:batchedIsbns];
                [batchedIsbns removeAllObjects];
            }
        }
        
        if ([batchedIsbns count]) {
            [self processIsbns:batchedIsbns];
            [batchedIsbns removeAllObjects];
        }
    }
               	
    for (NSString *isbn in isbnsToBeIndividuallyProcessed) {
        [self processIsbn:isbn];
    }
}

- (void)checkStateForRecommendation:(SCHAppRecommendationItem *)recommendationItem
{
    NSAssert([NSThread isMainThread], @"checkStateForRecommendation must run on main thread");

    if (recommendationItem != nil && [self recommendationNeedsProcessing:recommendationItem batch:NULL]) {
        [self processIsbn:recommendationItem.ContentIdentifier];
    }
}

- (BOOL)recommendationNeedsProcessing:(SCHAppRecommendationItem *)recommendationItem batch:(BOOL *)batchProcess
{
    BOOL needsProcessing = NO;
    
    if (batchProcess) {
        *batchProcess = NO;
    }
    
    if (![self isbnIsProcessing:[recommendationItem ContentIdentifier]]) {        
        if (recommendationItem != nil) {
            switch ([recommendationItem processingState]) {
                case kSCHAppRecommendationProcessingStateURLsNotPopulated:
                case kSCHAppRecommendationProcessingStateCachedCoverError:    
                case kSCHAppRecommendationProcessingStateThumbnailError:      
                case kSCHAppRecommendationProcessingStateUnspecifiedError:    
                case kSCHAppRecommendationProcessingStateInvalidRecommendation:
                case kSCHAppRecommendationProcessingStateWaitingOnUserAction:
                case kSCHAppRecommendationProcessingStateComplete:      
                    needsProcessing = NO;
                    break;
                case kSCHAppRecommendationProcessingStateDownloadFailed:     
                case kSCHAppRecommendationProcessingStateNoCover:
                case kSCHAppRecommendationProcessingStateNoThumbnails:
                    needsProcessing = YES;
                    break;
                case kSCHAppRecommendationProcessingStateNoMetadata:
                    if (batchProcess) {
                        *batchProcess = YES;
                    }
                    needsProcessing = YES;
                    break;
            }
        }
    }
    
	return needsProcessing;

}

- (BOOL)isbnNeedsProcessing:(NSString *)isbn
{
    NSAssert([NSThread isMainThread], @"isbnNeedsProcessing must run on main thread");
    SCHAppRecommendationItem *recommendationItem = [self appRecommendationForIsbn:isbn];
    
    return [self recommendationNeedsProcessing:recommendationItem batch:NULL];
}

#pragma mark - Processing

- (BOOL)isbnIsProcessing:(NSString *)isbn
{
    @synchronized(self.currentlyProcessingIsbns) {
        return [self.currentlyProcessingIsbns containsObject:isbn];
    }
}

- (void)setProcessing:(BOOL)processing forIsbn:(NSString *)isbn
{
    @synchronized(self.currentlyProcessingIsbns) {
        if (processing) {
            if (isbn != nil &&
                ![self.currentlyProcessingIsbns containsObject:isbn]) {
                [self.currentlyProcessingIsbns addObject:isbn];
            }
            
        } else if (isbn != nil) {
            [self.currentlyProcessingIsbns removeObject:isbn];
        }
    }
}

- (void)processIsbns:(NSArray *)isbns
{
    // Only supported batch operation is recommendationurl requests but should still check
    NSMutableArray *noURLsBatch = [NSMutableArray array];
    NSMutableArray *invalidBatch = [NSMutableArray array];
    
    for (NSString *isbn in isbns) {
        SCHAppRecommendationItem *item = [self appRecommendationForIsbn:isbn];
        
        if (![self isbnIsProcessing:isbn]) {
            switch (item.processingState) {
                case kSCHAppRecommendationProcessingStateNoMetadata:
                    [noURLsBatch addObject:isbn];
                    break;
                default:
                    NSLog(@"WARNING: Batch processing attempted for isbn: %@ in unbatchable state: %d", isbn, [item processingState]);
                    [invalidBatch addObject:isbn];
                    break;
            }
        } else {
            NSLog(@"Warning: ISBN requested batch processing whilst already processing: %@", isbn);
        }
    }
    
    if ([noURLsBatch count]) {
        SCHRecommendationURLRequestOperation *urlOp = [[SCHRecommendationURLRequestOperation alloc] init];
        [urlOp setMainThreadManagedObjectContext:self.managedObjectContext];
        urlOp.isbns = noURLsBatch;
        
        [urlOp setNotCancelledCompletionBlock:^{
            for (NSString *isbn in noURLsBatch) {
                [self redispatchIsbn:isbn];
            }
        }];
        
        [self.processingQueue addOperation:urlOp];
        [urlOp release];
    }
    
    for (NSString *isbn in invalidBatch) {
        [self processIsbn:isbn];
    }
}

- (void)processIsbn:(NSString *)isbn
{
    if ([self isbnIsProcessing:isbn]) {
        NSLog(@"Warning: ISBN requested batch processing whilst already processing: %@", isbn);
        return;
    }
    
    SCHAppRecommendationItem *item = [self appRecommendationForIsbn:isbn];
    
    if (item != nil) {
        switch ([item processingState]) {
            case kSCHAppRecommendationProcessingStateWaitingOnUserAction:
                // waiting for the user to access recommendations
                return;
            case kSCHAppRecommendationProcessingStateNoMetadata:
            { 
                SCHRecommendationURLRequestOperation *urlOp = [[SCHRecommendationURLRequestOperation alloc] init];
                [urlOp setMainThreadManagedObjectContext:self.managedObjectContext];
                urlOp.isbns = [NSArray arrayWithObject:isbn];
                
                [urlOp setNotCancelledCompletionBlock:^{
                    [self postRecommendationStateUpdate:isbn];
                    [self redispatchIsbn:isbn];
                }];
                
                [self.processingQueue addOperation:urlOp];
                [urlOp release];
                return;
            }
            case kSCHAppRecommendationProcessingStateNoCover:
            {	
                if (![SCHRecommendationManager urlIsValid:item.CoverURL]) {
                    [item setProcessingState:kSCHAppRecommendationProcessingStateNoMetadata];
                    [self redispatchIsbn:isbn];
                    return;
                }
                
                // create cover image download operation
                SCHRecommendationDownloadCoverOperation *downloadOp = [[SCHRecommendationDownloadCoverOperation alloc] init];
                [downloadOp setMainThreadManagedObjectContext:self.managedObjectContext];
                downloadOp.isbn = isbn;
                // the book will be redispatched on completion
                [downloadOp setNotCancelledCompletionBlock:^{
                    [self redispatchIsbn:isbn];
                }];
                
                    [self.downloadQueue addOperation:downloadOp];
                [downloadOp release];                
                return;
            }
            case kSCHAppRecommendationProcessingStateNoThumbnails:
            {
                SCHRecommendationThumbnailOperation *thumbOp = [[SCHRecommendationThumbnailOperation alloc] init];
                [thumbOp setMainThreadManagedObjectContext:self.managedObjectContext];
                thumbOp.isbn = isbn;
                
                [thumbOp setNotCancelledCompletionBlock:^{
                    [self postRecommendationStateUpdate:isbn];
                    [self redispatchIsbn:isbn];
                }];
                
                [self.processingQueue addOperation:thumbOp];

                [thumbOp release];
                return;
            }
            case kSCHAppRecommendationProcessingStateCachedCoverError:  
            case kSCHAppRecommendationProcessingStateThumbnailError:      
            case kSCHAppRecommendationProcessingStateUnspecifiedError:               
            case kSCHAppRecommendationProcessingStateComplete: 
            case kSCHAppRecommendationProcessingStateDownloadFailed:  
            case kSCHAppRecommendationProcessingStateURLsNotPopulated:
            case kSCHAppRecommendationProcessingStateInvalidRecommendation:
            {
                // Do nothing until the sync kicks off again or the user initiates an action
                // Prefer explicitly listing these state to just having a default because it catches
                // Unhandled cases at compile time
                return;
            }
        }
	}
}
            
- (void)redispatchIsbn:(NSString *)isbn
{    
    dispatch_block_t redispatchBlock = ^{
        if ([self isbnNeedsProcessing:isbn]) {
            [self processIsbn:isbn];
        }
    };
    
    if ([NSThread isMainThread]) {
        redispatchBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), redispatchBlock);
    }
}

#pragma mark - Notification handlers

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

- (void)enterBackground
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
        // if there's already a background monitoring task, then return - the existing one will work
        if (self.backgroundTask && self.backgroundTask != UIBackgroundTaskInvalid) {
            return;
        }
        
		if (([self.processingQueue operationCount] > 0) || ([self.downloadQueue operationCount] > 0)) {
			NSLog(@"Recommendations processing needs more time - going into the background.");
			
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                if(self.backgroundTask != UIBackgroundTaskInvalid) {
                    NSLog(@"Ran out of time. Pausing queue.");
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }
            }];
			
            dispatch_queue_t taskcompletion = dispatch_get_global_queue(
																		DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			
			dispatch_async(taskcompletion, ^{
				NSLog(@"Emptying operation queues...");
                if(self.backgroundTask != UIBackgroundTaskInvalid) {
                    [self.processingQueue waitUntilAllOperationsAreFinished];
                    [self.downloadQueue waitUntilAllOperationsAreFinished];
					NSLog(@"operation queues are finished!");
                    if(self.backgroundTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                    } else {
                        NSLog(@"App came to foreground in the meantime");
                    }
                }
            });
        }
	}
    
    // if the user kills the app while we are performing background tasks the 
    // DidEnterBackground notification is called again, so we disable it and 
    // enable it in the foreground
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];        
}

- (void)enterForeground
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(enterBackground) 
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];	
    
	NSLog(@"Entering foreground - quitting background task.");
	if(self.backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
		self.backgroundTask = UIBackgroundTaskInvalid;
	}		
}

#pragma mark - SCHAppRecommendationItem vending

- (SCHAppRecommendationItem *)appRecommendationForIsbn:(NSString *)isbn
{
    NSAssert([NSThread isMainThread], @"appRecommendation called not on main thread");
    
    SCHAppRecommendationItem *ret = nil;
    
    if (isbn) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier = %@", isbn]];
        
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
        [fetchRequest release], fetchRequest = nil;
        if (result == nil) {
            NSLog(@"Unresolved error fetching recommendation %@, %@", error, [error userInfo]);
        } else if ([result count] == 0) {
            NSLog(@"Could not fetch recoomendation with isbn %@", isbn);
        } else {
            ret = [result lastObject];
        }
    }
    
    return ret;
}

- (void)postRecommendationStateUpdate:(NSString *)isbn
{
    dispatch_block_t notify = ^{
        if (isbn != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:isbn
                                                                 forKey:kSCHAppRecommendationItemISBN];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHRecommendationStateUpdateNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), notify);
    } else {
        notify();
    }
}

#pragma mark - Class methods

+ (SCHRecommendationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		sharedManager = [[SCHRecommendationManager alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterForeground) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];
    });
	
	return sharedManager;
}

+ (BOOL)urlIsValid:(NSString *)urlString
{
    return (urlString && ![SCHRecommendationManager urlHasExpired:urlString]);
}

+ (BOOL)urlHasExpired:(NSString *)urlString
{
    BOOL ret = NO;
    
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *expires = [[url queryParameters] objectForKey:@"Expires"];
        if (expires) {
            NSDate *expiresDate = [NSDate dateWithTimeIntervalSince1970:[expires integerValue]];
            
            if ([expiresDate earlierDate:[NSDate serverDate]] == expiresDate) {
                ret = YES;
            }
        }
    }
    
    return ret;
}

@end
