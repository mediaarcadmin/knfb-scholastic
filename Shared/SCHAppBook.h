//
//  SCHAppBook.h
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentMetadataItem.h"
#import "SCHProcessingManager.h"

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
static NSString * const kSCHAppBookCoverURL = @"BookCoverURL";
static NSString * const kSCHAppBookFileURL = @"BookFileURL";


static NSString * const kSCHAppBook = @"SCHAppBook";

@interface SCHAppBook :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * ContentIdentifier;
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
@property (nonatomic, retain) NSString * BookCoverURL;
@property (nonatomic, retain) NSString * BookFileURL;



@property (readonly) NSString * Author;
@property (readonly) NSString * Description;
@property (readonly) NSString * Version;
@property (readonly) BOOL Enhanced;
@property (readonly) NSString * Title;
@property (readonly) NSNumber * FileSize;
@property (readonly) int PageNumber;
@property (readonly) NSString * FileName;


- (SCHBookCurrentProcessingState) processingState;
- (NSString *) processingStateAsString;
- (BOOL) isProcessing;
- (void) setProcessing:(BOOL)value;

// the path to the XPS file within the system - by default, in the cache directory
- (NSString *) xpsPath;
- (NSString *) coverImagePath;
- (NSString *) thumbPathForSize: (CGSize) size;

+ (NSString *)cacheDirectory;

- (float) currentDownloadedPercentage;
- (BOOL) haveURLs;
- (BOOL) canOpenBook;

@end



