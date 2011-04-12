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
#import "SCHDictionaryParseOperation.h"

#import "SCHDictionaryWordForm.h"
#import "SCHDictionaryEntry.h"

#pragma mark Dictionary Version Class

@implementation SCHDictionaryManifestEntry

@synthesize fromVersion, toVersion, url;

@end

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

// locks for word form and entry table files
@property (nonatomic, retain) NSLock *wordFormMutationLock;
@property (nonatomic, retain) NSLock *entryTableMutationLock;



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

// Core Data Save method
- (BOOL)save:(NSError **)error;

@end


// mutation count - additional check for thread safety
static int mutationCount = 0;


#pragma mark -

@implementation SCHDictionaryManager

@synthesize backgroundTask, dictionaryDownloadQueue;
@synthesize wifiReach, startTimer, wifiAvailable, connectionIdle;
@synthesize isProcessing;
@synthesize manifestUpdates;
@synthesize threadSafeMutationLock, wordFormMutationLock, entryTableMutationLock;

#pragma mark -
#pragma mark Object Lifecycle

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.dictionaryDownloadQueue = nil;
	[self.wifiReach stopNotifier];
	self.wifiReach = nil;
    self.threadSafeMutationLock = nil;
    self.wordFormMutationLock = nil;
    self.entryTableMutationLock = nil;
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
        self.wordFormMutationLock = [[NSLock alloc] init];
        self.entryTableMutationLock = [[NSLock alloc] init];
		
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
#pragma mark Dictionary Definition Methods

- (NSString *) HTMLForWord: (NSString *) dictionaryWord
{
    if ([self dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        NSLog(@"Dictionary is not ready yet!");
        return nil;
    }
    
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
    
    long offset = [entry.fileOffset longValue];
    
    NSString *result = nil;
    
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    
    NSString *filePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
    [self.entryTableMutationLock lock];
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    setlinebuf(file);
    char line[6560];
    
    //NSLog(@"Seeking to offset %ld", offset);
    
    fseek(file, offset, 0);
    
    if (fgets(line, 6560, file) != NULL) {
        char *start, *entryID, *headword, *level, *entryXML;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            entryID = strtok(NULL, sep);                    // MATCH
            if (entryID != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    level = strtok(NULL, sep);              // MATCH YD/OD
                    if (level != NULL) {
                        entryXML = strtok(NULL, sep);
                        if (entryXML != NULL) {
                            result = [NSString stringWithCString:entryXML encoding:NSUTF8StringEncoding];
                        }
                    }
                }
            }
        }
    }
    
    
    fclose(file);
    [self.entryTableMutationLock unlock];
    
    return result;
    
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
                [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsDownload];
                [self processDictionary];
            } else {
                [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateReady];
                [self processDictionary];
            }
            
			return;
			break;
		}	
		case SCHDictionaryProcessingStateNeedsDownload:
		{
			NSLog(@"needs download...");
            
            // FIXME: Gordon, check this workaround is correct
            
            if (self.manifestUpdates == nil) {
                [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
                [self processDictionary];
                return;
            }
            
            // figure out which dictionary file we're downloading
            SCHDictionaryManifestEntry *entry = [self.manifestUpdates objectAtIndex:0];
            
			// create dictionary download operation
			SCHDictionaryFileDownloadOperation *downloadOp = [[SCHDictionaryFileDownloadOperation alloc] init];
            downloadOp.manifestEntry = entry;
			
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
                
                [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsParse];
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

            SCHDictionaryManifestEntry *entry = [self.manifestUpdates objectAtIndex:0];

			// create dictionary parse operation
			SCHDictionaryParseOperation *parseOp = [[SCHDictionaryParseOperation alloc] init];
			parseOp.manifestEntry = entry;
            
			// dictionary processing is redispatched on completion
			[parseOp setCompletionBlock:^{
                self.dictionaryVersion = entry.toVersion;
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
            
            NSLog(@"a: %@", [self HTMLForWord:@"a"]);
            NSLog(@"badger: %@", [self HTMLForWord:@"badger"]);
            NSLog(@"rosy: %@", [self HTMLForWord:@"rosy"]);
            NSLog(@"teuchter: %@", [self HTMLForWord:@"teuchter"]);
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

- (NSString *)dictionaryTextFilesDirectory 
{
    NSString *libraryCacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dictionaryDirectory = [libraryCacheDirectory stringByAppendingPathComponent:@"Dictionary/Current"];
    
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

- (NSString *) dictionaryZipPath
{
    if ([[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion] == nil) {
        return [[self dictionaryDirectory] 
                stringByAppendingPathComponent:@"dictionary.zip"];
    } else {
        return [[self dictionaryDirectory] 
                stringByAppendingPathComponent:[NSString stringWithFormat:@"dictionary-%@.zip", 
                                                [[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion]]];
    }
}

#pragma mark -
#pragma mark Dictionary Version

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

#pragma mark -
#pragma mark Dictionary State

- (void)threadSafeUpdateDictionaryState: (SCHDictionaryProcessingState) newState 
{
    NSLog(@"Updating state to %d", newState);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self.threadSafeMutationLock lock];
	
    {
        ++mutationCount;
        if(mutationCount != 1) {
			[NSException raise:@"SCHDictionaryManagerMutationException" 
						format:@"Mutation count is greater than 1; multiple threads are accessing data in an unsafe manner."];
        }
        SCHDictionaryManager *dictionaryManager = [SCHDictionaryManager sharedDictionaryManager];
        SCHAppDictionaryState *state = [dictionaryManager appDictionaryState];
        if (nil == state) {
            NSLog(@"Failed to retrieve dictionary state object in SCHDictionaryManager threadSafeUpdateDictionaryState");
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

#pragma mark -
#pragma mark Dictionary Parsing Methods

- (void)initialParseEntryTable
{
    NSLog(@"Parsing entry table...");
    
 
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    
    NSString *filePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    NSError *error = nil;
    
   	[self.entryTableMutationLock lock];
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    char line[6560];
    
    long currentOffset = 0;
    
    int batchItems = 0;
    int savedItems = 0;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    while (fgets(line, 6560, file) != NULL) {
        
        char *start, *entryID, *headword, *level;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            entryID = strtok(NULL, sep);                    // MATCH
            if (entryID != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    level = strtok(NULL, sep);              // MATCH YD/OD
                }
            }
        }
        
        //        NSLog(@"Word: %@ Line offset: %ld", [NSString stringWithCString:headword encoding:NSUTF8StringEncoding], currentOffset);
		SCHDictionaryEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryEntry inManagedObjectContext:context];
        entry.word = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
        entry.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
        entry.fileOffset = [NSNumber numberWithLong:currentOffset];
        entry.category = [NSString stringWithCString:level encoding:NSUTF8StringEncoding];
        
        savedItems++;
        batchItems++;
        
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
        
        currentOffset = ftell(file);
    };
    
    [pool drain];
    fclose(file);
   	[self.entryTableMutationLock unlock];
    
    
    [context save:&error];
    
    if (error)
    {
        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
    } else {
        NSLog(@"Added %d entries to base words.", savedItems);
    }
}

- (void)initialParseWordFormTable
{
    NSLog(@"Parsing word form table...");
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    
    NSString *filePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"WordFormTable.txt"];
    NSError *error = nil;
    
   	[self.wordFormMutationLock lock];
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    setlinebuf(file);
    char line[90];
    
    int savedItems = 0;
    int batchItems = 0;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    while (fgets(line, 90, file) != NULL) {
        char *start, *wordform, *headword, *entryID, *category;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            wordform = strtok(NULL, sep);                   // search
            if (wordform != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    entryID = strtok(NULL, sep);            // MATCH
                    if (entryID != NULL) {
                        category = strtok(NULL, sep);      // MATCH YD/OD/ALL
                    }
                }
            }
        }
        
		SCHDictionaryWordForm *form = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryWordForm inManagedObjectContext:context];
        form.word = [NSString stringWithCString:wordform encoding:NSUTF8StringEncoding];
        form.rootWord = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
        form.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
        form.category = [NSString stringWithCString:category encoding:NSUTF8StringEncoding];
        
        savedItems++;
        batchItems++;
        
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
        
        
    };    
    
    [pool drain];
    
    fclose(file);
   	[self.wordFormMutationLock unlock];
    
    [context save:&error];
    
    if (error)
    {
        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
    } else {
        NSLog(@"Added %d entries to word entries.", savedItems);
    }
    
}

- (void) updateParseEntryTable
{
    NSLog(@"Updating entry table...");
    
    NSError *error = nil;
    
    // first, merge this file into the existing entry table file
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    
    NSString *existingFilePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    NSString *updateFilePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
   	[self.entryTableMutationLock lock];
    // open the two files
    // "a" opens a file for writing at the end, no need to seek
    FILE *existingFile = fopen([existingFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a");
    FILE *updateFile = fopen([updateFilePath cStringUsingEncoding:NSUTF8StringEncoding], "r");

    if (existingFile == NULL || updateFile == NULL) {
        NSLog(@"Warning: could not read a file in updateParseEntryTable..");
        return;
    }
    
    char line[6560];
    setlinebuf(updateFile);
    long currentOffset = 0;

    int updatedTotal = 0;
    int batchItems = 0;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 

    // go through each line of the update file
    while (fgets(line, 6560, updateFile) != NULL) {
        
        // get the current offset, then write the line to the main file
        currentOffset = ftell(existingFile);
        fputs(line, existingFile);
        
        // parse out the necessary information from the new line
        char *start, *entryID, *headword, *level;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            entryID = strtok(NULL, sep);                    // MATCH
            if (entryID != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    level = strtok(NULL, sep);              // MATCH YD/OD
                }
            }
        }
        
        SCHDictionaryEntry *entry = nil;
        
        // try to find an existing core data entry to update
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryEntry 
                                                  inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
        [fetchRequest setEntity:entity];
        entity = nil;
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"baseWordID == %@", [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding]];
        
        [fetchRequest setPredicate:pred];
        pred = nil;
        
        NSArray *results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
        
        [fetchRequest release], fetchRequest = nil;
        
        if (error) {
            NSLog(@"error when retrieving word with ID %@: %@", [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding], [error localizedDescription]);
            entry = nil;
        }
        
        if (!results || [results count] != 1) {
            int resultCount = -1;
            if (results) {
                resultCount = [results count];
            }
            
            entry = nil;
        } else {
            entry = [results objectAtIndex:0];
        }
        
        
        results = nil;
        
        if (entry) {
            [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] refreshObject:entry mergeChanges:YES];
            entry.word = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
            entry.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
            entry.fileOffset = [NSNumber numberWithLong:currentOffset];
            entry.category = [NSString stringWithCString:level encoding:NSUTF8StringEncoding];
        } else {
            entry = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryEntry inManagedObjectContext:context];
            entry.word = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
            entry.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
            entry.fileOffset = [NSNumber numberWithLong:currentOffset];
            entry.category = [NSString stringWithCString:level encoding:NSUTF8StringEncoding];
        }
        
        updatedTotal++;
        batchItems++;
        
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

    [pool drain];
    
    fclose(existingFile);
    fclose(updateFile);

    error = nil;
    [context save:&error];

    if (error)
    {
        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
    }

   	[self.entryTableMutationLock unlock];

    NSLog(@"total entry table items added or updated: %d", updatedTotal);
    
    // now we've processed the entry table file, delete the update file
    error = nil;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    [localFileManager removeItemAtPath:updateFilePath error:&error];
    
    if (error) {
        NSLog(@"Error while deleting entry table update file: %@", [error localizedDescription]);
    }

}

- (void) updateParseWordFormTable
{
    
    NSLog(@"Updating word form table...");
    
    // parse the new text file
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    
    NSString *filePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"WordFormTable.txt"];
    NSError *error = nil;
    
   	[self.wordFormMutationLock lock];
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    setlinebuf(file);
    char line[90];
    
    int updatedTotal = 0;
    int batchItems = 0;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    while (fgets(line, 90, file) != NULL) {
        char *start, *wordform, *headword, *entryID, *category;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            wordform = strtok(NULL, sep);                   // search
            if (wordform != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    entryID = strtok(NULL, sep);            // MATCH
                    if (entryID != NULL) {
                        category = strtok(NULL, sep);      // MATCH YD/OD/ALL
                    }
                }
            }
        }
        
        NSString *dictWord = [NSString stringWithCString:wordform encoding:NSUTF8StringEncoding];
        SCHDictionaryWordForm *dictionaryWordForm = nil;
        
        // try to fetch a core data object matching this entry
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryWordForm 
                                                  inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
        [fetchRequest setEntity:entity];
        entity = nil;
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"word == %@", dictWord];
        
        [fetchRequest setPredicate:pred];
        pred = nil;
        
        NSArray *results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
        
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
            [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] refreshObject:dictionaryWordForm mergeChanges:YES];
            dictionaryWordForm.word = [NSString stringWithCString:wordform encoding:NSUTF8StringEncoding];
            dictionaryWordForm.rootWord = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
            dictionaryWordForm.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
            dictionaryWordForm.category = [NSString stringWithCString:category encoding:NSUTF8StringEncoding];
        } else {
             dictionaryWordForm = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryWordForm inManagedObjectContext:context];
             dictionaryWordForm.word = [NSString stringWithCString:wordform encoding:NSUTF8StringEncoding];
             dictionaryWordForm.rootWord = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
             dictionaryWordForm.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
             dictionaryWordForm.category = [NSString stringWithCString:category encoding:NSUTF8StringEncoding];
            NSLog(@"Created new word form: %@ %@ %@ %@", dictionaryWordForm.word, dictionaryWordForm.rootWord, dictionaryWordForm.baseWordID, dictionaryWordForm.category);
        }
        
        updatedTotal++;
        batchItems++;
        
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
        
        
    };    
    
    [pool drain];
    
    fclose(file);
   	[self.wordFormMutationLock unlock];
    
    
    error = nil;
    [context save:&error];
    
    if (error)
    {
        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
    }
    
    
    NSLog(@"total word form items added or updated: %d", updatedTotal);
    
    error = nil;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    [localFileManager removeItemAtPath:filePath error:&error];
    
    if (error) {
        NSLog(@"Error while deleting word form update file: %@", [error localizedDescription]);
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
    [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] lock];
	[[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:saveNotification];
    [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] unlock];
}

- (BOOL)save:(NSError **)error
{
    return [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] save:error];
}



@end
