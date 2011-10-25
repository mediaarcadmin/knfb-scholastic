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

NSString * const kSCHSampleBooksManifestURL = @"http://bits.blioreader.com/partners/Scholastic/SampleBookshelf/SampleManifest.xml";

typedef enum {
	kSCHSampleBooksProcessingStateError = 0,
    kSCHSampleBooksProcessingStateNotStarted,
    kSCHSampleBooksProcessingStateInProgress
} SCHSampleBooksProcessingState;

@interface SCHSampleBooksImporter()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, assign) SCHSampleBooksProcessingState processingState;
@property (nonatomic, retain) NSOperationQueue *processingQueue;
@property (nonatomic, retain) Reachability *reachabilityNotifier;
@property (nonatomic, copy) NSURL *manifestURL;
@property (nonatomic, copy) SCHSampleBooksProcessingFailureBlock failureBlock;

- (void)checkState;
- (BOOL)isConnected;
- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)note;
- (void)enterBackground:(NSNotification *)note;
- (void)enterForeground:(NSNotification *)note;
- (BOOL)save:(NSError **)error;
- (void)start;
- (void)reset;
- (void)perfomFailureBlockOnMainThreadWithReason:(NSString *)failureReason;
+ (BOOL)stateIsReadyToBegin:(SCHSampleBooksProcessingState)state;

@end

@implementation SCHSampleBooksImporter

@synthesize mainThreadManagedObjectContext;
@synthesize persistentStoreCoordinator;

@synthesize backgroundTask;
@synthesize processingState;
@synthesize processingQueue;
@synthesize reachabilityNotifier;
@synthesize manifestURL;
@synthesize failureBlock;

- (void)dealloc
{
    [reachabilityNotifier stopNotifier];
    [reachabilityNotifier release], reachabilityNotifier = nil;

    [processingQueue cancelAllOperations];
    [processingQueue release], processingQueue = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                               object:nil];	 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];			
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
    
    [mainThreadManagedObjectContext release], mainThreadManagedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [manifestURL release], manifestURL = nil;
    [failureBlock release], failureBlock = nil;

    [super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		processingQueue = [[NSOperationQueue alloc] init];
		[processingQueue setMaxConcurrentOperationCount:1];
	        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];
        
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

- (void)importSampleBooksFromManifestURL:(NSURL *)url failureBlock:(SCHSampleBooksProcessingFailureBlock)aFailureBlock
{
    [self cancel];
    
    self.manifestURL = url;
    self.failureBlock = aFailureBlock;
    
    [self start];
}

- (void)checkState
{
	if ([self isConnected] && [SCHSampleBooksImporter stateIsReadyToBegin:self.processingState] && self.manifestURL) {
        [self start];
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
    
    self.manifestURL = nil;
    self.failureBlock = nil;  
}

- (void)start
{
    switch (self.processingState) {
        case kSCHSampleBooksProcessingStateError:
        case kSCHSampleBooksProcessingStateNotStarted:
        {
            self.reachabilityNotifier = [Reachability reachabilityForInternetConnection];
            
            SCHSampleBooksManifestOperation *manifestOp = [[SCHSampleBooksManifestOperation alloc] init];
            manifestOp.manifestURL = self.manifestURL;
            manifestOp.processingDelegate = self;
            [self.processingQueue addOperation:manifestOp];
            [manifestOp release];
            break;

        }
        default:
            break;
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

- (void)setCompletedWithSuccess:(BOOL)success failureReason:(NSString *)reason
{
    if (success) {
        [self reset];
    } else {
        [self perfomFailureBlockOnMainThreadWithReason:reason];
    }
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
	
	[self checkState];
}

- (BOOL)save:(NSError **)error
{
    __block BOOL rtn;
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSError *localError = nil;
        rtn = [self.mainThreadManagedObjectContext save:&localError];
        *error = [localError retain];
    });
    [*error autorelease];
    return rtn;
}

#pragma mark -
#pragma mark Reachability

- (void)reachabilityNotification:(NSNotification *)note
{
    if (self.reachabilityNotifier == [note object]) {
        if ([self isConnected]) {
            [self checkState];
        }
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
    return (state == kSCHSampleBooksProcessingStateError) || (state == kSCHSampleBooksProcessingStateNotStarted);
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

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    [self.processingQueue cancelAllOperations];
    self.mainThreadManagedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

@end
