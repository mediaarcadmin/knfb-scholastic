//
//  SCHSampleBooksManager.m
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSampleBooksImporter.h"
#import "Reachability.h"
#import "SCHCoreDataHelper.h"
#import "SCHSampleBooksManifestOperation.h"
#import "SCHSyncManager.h"

NSString * const kSCHSampleBooksRemoteManifestURL = @"http://bits.blioreader.com/partners/Scholastic/SampleBookshelf/SampleBookshelfManifest_v2.xml";
NSString * const kSCHSampleBooksLocalManifestFile = @"LocalSamplesManifest.xml";

typedef enum {
	kSCHSampleBooksProcessingStateError = 0,
    kSCHSampleBooksProcessingStateNotStarted,
    kSCHSampleBooksProcessingStateLocalManifestInProgress,
    kSCHSampleBooksProcessingStateLocalManifestComplete,
    kSCHSampleBooksProcessingStateRemoteManifestInProgress
} SCHSampleBooksProcessingState;

@interface SCHSampleBooksImporter()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, assign) SCHSampleBooksProcessingState processingState;
@property (nonatomic, retain) NSOperationQueue *processingQueue;
@property (nonatomic, retain) Reachability *reachabilityNotifier;
@property (nonatomic, copy) NSURL *remoteManifestURL;
@property (nonatomic, copy) NSURL *localManifestURL;
@property (nonatomic, copy) SCHSampleBooksProcessingSuccessBlock successBlock;
@property (nonatomic, copy) SCHSampleBooksProcessingFailureBlock failureBlock;
@property (nonatomic, retain) NSMutableArray *sampleEntries;

- (BOOL)isConnected;
- (void)enterBackground:(NSNotification *)note;
- (void)enterForeground:(NSNotification *)note;
- (void)checkRemoteState;
- (void)startLocal;
- (void)startRemote;
- (void)reset;
- (void)populateSampleStore;
- (void)perfomSuccessBlockOnMainThread;
- (void)perfomFailureBlockOnMainThreadWithReason:(NSString *)failureReason;
+ (BOOL)stateIsReadyToBegin:(SCHSampleBooksProcessingState)state;

@end

@implementation SCHSampleBooksImporter

@synthesize backgroundTask;
@synthesize processingState;
@synthesize processingQueue;
@synthesize reachabilityNotifier;
@synthesize remoteManifestURL;
@synthesize localManifestURL;
@synthesize successBlock;
@synthesize failureBlock;
@synthesize sampleEntries;

- (void)dealloc
{
    [reachabilityNotifier stopNotifier];
    [reachabilityNotifier release], reachabilityNotifier = nil;

    [processingQueue cancelAllOperations];
    [processingQueue release], processingQueue = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];			
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
    
    [remoteManifestURL release], remoteManifestURL = nil;
    [localManifestURL release], localManifestURL = nil;
    [successBlock release], successBlock = nil;
    [failureBlock release], failureBlock = nil;
    [sampleEntries release], sampleEntries = nil;

    [super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		processingQueue = [[NSOperationQueue alloc] init];
		[processingQueue setMaxConcurrentOperationCount:1];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(reachabilityNotification:) 
													 name:kReachabilityChangedNotification 
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(enterBackground:) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(enterForeground:) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];
    }
	
	return self;
}

- (void)importSampleBooksFromRemoteManifest:(NSURL *)remote 
                              localManifest:(NSURL *)local 
                               successBlock:(SCHSampleBooksProcessingSuccessBlock)aSuccessBlock
                               failureBlock:(SCHSampleBooksProcessingFailureBlock)aFailureBlock 
{
    [self cancel];
    
    self.remoteManifestURL = remote;
    self.localManifestURL = local;
    self.successBlock = aSuccessBlock;
    self.failureBlock = aFailureBlock;
    self.sampleEntries = [NSMutableArray array];
    
    if (self.localManifestURL) {
        [self startLocal];
    } else if (self.remoteManifestURL) {
        self.reachabilityNotifier = [Reachability reachabilityForInternetConnection];
        
        if ([self isConnected] && [SCHSampleBooksImporter stateIsReadyToBegin:self.processingState]) {
            [self startRemote];
        } else {
            [self perfomFailureBlockOnMainThreadWithReason:NSLocalizedString(@"You must be connected to the internet to retrieve the sample eBooks", @"")];
        }
        
    } else {
        [self perfomFailureBlockOnMainThreadWithReason:NSLocalizedString(@"No sample eBooks were found", @"")];
    }
}

- (void)checkRemoteState
{
    self.reachabilityNotifier = [Reachability reachabilityForInternetConnection];

	if ([self isConnected] && [SCHSampleBooksImporter stateIsReadyToBegin:self.processingState]) {
        [self startRemote];
	} else {
		[self.processingQueue cancelAllOperations];
	}
}

- (void)cancel
{
    [self.processingQueue cancelAllOperations];
    [self reset];
}

- (void)reset
{
    self.processingState = kSCHSampleBooksProcessingStateNotStarted;
    
    [self.reachabilityNotifier stopNotifier];
    self.reachabilityNotifier = nil;
    
    self.remoteManifestURL = nil;
    self.localManifestURL = nil;
    self.failureBlock = nil;
    self.sampleEntries = nil;
}
        
- (void)startLocal
{
    self.processingState = kSCHSampleBooksProcessingStateLocalManifestInProgress;
    
    SCHSampleBooksManifestOperation *manifestOp = [[SCHSampleBooksManifestOperation alloc] init];
    manifestOp.manifestURL = self.localManifestURL;
    manifestOp.processingDelegate = self;
    
    __block SCHSampleBooksManifestOperation *opPtr = manifestOp;
    
    [manifestOp setCompletionBlock:^{
        if (![opPtr isCancelled]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.sampleEntries addObjectsFromArray:opPtr.sampleEntries];
                self.processingState = kSCHSampleBooksProcessingStateLocalManifestComplete;
                
                self.reachabilityNotifier = [Reachability reachabilityForInternetConnection];

                if ([self isConnected]) {
                    [self startRemote];
                } else {
                    [self populateSampleStore];
                    [self reset];
                }
            });
        }
    }];
    
    [self.processingQueue addOperation:manifestOp];
    [manifestOp release];      
}

- (void)startRemote
{    
    SCHSampleBooksManifestOperation *manifestOp = [[SCHSampleBooksManifestOperation alloc] init];
    manifestOp.manifestURL = self.remoteManifestURL;
    manifestOp.processingDelegate = self;
    
    __block SCHSampleBooksManifestOperation *opPtr = manifestOp;
    
    [manifestOp setCompletionBlock:^{
        if (![opPtr isCancelled]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.sampleEntries addObjectsFromArray:opPtr.sampleEntries];
                [self populateSampleStore];
                [self reset];
            });
        }
    }];

    
    [self.processingQueue addOperation:manifestOp];
    [manifestOp release];
}
                          
- (void)populateSampleStore {
    if ([self.sampleEntries count]) {
        if ([[SCHSyncManager sharedSyncManager] populateSampleStoreFromManifestEntries:self.sampleEntries]) {
            [self perfomSuccessBlockOnMainThread];
        } else {
            [self importFailedWithReason:NSLocalizedString(@"Unable to populate the store with the sample eBooks", @"")];
        }
    } else {
        [self importFailedWithReason:NSLocalizedString(@"No sample eBooks were found", @"")];
    }
}

- (void)perfomSuccessBlockOnMainThread
{    
    if (self.successBlock != nil) {
        SCHSampleBooksProcessingSuccessBlock handler = Block_copy(self.successBlock);
        self.successBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler();
        });
        Block_release(handler);
    }
}

- (void)perfomFailureBlockOnMainThreadWithReason:(NSString *)failureReason
{
    self.processingState = kSCHSampleBooksProcessingStateError;

    if (self.failureBlock != nil) {
        SCHSampleBooksProcessingFailureBlock handler = Block_copy(self.failureBlock);
        self.failureBlock = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(failureReason);
        });
        Block_release(handler);
    }
}

- (void)importFailedWithReason:(NSString *)reason
{
    [self.processingQueue cancelAllOperations];
    
    if ([self.sampleEntries count]) {
        // We have some samples, we might as well use them
        [self populateSampleStore];
    } else {
        [self perfomFailureBlockOnMainThreadWithReason:reason];
    }
    
    [self reset];
}

- (void)enterBackground:(NSNotification *)note
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
		if ((self.processingQueue && [self.processingQueue operationCount]) ) {
			NSLog(@"Sample books processing needs more time - going into the background.");
			
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.backgroundTask != UIBackgroundTaskInvalid) {
						NSLog(@"Ran out of time. Pausing queue.");
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
			
            dispatch_queue_t taskcompletion = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			
			dispatch_async(taskcompletion, ^{

                if(self.backgroundTask != UIBackgroundTaskInvalid) {
					[self.processingQueue waitUntilAllOperationsAreFinished];
					NSLog(@"Sample books processing queue is finished!");
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }
            });
        }
	}
}

- (void)enterForeground:(NSNotification *)note
{
    if(self.backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
		self.backgroundTask = UIBackgroundTaskInvalid;
	}		
	
	[self checkRemoteState];
}

#pragma mark -
#pragma mark Reachability

- (void)reachabilityNotification:(NSNotification *)note
{
    if (self.reachabilityNotifier == [note object]) {
        [self checkRemoteState];
    }
}

- (BOOL)isConnected
{
	BOOL ret = YES;
    NetworkStatus netStatus = [self.reachabilityNotifier currentReachabilityStatus];
    
	switch (netStatus)
    {
        case NotReachable:
            ret = NO;
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
        default:
		{
			ret = YES;
            break;
		}
    }
    
    return ret;
}

#pragma mark - State Checking
  
+ (BOOL)stateIsReadyToBegin:(SCHSampleBooksProcessingState)state
{
    return (state == kSCHSampleBooksProcessingStateError) || (state == kSCHSampleBooksProcessingStateNotStarted) || (state == kSCHSampleBooksProcessingStateLocalManifestComplete);
}
                               
#pragma mark - Singleton Instance method

+ (SCHSampleBooksImporter *)sharedImporter
{
    static dispatch_once_t pred;
    static SCHSampleBooksImporter *sharedManager = nil;
    
    dispatch_once(&pred, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
	
    return sharedManager;
}

@end
