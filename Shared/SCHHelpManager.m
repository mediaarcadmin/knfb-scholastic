//
//  SCHHelpManager.m
//  Scholastic
//
//  Created by Matt Farrugia on 04/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHHelpManager.h"
#import "Reachability.h"
#import "SCHAppHelpState.h"
#import "SCHHelpVideoManifestOperation.h"
#import "SCHHelpVideoFileDownloadOperation.h"
#import "SCHCoreDataHelper.h"

NSString * const kSCHHelpDownloadPercentageUpdate = @"kSCHHelpDownloadPercentageUpdate";
NSString * const kSCHHelpStateChange = @"kSCHHelpStateChange";
char * const kSCHHelpManifestEntryColumnSeparator = "\t";

static NSString * const kSCHHelpVideosDirectoryName = @"HelpVideos";


#pragma mark Class Extension

@interface SCHHelpManager()

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (readwrite, retain) NSOperationQueue *downloadQueue;
@property (readwrite, retain) Reachability *reachability;
@property (readwrite, retain) NSTimer *startTimer;
@property (readwrite) float currentHelpVideoDownloadPercentage;
@property BOOL internetAvailable;

- (void)reachabilityCheck: (Reachability *) curReach;
- (void)enterBackground;
- (void)enterForeground;
- (void)checkOperatingStateImmediately:(BOOL)immediately;
- (void)processHelp;
- (BOOL)save:(NSError **)error;

@end

#pragma mark -

@implementation SCHHelpManager

@synthesize backgroundTask;
@synthesize downloadQueue;
@synthesize reachability;
@synthesize startTimer;
@synthesize internetAvailable;
//@synthesize connectionIdle;
@synthesize isProcessing;
@synthesize mainThreadManagedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize currentHelpVideoDownloadPercentage;
@synthesize helpVideoManifest;

#pragma mark -
#pragma mark Object Lifecycle

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.downloadQueue = nil;
	
    [self.reachability stopNotifier];
	self.reachability = nil;
    
    self.mainThreadManagedObjectContext = nil;
    self.persistentStoreCoordinator = nil;
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		self.downloadQueue = [[[NSOperationQueue alloc] init] autorelease];
		[self.downloadQueue setMaxConcurrentOperationCount:1];
		
		self.internetAvailable = YES;
		//self.connectionIdle = YES;
		
		self.reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	   
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(helpVideoDownloadPercentageUpdate:) 
                                                     name:kSCHHelpDownloadPercentageUpdate 
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

static SCHHelpManager *sharedManager = nil;

+ (SCHHelpManager *)sharedHelpManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHHelpManager alloc] init];
        
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
        
		[sharedManager.reachability startNotifier];
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
        
		if ((self.downloadQueue && [self.downloadQueue operationCount]) ) {
			NSLog(@"Help download needs more time - going into the background.");
			
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
					[self.downloadQueue waitUntilAllOperationsAreFinished];
					NSLog(@"help download queue is finished!");
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
 
	NSLog(@"Entering foreground - quitting help background task.");
	if(self.backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
		self.backgroundTask = UIBackgroundTaskInvalid;
	}		
	
	[sharedManager reachabilityCheck:sharedManager.reachability];
}


#pragma mark -
#pragma mark Reachability reactions

- (void)reachabilityNotification:(NSNotification *)note
{
	Reachability* curReach = [note object];
	[self reachabilityCheck:curReach];
}

- (void)reachabilityCheck:(Reachability *)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
	switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"No network; suspending Help download.");
            self.internetAvailable = NO;
            break;
        }
        case ReachableViaWWAN:
        case ReachableViaWiFi:
        {
			NSLog(@"Network available; help download can begin.");
			self.internetAvailable = YES;
			break;
		}
    }
	
	[self checkOperatingStateImmediately:NO];
}

#pragma mark -
#pragma mark Check Operating State

- (void)checkOperatingStateImmediately:(BOOL)immediately
{
	
	if (self.internetAvailable) {
        
		// start the countdown from 3 seconds again
		if (self.startTimer && [self.startTimer isValid]) {
			[self.startTimer invalidate];
			self.startTimer = nil; 
		} 
        
		NSLog(@"********* Starting timer...");
        if (immediately) {
            [self processHelp];
        } else {
            self.startTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                               target:self
                                                             selector:@selector(processHelp)
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
		[self.downloadQueue cancelAllOperations];
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCHHelpStateChange object:nil userInfo:nil];
}

#pragma mark -
#pragma mark Processing Methods

- (void)processHelp
{
	if ([NSThread currentThread] != [NSThread mainThread]) {
		[self performSelectorOnMainThread:@selector(processHelp) withObject:nil waitUntilDone:NO];
		return;
	}
	
    if (!self.internetAvailable) {
        NSLog(@"Process help called, but no wifi available.");
		return;
	}
    
    if (self.isProcessing) {
        NSLog(@"Process help called, but help is already processing.");
        return;
    }
	
    SCHHelpProcessingState state = [self helpProcessingState];
	NSLog(@"**** Calling processHelp with state %d...", state);
    
	switch (state) {
        case SCHHelpProcessingStateHelpVideoManifest:
        {
            // check to see if we need to download help videos
            NSString *lastPrefUpdate = [self helpVideoVersion];
            
            // this could be changed to a version check - if the version 
            // in the manifest is higher, redownload the videos
            if (!lastPrefUpdate) {
                NSLog(@"needs help video manifest...");
                // create manifest processing operation
                SCHHelpVideoManifestOperation *manifestOp = [[SCHHelpVideoManifestOperation alloc] init];
                
                // dictionary processing is redispatched on completion
                [manifestOp setNotCancelledCompletionBlock:^{
                    [self processHelp];
                }];
                
                // add the operation to the queue
                [self.downloadQueue addOperation:manifestOp];
                [manifestOp release];
                return;
                break;
            } else {
                [self threadSafeUpdateHelpState:SCHHelpProcessingStateReady];
            }
            break;
        }
        case SCHHelpProcessingStateDownloadingHelpVideos:
        {
            NSLog(@"Downloading help videos...");
            
            // if there's no manifest set, restart the process
            if (!self.helpVideoManifest) {
                [self threadSafeUpdateHelpState:SCHHelpProcessingStateHelpVideoManifest];
                [self processHelp];
                return;
            }
            
			// create help download operation
			SCHHelpVideoFileDownloadOperation *downloadOp = [[SCHHelpVideoFileDownloadOperation alloc] init];
            downloadOp.videoManifest = self.helpVideoManifest;
            self.currentHelpVideoDownloadPercentage = 0.0;
            
			// dictionary processing is redispatched on completion
			[downloadOp setNotCancelledCompletionBlock:^{
				[self processHelp];
			}];
			
			// add the operation to the queue
			[self.downloadQueue addOperation:downloadOp];
			[downloadOp release];
			return;
			break;
            
            
        }
        default:
			break;
	}
}

#pragma mark -
#pragma mark Help Location

- (BOOL)haveHelpVideosDownloaded
{
    NSString *helpVideoVersion = [self helpVideoVersion];
    return (helpVideoVersion?YES:NO);
}

- (NSString *)helpVideoDirectory
{
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *helpDirectory = [applicationSupportDirectory stringByAppendingPathComponent:kSCHHelpVideosDirectoryName];
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDirectory = NO;
    
    if (![localFileManager fileExistsAtPath:helpDirectory isDirectory:&isDirectory]) {
        [localFileManager createDirectoryAtPath:helpDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Warning: problem creating help video directory. %@", [error localizedDescription]);
        }
    }
    
    [localFileManager release];
    
    return helpDirectory;
}

#pragma mark - Help Video Version

- (NSString *)helpVideoVersion
{
    __block NSString *helpVideoVersion;
    [self withAppHelpStatePerform:^(SCHAppHelpState *state) {
        helpVideoVersion = [[state helpVideoVersion] retain];
    }];
    return [helpVideoVersion autorelease];
}

- (NSString *)helpVideoOlderURL
{
    __block NSString *helpVideoURL;
    [self withAppHelpStatePerform:^(SCHAppHelpState *state) {
        helpVideoURL = [[state helpVideoOlderURL] retain];
    }];
    return [helpVideoURL autorelease];
}

- (NSString *)helpVideoYoungerURL
{
    __block NSString *helpVideoURL;
    [self withAppHelpStatePerform:^(SCHAppHelpState *state) {
        helpVideoURL = [[state helpVideoYoungerURL] retain];
    }];
    return [helpVideoURL autorelease];
}

- (void)threadSafeUpdateHelpVideoVersion:(NSString *)newVersion olderURL:(NSString *)olderURL youngerURL:(NSString*)youngerURL
{
    [self withAppHelpStatePerform:^(SCHAppHelpState *state) {
        state.helpVideoVersion = newVersion;
        state.helpVideoOlderURL = olderURL;
        state.helpVideoYoungerURL = youngerURL;
    }];	
}

#pragma mark -
#pragma mark Help State

- (void)threadSafeUpdateHelpState:(SCHHelpProcessingState)newState 
{
    NSLog(@"Updating state to %d", newState);
    
    [self withAppHelpStatePerform:^(SCHAppHelpState *state) {
        state.State = [NSNumber numberWithInt:(int)newState];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHHelpStateChange object:nil userInfo:nil];
    }];
}

- (SCHHelpProcessingState)helpProcessingState
{
    __block SCHHelpProcessingState processingState;
    [self withAppHelpStatePerform:^(SCHAppHelpState *state) {
        processingState = [state.State intValue];
    }];
    return processingState;
}

- (void)helpVideoDownloadPercentageUpdate:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *currentPercentage = [userInfo objectForKey:@"currentPercentage"];
    
    if (currentPercentage != nil) {
        self.currentHelpVideoDownloadPercentage = [currentPercentage floatValue];
    }
}

#pragma mark - Update Check

- (void)checkIfHelpUpdateNeeded
{
    
    if (!self.isProcessing) {
        SCHHelpProcessingState state = [self helpProcessingState];
        
        if (state == SCHHelpProcessingStateError || state == SCHHelpProcessingStateNotEnoughFreeSpace) {
            NSLog(@"There was an error - try the help again.");
            [self threadSafeUpdateHelpState:SCHHelpProcessingStateHelpVideoManifest];
        } else if (state == SCHHelpProcessingStateReady) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // check to see if we need to do an update
            bool doUpdate = NO;
            
            NSDate *lastPrefUpdate = [defaults objectForKey:@"lastHelpUpdateDate"];
            NSDate *currentDate = [[NSDate alloc] init];
            
            // if there's no default, set the current date
            if (lastPrefUpdate == nil) {
                [defaults setValue:currentDate forKey:@"lastHelpUpdateDate"];
                [defaults synchronize];
                doUpdate = YES;
            } else {
                double timeInterval = [currentDate timeIntervalSinceDate:lastPrefUpdate];
                
                // have we updated in the last 24 hours?
                if (timeInterval >= 86400) {
                    [defaults setValue:currentDate forKey:@"lastHelpUpdateDate"];
                    [defaults synchronize];					
                }
            }		
            
            [currentDate release];
            
            if (doUpdate) {
                NSLog(@"Help needs an update check.");
                [self threadSafeUpdateHelpState:SCHHelpProcessingStateHelpVideoManifest];
            }
        }
        
        [self processHelp];
    }
}

#pragma mark - Core Data - App Help State

- (void)withAppHelpStatePerform:(void(^)(SCHAppHelpState *))block
{
    dispatch_block_t action = ^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHAppHelpState inManagedObjectContext:self.mainThreadManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;				
        NSArray *results = [self.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [fetchRequest release];
        
        if (!results) {
            NSLog(@"error when retrieving app dictionary state: %@", [error localizedDescription]);
            return;
        }
        
        SCHAppHelpState *state;
        
        if (results && [results count] == 1) {
            state = [results objectAtIndex:0];
        } else {
            // otherwise, create a dictionary state object
            state = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppHelpState 
                                                  inManagedObjectContext:self.mainThreadManagedObjectContext];
            state.State = [NSNumber numberWithInt:SCHHelpProcessingStateHelpVideoManifest];
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

- (void)retryHelpDownload
{
    if (!self.isProcessing) {
        if (!((self.helpProcessingState == SCHHelpProcessingStateHelpVideoManifest) ||
              (self.helpProcessingState == SCHHelpProcessingStateDownloadingHelpVideos))) {
            [self threadSafeUpdateHelpState:SCHHelpProcessingStateHelpVideoManifest];
            [self checkOperatingStateImmediately:YES];
        }
    }
}

@end
