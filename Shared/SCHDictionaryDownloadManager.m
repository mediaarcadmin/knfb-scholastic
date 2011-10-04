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

// Constants
NSString * const kSCHDictionaryDownloadPercentageUpdate = @"SCHDictionaryDownloadPercentageUpdate";

NSString * const kSCHDictionaryStateChange = @"SCHDictionaryStateChange";

static NSString * const kSCHDictionaryDownloadDirectoryName = @"Dictionary";

int const kSCHDictionaryManifestEntryEntryTableBufferSize = 8192;
int const kSCHDictionaryManifestEntryWordFormTableBufferSize = 1024;

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

@property (readwrite) float currentDownloadPercentage;

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

// Core Data Save method
- (BOOL)save:(NSError **)error;

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
@synthesize currentDownloadPercentage;

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
		[sharedManager reachabilityCheck:sharedManager.wifiReach];        
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

- (void)enterForeground
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
	
	[self checkOperatingState];
}

#pragma mark -
#pragma mark Processing Manager reactions

- (void)connectionBecameIdle:(NSNotification *)notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not on main thread!");
	NSLog(@"****************** Processing manager became idle! ******************");
	self.connectionIdle = YES;
	[self checkOperatingState];
}

- (void)connectionBecameBusy:(NSNotification *)notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not on main thread!");
	NSLog(@"****************** Processing manager became busy! ******************");
	self.connectionIdle = NO;
	[self checkOperatingState];
}

#pragma mark -
#pragma mark Check Operating State

- (void)checkOperatingState
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
	if (self.wifiAvailable) {

		// start the countdown from 10 seconds again
		if (self.startTimer && [self.startTimer isValid]) {
			[self.startTimer invalidate];
			self.startTimer = nil; 
		} 

		NSLog(@"********* Starting timer...");
		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:10
														   target:self
														 selector:@selector(processDictionary)
														 userInfo:nil
														  repeats:NO];
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

- (void)processDictionary
{
	if ([NSThread currentThread] != [NSThread mainThread]) {
		[self performSelectorOnMainThread:@selector(processDictionary) withObject:nil waitUntilDone:NO];
		return;
	}
	
//	if (!self.wifiAvailable || !self.connectionIdle) {
    if (!self.wifiAvailable) {
        NSLog(@"Process dictionary called, but no wifi available.");
		return;
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
		case SCHDictionaryProcessingStateManifestVersionCheck:
		{
			NSLog(@"needs manifest version check...");
            
            bool processUpdate = NO;
            
            if (self.dictionaryVersion == nil) {
                processUpdate = YES;
            } else {
            
                for (SCHDictionaryManifestEntry *entry in self.manifestUpdates) {
                    NSLog(@"from: %@ to: %@ URL: %@", entry.fromVersion, entry.toVersion, entry.url);
                }
                
                
                NSArray *currentVersionComponents = [self.dictionaryVersion componentsSeparatedByString:@"."];
                
                if (!currentVersionComponents || [currentVersionComponents count] != 2) {
                    NSLog(@"Could not process version '%@'", self.dictionaryVersion);
                    return;
                }
                
                int currentMajorVersion = [[currentVersionComponents objectAtIndex:0] intValue];
                int currentMinorVersion = [[currentVersionComponents objectAtIndex:1] intValue];
                
                
                while ([self.manifestUpdates count] > 0) {
                    
                    NSArray *tmpVersionComponents = [[(SCHDictionaryManifestEntry *) [self.manifestUpdates objectAtIndex:0] toVersion]
                                                     componentsSeparatedByString:@"."];
                    
                    if (!tmpVersionComponents || [currentVersionComponents count] != 2) {
                        NSLog(@"Did not understand manifest version '%@'", [[self.manifestUpdates objectAtIndex:0] toVersion]);
                        break;
                    }
                    
                    int tmpMajorVersion = [[tmpVersionComponents objectAtIndex:0] intValue];
                    int tmpMinorVersion = [[tmpVersionComponents objectAtIndex:1] intValue];
                    
                    // if the version is greater than the current one, then we need to process this entry
                    if ((tmpMajorVersion > currentMajorVersion) 
                        || (tmpMajorVersion == currentMajorVersion && tmpMinorVersion > currentMinorVersion)) {
                        processUpdate = YES;
                        break;
                    } else {
                        // otherwise we need to remove this manifest entry and try again
                        [self.manifestUpdates removeObjectAtIndex:0];
                    }
                    
                }
            }
            
            if (processUpdate) {
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
            if (self.manifestUpdates == nil) {
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                [self processDictionary];
                return;
            }
            
            // figure out which dictionary file we're downloading
            SCHDictionaryManifestEntry *entry = [self.manifestUpdates objectAtIndex:0];
            
			// create dictionary download operation
			SCHDictionaryFileDownloadOperation *downloadOp = [[SCHDictionaryFileDownloadOperation alloc] init];
            downloadOp.manifestEntry = entry;
			self.currentDownloadPercentage = 0.0;
            
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
            
			// on completion, we need to check if we are on the first download, or subsequent downloads
			[unzipOp setCompletionBlock:^{
                
                // if this is the first download, move the two text files into the current directory
                // otherwise we leave them where they are - the update text files are deleted at the end of the update parse
                NSFileManager *localFileManager = [[NSFileManager alloc] init];
                BOOL firstRun = NO;
                
                SCHDictionaryManifestEntry *manifestEntry = [self.manifestUpdates objectAtIndex:0];
                
                if (manifestEntry.fromVersion == nil) {
                    firstRun = YES;
                }
                
                if (firstRun) {
                    NSString *currentLocation = [self dictionaryDirectory];
                    NSString *newLocation = [self dictionaryTextFilesDirectory];
                    
                    [localFileManager moveItemAtPath:[currentLocation stringByAppendingPathComponent:@"EntryTable.txt"]
                                              toPath:[newLocation stringByAppendingPathComponent:@"EntryTable.txt"] error:nil];
                    
                    [localFileManager moveItemAtPath:[currentLocation stringByAppendingPathComponent:@"WordFormTable.txt"]
                                              toPath:[newLocation stringByAppendingPathComponent:@"WordFormTable.txt"] error:nil];
                }
                
                [localFileManager release];
                
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsParse];
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

            // if there's no manifest set, restart the process
            // this prevents double processing in the event of interruptions during parsing
            if (self.manifestUpdates == nil) {
                [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                [self processDictionary];
                return;
            }

            SCHDictionaryManifestEntry *entry = [self.manifestUpdates objectAtIndex:0];

			// create dictionary parse operation
			SCHDictionaryParseOperation *parseOp = [[SCHDictionaryParseOperation alloc] init];
			parseOp.manifestEntry = entry;
            
			// when parsing is successful, delete the zip file
            // note the filename as it will change once we have parsed and know the version number
            NSString *dictionaryZipPath = [self dictionaryZipPath];
			[parseOp setCompletionBlock:^{
                self.dictionaryVersion = entry.toVersion;
                NSFileManager *localFileManager = [[NSFileManager alloc] init];
                [localFileManager removeItemAtPath:dictionaryZipPath error:nil];
                [localFileManager release];
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
        self.currentDownloadPercentage = [currentPercentage floatValue];
    }
}

- (void)startDictionaryDownload
{
    if (![self dictionaryDownloadStarted]) {
        [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
    }
}

#pragma mark - Update Check

- (void)checkIfUpdateNeeded
{
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    
    if (state == SCHDictionaryProcessingStateError || state == SCHDictionaryProcessingStateNotEnoughFreeSpace) {
        NSLog(@"There was an error - try the dictionary again.");
        [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
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
        char *completeLine, *start, *entryID, *headword, *level;
        NSMutableData *collectLine = nil;                
        NSString *tmpCompleteLine = nil;    
        size_t strLength = 0;
        
        FILE *file = fopen([filePath UTF8String], "r");
        char line[kSCHDictionaryManifestEntryEntryTableBufferSize];
        
        long currentOffset = 0;
        
        int batchItems = 0;
        int savedItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        if (file != NULL) {
            while (fgets(line, kSCHDictionaryManifestEntryEntryTableBufferSize, file) != NULL) {
                
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {                    
                        [collectLine appendBytes:line length:strlen(line)];                                        
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        [tmpCompleteLine release];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                    }
                    
                    start = strtok(completeLine, kSCHDictionaryManifestEntryColumnSeparator);
                    if (start != NULL) {
                        entryID = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);                    // MATCH
                        if (entryID != NULL) {
                            headword = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);
                            if (headword != NULL) {
                                level = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);              // MATCH YD/OD
                                if (level != NULL) {
                                    SCHDictionaryEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryEntry inManagedObjectContext:context];
                                    entry.word = [NSString stringWithUTF8String:headword];
                                    entry.baseWordID = [NSString stringWithUTF8String:entryID];
                                    entry.fileOffset = [NSNumber numberWithLong:currentOffset];
                                    entry.category = [NSString stringWithUTF8String:level];                        
                                    
                                    savedItems++;
                                    batchItems++;
                                }
                            }
                        }
                    }
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
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
            [collectLine release], collectLine = nil;
            [tmpCompleteLine release], tmpCompleteLine = nil;
            
            [pool drain];
            fclose(file);
            
            if (![context save:&error]) {
                NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
            } else {
                NSLog(@"Added %d entries to base words.", savedItems);
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
        char *completeLine, *start, *wordform, *headword, *entryID, *category;
        NSMutableData *collectLine = nil;
        NSString *tmpCompleteLine = nil;            
        size_t strLength = 0;
        
        FILE *file = fopen([filePath UTF8String], "r");
        char line[kSCHDictionaryManifestEntryWordFormTableBufferSize];
        
        int savedItems = 0;
        int batchItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        if (file != NULL) {
            setlinebuf(file);
            while (fgets(line, kSCHDictionaryManifestEntryWordFormTableBufferSize, file) != NULL) {
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];                    
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        [tmpCompleteLine release];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                    }
                    
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
                                        SCHDictionaryWordForm *form = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryWordForm inManagedObjectContext:context];
                                        form.word = [NSString stringWithUTF8String:wordform];
                                        form.rootWord = [NSString stringWithUTF8String:headword];
                                        form.baseWordID = [NSString stringWithUTF8String:entryID];
                                        form.category = [NSString stringWithUTF8String:category];
                                        
                                        savedItems++;
                                        batchItems++;          
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
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
            [collectLine release], collectLine = nil;
            [tmpCompleteLine release], tmpCompleteLine = nil;
            
            [pool drain];
            
            fclose(file);
            
            if (![context save:&error]) {
                NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
            } else {
                NSLog(@"Added %d entries to word entries.", savedItems);
            }
        }
        [context release];            
    });
}

- (void)updateParseEntryTable
{
    NSLog(@"Updating entry table...");
    
    dispatch_sync([SCHDictionaryAccessManager sharedAccessManager].dictionaryAccessQueue, ^{
        
        NSError *error = nil;
        char *completeLine, *start, *entryID, *headword, *level;
        NSMutableData *collectLine = nil;                
        NSString *tmpCompleteLine = nil;            
        size_t strLength = 0;
        
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
        
        // go through each line of the update file
        while (fgets(line, kSCHDictionaryManifestEntryEntryTableBufferSize, updateFile) != NULL) {
            if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                
                if (collectLine == nil) {
                    completeLine = line;
                } else {
                    [collectLine appendBytes:line length:strlen(line)];                                    
                    [collectLine appendBytes:(char []){'\0'} length:1];
                    [tmpCompleteLine release];
                    tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                    completeLine = (char *)[tmpCompleteLine UTF8String];
                    [collectLine release], collectLine = nil;
                }
                
                // get the current offset, then write the line to the main file
                currentOffset = ftell(existingFile);
                fputs(line, existingFile);
                
                start = strtok(completeLine, kSCHDictionaryManifestEntryColumnSeparator);
                if (start != NULL) {
                    entryID = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);                    // MATCH
                    if (entryID != NULL) {
                        headword = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);
                        if (headword != NULL) {
                            level = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);              // MATCH YD/OD
                            if (level != NULL) {
                                SCHDictionaryEntry *entry = nil;
                                
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
                                }
                                
                                if ([results count] != 1) {
                                    NSLog(@"error when retrieving word with ID %@: %d results retrieved.", [NSString stringWithUTF8String:entryID], [results count]);
                                    entry = nil;
                                } else {
                                    entry = [results objectAtIndex:0];
                                }
                                
                                results = nil;
                                
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
                                
                                updatedTotal++;
                                batchItems++;
                            }
                        }
                    }
                }
            } else {
                if (collectLine == nil) {
                    collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                } else {
                    [collectLine appendBytes:line length:strlen(line)];
                }
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
        [collectLine release], collectLine = nil;
        [tmpCompleteLine release], tmpCompleteLine = nil;
        
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
        char *completeLine, *start, *wordform, *headword, *entryID, *category;
        NSMutableData *collectLine = nil;                
        NSString *tmpCompleteLine = nil;        
        size_t strLength = 0;
        
        FILE *file = fopen([filePath UTF8String], "r");
        char line[kSCHDictionaryManifestEntryWordFormTableBufferSize];
        
        int updatedTotal = 0;
        int batchItems = 0;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        
        if (file != NULL) {
            setlinebuf(file);
            while (fgets(line, kSCHDictionaryManifestEntryWordFormTableBufferSize, file) != NULL) {
                
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];                                        
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        [tmpCompleteLine release];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                    }
                    
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
                                            int resultCount = -1;
                                            if (results) {
                                                resultCount = [results count];
                                            }
                                            
                                            NSLog(@"error when retrieving word %@: %d results retrieved.", dictWord, resultCount);
                                            dictionaryWordForm = nil;
                                        } else {
                                            dictionaryWordForm = [results objectAtIndex:0];
                                        }
                                        
                                        
                                        results = nil;
                                        
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
                                            NSLog(@"Created new word form: %@ %@ %@ %@", dictionaryWordForm.word, dictionaryWordForm.rootWord, dictionaryWordForm.baseWordID, dictionaryWordForm.category);
                                        }
                                        
                                        updatedTotal++;
                                        batchItems++;  
                                        
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
                                }
                            }
                        }
                    }
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
                }
                [collectLine release], collectLine = nil;
                [tmpCompleteLine release], tmpCompleteLine = nil;
            }   
            
            [pool drain];
            
            fclose(file);
            
            if (![context save:&error]) {
                NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
            }
            
            
            NSLog(@"total word form items added or updated: %d", updatedTotal);
            
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
            NSLog(@"Error while saving app dictionary state: %@", [error localizedDescription]);
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
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSError *localError = nil;
        rtn = [self.mainThreadManagedObjectContext save:&localError];
        *error = [localError retain];
    });
    [*error autorelease];
    return rtn;
}

#pragma mark - user control

- (void)beginDictionaryDownload
{
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    if (state == SCHDictionaryProcessingStateUserSetup || state == SCHDictionaryProcessingStateUserDeclined) {
        [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
        [self checkOperatingState];
    }
}

- (void)deleteDictionary
{
    SCHDictionaryProcessingState state = [self dictionaryProcessingState];
    if (state == SCHDictionaryProcessingStateReady) {
        
        [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateDeleting];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // move the dictionary files to tmp and delete in the background 
            NSString *dictionaryTmpDirectory = [self dictionaryTmpDirectory];
            NSError *error = nil;
            NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
            if (![fileManager moveItemAtPath:[self dictionaryDirectory] 
                                      toPath:dictionaryTmpDirectory error:&error]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                                                    message:NSLocalizedString(@"Failed to remove dictionary", @"remove dictionary error message")
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                });
            } else {
                // remove dictionary files from tmp in the background
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
                    [fileManager removeItemAtPath:dictionaryTmpDirectory error:nil];
                });
            }
            
            // move the core data operation to the background, should this fail
            // before it ends dictionary processing also makes sure that it is clear
            // prior to import
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // clear dictionary entries out of database
                NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
                [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
                
                NSError *error = nil;
                NSArray *entities = [NSArray arrayWithObjects:kSCHAppDictionaryState, kSCHDictionaryEntry, kSCHDictionaryWordForm, nil];
                for (NSString *entity in entities) {
                    if (![managedObjectContext BITemptyEntity:entity error:&error]) {
                        NSLog(@"error removing %@: %@", entity, error);
                    }
                }
                
                [managedObjectContext release];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
                });
            });
        });
    }
}

@end
