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
	SCHDictionaryProcessingStateNeedsInitialParse,
	SCHDictionaryProcessingStateNeedsUpdateParse,
	SCHDictionaryProcessingStateReady
} SCHDictionaryProcessingState;


@interface SCHDictionaryManager : NSObject {

}

// the dictionary URL
@property (readwrite, retain) NSString *dictionaryURL;

// the dictionary version
@property (readwrite, retain) NSString *dictionaryVersion;

// dictionary is currently processing
@property BOOL isProcessing;

+ (SCHDictionaryManager *) sharedDictionaryManager;

// the local dictionary directory
- (NSString *) dictionaryDirectory;

// the location of the downloaded zip file
- (NSString *) dictionaryZipPath;

// the location that the current version of the 
// entry table/word form text files are stored
- (NSString *)dictionaryTextFilesDirectory;

// the current dictionary state
- (void)threadSafeUpdateDictionaryState: (SCHDictionaryProcessingState) state;
- (SCHDictionaryProcessingState) dictionaryProcessingState;

// flag that indicates if we're on the initial update, or subsequent updates
- (void)threadSafeUpdateInitialDictionaryProcessed: (BOOL) newState;
- (BOOL) initialDictionaryProcessed;

// parsing methods called by the parsing operation
- (void)initialParseEntryTable;
- (void)initialParseWordFormTable;

// HTML definition for a word
- (NSString *) HTMLForWord: (NSString *) dictionaryWord;

@end
