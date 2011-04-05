//
//  SCHDictionaryManager.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kSCHDictionaryDownloadPercentageUpdate = @"SCHDictionaryDownloadPercentageUpdate";

typedef enum {
	SCHDictionaryProcessingStateError = 0,
	SCHDictionaryProcessingStateNeedsManifest,
	SCHDictionaryProcessingStateNeedsDownload,
	SCHDictionaryProcessingStateNeedsUnzip,
	SCHDictionaryProcessingStateNeedsParsing,
	SCHDictionaryProcessingStateDone
} SCHDictionaryProcessingState;


@interface SCHDictionaryManager : NSObject {

}

+ (SCHDictionaryManager *) sharedDictionaryManager;

// the local dictionary directory
- (NSString *) dictionaryDirectory;
- (NSString *) dictionaryZipPath;

// the dictionary URL
@property (readwrite, retain) NSString *dictionaryURL;

// the dictionary version
@property (readwrite, retain) NSString *dictionaryVersion;

// the current dictionary state
//@property (readwrite) SCHDictionaryProcessingState dictionaryState;
- (void)threadSafeUpdateDictionaryState: (SCHDictionaryProcessingState) state;
- (SCHDictionaryProcessingState) dictionaryProcessingState;

// dictionary is currently processing
@property BOOL isProcessing;

- (NSString *) HTMLForWord: (NSString *) dictionaryWord;

@end
