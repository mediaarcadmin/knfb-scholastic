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
#import "SCHBookManager.h"
#import "SCHAppDictionaryState.h"
#import "SCHDictionaryManifestOperation.h"
#import "SCHDictionaryFileDownloadOperation.h"
#import "SCHDictionaryFileUnzipOperation.h"
#import "SCHDictionaryEntryParseOperation.h"

#import "SCHDictionaryWordForm.h"
#import "SCHDictionaryEntry.h"

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

// lock preventing multiple accesses of save simulaneously
@property (nonatomic, retain) NSLock *threadSafeMutationLock;

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

- (BOOL)save:(NSError **)error;

@end


// mutation count - additional check for thread safety
static int mutationCount = 0;


#pragma mark -

@implementation SCHDictionaryManager

@synthesize backgroundTask, dictionaryDownloadQueue;
@synthesize wifiReach, startTimer, wifiAvailable, connectionIdle;
@synthesize isProcessing;
@synthesize dictionaryURL;
@synthesize threadSafeMutationLock;

#pragma mark -
#pragma mark Object Lifecycle

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.dictionaryDownloadQueue = nil;
	[self.wifiReach stopNotifier];
	self.wifiReach = nil;
    self.threadSafeMutationLock = nil;
	[super dealloc];
}

- (id) init
{
	if ((self = [super init])) {
		self.dictionaryDownloadQueue = [[NSOperationQueue alloc] init];
		[self.dictionaryDownloadQueue setMaxConcurrentOperationCount:1];
		
		self.wifiAvailable = YES;
		self.connectionIdle = YES;
		
		self.wifiReach = [Reachability reachabilityForInternetConnection];
        self.threadSafeMutationLock = [[NSLock alloc] init];
		
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
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(mergeChanges:) 
													 name:NSManagedObjectContextDidSaveNotification
												   object:nil];		
		
        
        
		[sharedManager.wifiReach startNotifier];
	} 
	
	return sharedManager;
}

#pragma mark -
#pragma mark Background Processing Methods

- (NSString *) HTMLForWord: (NSString *) dictionaryWord
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryWordForm 
											  inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
    [fetchRequest setEntity:entity];
    entity = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"word == %@", dictionaryWord];
    
    [fetchRequest setPredicate:pred];
    pred = nil;
    
	NSError *error = nil;				
	NSArray *results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release], fetchRequest = nil;
	
	if (error) {
		NSLog(@"error when retrieving word %@: %@", dictionaryWord, [error localizedDescription]);
		return nil;
	}
	
	if (!results || [results count] != 1) {
        int resultCount = -1;
        if (results) {
            resultCount = [results count];
        }
        
		NSLog(@"error when retrieving word %@: %d results retrieved.", dictionaryWord, resultCount);
		return nil;
	}
    

    SCHDictionaryWordForm *wordForm = [results objectAtIndex:0];
    results = nil;
    [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] refreshObject:wordForm mergeChanges:YES];
        
    fetchRequest = [[NSFetchRequest alloc] init];
    
    entity = [NSEntityDescription entityForName:kSCHDictionaryEntry
                         inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
    
    [fetchRequest setEntity:entity];
    
    pred = [NSPredicate predicateWithFormat:@"baseWordID == %@", wordForm.baseWordID];
    
    [fetchRequest setPredicate:pred];
    pred = nil;
    
	results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	if (error) {
		NSLog(@"error when retrieving definition for word %@: %@", dictionaryWord, [error localizedDescription]);
		return nil;
	}
	
	if (!results || [results count] != 1) {
        int resultCount = -1;
        if (results) {
            resultCount = [results count];
        }
        
		NSLog(@"error when retrieving definition for word %@: %d results retrieved.", dictionaryWord, resultCount);
		return nil;
	}
    
    SCHDictionaryEntry *entry = [results objectAtIndex:0];
    results = nil;
    
    return [entry HTMLforEntry];
    
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
        NSLog(@"Process dictionary called, but connection is busy.");
		return;
	}
	
    SCHDictionaryProcessingState state = [[SCHDictionaryManager sharedDictionaryManager] dictionaryProcessingState];
	NSLog(@"**** Calling processDictionary with state %d...", state);
    
	switch (state) {
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
			// create dictionary download operation
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
		case SCHDictionaryProcessingStateNeedsUnzip:
		{
			NSLog(@"needs unzip...");
			// create unzip operation
			SCHDictionaryFileUnzipOperation *unzipOp = [[SCHDictionaryFileUnzipOperation alloc] init];
			
			// dictionary processing is redispatched on completion
			[unzipOp setCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:unzipOp];
			[unzipOp release];
			return;
			break;
		}	
		case SCHDictionaryProcessingStateNeedsParsing:
		{
			NSLog(@"needs parse...");
			// create dictionary parse operation
			SCHDictionaryEntryParseOperation *parseOp = [[SCHDictionaryEntryParseOperation alloc] init];
			
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
#pragma mark Dictionary Location

- (NSString *)dictionaryDirectory 
{
    NSString *libraryCacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dictionaryDirectory = [libraryCacheDirectory stringByAppendingPathComponent:@"Dictionary"];
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDirectory = NO;
    
    if (![localFileManager fileExistsAtPath:dictionaryDirectory isDirectory:&isDirectory]) {
        [localFileManager createDirectoryAtPath:dictionaryDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Warning: problem creating dictionary directory. %@", [error localizedDescription]);
        }
    }
    
    [localFileManager release];
    
    return dictionaryDirectory;
}

- (NSString *) dictionaryZipPath
{
    return [[self dictionaryDirectory] 
     stringByAppendingPathComponent:[NSString stringWithFormat:@"dictionary-%@.zip", 
                                     [[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion]]];
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

- (void)threadSafeUpdateDictionaryState: (SCHDictionaryProcessingState) newState 
{
    NSLog(@"Updating state to %d", newState);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self.threadSafeMutationLock lock];
	
    {
        ++mutationCount;
        if(mutationCount != 1) {
			[NSException raise:@"SCHBookManagerMutationException" 
						format:@"Mutation count is greater than 1; multiple threads are accessing data in an unsafe manner."];
        }        
        SCHDictionaryManager *dictionaryManager = [SCHDictionaryManager sharedDictionaryManager];
        SCHAppDictionaryState *state = [dictionaryManager appDictionaryState];
        if (nil == state) {
            NSLog(@"Failed to retrieve state in SCHDictionaryManager threadSafeUpdateDictionaryState");
        } else {
            state.State = [NSNumber numberWithInt: (int) newState];
        }
        NSError *anError;
        if (![dictionaryManager save:&anError]) {
            NSLog(@"[SCHDictionaryManager threadSafeUpdateDictionaryState:%@] Save failed with error: %@, %@", [state.State stringValue], anError, [anError userInfo]);
        }
        --mutationCount;
    }
	
	[self.threadSafeMutationLock unlock];
    
    [pool drain];
}

- (SCHDictionaryProcessingState) dictionaryProcessingState
{
	SCHAppDictionaryState *state = [[SCHDictionaryManager sharedDictionaryManager] appDictionaryState];
    if (nil == state) {
        NSLog(@"Failed to retrieve dictionary state object in dictionaryProcessingState");
        return SCHDictionaryProcessingStateError;
    } else {
        return [[state State] intValue];
    }
}


- (BOOL)save:(NSError **)error
{
    return [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] save:error];
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
        SCHAppDictionaryState *state = [results objectAtIndex:0];
        [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] refreshObject:state mergeChanges:YES];
		return state;
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

- (void) mergeChanges:(NSNotification*)saveNotification
{
	// Fault in all updated objects
	NSArray* updates = [[saveNotification.userInfo objectForKey:@"updated"] allObjects];
	for (NSInteger i = [updates count]-1; i >= 0; i--)
	{
		[[[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] objectWithID:[[updates objectAtIndex:i] objectID]] willAccessValueForKey:nil];
	}
    
	// Merge
	[[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:saveNotification];
}

@end
