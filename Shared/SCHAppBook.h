//
//  SCHAppBook.h
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentMetadataItem.h"
#import "SCHProcessingManager.h"

extern NSString * const kSCHAppBookErrorDomain;

typedef enum 
{
	kSCHAppBookStillBeingProcessedError = 0,
    kSCHAppBookUnableToAcquireLicenseError,
    kSCHAppBookDownloadFailedError,
    kSCHAppBookUnspecifiedError
} SCHAppBookError;

@class SCHBookIdentifier;

static NSString * const kSCHAppBookProcessingState = @"SCHBookProcessingState";

static NSString * const kSCHAppBookTTSPermitted = @"TTSPermitted";
static NSString * const kSCHAppBookReflowPermitted = @"ReflowPermitted";
static NSString * const kSCHAppBookHasAudio = @"HasAudio";
static NSString * const kSCHAppBookHasStoryInteractions = @"HasStoryInteractions";
static NSString * const kSCHAppBookHasExtras = @"HasExtras";
static NSString * const kSCHAppBookLayoutStartsOnLeftSide = @"LayoutStartsOnLeftSide";
static NSString * const kSCHAppBookDRMVersion = @"DRMVersion";
static NSString * const kSCHAppBookXPSAuthor = @"XPSAuthor";
static NSString * const kSCHAppBookXPSTitle = @"XPSTitle";
static NSString * const kSCHAppBookXPSCategory = @"XPSCategory";
static NSString * const kSCHAppBookState = @"State";
static NSString * const kSCHAppBookCoverImageHeight = @"BookCoverHeight";
static NSString * const kSCHAppBookCoverImageWidth = @"BookCoverWidth";
static NSString * const kSCHAppBookCoverURL = @"BookCoverURL";
static NSString * const kSCHAppBookFileURL = @"BookFileURL";
static NSString * const kSCHAppBookTextFlowPageRanges = @"TextFlowPageRanges";
static NSString * const kSCHAppBookSmartZoomPageMarkers = @"SmartZoomPageMarkers";
static NSString * const kSCHAppBookLayoutPageEquivalentCount = @"LayoutPageEquivalentCount";
static NSString * const kSCHAppBookAudioBookReferences = @"AudioBookReferences";


// Audio File keys
static NSString * const kSCHAppBookAudioFile = @"AudioFile";
static NSString * const kSCHAppBookTimingFile = @"TimingFile";

// XPS Categories
static NSString * const kSCHAppBookYoungReader = @"YoungReader";
static NSString * const kSCHAppBookOldReader = @"OldReader";

static NSString * const kSCHAppBookCategoryPictureBook = @"Picture Book";
static NSString * const kSCHAppBookCategoryEarlyReader = @"Early Reader";
static NSString * const kSCHAppBookCategoryAdvancedReader = @"Advanced Reader";
static NSString * const kSCHAppBookCategoryChapterBook = @"Chapter Book";
static NSString * const kSCHAppBookCategoryNovelMiddleGrade = @"Novel - Middle Grade";
static NSString * const kSCHAppBookCategoryNovelYoungAdult = @"Novel - Young Adult";
static NSString * const kSCHAppBookCategoryGraphicNovel = @"Graphic Novel";
static NSString * const kSCHAppBookCategoryReference = @"Reference";
static NSString * const kSCHAppBookCategoryNonFictionEarly = @"Non-Fiction Early";
static NSString * const kSCHAppBookCategoryNonFictionAdvanced = @"Non-Fiction Advanced";

static NSString * const kSCHAppBook = @"SCHAppBook";

static NSString * const kSCHAppBookFetchWithContentIdentifier = @"fetchAppBookWithContentIdentifier";
extern NSString * const kSCHAppBookCONTENT_IDENTIFIER;
extern NSString * const kSCHAppBookDRM_QUALIFIER;

static NSString * const kSCHAppBookEucalyptusCacheDir = @"libEucalyptusCache";

typedef enum {
    kSCHAppBookFeaturesNone,
    kSCHAppBookFeaturesSample,
    kSCHAppBookFeaturesStoryInteractions,
    kSCHAppBookFeaturesSampleWithStoryInteractions
} SCHAppBookFeatures;

@interface SCHAppBook :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * DRMVersion;
@property (nonatomic, retain) NSNumber * HasAudio;
@property (nonatomic, retain) NSNumber * HasExtras;
@property (nonatomic, retain) NSNumber * HasStoryInteractions;
@property (nonatomic, retain) NSNumber * LayoutStartsOnLeftSide;
@property (nonatomic, retain) NSNumber * ReflowPermitted;
@property (nonatomic, retain) NSNumber * State;
@property (nonatomic, retain) NSNumber * TTSPermitted;
@property (nonatomic, retain) NSString * XPSAuthor;
@property (nonatomic, retain) NSString * XPSCategory;
@property (nonatomic, retain) NSString * XPSTitle;
@property (nonatomic, retain) SCHContentMetadataItem * ContentMetadataItem;
@property (nonatomic, retain) NSNumber * BookCoverWidth;
@property (nonatomic, retain) NSNumber * BookCoverHeight;
@property (nonatomic, retain) NSString * BookCoverURL;
@property (nonatomic, retain) NSString * BookFileURL;
@property (nonatomic, retain) NSSet *TextFlowPageRanges;
@property (nonatomic, retain) NSSet *SmartZoomPageMarkers;
@property (nonatomic, retain) NSNumber *LayoutPageEquivalentCount;
@property (nonatomic, retain) NSArray *AudioBookReferences;
@property (nonatomic, retain) NSString *OnDiskVersion;

// convenience variables from the SCHContentMetadataItem
@property (nonatomic, readonly) NSString * ContentIdentifier;
@property (nonatomic, readonly) NSString * Author;
@property (nonatomic, readonly) NSString * Description;
@property (nonatomic, readonly) NSString * Version;
@property (nonatomic, readonly) BOOL Enhanced;
@property (nonatomic, readonly) NSString * Title;
@property (nonatomic, readonly) NSNumber * FileSize;
@property (nonatomic, readonly) int PageNumber;
@property (nonatomic, readonly) NSString * FileName;
@property (nonatomic, readonly) SCHBookIdentifier *bookIdentifier;
@property (nonatomic, readonly) NSString *categoryType;
@property (nonatomic, readonly) BOOL diskVersionOutOfDate;


- (SCHBookCurrentProcessingState)processingState;
- (void)setProcessingState:(SCHBookCurrentProcessingState)processingState;

- (NSString *)processingStateAsString;
- (BOOL)isProcessing;
- (void)setProcessing:(BOOL)value;

// the path to the XPS file within the system - by default, in the cache directory
- (NSString *)xpsPath;
- (NSString *)coverImagePath;
- (NSString *)thumbPathForSize:(CGSize)size;
- (NSString *)cacheDirectory;
- (NSString *)libEucalyptusCache;

+ (NSString *)rootCacheDirectory;

- (float)currentDownloadedPercentage;
- (BOOL)haveURLs;
- (BOOL)canOpenBookError:(NSError **)error;
- (CGSize)bookCoverImageSize;
- (SCHAppBookFeatures) bookFeatures;

@end



