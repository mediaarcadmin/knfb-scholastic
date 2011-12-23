//
//  SCHVersionDownloadManager.h
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const SCHVersionDownloadManagerChangedNotification;

typedef enum {
    SCHVersionDownloadManagerProcessingStateParseError = -2,    
	SCHVersionDownloadManagerProcessingStateError = -1,
    SCHVersionDownloadManagerProcessingStateUnknown = 0,
	SCHVersionDownloadManagerProcessomgStateNeedsManifest,
	SCHVersionDownloadManagerProcessingStateManifestVersionCheck,
} SCHVersionDownloadManagerProcessingState;

@interface SCHVersionDownloadManager : NSObject

@property (nonatomic, retain) NSMutableArray *manifestUpdates;

// the current version
@property (nonatomic, readwrite, retain) NSString *version;

// version check is currently processing
@property (nonatomic, assign) BOOL isProcessing;

+ (SCHVersionDownloadManager *)sharedVersionManager;

- (void)checkVersion;

@end
