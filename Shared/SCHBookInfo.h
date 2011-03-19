//
//  SCHBookInfo.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <CoreData/CoreData.h>
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHAppBook+Extensions.h"
#import "SCHProcessingManager.h"

static NSString * const kSCHBookInfoAuthor = @"SCHBookInfoAuthor";
static NSString * const kSCHBookInfoVersion = @"SCHBookInfoVersion";
static NSString * const kSCHBookInfoEnhanced = @"SCHBookInfoEnhanced";
static NSString * const kSCHBookInfoFileSize = @"SCHBookInfoFileSize";
static NSString * const kSCHBookInfoCoverURL = @"SCHBookInfoCoverURL";
static NSString * const kSCHBookInfoContentURL = @"SCHBookInfoContentURL";
static NSString * const kSCHBookInfoPageNumber = @"SCHBookInfoPageNumber";
static NSString * const kSCHBookInfoTitle = @"SCHBookInfoTitle";
static NSString * const kSCHBookInfoFileName = @"SCHBookInfoFileName";
static NSString * const kSCHBookInfoDescription = @"SCHBookInfoDescription";
static NSString * const kSCHBookInfoContentIdentifier = @"SCHBookInfoContentIdentifier";

static NSString * const kSCHBookInfoProcessingState = @"SCHBookInfoProcessingState";

static NSString * const kSCHBookInfoRightsTTSPermitted = @"SCHBookInfoRightsTTSPermitted";
static NSString * const kSCHBookInfoRightsReflowPermitted = @"SCHBookInfoRightsReflowPermitted";
static NSString * const kSCHBookInfoRightsHasAudio = @"SCHBookInfoRightsHasAudio";
static NSString * const kSCHBookInfoRightsHasStoryInteractions = @"SCHBookInfoRightsHasStoryInteractions";
static NSString * const kSCHBookInfoRightsHasExtras = @"SCHBookInfoRightsHasExtras";
static NSString * const kSCHBookInfoRightsLayoutStartsOnLeftSide = @"SCHBookInfoRightsLayoutStartsOnLeftSide";
static NSString * const kSCHBookInfoRightsDRMVersion = @"SCHBookInfoRightsDRMVersion";
static NSString * const kSCHBookInfoXPSAuthor = @"SCHBookInfoXPSAuthor";
static NSString * const kSCHBookInfoXPSTitle = @"SCHBookInfoXPSTitle";
static NSString * const kSCHBookInfoXPSCategory = @"SCHBookInfoXPSCategory";

@interface SCHBookInfo : NSObject {

}

// SCHBookInfo objects use the book identifier (ISBN number) as a unique ID
@property (nonatomic, readwrite, retain) NSString *bookIdentifier;

// is this book currently being processed?
@property (getter=isProcessing) BOOL processing;

// the current processing state of the book
@property (readwrite) SCHBookInfoCurrentProcessingState processingState;

// methods for getting and setting content metadata (SCHContentMetadataItem)
- (id) objectForMetadataKey: (NSString *) metadataKey;
- (void) setObject: (id) obj forMetadataKey: (NSString *) metadataKey;
- (NSString *) stringForMetadataKey: (NSString *) metadataKey;
- (void) setString: (NSString *) obj forMetadataKey: (NSString *) metadataKey;

// methods for getting and setting local metadata (SCHAppBook)
- (id) objectForLocalMetadataKey: (NSString *) metadataKey;
- (NSString *) stringForLocalMetadataKey: (NSString *) metadataKey;
- (void) setObject: (id) obj forLocalMetadataKey: (NSString *) metadataKey;
- (void) setString: (NSString *) obj forLocalMetadataKey: (NSString *) metadataKey;

// the path to the XPS file within the system - by default, in the cache directory
- (NSString *) xpsPath;
- (NSString *) coverImagePath;
- (NSString *) thumbPathForSize: (CGSize) size;

// book file current percentage downloaded
- (float) currentDownloadedPercentage;

// Short string representation of the current processing state
- (NSString *) currentProcessingStateAsString;

// the library cache directory. Used for book files and cached images.
+ (NSString *)cacheDirectory;

// state check to determine if book is in a state for reading
- (BOOL) canOpenBook;

@end
