//
//  SCHDictionaryManager.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryManager.h"
#import "Reachability.h"
#import "SCHProcessingManager.h"
#import "SCHDictionaryManifestOperation.h"
#import "SCHDictionaryFileDownloadOperation.h"
#import "SCHDictionaryFileUnarchiveOperation.h"
#import "SCHDictionaryFileParseOperation.h"
#import "SCHBookManager.h"
#import "SCHAppDictionaryState.h"

#pragma mark Class Extension

@interface SCHDictionaryManager()

// the background task ID for background processing
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

// operation queue - to perform the dictionary download
@property (readwrite, retain) NSOperationQueue *dictionaryDownloadQueue;

// local reachability - used to determine the status of the network connection
@property (readwrite, retain) Reachability *wifiReach;

// timer for preventing false starts
@property (readwrite, retain) NSTimer *startTimer;

// properties indicating wifi availability/if the connection is idle
@property BOOL wifiAvailable;
@property BOOL connectionIdle;

// check current reachability state
- (void) reachabilityCheck: (Reachability *) curReach;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void) enterBackground;
- (void) enterForeground;

// checks to see if we're on wifi and the processing manager is idle
// if so, spawn a timer to begin processing
// the timer prevents rapid starting and stopping of the dictionary download/processing
- (void) checkOperatingState;
- (void) processDictionary;

// the core data object for dictionary state - creates a new one if needed
- (SCHAppDictionaryState *) appDictionaryState;

@end

#pragma mark -

@implementation SCHDictionaryManager

@synthesize backgroundTask, dictionaryDownloadQueue;
@synthesize wifiReach, startTimer, wifiAvailable, connectionIdle;
@synthesize isProcessing;
@synthesize dictionaryURL;

#pragma mark -
#pragma mark Object Lifecycle

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.dictionaryDownloadQueue = nil;
	[self.wifiReach stopNotifier];
	self.wifiReach = nil;
	[super dealloc];
}

- (id) init
{
	if ((self = [super init])) {
		self.dictionaryDownloadQueue = [[NSOperationQueue alloc] init];
		[self.dictionaryDownloadQueue setMaxConcurrentOperationCount:1];
		
		self.wifiAvailable = NO;
		self.connectionIdle = NO;
		
		self.wifiReach = [Reachability reachabilityForInternetConnection];
		
		// check for the core data dictionary object
		
	
	}
	
	return self;
}

#pragma mark -
#pragma mark Default Manager Object

static SCHDictionaryManager *sharedManager = nil;

+ (SCHDictionaryManager *) sharedDictionaryManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHDictionaryManager alloc] init];
		
		[sharedManager reachabilityCheck:sharedManager.wifiReach];
		
		// notifications for changes in reachability
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(reachabilityNotification:) 
													 name:kReachabilityChangedNotification 
												   object:nil];

		
		// notification for processing manager being idle
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(connectionBecameIdle:) 
													 name:kSCHProcessingManagerConnectionIdle
												   object:nil];			
		
		
		// notification for processing manager starting work
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(connectionBecameBusy:) 
													 name:kSCHProcessingManagerConnectionBusy
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
#pragma mark Dictionary Directory

+ (NSString *)dictionaryDirectory 
{
	return([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/Dictionary"]);
}

#pragma mark -
#pragma mark Background Processing Methods

- (void) enterBackground
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
		if ((self.dictionaryDownloadQueue && [self.dictionaryDownloadQueue operationCount]) ) {
			NSLog(@"Dictionary download needs more time - going into the background.");
			
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
					[self.dictionaryDownloadQueue waitUntilAllOperationsAreFinished];
					NSLog(@"dictionary download queue is finished!");
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
	
	[sharedManager reachabilityCheck:sharedManager.wifiReach];
}


#pragma mark -
#pragma mark Reachability reactions

- (void) reachabilityNotification: (NSNotification *) note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self reachabilityCheck:curReach];
}

- (void) reachabilityCheck: (Reachability *) curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];

	switch (netStatus)
    {
        case NotReachable:
        case ReachableViaWWAN:
		{
			NSLog(@"Phone network or no network; suspending Dictionary download.");
			self.wifiAvailable = NO;
			break;
		}
        case ReachableViaWiFi:
        {
			NSLog(@"Wifi network; Dictionary download can begin.");
			self.wifiAvailable = YES;
			break;
		}
    }
	
	[self checkOperatingState];
}

#pragma mark -
#pragma mark Processing Manager reactions

- (void) connectionBecameIdle: (NSNotification *) notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not on main thread!");
	NSLog(@"****************** Processing manager became idle! ******************");
	self.connectionIdle = YES;
	[self checkOperatingState];
}

- (void) connectionBecameBusy: (NSNotification *) notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not on main thread!");
	NSLog(@"****************** Processing manager became busy! ******************");
	self.connectionIdle = NO;
	[self checkOperatingState];
}

#pragma mark -
#pragma mark Check Operating State

- (void) checkOperatingState
{
	NSLog(@"*** wifi: %@ connectionIdle: %@ ***", self.wifiAvailable?@"Yes":@"No", self.connectionIdle?@"Yes":@"No");
	
	// if both conditions are met, start the countdown to begin work
	if (self.wifiAvailable && self.connectionIdle) {

		// start the countdown from 10 seconds again
		if (self.startTimer && [self.startTimer isValid]) {
			[self.startTimer invalidate];
			self.startTimer = nil; 
		} 

//		if (!self.startTimer) {
		NSLog(@"********* Starting timer...");
		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:10
														   target:[SCHDictionaryManager sharedDictionaryManager]
														 selector:@selector(processDictionary)
														 userInfo:nil
														  repeats:NO];
//		} else {
//			NSLog(@"********* Timer already exists!");
//		}

	} else {
		// otherwise, cancel work in progress
		NSLog(@"Cancelling operations etc.");
		if (self.startTimer && [self.startTimer isValid]) {
			[self.startTimer invalidate];
			self.startTimer = nil; 
		}
		[self.dictionaryDownloadQueue cancelAllOperations];
	}
}

#pragma mark -
#pragma mark Processing Methods

- (void) processDictionary
{
	if ([NSThread currentThread] != [NSThread mainThread]) {
		[self performSelectorOnMainThread:@selector(processDictionary) withObject:nil waitUntilDone:NO];
		return;
	}
	
	if (!self.wifiAvailable || !self.connectionIdle) {
		return;
	}
	
	NSLog(@"**** Calling processDictionary...");
	switch ([SCHDictionaryManager sharedDictionaryManager].dictionaryState) {
		case SCHDictionaryProcessingStateNeedsManifest:
		{
			NSLog(@"needs manifest...");
			// create manifest processing operation
			SCHDictionaryManifestOperation *manifestOp = [[SCHDictionaryManifestOperation alloc] init];
			
			// dictionary processing is redispatched on completion
			[manifestOp setCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:manifestOp];
			[manifestOp release];
			return;
			break;
		}	
		case SCHDictionaryProcessingStateNeedsDownload:
		{
			NSLog(@"needs download...");
			// create manifest processing operation
			SCHDictionaryFileDownloadOperation *downloadOp = [[SCHDictionaryFileDownloadOperation alloc] init];
			
			// dictionary processing is redispatched on completion
			[downloadOp setCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:downloadOp];
			[downloadOp release];
			return;
			break;
		}	            
        case SCHDictionaryProcessingStateNeedsUnarchiving:
		{
			NSLog(@"needs unarchiving...");
			// create unarchiving processing operation
			SCHDictionaryFileUnarchiveOperation *unarchiveOp = [[SCHDictionaryFileUnarchiveOperation alloc] init];
			
			// dictionary processing is redispatched on completion
			[unarchiveOp setCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:unarchiveOp];
			[unarchiveOp release];
			return;
			break;
        }
        case SCHDictionaryProcessingStateNeedsParsing:
		{
			NSLog(@"needs parsing...");
			// create parsing processing operation
			SCHDictionaryFileParseOperation *parseOp = [[SCHDictionaryFileParseOperation alloc] init];
			
			// dictionary processing is redispatched on completion
			[parseOp setCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:parseOp];
			[parseOp release];
			return;
			break;
        }
		default:
			break;
	}
	
	
}

#pragma mark -
#pragma mark Dictionary State

- (NSString *) dictionaryVersion
{
	SCHAppDictionaryState *state = [[SCHDictionaryManager sharedDictionaryManager] appDictionaryState];
	return [state Version];
}

- (void) setDictionaryVersion:(NSString *) newVersion
{
	SCHAppDictionaryState *state = [[SCHDictionaryManager sharedDictionaryManager] appDictionaryState];
	state.Version = newVersion;
	
	NSError *error = nil;
	[[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] save:&error];
	
	if (error) {
		NSLog(@"Error while saving dictionary version: %@", [error localizedDescription]);
	}
	
}

- (SCHDictionaryProcessingState) dictionaryState
{
	SCHAppDictionaryState *state = [[SCHDictionaryManager sharedDictionaryManager] appDictionaryState];
	return [[state State] intValue];
}

- (void) setDictionaryState:(SCHDictionaryProcessingState) newState
{
	SCHAppDictionaryState *state = [[SCHDictionaryManager sharedDictionaryManager] appDictionaryState];
	state.State = [NSNumber numberWithInt:newState];
	
	NSError *error = nil;
	[[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] save:&error];
	
	if (error) {
		NSLog(@"Error while saving dictionary state: %@", [error localizedDescription]);
	}
}

#pragma mark -
#pragma mark Core Data - App Dictionary State
- (SCHAppDictionaryState *) appDictionaryState
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHAppDictionaryState 
											  inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
    [fetchRequest setEntity:entity];
    
	NSError *error = nil;				
	NSArray *results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	if (error) {
		NSLog(@"error when retrieving app dictionary state: %@", [error localizedDescription]);
		return nil;
	}
	
	if (results && [results count] == 1) {
		return [results objectAtIndex:0];
	} else {
		// otherwise, create a dictionary state object
		SCHAppDictionaryState *newState = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppDictionaryState 
																		inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
		newState.State = [NSNumber numberWithInt:SCHDictionaryProcessingStateNeedsManifest];
		
		NSError *error = nil;
		[[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] save:&error];
		
		if (error) {
			NSLog(@"Error while saving app dictionary state: %@", [error localizedDescription]);
		}
		
		return newState;
	}
}


@end
