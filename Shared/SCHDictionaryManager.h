//
//  SCHDictionaryManager.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kSCHDictionaryDownloadPercentageUpdate = @"SCHDictionaryDownloadPercentageUpdate";
static NSString* const kSCHDictionaryYoungReader = @"YD";
static NSString* const kSCHDictionaryOlderReader = @"OD";

static NSString* const kSCHDictionaryStateChange = @"SCHDictionaryStateChange";

typedef enum {
	SCHDictionaryProcessingStateError = 0,
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


@interface SCHDictionaryManager : NSObject {

}

@property (nonatomic, retain) NSMutableArray *manifestUpdates;

// the current dictionary version
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

// parsing methods called by the parsing operation
- (void) initialParseEntryTable;
- (void) initialParseWordFormTable;
- (void) updateParseEntryTable;
- (void) updateParseWordFormTable;

// HTML definition for a word (uses YD/OD as category)
- (NSString *) HTMLForWord: (NSString *) dictionaryWord category: (NSString *) category;

// properties indicating wifi availability/if the connection is idle
@property BOOL wifiAvailable;
@property BOOL connectionIdle;

- (void) checkIfUpdateNeeded;

@end
