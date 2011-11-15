//
//  SCHDictionaryDownloadManager.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHHelpVideoManifest.h"

// Constants
extern NSString * const kSCHDictionaryDownloadPercentageUpdate;
extern NSString * const kSCHHelpVideoDownloadPercentageUpdate;
extern NSString * const kSCHDictionaryProcessingPercentageUpdate;

extern NSString * const kSCHDictionaryStateChange;

extern int const kSCHDictionaryManifestEntryEntryTableBufferSize;
extern int const kSCHDictionaryManifestEntryWordFormTableBufferSize;

extern char * const kSCHDictionaryManifestEntryColumnSeparator;

typedef enum {
	SCHDictionaryProcessingStateError = 0,
    SCHDictionaryProcessingStateHelpVideoManifest,
    SCHDictionaryProcessingStateDownloadingHelpVideos,
    SCHDictionaryProcessingStateUserSetup,
    SCHDictionaryProcessingStateUserDeclined,
	SCHDictionaryProcessingStateNotEnoughFreeSpace,
	SCHDictionaryProcessingStateNeedsManifest,
	SCHDictionaryProcessingStateManifestVersionCheck,
	SCHDictionaryProcessingStateNeedsDownload,
	SCHDictionaryProcessingStateNeedsUnzip,
	SCHDictionaryProcessingStateNeedsParse,
	SCHDictionaryProcessingStateReady,
    SCHDictionaryProcessingStateDeleting,
} SCHDictionaryProcessingState;

typedef enum {
    SCHDictionaryUserNotYetAsked = 0,
    SCHDictionaryUserDeclined,
    SCHDictionaryUserAccepted
} SCHDictionaryUserRequestState;

@interface SCHDictionaryManifestEntry : NSObject 
    
@property (nonatomic, retain) NSString *fromVersion;
@property (nonatomic, retain) NSString *toVersion;
@property (nonatomic, retain) NSString *url;
    
@end

@class SCHAppDictionaryState;

@interface SCHDictionaryDownloadManager : NSObject
{
}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSMutableArray *manifestUpdates;
@property (nonatomic, retain) SCHHelpVideoManifest *helpVideoManifest;

// the current dictionary version
@property (readwrite, retain) NSString *dictionaryVersion;

// the current help video version
@property (readonly) NSString *helpVideoVersion;
@property (readonly) NSString *helpVideoOlderURL;
@property (readonly) NSString *helpVideoYoungerURL;

// dictionary is currently processing
@property BOOL isProcessing;

@property (readonly) float currentDictionaryDownloadPercentage;
@property (readonly) float currentHelpVideoDownloadPercentage;
@property (readonly) float currentDictionaryProcessingPercentage;

@property (nonatomic, assign) SCHDictionaryUserRequestState userRequestState;

+ (SCHDictionaryDownloadManager *)sharedDownloadManager;

// have the help videos been downloaded?
- (BOOL)haveHelpVideosDownloaded;

// the local help videos directory
- (NSString *)helpVideoDirectory;

// the local dictionary directory
- (NSString *)dictionaryDirectory;

// the local dictionary tmp directory
- (NSString *)dictionaryTmpDirectory;

// the location of the downloaded zip file
- (NSString *)dictionaryZipPath;

// the location that the current version of the 
// entry table/word form text files are stored
- (NSString *)dictionaryTextFilesDirectory;

// execute a block in Core Data context with access to the current AppDictionaryState
- (void)withAppDictionaryStatePerform:(void (^)(SCHAppDictionaryState *state))block;

- (void)threadSafeUpdateDictionaryState:(SCHDictionaryProcessingState)processingState;
- (SCHDictionaryProcessingState)dictionaryProcessingState;

// parsing methods called by the parsing operation
- (void)initialParseEntryTable;
- (void)initialParseWordFormTable;
- (void)updateParseEntryTable;
- (void)updateParseWordFormTable;

// properties indicating wifi availability/if the connection is idle
@property BOOL wifiAvailable;
@property BOOL connectionIdle;

- (void)checkIfUpdateNeeded;

// Video download control
- (void)retryVideoDownload;

// dictionary download control
- (void)beginDictionaryDownload;
- (void)deleteDictionary;

// this sets the help video information in core data in a thread safe way
- (void)setHelpVideoVersion:(NSString *)newVersion olderURL:(NSString *)olderURL youngerURL:(NSString*)youngerURL;

@end
