//
//  SCHVersionDownloadManager.m
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHVersionDownloadManager.h"

#import "Reachability.h"
#import "SCHVersionManifestOperation.h"
#import "SCHVersionManifestEntry.h"

// Constants
NSString * const SCHVersionDownloadManagerChangedNotification = @"SCHVersionDownloadManagerChangedNotification";

#pragma mark - Class Extension

@interface SCHVersionDownloadManager ()

// the background task ID for background processing
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;

// operation queue - to perform the dictionary download
@property (nonatomic, readwrite, retain) NSOperationQueue *versionDownloadQueue;

@property (nonatomic, assign) SCHVersionDownloadManagerProcessingState state;

// local reachability - used to determine the status of the network connection
@property (nonatomic, readwrite, retain) Reachability *wifiReach;

// timer for preventing false starts
@property (nonatomic, readwrite, retain) NSTimer *startTimer;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void) enterBackground;
- (void) enterForeground;

// checks to see if we're on wifi and the processing manager is idle
// if so, spawn a timer to begin processing
// the timer prevents rapid starting and stopping of the dictionary download/processing
- (void)checkOperatingStateImmediately:(BOOL)immediately;

- (void)process;

- (SCHVersionManifestEntry *)nextManifestEntryUpdateForCurrentVersion;

@end

#pragma mark -

@implementation SCHVersionDownloadManager

@synthesize manifestUpdates;
@synthesize version;
@synthesize isProcessing;
@synthesize backgroundTask;
@synthesize versionDownloadQueue;
@synthesize state;
@synthesize wifiReach;
@synthesize startTimer;

#pragma mark -
#pragma mark Object Lifecycle

- (id)init
{
	if ((self = [super init])) {
		versionDownloadQueue = [[NSOperationQueue alloc] init];
		[versionDownloadQueue setMaxConcurrentOperationCount:1];
        state = SCHVersionDownloadManagerProcessomgStateNeedsManifest;
		wifiReach = [[Reachability reachabilityForInternetConnection] retain];        
    }
	
	return self;
}

- (void)dealloc
{
    [manifestUpdates release], manifestUpdates = nil;
    [version release], version = nil;
	[versionDownloadQueue release], versionDownloadQueue = nil;
	[wifiReach stopNotifier];
	[wifiReach release], wifiReach = nil;
    [startTimer invalidate];
    [startTimer release], startTimer = nil;
    
	[super dealloc];
}

#pragma mark - Default Manager Object

static SCHVersionDownloadManager *sharedManager = nil;

+ (SCHVersionDownloadManager *)sharedVersionManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHVersionDownloadManager alloc] init];
        
		// notifications for changes in reachability
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(reachabilityNotification:) 
													 name:kReachabilityChangedNotification 
												   object:nil];
		
		// background notifications
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterForeground) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];	
                
		[sharedManager.wifiReach startNotifier];
	} 
	
	return sharedManager;
}

#pragma mark -
#pragma mark Background Processing Methods

- (void)enterBackground
{
    // if there's already a background monitoring task, then return - the existing one will work
    if (self.backgroundTask && self.backgroundTask != UIBackgroundTaskInvalid) {
        return;
    }
    
    if ((self.versionDownloadQueue && [self.versionDownloadQueue operationCount]) ) {
        NSLog(@"Dictionary download needs more time - going into the background.");
        
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            if(self.backgroundTask != UIBackgroundTaskInvalid) {
                NSLog(@"Ran out of time. Pausing queue.");
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }
        }];
        
        dispatch_queue_t taskcompletion = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(taskcompletion, ^{
            NSLog(@"Emptying operation queues...");
            if(self.backgroundTask != UIBackgroundTaskInvalid) {
                [self.versionDownloadQueue waitUntilAllOperationsAreFinished];
                NSLog(@"dictionary download queue is finished!");
                if(self.backgroundTask != UIBackgroundTaskInvalid) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                } else {
                    NSLog(@"App came to foreground in the meantime");
                }
            }
        });
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
	
    [self checkOperatingStateImmediately:NO]; 
}


#pragma mark -
#pragma mark Reachability notification

- (void)reachabilityNotification:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
	switch (netStatus)
    {
        case NotReachable:
        {
            break;
        }
        case ReachableViaWWAN:
        case ReachableViaWiFi:            
		{
            [self checkOperatingStateImmediately:NO];
			break;
		}
    }
}

#pragma mark -
#pragma mark Check Operating State

- (void)checkOperatingStateImmediately:(BOOL)immediately
{    
    // start the countdown from 3 seconds again
    if (self.startTimer && [self.startTimer isValid]) {
        [self.startTimer invalidate];
        self.startTimer = nil; 
    } 
    
    NSLog(@"********* Starting timer...");
    if (immediately) {
        [self process];
    } else {
        self.startTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                           target:self
                                                         selector:@selector(process)
                                                         userInfo:nil
                                                          repeats:NO];
    }

    [self.versionDownloadQueue cancelAllOperations];
}

#pragma mark -
#pragma mark Processing Methods

- (SCHVersionManifestEntry *)nextManifestEntryUpdateForCurrentVersion
{
    NSString *currentVersion = [self version];
    
    SCHVersionManifestEntry *entryUpdateForCurrentVersion = nil;
    SCHVersionManifestEntry *defaultEntryUpdate = nil;
    
    for (SCHVersionManifestEntry *anEntry in self.manifestUpdates) {
        //NSLog(@"from: (%@) to: (%@) URL: %@", anEntry.fromVersion, anEntry.toVersion, anEntry.url);

        if ([anEntry fromVersion]) {
            if ([[anEntry fromVersion] isEqualToString:currentVersion]) {
                entryUpdateForCurrentVersion = anEntry;
                break;
            }
        } else {
            defaultEntryUpdate = anEntry;
        }
    }
    
    if (entryUpdateForCurrentVersion) {
        return entryUpdateForCurrentVersion;
    } else {
        return defaultEntryUpdate;
    }
}

- (void)process
{
	if ([NSThread currentThread] != [NSThread mainThread]) {
		[self performSelectorOnMainThread:@selector(process) withObject:nil waitUntilDone:NO];
		return;
	}
	    
    if (self.isProcessing == YES) {
        NSLog(@"Process version called, but version is already processing.");
        return;
    }
        
    if ([self.versionDownloadQueue operationCount]) {
        NSLog(@"Trying to process a new operation whilst there are remaining operations");
        [self.versionDownloadQueue cancelAllOperations];
    }
	
	NSLog(@"**** Calling process with state %d...", self.state);
    
	switch (self.state) {
        case SCHVersionDownloadManagerProcessingStateParseError:
        case SCHVersionDownloadManagerProcessingStateError:            
            self.state = SCHVersionDownloadManagerProcessomgStateNeedsManifest;
            [self checkOperatingStateImmediately:NO];
            break;
        case SCHVersionDownloadManagerProcessingStateUnknown:
            NSLog(@"The version manager has an unknown state!");
            break;
        case SCHVersionDownloadManagerProcessomgStateNeedsManifest:
			NSLog(@"needs version manifest...");
            
			// create manifest processing operation
			SCHVersionManifestOperation *manifestOp = [[SCHVersionManifestOperation alloc] init];
            
            NSLog(@"Manifest op: %@", manifestOp);
			
			// version processing is redispatched on completion
			[manifestOp setNotCancelledCompletionBlock:^{
				[self process];
			}];
			
			// add the operation to the queue
			[self.versionDownloadQueue addOperation:manifestOp];
			[manifestOp release];
			return;
			break;
        case SCHVersionDownloadManagerProcessingStateManifestVersionCheck:
			NSLog(@"needs manifest version check...");
            
            BOOL processUpdate = NO;
            SCHVersionManifestEntry *entry = [self nextManifestEntryUpdateForCurrentVersion];
            
            NSString *currentVersion = [self version];
            
            if (currentVersion) {
                if ([currentVersion compare:[entry toVersion] options:NSNumericSearch] == NSOrderedAscending) {
                    processUpdate = YES;
                }
            } else {
                processUpdate = YES;
            }
            
            if (processUpdate) {
                if (entry) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHVersionDownloadManagerChangedNotification 
                                                                        object:nil 
                                                                      userInfo:[NSDictionary dictionaryWithObject:[entry toVersion] forKey:@"toVersion"]];
                }
                [self process];
            } else {
                [self process];
            }
            
			return;
			break;
        default:
            break;
    }            
}

#pragma mark -
#pragma mark App Version

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark - Update Check

- (void)checkVersion
{    
    [self process];
}
         
@end
