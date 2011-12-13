//
//  SCHDictionaryDownloadManager.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryDownloadManager.h"
#import "Reachability.h"
#import "SCHProcessingManager.h"
#import "SCHBookManager.h"
#import "SCHAppDictionaryState.h"
#import "SCHDictionaryManifestOperation.h"
#import "SCHDictionaryFileDownloadOperation.h"
#import "SCHDictionaryFileUnzipOperation.h"
#import "SCHDictionaryParseOperation.h"
#import "SCHDictionaryWordForm.h"
#import "SCHDictionaryEntry.h"
#import "SCHDictionaryAccessManager.h"
#import "NSManagedObjectContext+Extensions.h"
#import "SCHCoreDataHelper.h"
#import "SCHAppDictionaryManifestEntry.h"
#import "SCHDictionaryOperation.h"
#import "AppDelegate_Shared.h"

// Constants
NSString * const kSCHDictionaryDownloadPercentageUpdate = @"SCHDictionaryDownloadPercentageUpdate";
NSString * const kSCHDictionaryProcessingPercentageUpdate = @"SCHDictionaryProcessingPercentageUpdate";

NSString * const kSCHDictionaryStateChange = @"SCHDictionaryStateChange";

static NSString * const kSCHDictionaryDownloadDirectoryName = @"Dictionary";

int const kSCHDictionaryManifestEntryEntryTableBufferSize = 8192;
int const kSCHDictionaryManifestEntryWordFormTableBufferSize = 1024;
CGFloat const kSCHDictionaryFileUnzipMaxPercentage = 0.9f;

char * const kSCHDictionaryManifestEntryColumnSeparator = "\t";

#pragma mark Dictionary Version Class

@implementation SCHDictionaryManifestEntry

@synthesize fromVersion;
@synthesize toVersion;
@synthesize url;

@end

#pragma mark Class Extension

@interface SCHDictionaryDownloadManager()

// the background task ID for background processing
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

// operation queue - to perform the dictionary download
@property (readwrite, retain) NSOperationQueue *dictionaryDownloadQueue;

// local reachability - used to determine the status of the network connection
@property (readwrite, retain) Reachability *wifiReach;

// timer for preventing false starts
@property (readwrite, retain) NSTimer *startTimer;

@property (readwrite) float currentDictionaryDownloadPercentage;
@property (readwrite) float currentDictionaryProcessingPercentage;

// check current reachability state
- (void) reachabilityCheck: (Reachability *) curReach;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void) enterBackground;
- (void) enterForeground;

// checks to see if we're on wifi and the processing manager is idle
// if so, spawn a timer to begin processing
// the timer prevents rapid starting and stopping of the dictionary download/processing
- (void) checkOperatingStateImmediately:(BOOL)immediately;
- (void) processDictionary;

// Core Data Save method
- (BOOL)save:(NSError **)error;

// Cache the current manifest entry in core data
- (void)storeManifestEntryInDatabase:(SCHDictionaryManifestEntry *)manifestEntry;
- (SCHDictionaryManifestEntry *)manifestEntryFromDatabase;
- (void)removeManifestEntryFromDatabase;
- (void)deleteDictionaryFileWithCompletionBlock:(dispatch_block_t)completion;

- (BOOL)stateNeedsWiFi;
- (BOOL)stateIsWaitingForUserInteraction;

- (SCHDictionaryManifestEntry *)nextManifestEntryUpdateForCurrentDictionaryVersion;

- (BOOL)parseEntryTableLine:(char *)completeLine withOffset:(long)currentOffset context:(NSManagedObjectContext*)context updates:(BOOL)doesUpdate;
- (BOOL)parseWordFormLine:(char *)completeLine context:(NSManagedObjectContext*)context updates:(BOOL)doesUpdate;

@end

#pragma mark -

@implementation SCHDictionaryDownloadManager

@synthesize backgroundTask;
@synthesize dictionaryDownloadQueue;
@synthesize wifiReach;
@synthesize startTimer;
@synthesize wifiAvailable;
@synthesize connectionIdle;
@synthesize isProcessing;
@synthesize manifestUpdates;
@synthesize mainThreadManagedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize currentDictionaryDownloadPercentage;
@synthesize currentDictionaryProcessingPercentage;

#pragma mark -
#pragma mark Object Lifecycle

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.dictionaryDownloadQueue = nil;
	[self.wifiReach stopNotifier];
	self.wifiReach = nil;
    self.mainThreadManagedObjectContext = nil;
    self.persistentStoreCoordinator = nil;
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		self.dictionaryDownloadQueue = [[[NSOperationQueue alloc] init] autorelease];
		[self.dictionaryDownloadQueue setMaxConcurrentOperationCount:1];
		
		self.wifiAvailable = YES;
		self.connectionIdle = YES;
		
		self.wifiReach = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	 
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(dictionaryDownloadPercentageUpdate:) 
                                                     name:kSCHDictionaryDownloadPercentageUpdate 
                                                   object:nil];    
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(dictionaryProcessingPercentageUpdate:) 
                                                     name:kSCHDictionaryProcessingPercentageUpdate 
                                                   object:nil];       
    }
	
	return self;
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.mainThreadManagedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

#pragma mark -
#pragma mark Default Manager Object

static SCHDictionaryDownloadManager *sharedManager = nil;

+ (SCHDictionaryDownloadManager *)sharedDownloadManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHDictionaryDownloadManager alloc] init];
        
		// notifications for changes in reachability
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(reachabilityNotification:) 
													 name:kReachabilityChangedNotification 
												   object:nil];

		
//		// notification for processing manager being idle
//		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
//												 selector:@selector(connectionBecameIdle:) 
//													 name:kSCHProcessingManagerConnectionIdle
//												   object:nil];			
//		
//		
//		// notification for processing manager starting work
//		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
//												 selector:@selector(connectionBecameBusy:) 
//													 name:kSCHProcessingManagerConnectionBusy
//												   object:nil];			
		
		
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
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
        // if there's already a background monitoring task, then return - the existing one will work
        if (self.backgroundTask && self.backgroundTask != UIBackgroundTaskInvalid) {
            return;
        }
        
		if ((self.dictionaryDownloadQueue && [self.dictionaryDownloadQueue operationCount]) ) {
			NSLog(@"Dictionary download needs more time - going into the background.");
			
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
					[self.dictionaryDownloadQueue waitUntilAllOperationsAreFinished];
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
	
	[sharedManager reachabilityCheck:sharedManager.wifiReach];
}


#pragma mark -
#pragma mark Reachability reactions

- (void)reachabilityNotification:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self reachabilityCheck:curReach];
}

- (void)reachabilityCheck:(Reachability *)curReach
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
	
	[self checkOperatingStateImmediately:NO];
}

#pragma mark -
#pragma mark Processing Manager reactions

- (void)connectionBecameIdle:(NSNotification *)notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not on main thread!");
	NSLog(@"****************** Processing manager became idle! ******************");
	self.connectionIdle = YES;
	[self checkOperatingStateImmediately:NO];
}

- (void)connectionBecameBusy:(NSNotification *)notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not on main thread!");
	NSLog(@"****************** Processing manager became busy! ******************");
	self.connectionIdle = NO;
	[self checkOperatingStateImmediately:NO];
}

#pragma mark -
#pragma mark Check Operating State

- (BOOL)stateNeedsWiFi
{
    BOOL stateNeedsWiFi = NO;
    
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    
    switch (state) {
        case SCHDictionaryProcessingStateNeedsManifest:
        case SCHDictionaryProcessingStateNeedsDownload:
            stateNeedsWiFi = YES;
            break;
        default:
            stateNeedsWiFi = NO;
            break;
    }
    
    return stateNeedsWiFi;
}

- (BOOL)stateIsWaitingForUserInteraction
{
    BOOL stateIsWaitingForUserInteraction = NO;
    
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    
    switch (state) {
        case SCHDictionaryProcessingStateError:
        case SCHDictionaryProcessingStateUserSetup:
        case SCHDictionaryProcessingStateUserDeclined:
        case SCHDictionaryProcessingStateNotEnoughFreeSpace:
        case SCHDictionaryProcessingStateUnexpectedConnectivityFailure:
            stateIsWaitingForUserInteraction = YES;
            break;
        default:
            stateIsWaitingForUserInteraction = NO;
            break;
    }
    
    return stateIsWaitingForUserInteraction;
}

- (void)checkOperatingStateImmediately:(BOOL)immediately
{
    // Dictionary can be disabled using preprocessor flag
#if DICTIONARY_DOWNLOAD_DISABLED
    NSLog(@"****************** Dictionary download is disabled. ******************");
    return;
#endif
    
//	NSLog(@"*** wifi: %@ connectionIdle: %@ ***", self.wifiAvailable?@"Yes":@"No", self.connectionIdle?@"Yes":@"No");
	NSLog(@"*** wifi: %@ ***", self.wifiAvailable?@"Yes":@"No");
	
	// if both conditions are met, start the countdown to begin work
//	if (self.wifiAvailable && self.connectionIdle) {
    
    BOOL stateNeedsWiFi = [self stateNeedsWiFi];
    
	if (self.wifiAvailable || !stateNeedsWiFi) {

		// start the countdown from 3 seconds again
		if (self.startTimer && [self.startTimer isValid]) {
			[self.startTimer invalidate];
			self.startTimer = nil; 
		} 

		NSLog(@"********* Starting timer...");
        if (immediately) {
            [self processDictionary];
        } else {
            self.startTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                               target:self
                                                             selector:@selector(processDictionary)
                                                             userInfo:nil
                                                              repeats:NO];
        }
	} else {
		// otherwise, cancel work in progress
		NSLog(@"Cancelling operations etc.");
		if (self.startTimer && [self.startTimer isValid]) {
			[self.startTimer invalidate];
			self.startTimer = nil; 
		}
		[self.dictionaryDownloadQueue cancelAllOperations];
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryStateChange object:nil userInfo:nil];
}

#pragma mark -
#pragma mark Processing Methods

- (SCHDictionaryManifestEntry *)nextManifestEntryUpdateForCurrentDictionaryVersion
{
    NSString *currentDictionaryVersion = [self dictionaryVersion];
    
    SCHDictionaryManifestEntry *entryUpdateForCurrentDictionaryVersion = nil;
    SCHDictionaryManifestEntry *defaultEntryUpdate = nil;
    
    for (SCHDictionaryManifestEntry *anEntry in self.manifestUpdates) {
        //NSLog(@"from: (%@) to: (%@) URL: %@", anEntry.fromVersion, anEntry.toVersion, anEntry.url);

        if ([anEntry fromVersion]) {
            if ([[anEntry fromVersion] isEqualToString:currentDictionaryVersion]) {
                entryUpdateForCurrentDictionaryVersion = anEntry;
                break;
            }
        } else {
            defaultEntryUpdate = anEntry;
        }
    }
    
    if (entryUpdateForCurrentDictionaryVersion) {
        return entryUpdateForCurrentDictionaryVersion;
    } else {
        return defaultEntryUpdate;
    }
}

- (void)processDictionary
{
    
	if ([NSThread currentThread] != [NSThread mainThread]) {
		[self performSelectorOnMainThread:@selector(processDictionary) withObject:nil waitUntilDone:NO];
		return;
	}
	    
    if (self.isProcessing && ![self stateIsWaitingForUserInteraction]) {
        NSLog(@"Process dictionary called, but dictionary is already processing.");
        return;
    }
    
    if (!self.wifiAvailable &&  [self stateNeedsWiFi]) {
        NSLog(@"Process dictionary called, but no wifi available.");
        return;
    }
    
    if ([self.dictionaryDownloadQueue operationCount]) {
        NSLog(@"Trying to process a new operation whilst there are remaining operations");
        [self.dictionaryDownloadQueue cancelAllOperations];
    }
	
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
	NSLog(@"**** Calling processDictionary with state %d...", state);
    
	switch (state) {
        case SCHDictionaryProcessingStateUserSetup:
        case SCHDictionaryProcessingStateUserDeclined:
        {
            // do nothing
            return;
        }
   		case SCHDictionaryProcessingStateNeedsManifest:
		{
			NSLog(@"needs dictionary manifest...");
            
			// create manifest processing operation
			SCHDictionaryManifestOperation *manifestOp = [[SCHDictionaryManifestOperation alloc] init];
            
            NSLog(@"Manifest op: %@", manifestOp);
			
			// dictionary processing is redispatched on completion
			[manifestOp setNotCancelledCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:manifestOp];
			[manifestOp release];
			return;
			break;
		}	
		case SCHDictionaryProcessingStateManifestVersionCheck:
		{
			NSLog(@"needs manifest version check...");
            
            BOOL processUpdate = NO;
            SCHDictionaryManifestEntry *entry = [self nextManifestEntryUpdateForCurrentDictionaryVersion];

            NSString *currentDictionaryVersion = [self dictionaryVersion];
            
            if (currentDictionaryVersion) {
                if ([currentDictionaryVersion compare:[entry toVersion] options:NSNumericSearch] == NSOrderedAscending) {
                    processUpdate = YES;
                }
            } else {
                processUpdate = YES;
            }
            
            if (processUpdate) {
                if (entry) {
                    [self storeManifestEntryInDatabase:entry];
                }
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsDownload];
                [self processDictionary];
            } else {
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateReady];
                [self processDictionary];
            }
            
			return;
			break;
		}	
		case SCHDictionaryProcessingStateNeedsDownload:
		{
			NSLog(@"needs download...");
            
            // if there's no manifest set, restart the process
            SCHDictionaryManifestEntry *entry = nil;
            
            if ([self.manifestUpdates count]) {
                entry = [self nextManifestEntryUpdateForCurrentDictionaryVersion];
            } else {
                entry = [self manifestEntryFromDatabase];
            }
            
            if (entry == nil) {                
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                [self processDictionary];
                return;
            }
                        
			// create dictionary download operation
			SCHDictionaryFileDownloadOperation *downloadOp = [[SCHDictionaryFileDownloadOperation alloc] init];
            downloadOp.manifestEntry = entry;
			self.currentDictionaryDownloadPercentage = 0.0;
            
			// dictionary processing is redispatched on completion
			[downloadOp setNotCancelledCompletionBlock:^{
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
            
            // if there's no manifest set, restart the process
            SCHDictionaryManifestEntry *entry = nil;
            
            if ([self.manifestUpdates count]) {
                entry = [self nextManifestEntryUpdateForCurrentDictionaryVersion];
            } else {
                entry = [self manifestEntryFromDatabase];
            }
            
            if (entry == nil) {
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                [self processDictionary];
                return;
            }
            
            self.currentDictionaryProcessingPercentage = 0.0;
            
			SCHDictionaryFileUnzipOperation *unzipOp = [[SCHDictionaryFileUnzipOperation alloc] init];
            unzipOp.manifestEntry = entry;
            
			// on completion, we need to check if we are on the first download, or subsequent downloads
			[unzipOp setNotCancelledCompletionBlock:^{
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:unzipOp];
			[unzipOp release];
			return;
			break;
		}	
		case SCHDictionaryProcessingStateNeedsParse:
		{
			NSLog(@"needs parse...");
            
            self.currentDictionaryProcessingPercentage = kSCHDictionaryFileUnzipMaxPercentage;

            // to cope with resuming the app in this state, the manifest entry being processed
            // is cached in the database
            SCHDictionaryManifestEntry *entry;
            if ([self.manifestUpdates count]) {
                entry = [self nextManifestEntryUpdateForCurrentDictionaryVersion];
                [self storeManifestEntryInDatabase:entry];
            } else {
                entry = [self manifestEntryFromDatabase];
                if (entry == nil) {
                    // if there's no manifest set, restart the process
                    // this prevents double processing in the event of interruptions during parsing
                    [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                    [self processDictionary];
                    return;
                }
            }

			// create dictionary parse operation
			SCHDictionaryParseOperation *parseOp = [[SCHDictionaryParseOperation alloc] init];
			parseOp.manifestEntry = entry;
            
			[parseOp setNotCancelledCompletionBlock:^{
                self.dictionaryVersion = entry.toVersion;
                [self removeManifestEntryFromDatabase];
				[self processDictionary];
			}];
			
			// add the operation to the queue
			[self.dictionaryDownloadQueue addOperation:parseOp];
			[parseOp release];
			return;
			break;
		}	
        case SCHDictionaryProcessingStateReady:
        {
            NSLog(@"Dictionary is ready.");
            [[SCHDictionaryAccessManager sharedAccessManager] updateOnReady];
            break;
        }
		default:
			break;
	}
}

- (void)storeManifestEntryInDatabase:(SCHDictionaryManifestEntry *)manifestEntry
{    
    if ([self manifestEntryFromDatabase]) {
        NSLog(@"attempt to overwrite manifest entry in database. Existing one will be deleted");
        [self removeManifestEntryFromDatabase];
    }
    
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {

        SCHAppDictionaryManifestEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"SCHAppDictionaryManifestEntry"
                                                                          inManagedObjectContext:self.mainThreadManagedObjectContext];
        entry.fromVersion = manifestEntry.fromVersion;
        entry.toVersion = manifestEntry.toVersion;
        entry.url = manifestEntry.url;
        state.appDictionaryManifestEntry = entry;
    }];
    
    NSError *error = nil;
    if (![self save:&error]) {
        NSLog(@"failed to save after updating database manifest entry: %@", error);
    }
}

- (SCHDictionaryManifestEntry *)manifestEntryFromDatabase
{
    __block SCHDictionaryManifestEntry *manifestEntry = nil;
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        if (state.appDictionaryManifestEntry != nil) {
            manifestEntry = [[SCHDictionaryManifestEntry alloc] init];
            manifestEntry.fromVersion = state.appDictionaryManifestEntry.fromVersion;
            manifestEntry.toVersion = state.appDictionaryManifestEntry.toVersion;
            manifestEntry.url = state.appDictionaryManifestEntry.url;
        }
    }];
    return [manifestEntry autorelease];
}

- (void)removeManifestEntryFromDatabase
{
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        if (state.appDictionaryManifestEntry) {
            [self.mainThreadManagedObjectContext deleteObject:state.appDictionaryManifestEntry];
            state.appDictionaryManifestEntry = nil;
        }
    }];
}

#pragma mark -
#pragma mark Dictionary Location

- (NSString *)dictionaryDirectory 
{
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dictionaryDirectory = [applicationSupportDirectory stringByAppendingPathComponent:kSCHDictionaryDownloadDirectoryName];
    
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

- (NSString *)dictionaryTmpDirectory 
{
    NSString *ret = [NSTemporaryDirectory() stringByAppendingPathComponent:kSCHDictionaryDownloadDirectoryName];  
    return(ret);
}

- (NSString *)dictionaryTextFilesDirectory 
{
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dictionaryDirectory = [applicationSupportDirectory stringByAppendingPathComponent:@"Dictionary/Current"];
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDirectory = NO;
    
    if (![localFileManager fileExistsAtPath:dictionaryDirectory isDirectory:&isDirectory]) {
        [localFileManager createDirectoryAtPath:dictionaryDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Warning: problem creating current dictionary directory. %@", [error localizedDescription]);
        }
    }
    
    [localFileManager release];
    
    return dictionaryDirectory;
}

- (NSString *)dictionaryZipPath
{
    if ([self dictionaryVersion] == nil) {
        return [[self dictionaryDirectory] 
                stringByAppendingPathComponent:@"dictionary.zip"];
    } else {
        return [[self dictionaryDirectory] 
                stringByAppendingPathComponent:[NSString stringWithFormat:@"dictionary-%@.zip", 
                                                [self dictionaryVersion]]];
    }
}

#pragma mark -
#pragma mark Dictionary Version

- (NSString *)dictionaryVersion
{
    __block NSString *version;
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        version = [[state Version] retain];
    }];
    return [version autorelease];
}

- (void)setDictionaryVersion:(NSString *)newVersion
{
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        state.Version = newVersion;
    }];	
}

#pragma mark -
#pragma mark Dictionary State

- (void)threadSafeUpdateDictionaryState:(SCHDictionaryProcessingState)newState 
{
    NSLog(@"Updating state to %d", newState);
    
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        state.State = [NSNumber numberWithInt:(int)newState];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryStateChange object:nil userInfo:nil];
    }];
}

- (SCHDictionaryProcessingState)dictionaryProcessingState
{
    __block SCHDictionaryProcessingState processingState;
    [self withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
        processingState = [state.State intValue];
    }];
    return processingState;
}

- (BOOL)dictionaryDownloadStarted
{
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    return (state != SCHDictionaryProcessingStateUserSetup && state != SCHDictionaryProcessingStateUserDeclined);
}

- (void)dictionaryDownloadPercentageUpdate:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *currentPercentage = [userInfo objectForKey:@"currentPercentage"];
    
    if (currentPercentage != nil) {
        self.currentDictionaryDownloadPercentage = [currentPercentage floatValue];
    }
}

- (void)dictionaryProcessingPercentageUpdate:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *currentPercentage = [userInfo objectForKey:@"currentPercentage"];
    
    if (currentPercentage != nil) {
        self.currentDictionaryProcessingPercentage = [currentPercentage floatValue];
    }
}

#pragma mark - Update Check

- (void)checkIfDictionaryUpdateNeeded
{
    
    if (!self.isProcessing  || [self stateIsWaitingForUserInteraction]) {
        SCHDictionaryProcessingState state = [self dictionaryProcessingState];
        
        if (state == SCHDictionaryProcessingStateNotEnoughFreeSpace) {
            [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserSetup]; // wait for user input but don't delete
        } else if (state == SCHDictionaryProcessingStateError || state == SCHDictionaryProcessingStateDeleting) {
            [self deleteDictionaryFileWithCompletionBlock:^{
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserSetup]; // wait for user input after a delete
            }];
        } else if (state == SCHDictionaryProcessingStateUnexpectedConnectivityFailure) {
            [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest]; // Don't delete the existing files & attempt to restart
        } else if (state == SCHDictionaryProcessingStateReady) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // check to see if we need to do an update
            bool doUpdate = NO;
            
            NSDate *lastPrefUpdate = [defaults objectForKey:@"lastDictionaryUpdateDate"];
            NSDate *currentDate = [[NSDate alloc] init];
            
            // if there's no default, set the current date
            if (lastPrefUpdate == nil) {
                [defaults setValue:currentDate forKey:@"lastDictionaryUpdateDate"];
                [defaults synchronize];
                doUpdate = YES;
            } else {
                double timeInterval = [currentDate timeIntervalSinceDate:lastPrefUpdate];
                
                // have we updated in the last 24 hours?
                if (timeInterval >= 86400) {
                    [defaults setValue:currentDate forKey:@"lastDictionaryUpdateDate"];
                    [defaults synchronize];					
                }
            }		
            
            [currentDate release];
            
            if (doUpdate) {
                NSLog(@"Dictionary needs an update check.");
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
            }
        }
        
        [self processDictionary];
    }
}

- (SCHDictionaryUserRequestState)userRequestState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SCHDictionaryUserRequestState currentUserRequestState = (SCHDictionaryUserRequestState) [defaults integerForKey:@"currentDictionaryUserRequestState"];
    
    // if there is no key set, this defaults to 0, which is "User Not Yet Asked" - exactly what we need
    return currentUserRequestState;
}

- (void)setUserRequestState:(SCHDictionaryUserRequestState)newUserRequestState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(NSInteger) newUserRequestState forKey:@"currentDictionaryUserRequestState"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Dictionary Parsing Methods

- (void)initialParseEntryTable
{
    NSLog(@"Parsing entry table...");
    
    dispatch_sync([SCHDictionaryAccessManager sharedAccessManager].dictionaryAccessQueue, ^{

        SCHDictionaryDownloadManager *dictManager = self;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSLog(@"Removing any existing %@ objects.", kSCHDictionaryEntry);
                
        NSError *error = nil;
        [context BITemptyEntity:kSCHDictionaryEntry error:&error];
        if (error) {
            NSLog(@"Error during processing; could not remove %@ objects. %@", kSCHDictionaryEntry, [error localizedDescription]);            
        }
        
        // begin processing
        
        NSString *filePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
        error = nil;
        char *completeLine;
        NSMutableData *collectLine = nil;                
        NSString *tmpCompleteLine = nil;    
        size_t strLength = 0;
        
        FILE *file = fopen([filePath UTF8String], "r");
        char line[kSCHDictionaryManifestEntryEntryTableBufferSize];
        
        long currentOffset = 0;
        
        int batchItems = 0;
        int savedItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        BOOL bufferPopulated = NO;

        if (file != NULL) {
            while (fgets(line, kSCHDictionaryManifestEntryEntryTableBufferSize, file) != NULL) {
                
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {                    
                        [collectLine appendBytes:line length:strlen(line)];                                        
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                        [tmpCompleteLine release], tmpCompleteLine = nil;
                    }
                    
                    BOOL success = [self parseEntryTableLine:completeLine withOffset:currentOffset context:context updates:NO];
                                    
                    if (success) {
                        savedItems++;
                        batchItems++;
                    }
                    
                    bufferPopulated = NO;
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
                    
                    bufferPopulated = YES;
                }
                
                if (batchItems > 500) {
                    batchItems = 0;
                    
                    [context save:&error];
                    if (error)
                    {
                        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
                    }
                    [context reset];
                    [pool drain];
                    pool = [[NSAutoreleasePool alloc] init];
                }
                if (collectLine == nil) {
                    currentOffset = ftell(file);
                }
            }
            
            // if the final line doesn't have an end of line character, check to see if the buffer still has data
            // if so, try to parse the final line
            if (bufferPopulated) {
                
                tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                // add a new line character
                completeLine = (char *)[[NSString stringWithFormat:@"%@\n", tmpCompleteLine] UTF8String];
                [tmpCompleteLine release], tmpCompleteLine = nil;
                
                BOOL success = [self parseEntryTableLine:completeLine withOffset:currentOffset context:context updates:NO];
                if (success) {
                    batchItems++;
                    savedItems++;   
                }
            }
            
            
            [collectLine release], collectLine = nil;
            
            [pool drain];
            fclose(file);
            
            if (![context save:&error]) {
                NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
            } else {
                NSLog(@"Added %d entries to base words.", savedItems);
                
                // fire a notification - this one is 50%
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    CGFloat progress = 0.5f;
                    CGFloat overall = kSCHDictionaryFileUnzipMaxPercentage + ((1 - kSCHDictionaryFileUnzipMaxPercentage) * progress);
                
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:overall], @"currentPercentage",
                                              nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryProcessingPercentageUpdate object:nil userInfo:userInfo];
                    
                });
            }
        }
        [context release];            
    });
}

- (void)initialParseWordFormTable
{
    NSLog(@"Parsing word form table...");
    
    dispatch_sync([SCHDictionaryAccessManager sharedAccessManager].dictionaryAccessQueue, ^{

        SCHDictionaryDownloadManager *dictManager = self;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSLog(@"Removing any existing %@ objects.", kSCHDictionaryWordForm);
        
        NSError *error = nil;
        [context BITemptyEntity:kSCHDictionaryWordForm error:&error];
        if (error) {
            NSLog(@"Error during processing; could not remove %@ objects. %@", kSCHDictionaryWordForm, [error localizedDescription]);            
        }
        
        // begin processing
        
        NSString *filePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"WordFormTable.txt"];
        error = nil;
        char *completeLine;
        NSMutableData *collectLine = nil;
        NSString *tmpCompleteLine = nil;            
        size_t strLength = 0;
        
        FILE *file = fopen([filePath UTF8String], "r");
        char line[kSCHDictionaryManifestEntryWordFormTableBufferSize];
        
        int savedItems = 0;
        int batchItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        BOOL bufferPopulated = NO;
        
        if (file != NULL) {
            setlinebuf(file);
            while (fgets(line, kSCHDictionaryManifestEntryWordFormTableBufferSize, file) != NULL) {
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];                    
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                        [tmpCompleteLine release], tmpCompleteLine = nil;
                    }
                    
                    bufferPopulated = NO;
                    
                    BOOL success = [self parseWordFormLine:completeLine context:context updates:NO];
                    if (success) {
                        savedItems++;
                        batchItems++;          
                    }
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
                    
                    bufferPopulated = YES;
                }
                
                if (batchItems > 1000) {
                    batchItems = 0;
                    [context save:&error];
                    if (error)
                    {
                        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
                    }
                    
                    [context reset];
                    [pool drain];
                    pool = [[NSAutoreleasePool alloc] init];
                }
            }    
            
            // if the final line doesn't have an end of line character, check to see if the buffer still has data
            // if so, try to parse the final line
            if (bufferPopulated) {
                
                tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                completeLine = (char *)[tmpCompleteLine UTF8String];
                [tmpCompleteLine release], tmpCompleteLine = nil;
                
                BOOL success = [self parseWordFormLine:completeLine context:context updates:NO];
                if (success) {
                    savedItems++;
                    batchItems++;
                }
            }

            
            [collectLine release], collectLine = nil;
            
            [pool drain];
            
            fclose(file);
            
            if (![context save:&error]) {
                NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
            } else {
                NSLog(@"Added %d entries to word entries.", savedItems);
                
                // fire a notification - this one is 100%
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    CGFloat progress = 1.0f;
                    CGFloat overall = kSCHDictionaryFileUnzipMaxPercentage + ((1 - kSCHDictionaryFileUnzipMaxPercentage) * progress);
                    
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:overall], @"currentPercentage",
                                              nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryProcessingPercentageUpdate object:nil userInfo:userInfo];
                    
                });

            }
        }
        [context release];            
    });
}

- (BOOL)parseWordFormLine:(char *)completeLine context:(NSManagedObjectContext*)context updates:(BOOL)doesUpdate
{
    BOOL success = NO;
    
    char *start, *entryID, *headword, *wordform, *category;
    NSError *error = nil;

    start = strtok(completeLine, kSCHDictionaryManifestEntryColumnSeparator);
    if (start != NULL) {
        wordform = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);                   // search
        if (wordform != NULL) {
            headword = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);
            if (headword != NULL) {
                entryID = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);            // MATCH
                if (entryID != NULL) {
                    category = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);      // MATCH YD/OD/ALL
                    if (category != NULL) {
                        category[strlen(category)-1] = '\0';    // remove the line end
                        NSString *dictWord = [NSString stringWithUTF8String:wordform];
                        SCHDictionaryWordForm *dictionaryWordForm = nil;
                        
                        // try to fetch a core data object matching this entry
                        
                        if (doesUpdate) {
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            // Edit the entity name as appropriate.
                            NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryWordForm inManagedObjectContext:context];
                            [fetchRequest setEntity:entity];
                            entity = nil;
                            
                            NSPredicate *pred = [NSPredicate predicateWithFormat:@"word == %@", dictWord];
                            
                            [fetchRequest setPredicate:pred];
                            pred = nil;
                            
                            NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
                            
                            [fetchRequest release], fetchRequest = nil;
                            
                            if (error) {
                                NSLog(@"error when retrieving word %@: %@", dictWord, [error localizedDescription]);
                                dictionaryWordForm = nil;
                            }
                            
                            if (!results || [results count] != 1) {
                                NSLog(@"error when retrieving word %@: %d results retrieved.", dictWord, [results count]);
                                
                                // we assume that there is only one valid word form for each word
                                // therefore we delete existing entries to remove duplicates, then recreate from scratch
                                if ([results count] > 1) {
                                    NSLog(@"Multiple results: deleting existing word form objects, then replacing with new from update file.");
                                    
                                    for (SCHDictionaryWordForm *deletedWordForm in results) {
                                        [context deleteObject:deletedWordForm];
                                    }
                                }
                                
                                dictionaryWordForm = nil;
                            } else {
                                dictionaryWordForm = [results objectAtIndex:0];
                            }
                            
                            results = nil;
                        }
                        if (dictionaryWordForm) {
                            dictionaryWordForm.word = [NSString stringWithUTF8String:wordform];
                            dictionaryWordForm.rootWord = [NSString stringWithUTF8String:headword];
                            dictionaryWordForm.baseWordID = [NSString stringWithUTF8String:entryID];
                            dictionaryWordForm.category = [NSString stringWithUTF8String:category];
                        } else {
                            dictionaryWordForm = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryWordForm inManagedObjectContext:context];
                            dictionaryWordForm.word = [NSString stringWithUTF8String:wordform];
                            dictionaryWordForm.rootWord = [NSString stringWithUTF8String:headword];
                            dictionaryWordForm.baseWordID = [NSString stringWithUTF8String:entryID];
                            dictionaryWordForm.category = [NSString stringWithUTF8String:category];
//                            NSLog(@"Created new word form: %@ %@ %@ %@", dictionaryWordForm.word, dictionaryWordForm.rootWord, dictionaryWordForm.baseWordID, dictionaryWordForm.category);
                        }
                        
                        success = YES;
                    }
                }
            }
        }
    }

    
    return success;
}

- (BOOL)parseEntryTableLine:(char *)completeLine withOffset:(long)currentOffset context:(NSManagedObjectContext*)context updates:(BOOL)doesUpdate
{
    BOOL success = NO;
    char *start, *entryID, *headword, *level;
    NSError *error = nil;

    start = strtok(completeLine, kSCHDictionaryManifestEntryColumnSeparator);
    if (start != NULL) {
        entryID = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);                    // MATCH
        if (entryID != NULL) {
            headword = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);
            if (headword != NULL) {
                level = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);              // MATCH YD/OD
                if (level != NULL) {
                    SCHDictionaryEntry *entry = nil;
                    
                    if (doesUpdate) {
                    // try to find an existing core data entry to update
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    // Edit the entity name as appropriate.
                    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryEntry inManagedObjectContext:context];
                    [fetchRequest setEntity:entity];
                    entity = nil;
                    
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"baseWordID == %@ AND category == %@", 
                                         [NSString stringWithUTF8String:entryID], [NSString stringWithUTF8String:level]];
                    
                    [fetchRequest setPredicate:pred];
                    pred = nil;
                    
                    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
                    
                    [fetchRequest release], fetchRequest = nil;
                    
                    if (!results) {
                        NSLog(@"error when retrieving word with ID %@: %@", [NSString stringWithUTF8String:entryID], [error localizedDescription]);
                        entry = nil;
                    } else if ([results count] != 1) {
                        // we assume that there is only one valid entry for each word/category grouping
                        // therefore we delete existing entries to remove duplicates, then recreate from scratch
                        
                        NSLog(@"error when retrieving word with ID %@: %d results retrieved.", [NSString stringWithUTF8String:entryID], [results count]);
                        
                        NSLog(@"Multiple results: deleting existing entry objects, then replacing with new from update file.");
                        
                        for (SCHDictionaryEntry *deletedEntry in results) {
                            [context deleteObject:deletedEntry];
                        }
                        
                        entry = nil;
                    } else {
                        entry = [results objectAtIndex:0];
                    }
                    
                    results = nil;
                    
                    }
                    
                    if (entry) {
                        entry.word = [NSString stringWithUTF8String:headword];
                        entry.baseWordID = [NSString stringWithUTF8String:entryID];
                        entry.fileOffset = [NSNumber numberWithLong:currentOffset];
                        entry.category = [NSString stringWithUTF8String:level];
                    } else {
                        entry = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryEntry inManagedObjectContext:context];
                        entry.word = [NSString stringWithUTF8String:headword];
                        entry.baseWordID = [NSString stringWithUTF8String:entryID];
                        entry.fileOffset = [NSNumber numberWithLong:currentOffset];
                        entry.category = [NSString stringWithUTF8String:level];
                    }
                    
                    success = YES;
                }
            }
        }
    }
    
    return success;
}

- (void)updateParseEntryTable
{
    NSLog(@"Updating entry table...");
    
    dispatch_sync([SCHDictionaryAccessManager sharedAccessManager].dictionaryAccessQueue, ^{
        
        char *completeLine;
        NSMutableData *collectLine = nil;                
        NSString *tmpCompleteLine = nil;            
        size_t strLength = 0;
        NSError *error = nil;

        // first, merge this file into the existing entry table file
        SCHDictionaryDownloadManager *dictManager = self;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSString *existingFilePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
        NSString *updateFilePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
        
        // open the two files
        // "a" opens a file for writing at the end, no need to seek
        FILE *existingFile = fopen([existingFilePath UTF8String], "a");
        FILE *updateFile = fopen([updateFilePath UTF8String], "r");
        
        if (existingFile == NULL || updateFile == NULL) {
            NSLog(@"Warning: could not read a file in updateParseEntryTable..");
            [context release];
            return;
        }
        
        char line[kSCHDictionaryManifestEntryEntryTableBufferSize];
        setlinebuf(updateFile);
        long currentOffset = 0;

        int updatedTotal = 0;
        int batchItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        BOOL bufferPopulated = NO;
        
        // go through each line of the update file
        while (fgets(line, kSCHDictionaryManifestEntryEntryTableBufferSize, updateFile) != NULL) {
            if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                
                if (collectLine == nil) {
                    completeLine = line;
                } else {
                    [collectLine appendBytes:line length:strlen(line)];                                    
                    [collectLine appendBytes:(char []){'\0'} length:1];
                    tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                    completeLine = (char *)[tmpCompleteLine UTF8String];
                    [collectLine release], collectLine = nil;
                    [tmpCompleteLine release], tmpCompleteLine = nil;
                }
                
                // get the current offset, then write the line to the main file
                currentOffset = ftell(existingFile);
                fputs(completeLine, existingFile);
                
                bufferPopulated = NO;

                BOOL success = [self parseEntryTableLine:completeLine withOffset:currentOffset context:context updates:YES];
                if (success) {
                    updatedTotal++;
                    batchItems++;
                }
                
            } else {
                if (collectLine == nil) {
                    collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                } else {
                    [collectLine appendBytes:line length:strlen(line)];
                }
                
                bufferPopulated = YES;
            }
            
            if (batchItems > 1000) {
                batchItems = 0;
                if (![context save:&error]) {
                    NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
                }
                
                [context reset];
                [pool drain];
                pool = [[NSAutoreleasePool alloc] init];
            }
        }
        
        // if the final line doesn't have an end of line character, check to see if the buffer still has data
        // if so, try to parse the final line
        if (bufferPopulated) {

            tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
            // add a new line character
            completeLine = (char *)[[NSString stringWithFormat:@"%@\n", tmpCompleteLine] UTF8String];
            [tmpCompleteLine release], tmpCompleteLine = nil;

            // get the current offset, then write the line to the main file
            currentOffset = ftell(existingFile);
            fputs(completeLine, existingFile);
            
            BOOL success = [self parseEntryTableLine:completeLine withOffset:currentOffset context:context updates:YES];
            if (success) {
                updatedTotal++;
                batchItems++;
            }
        }
        
        [collectLine release], collectLine = nil;
        
        [pool drain];
        
        fclose(existingFile);
        fclose(updateFile);
        
        error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
        }
        
        NSLog(@"total entry table items added or updated: %d", updatedTotal);
        
        // now we've processed the entry table file, delete the update file
        error = nil;
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        [localFileManager removeItemAtPath:updateFilePath error:&error];
        
        if (error) {
            NSLog(@"Error while deleting entry table update file: %@", [error localizedDescription]);
        }
        
        // fire a notification - this one is 50%
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            CGFloat progress = 0.5f;
            CGFloat overall = kSCHDictionaryFileUnzipMaxPercentage + ((1 - kSCHDictionaryFileUnzipMaxPercentage) * progress);
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:overall], @"currentPercentage",
                                      nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryProcessingPercentageUpdate object:nil userInfo:userInfo];
            
        });

        
        [localFileManager release];
        [context release];
        
    });
}

- (void)updateParseWordFormTable
{
    
    NSLog(@"Updating word form table...");
    
    dispatch_sync([SCHDictionaryAccessManager sharedAccessManager].dictionaryAccessQueue, ^{
        
        // parse the new text file
        SCHDictionaryDownloadManager *dictManager = self;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSString *filePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"WordFormTable.txt"];
        NSError *error = nil;
        char *completeLine;
        NSMutableData *collectLine = nil;                
        NSString *tmpCompleteLine = nil;        
        size_t strLength = 0;
        
        FILE *file = fopen([filePath UTF8String], "r");
        char line[kSCHDictionaryManifestEntryWordFormTableBufferSize];
        
        int updatedTotal = 0;
        int batchItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        BOOL bufferPopulated = NO;
        
        if (file != NULL) {
            setlinebuf(file);
            while (fgets(line, kSCHDictionaryManifestEntryWordFormTableBufferSize, file) != NULL) {
                
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];                                        
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                        [tmpCompleteLine release], tmpCompleteLine = nil;
                        bufferPopulated = NO;
                    }
                    
                    BOOL success = [self parseWordFormLine:completeLine context:context updates:YES];
                                        
                    if (success) {
                        updatedTotal++;
                        batchItems++; 
                    }
                    
                    if (batchItems > 1000) {
                        batchItems = 0;
                        if (![context save:&error]) {
                            NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
                        }
                        
                        [context reset];
                        [pool drain];
                        pool = [[NSAutoreleasePool alloc] init];
                    } 
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
                    
                    bufferPopulated = YES;
                }
                
            }   
            
            if (bufferPopulated) {
                tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                // add a new line character
                completeLine = (char *)[tmpCompleteLine UTF8String];
                [tmpCompleteLine release], tmpCompleteLine = nil;
                
                BOOL success = [self parseWordFormLine:completeLine context:context updates:YES];
                
                if (success) {
                    updatedTotal++;
                    batchItems++; 
                }

            }
            
            [collectLine release], collectLine = nil;
            
            [pool drain];
            
            fclose(file);
            
            if (![context save:&error]) {
                NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
            }
            
            
            NSLog(@"total word form items added or updated: %d", updatedTotal);
            
            // fire a notification - this one is 100%
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                CGFloat progress = 1.0f;
                CGFloat overall = kSCHDictionaryFileUnzipMaxPercentage + ((1 - kSCHDictionaryFileUnzipMaxPercentage) * progress);
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:overall], @"currentPercentage",
                                          nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryProcessingPercentageUpdate object:nil userInfo:userInfo];
                
            });

            error = nil;
            NSFileManager *localFileManager = [[NSFileManager alloc] init];
            [localFileManager removeItemAtPath:filePath error:&error];
            [localFileManager release], localFileManager = nil;
            
            if (error) {
                NSLog(@"Error while deleting word form update file: %@", [error localizedDescription]);
            }
        }
        [context release];        
    });
}

#pragma mark - Core Data - App Dictionary State

- (void)withAppDictionaryStatePerform:(void(^)(SCHAppDictionaryState *))block
{
    NSAssert(self.mainThreadManagedObjectContext != nil, @"mainThreadManagedObjectContext nil in withAppDictionaryStatePerform");

    dispatch_block_t action = ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHAppDictionaryState inManagedObjectContext:self.mainThreadManagedObjectContext];
        [fetchRequest setEntity:entity];
    
        NSError *error = nil;				
        NSArray *results = [self.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [fetchRequest release];
	
        if (!results) {
            NSLog(@"error when retrieving app dictionary state: %@", [error localizedDescription]);
            return;
        }

        SCHAppDictionaryState *state;
        
        if (results && [results count] == 1) {
            state = [results objectAtIndex:0];
        } else {
            // otherwise, create a dictionary state object
            state = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppDictionaryState 
                                                                            inManagedObjectContext:self.mainThreadManagedObjectContext];
            state.State = [NSNumber numberWithInt:SCHDictionaryProcessingStateUserSetup];
        }
            
        block(state);
        
        if ([self.mainThreadManagedObjectContext hasChanges] && ![self.mainThreadManagedObjectContext save:&error]) {
            NSLog(@"Error while saving app dictionary state: %@", error);
        }
    };
    
    if ([NSThread isMainThread]) {
        action();
    } else {
        dispatch_sync(dispatch_get_main_queue(), action);
    }
}

- (BOOL)save:(NSError **)error
{
    __block BOOL rtn;
    dispatch_block_t saveBlock = ^{
        NSError *localError = nil;
        rtn = [self.mainThreadManagedObjectContext save:&localError];
        *error = [localError retain];
    };
    if ([NSThread isMainThread]) {
        saveBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), saveBlock);
    }
    
    [*error autorelease];
    return rtn;
}

#pragma mark - user control

- (void)beginDictionaryDownload
{
    if (!self.isProcessing || [self stateIsWaitingForUserInteraction]) {
        SCHDictionaryProcessingState state = [self dictionaryProcessingState];
        
        self.userRequestState = SCHDictionaryUserAccepted;
        
        if ((state == SCHDictionaryProcessingStateUserSetup) || 
            (state == SCHDictionaryProcessingStateUserDeclined) || 
            (state == SCHDictionaryProcessingStateNotEnoughFreeSpace) || 
            (state == SCHDictionaryProcessingStateUnexpectedConnectivityFailure) || 
            (state == SCHDictionaryProcessingStateError)) {
            
            dispatch_block_t needsManifestBlock = ^{
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                [self checkOperatingStateImmediately:YES];
            };
            
            if (state == SCHDictionaryProcessingStateError) {
                [self deleteDictionaryFileWithCompletionBlock:needsManifestBlock];
            } else {
                needsManifestBlock();
            }
            NSLog(@"Set user request state to %d", self.userRequestState);
        }
    }
    
}

- (void)deleteDictionaryFileWithCompletionBlock:(dispatch_block_t)completion
{
    self.isProcessing = YES;
    [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateDeleting];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // move the dictionary files to tmp and delete in the background 
        NSString *dictionaryTmpDirectory = [NSString stringWithFormat:@"%@-%@", [self dictionaryTmpDirectory], [NSDate date]];
        NSError *error = nil;
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        NSString *dictionaryDir = [self dictionaryDirectory];
                
        BOOL successfullyMovedToTmp = [fileManager moveItemAtPath:dictionaryDir 
                                                           toPath:dictionaryTmpDirectory error:&error];
        
        if (!successfullyMovedToTmp) {
            NSLog(@"Failed to move dictionary %@ : %@", error, [error userInfo]);
            [fileManager removeItemAtPath:dictionaryDir error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isProcessing = NO;

            if (completion) {
                completion();
            }            
        });
        
        if (successfullyMovedToTmp) {
            [fileManager removeItemAtPath:dictionaryTmpDirectory error:nil];
        }
    });
    
}
         
- (void)deleteDictionary
{
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    if (state == SCHDictionaryProcessingStateReady) {
        
        [(AppDelegate_Shared *)[[UIApplication sharedApplication] delegate] resetDictionaryStore];
        
        [self deleteDictionaryFileWithCompletionBlock:^{
            self.currentDictionaryDownloadPercentage = 0;
            self.currentDictionaryProcessingPercentage = 0;
            
            [self setUserRequestState:SCHDictionaryUserDeclined];
            [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
        }];
    }
}

@end
