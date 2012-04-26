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
    kSCHAppBookCachedCoverError,
    kSCHAppBookDownloadFailedError,
    kSCHAppBookURLsNotPopulatedError,
    kSCHAppBookUnspecifiedError
} SCHAppBookError;

@class SCHBookIdentifier;
@class SCHRecommendationISBN;

// Constants
extern NSString * const kSCHAppBookProcessingState;

extern NSString * const kSCHAppBookTTSPermitted;
extern NSString * const kSCHAppBookReflowPermitted;
extern NSString * const kSCHAppBookHasAudio;
extern NSString * const kSCHAppBookHasStoryInteractions;
extern NSString * const kSCHAppBookHasExtras;
extern NSString * const kSCHAppBookLayoutStartsOnLeftSide;
extern NSString * const kSCHAppBookDRMVersion;
extern NSString * const kSCHAppBookXPSAuthor;
extern NSString * const kSCHAppBookXPSTitle;
extern NSString * const kSCHAppBookXPSCategory;
extern NSString * const kSCHAppBookState;
extern NSString * const kSCHAppBookCoverImageHeight;
extern NSString * const kSCHAppBookCoverImageWidth;
extern NSString * const kSCHAppBookCoverURL;
extern NSString * const kSCHAppBookFileURL;
extern NSString * const kSCHAppBookTextFlowPageRanges;
extern NSString * const kSCHAppBookSmartZoomPageMarkers;
extern NSString * const kSCHAppBookLayoutPageEquivalentCount;
extern NSString * const kSCHAppBookAudioBookReferences;

// Audio File keys
extern NSString * const kSCHAppBookAudioFile;
extern NSString * const kSCHAppBookTimingFile;

// XPS Categories
extern NSString * const kSCHAppBookYoungReader;
extern NSString * const kSCHAppBookOldReader;

extern NSString * const kSCHAppBookCategoryPictureBook;
extern NSString * const kSCHAppBookCategoryEarlyReader;
extern NSString * const kSCHAppBookCategoryAdvancedReader;
extern NSString * const kSCHAppBookCategoryChapterBook;
extern NSString * const kSCHAppBookCategoryNovelMiddleGrade;
extern NSString * const kSCHAppBookCategoryNovelYoungAdult;
extern NSString * const kSCHAppBookCategoryGraphicNovel;
extern NSString * const kSCHAppBookCategoryReference;
extern NSString * const kSCHAppBookCategoryNonFictionEarly;
extern NSString * const kSCHAppBookCategoryNonFictionAdvanced;

extern NSString * const kSCHAppBook;

extern NSString * const kSCHAppBookFetchWithContentIdentifier;
extern NSString * const kSCHAppBookCONTENT_IDENTIFIER;
extern NSString * const kSCHAppBookDRM_QUALIFIER;

extern NSString * const kSCHAppBookEucalyptusCacheDir;

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
@property (nonatomic, retain) NSNumber *ForceProcess;
@property (nonatomic, retain) NSNumber * BookCoverExists;
@property (nonatomic, retain) NSNumber * XPSExists;
@property (nonatomic, retain) NSNumber * urlExpiredCount;
@property (nonatomic, retain) NSNumber * downloadFailedCount;

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
@property (nonatomic, readonly) BOOL shouldShowChapters;
@property (nonatomic, readonly) BOOL alwaysOpenToCover;
@property (nonatomic, readonly) BOOL diskVersionOutOfDate;
@property (nonatomic, readonly) NSNumber * AverageRating;

+ (SCHBookIdentifier *)invalidBookIdentifier;
- (BOOL)bookCoverURLIsValid;
- (BOOL)bookFileURLIsValid;
- (BOOL)bookCoverURLIsBundleURL;
- (BOOL)bookFileURLIsBundleURL;
- (BOOL)contentMetadataCoverURLIsValid;
- (BOOL)contentMetadataFileURLIsValid;
- (BOOL)contentMetadataCoverURLIsBundleURL;
- (BOOL)contentMetadataFileURLIsBundleURL;

- (SCHBookCurrentProcessingState)processingState;
- (void)setProcessingState:(SCHBookCurrentProcessingState)processingState;

- (NSString *)processingStateAsString;
- (BOOL)isProcessing;
- (void)setProcessing:(BOOL)value;

// the path to the XPS file within the system - by default, in the cache directory
- (NSString *)xpsPath;
- (NSString *)coverImagePath;
- (NSString *)thumbPathForSize:(CGSize)size;
+ (NSString *)booksDirectory;
+ (void)clearBooksDirectory;
- (void)clearCachedBookDirectory;
- (NSString *)bookDirectory;
- (NSString *)libEucalyptusCache;
- (void)clearToDefaultValues;

- (float)currentDownloadedPercentage;
- (BOOL)haveURLs;
- (BOOL)canOpenBookError:(NSError **)error;
- (CGSize)bookCoverImageSize;
- (SCHAppBookFeatures) bookFeatures;
- (SCHRecommendationISBN *)recommendationISBN;
- (NSArray *)recommendationDictionaries;

- (void)setForcedProcessing:(BOOL)forceProcess;

@end



