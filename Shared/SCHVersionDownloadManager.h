//
//  SCHVersionDownloadManager.h
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const SCHVersionDownloadManagerCompletedNotification;
extern NSString * const SCHVersionDownloadManagerCompletionAppVersionState;

typedef enum {
    SCHVersionDownloadManagerAppVersionStatePendingCheck = 0,
    SCHVersionDownloadManagerAppVersionStateCurrent,    
    SCHVersionDownloadManagerAppVersionStateOutdated,    
    SCHVersionDownloadManagerAppVersionStateOutdatedRequiresForcedUpdate 
} SCHVersionDownloadManagerAppVersionState;

typedef enum {
    SCHVersionDownloadManagerProcessingStateUnexpectedConnectivityFailureError = -3,
    SCHVersionDownloadManagerProcessingStateParseError = -2,    
	SCHVersionDownloadManagerProcessingStateError = -1,
    SCHVersionDownloadManagerProcessingStateUnknown = 0,
    SCHVersionDownloadManagerProcessingStateFetchingManifest,
	SCHVersionDownloadManagerProcessingStateNeedsManifest,
	SCHVersionDownloadManagerProcessingStateManifestVersionCheck,
	SCHVersionDownloadManagerProcessingStateCompleted,    
} SCHVersionDownloadManagerProcessingState;

@interface SCHVersionDownloadManager : NSObject

@property (nonatomic, retain) NSMutableArray *manifestUpdates;

@property (nonatomic, assign, readonly) SCHVersionDownloadManagerAppVersionState appVersionState;
@property (nonatomic, assign) SCHVersionDownloadManagerProcessingState state;

@property (nonatomic, assign) BOOL isProcessing;

+ (SCHVersionDownloadManager *)sharedVersionManager;

- (void)checkVersion;

@end
