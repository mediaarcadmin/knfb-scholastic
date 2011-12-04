//
//  SCHHelpManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 04/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const kSCHHelpDownloadPercentageUpdate;
extern NSString * const kSCHHelpStateChange;
extern char * const kSCHHelpManifestEntryColumnSeparator;

typedef enum {
	SCHHelpProcessingStateError = 0,
    SCHHelpProcessingStateHelpVideoManifest,
    SCHHelpProcessingStateDownloadingHelpVideos,
	SCHHelpProcessingStateNotEnoughFreeSpace,
	SCHHelpProcessingStateReady,
} SCHHelpProcessingState;

@class SCHHelpVideoManifest;
@class SCHAppHelpState;

@interface SCHHelpManager : NSObject
{
}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) SCHHelpVideoManifest *helpVideoManifest;

// the current help video version
@property (readonly) NSString *helpVideoVersion;
@property (readonly) NSString *helpVideoOlderURL;
@property (readonly) NSString *helpVideoYoungerURL;

// help is currently processing
@property BOOL isProcessing;

@property (readonly) float currentHelpVideoDownloadPercentage;

+ (SCHHelpManager *)sharedHelpManager;

// have the help videos been downloaded?
- (BOOL)haveHelpVideosDownloaded;

// the local help videos directory
- (NSString *)helpVideoDirectory;

- (void)withAppHelpStatePerform:(void (^)(SCHAppHelpState *state))block;
- (void)threadSafeUpdateHelpState:(SCHHelpProcessingState)processingState;
- (SCHHelpProcessingState)helpProcessingState;
- (void)threadSafeUpdateHelpVideoVersion:(NSString *)newVersion olderURL:(NSString *)olderURL youngerURL:(NSString*)youngerURL;

- (void)checkIfHelpUpdateNeeded;
- (void)retryHelpDownload;

@end
