//
//  SCHDictionaryDownloadManager.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kSCHDictionaryDownloadPercentageUpdate = @"SCHDictionaryDownloadPercentageUpdate";

static NSString* const kSCHDictionaryStateChange = @"SCHDictionaryStateChange";

static int const kSCHDictionaryManifestEntryEntryTableBufferSize = 8192;
static int const kSCHDictionaryManifestEntryWordFormTableBufferSize = 1024;

static char * const kSCHDictionaryManifestEntryColumnSeparator = "\t";

typedef enum {
	SCHDictionaryProcessingStateError = 0,
	SCHDictionaryProcessingStateNotEnoughFreeSpace,
	SCHDictionaryProcessingStateNeedsManifest,
	SCHDictionaryProcessingStateManifestVersionCheck,
	SCHDictionaryProcessingStateNeedsDownload,
	SCHDictionaryProcessingStateNeedsUnzip,
	SCHDictionaryProcessingStateNeedsParse,
	SCHDictionaryProcessingStateReady
} SCHDictionaryProcessingState;


@interface SCHDictionaryManifestEntry : NSObject 
    
@property (nonatomic, retain) NSString *fromVersion;
@property (nonatomic, retain) NSString *toVersion;
@property (nonatomic, retain) NSString *url;
    
@end

@class SCHAppDictionaryState;

@interface SCHDictionaryDownloadManager : NSObject {

}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSMutableArray *manifestUpdates;

// the current dictionary version
@property (readwrite, retain) NSString *dictionaryVersion;

// dictionary is currently processing
@property BOOL isProcessing;

+ (SCHDictionaryDownloadManager *) sharedDownloadManager;

// the local dictionary directory
- (NSString *) dictionaryDirectory;

// the location of the downloaded zip file
- (NSString *) dictionaryZipPath;

// the location that the current version of the 
// entry table/word form text files are stored
- (NSString *)dictionaryTextFilesDirectory;

// execute a block in Core Data context with access to the current AppDictionaryState
- (void)withAppDictionaryStatePerform:(void (^)(SCHAppDictionaryState *state))block;

- (void)threadSafeUpdateDictionaryState:(SCHDictionaryProcessingState)processingState;
- (SCHDictionaryProcessingState) dictionaryProcessingState;

// parsing methods called by the parsing operation
- (void) initialParseEntryTable;
- (void) initialParseWordFormTable;
- (void) updateParseEntryTable;
- (void) updateParseWordFormTable;

// properties indicating wifi availability/if the connection is idle
@property BOOL wifiAvailable;
@property BOOL connectionIdle;

- (void) checkIfUpdateNeeded;

@end
