//
//  SCHDictionaryDownloadManager.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHDictionaryManifestEntry.h"

// Constants
extern NSString * const kSCHDictionaryDownloadPercentageUpdate;
extern NSString * const kSCHDictionaryProcessingPercentageUpdate;
extern NSString * const kSCHDictionaryStateChange;

extern int const kSCHDictionaryManifestEntryEntryTableBufferSize;
extern int const kSCHDictionaryManifestEntryWordFormTableBufferSize;
extern CGFloat const kSCHDictionaryFileUnzipMaxPercentage;
extern char * const kSCHDictionaryManifestEntryColumnSeparator;

typedef enum {
	SCHDictionaryProcessingStateError = 0,
    SCHDictionaryProcessingStateInitialNeedsManifest,
    SCHDictionaryProcessingStateUserSetup,
    SCHDictionaryProcessingStateUserDeclined,
	SCHDictionaryProcessingStateNotEnoughFreeSpaceError,
    SCHDictionaryProcessingStateUnexpectedConnectivityFailureError,
    SCHDictionaryProcessingStateDownloadError,
    SCHDictionaryProcessingStateUnableToOpenZipError,
    SCHDictionaryProcessingStateUnZipFailureError,
    SCHDictionaryProcessingStateParseError,
	SCHDictionaryProcessingStateNeedsManifest,
	SCHDictionaryProcessingStateManifestVersionCheck,
	SCHDictionaryProcessingStateNeedsDownload,
	SCHDictionaryProcessingStateNeedsUnzip,
	SCHDictionaryProcessingStateNeedsParse,
	SCHDictionaryProcessingStateReady,
    SCHDictionaryProcessingStateDeleting,
    SCHDictionaryProcessingStateDeletingCategory,
} SCHDictionaryProcessingState;

typedef enum {
    SCHDictionaryUserNotYetAsked = 0,
    SCHDictionaryUserDeclined,
    SCHDictionaryUserAccepted
} SCHDictionaryUserRequestState;

@class SCHAppDictionaryState;

@interface SCHDictionaryDownloadManager : NSObject
{
}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSDictionary *manifestComponentsDictionary;

// dictionary is currently processing
@property BOOL isProcessing;

@property (readonly) float currentDictionaryDownloadPercentage;
@property (readonly) float currentDictionaryProcessingPercentage;

@property (nonatomic, assign) SCHDictionaryUserRequestState userRequestState;

+ (SCHDictionaryDownloadManager *)sharedDownloadManager;

// the local dictionary directory
- (NSString *)dictionaryDirectory;

// the local dictionary tmp directory
- (NSString *)dictionaryTmpDirectory;

// the location of the downloaded zip file
- (NSString *)zipPathForDictionaryManifestEntry:(SCHDictionaryManifestEntry *)dictionaryManifestEntry;

// the location that the current version of the 
// entry table/word form text files are stored
- (NSString *)dictionaryTextFilesDirectory;

// execute a block in Core Data context with access to the current AppDictionaryState
- (void)withAppDictionaryStatePerform:(void (^)(SCHAppDictionaryState *state))block;

- (void)threadSafeUpdateDictionaryState:(SCHDictionaryProcessingState)processingState;
- (SCHDictionaryProcessingState)dictionaryProcessingState;

- (NSString *)titleForCurrentDictionaryState;

// parsing methods called by the parsing operation
- (void)initialParseEntryTable;
- (void)initialParseWordFormTable;
- (void)updateParseEntryTable;
- (void)updateParseWordFormTable;

// properties indicating wifi availability/if the connection is idle
@property BOOL wifiAvailable;
@property BOOL connectionIdle;

- (void)checkIfDictionaryUpdateNeeded;

// dictionary download control
- (void)beginDictionaryDownload;
- (void)deleteDictionary;

- (void)setDictionaryIsCurrentlyReadable:(BOOL)setDictionaryIsCurrentlyReadableFlag;
- (BOOL)dictionaryIsAvailable;

@end
