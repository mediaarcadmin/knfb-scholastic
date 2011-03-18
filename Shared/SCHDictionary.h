//
//  SCHDictionary.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SCHDictionaryProcessingStateError = 0,
	SCHDictionaryProcessingStateNeedsManifest,
	SCHDictionaryProcessingStateNeedsDownload,
	SCHDictionaryProcessingStateDone
} SCHDictionaryProcessingState;

static NSString* const kSCHDictionaryDownloadPercentageUpdate = @"SCHDictionaryDownloadPercentageUpdate";

@interface SCHDictionary : NSObject {

}

@property BOOL isProcessing;
@property (readwrite, retain) NSString *dictionaryURL;
@property float dictionaryVersion;
@property (readwrite) SCHDictionaryProcessingState dictionaryState;

@end
