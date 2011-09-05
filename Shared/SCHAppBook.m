// 
//  SCHAppBook.m
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"

// Constants
NSString * const kSCHAppBookErrorDomain  = @"com.knfb.scholastic.AppBookErrorDomain";

NSString * const kSCHAppBookProcessingState = @"SCHBookProcessingState";

NSString * const kSCHAppBookTTSPermitted = @"TTSPermitted";
NSString * const kSCHAppBookReflowPermitted = @"ReflowPermitted";
NSString * const kSCHAppBookHasAudio = @"HasAudio";
NSString * const kSCHAppBookHasStoryInteractions = @"HasStoryInteractions";
NSString * const kSCHAppBookHasExtras = @"HasExtras";
NSString * const kSCHAppBookLayoutStartsOnLeftSide = @"LayoutStartsOnLeftSide";
NSString * const kSCHAppBookDRMVersion = @"DRMVersion";
NSString * const kSCHAppBookXPSAuthor = @"XPSAuthor";
NSString * const kSCHAppBookXPSTitle = @"XPSTitle";
NSString * const kSCHAppBookXPSCategory = @"XPSCategory";
NSString * const kSCHAppBookState = @"State";
NSString * const kSCHAppBookCoverImageHeight = @"BookCoverHeight";
NSString * const kSCHAppBookCoverImageWidth = @"BookCoverWidth";
NSString * const kSCHAppBookCoverURL = @"BookCoverURL";
NSString * const kSCHAppBookFileURL = @"BookFileURL";
NSString * const kSCHAppBookTextFlowPageRanges = @"TextFlowPageRanges";
NSString * const kSCHAppBookSmartZoomPageMarkers = @"SmartZoomPageMarkers";
NSString * const kSCHAppBookLayoutPageEquivalentCount = @"LayoutPageEquivalentCount";
NSString * const kSCHAppBookAudioBookReferences = @"AudioBookReferences";
NSString * const kSCHAppBookBookCoverExists = @"BookCoverExists";
NSString * const kSCHAppBookXPSExists = @"XPSExists";

// Audio File keys
NSString * const kSCHAppBookAudioFile = @"AudioFile";
NSString * const kSCHAppBookTimingFile = @"TimingFile";

// XPS Categories
NSString * const kSCHAppBookYoungReader = @"YoungReader";
NSString * const kSCHAppBookOldReader = @"OldReader";

NSString * const kSCHAppBookCategoryPictureBook = @"Picture Book";
NSString * const kSCHAppBookCategoryEarlyReader = @"Early Reader";
NSString * const kSCHAppBookCategoryAdvancedReader = @"Advanced Reader";
NSString * const kSCHAppBookCategoryChapterBook = @"Chapter Book";
NSString * const kSCHAppBookCategoryNovelMiddleGrade = @"Novel - Middle Grade";
NSString * const kSCHAppBookCategoryNovelYoungAdult = @"Novel - Young Adult";
NSString * const kSCHAppBookCategoryGraphicNovel = @"Graphic Novel";
NSString * const kSCHAppBookCategoryReference = @"Reference";
NSString * const kSCHAppBookCategoryNonFictionEarly = @"Non-Fiction Early";
NSString * const kSCHAppBookCategoryNonFictionAdvanced = @"Non-Fiction Advanced";

NSString * const kSCHAppBook = @"SCHAppBook";

NSString * const kSCHAppBookFetchWithContentIdentifier = @"fetchAppBookWithContentIdentifier";

NSString * const kSCHAppBookEucalyptusCacheDir = @"libEucalyptusCache";

@interface SCHAppBook()

- (NSError *)errorWithCode:(NSInteger)code;

@end

@implementation SCHAppBook 

@dynamic DRMVersion;
@dynamic HasAudio;
@dynamic HasExtras;
@dynamic HasStoryInteractions;
@dynamic LayoutStartsOnLeftSide;
@dynamic ReflowPermitted;
@dynamic State;
@dynamic TTSPermitted;
@dynamic XPSAuthor;
@dynamic XPSCategory;
@dynamic XPSTitle;
@dynamic ContentMetadataItem;
@dynamic BookCoverURL;
@dynamic BookFileURL;
@dynamic TextFlowPageRanges;
@dynamic SmartZoomPageMarkers;
@dynamic LayoutPageEquivalentCount;
@dynamic BookCoverWidth;
@dynamic BookCoverHeight;
@dynamic AudioBookReferences;
@dynamic OnDiskVersion;
@dynamic ForceProcess;
@dynamic BookCoverExists;
@dynamic XPSExists;

@synthesize diskVersionOutOfDate;

#pragma mark - Convenience Methods

- (NSString *)ContentIdentifier
{
	return self.ContentMetadataItem.ContentIdentifier;
}

- (NSString *)Author
{
	return self.ContentMetadataItem.Author;
}

- (NSString *)Description
{
	return self.ContentMetadataItem.Description;
}

- (NSString *)Version
{
	return self.ContentMetadataItem.Version;
}

- (BOOL)Enhanced
{
	return [self.ContentMetadataItem.Enhanced boolValue];
}

- (NSString *)Title
{
	return self.ContentMetadataItem.Title;
}

- (NSNumber *)FileSize
{
	return self.ContentMetadataItem.FileSize;
}

- (int)PageNumber
{
	return [self.ContentMetadataItem.PageNumber intValue];
}

- (NSString *)FileName
{
	return self.ContentMetadataItem.FileName;
}

- (SCHBookIdentifier *)bookIdentifier
{
    return(self.ContentMetadataItem.bookIdentifier);
}
            
- (NSNumber *)HasStoryInteractions
{
    NSNumber *ret = NO;

    [self willAccessValueForKey:kSCHAppBookHasStoryInteractions];
    ret = [self primitiveValueForKey:kSCHAppBookHasStoryInteractions];
    // if it hasnt been set then use the book info    
    if (ret == nil) {
        ret = self.ContentMetadataItem.Enhanced;
    }
    [self didAccessValueForKey:kSCHAppBookHasStoryInteractions];
    
    return(ret);
}

- (BOOL)haveURLs
{
	return(!(self.BookCoverURL == nil || self.BookFileURL == nil));
}

- (BOOL)diskVersionOutOfDate
{
    return([self.OnDiskVersion isEqualToString:self.ContentMetadataItem.Version] == NO);
}

- (SCHBookCurrentProcessingState) processingState
{
	return (SCHBookCurrentProcessingState) [self.State intValue];
}

- (void)setProcessingState:(SCHBookCurrentProcessingState)processingState
{
    self.State = [NSNumber numberWithInt:processingState];
}

- (BOOL)isProcessing
{
	return [[SCHProcessingManager sharedProcessingManager] identifierIsProcessing:[self bookIdentifier]];
}

- (void)setProcessing:(BOOL)value
{
	[[SCHProcessingManager sharedProcessingManager] setProcessing:value forIdentifier:[self bookIdentifier]];
}

- (NSString *)categoryType
{
    NSString *ret = nil;
    
    if ([self.XPSCategory caseInsensitiveCompare:kSCHAppBookYoungReader] == NSOrderedSame ||
        [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryPictureBook] == NSOrderedSame ||
        [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryEarlyReader] == NSOrderedSame ||        
        [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryAdvancedReader] == NSOrderedSame ||                
        [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryNonFictionEarly] == NSOrderedSame) {
        ret = kSCHAppBookYoungReader;
    } else if ([self.XPSCategory caseInsensitiveCompare:kSCHAppBookOldReader] == NSOrderedSame ||
               [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryChapterBook] == NSOrderedSame ||
               [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryNovelMiddleGrade] == NSOrderedSame ||
               [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryNovelYoungAdult] == NSOrderedSame ||
               [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryGraphicNovel] == NSOrderedSame ||
               [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryReference] == NSOrderedSame ||
               [self.XPSCategory caseInsensitiveCompare:kSCHAppBookCategoryNonFictionAdvanced] == NSOrderedSame) {
        ret = kSCHAppBookOldReader;
    }    
    
    return (ret);
}

#pragma mark - Cache Directory for Current Book

+ (NSString *)rootCacheDirectory 
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)cacheDirectory 
{
    NSString *libraryCacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *bookCacheDirectory = [libraryCacheDirectory stringByAppendingPathComponent:self.ContentIdentifier];
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDirectory = NO;
    
    if (![localFileManager fileExistsAtPath:bookCacheDirectory isDirectory:&isDirectory]) {
        [localFileManager createDirectoryAtPath:bookCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];

        if (error) {
            NSLog(@"Warning: problem creating book cache directory. %@", [error localizedDescription]);
        }
    }
    
    [localFileManager release], localFileManager = nil;
    
    return bookCacheDirectory;
}

- (NSString *)libEucalyptusCache
{
    NSString *cacheDir = [self cacheDirectory];
    NSString *libEucalyptusCacheDirectory = [cacheDir stringByAppendingPathComponent:@"libEucalyptusCache"];
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDirectory = NO;
    
    if (![localFileManager fileExistsAtPath:libEucalyptusCacheDirectory isDirectory:&isDirectory]) {
        [localFileManager createDirectoryAtPath:libEucalyptusCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Warning: problem creating book cache directory. %@", [error localizedDescription]);
        }
    }
    
    [localFileManager release], localFileManager = nil;
    
    return libEucalyptusCacheDirectory;
}

#pragma mark - Current Book Information

- (NSString *)xpsPath
{
    NSString *cacheDir = [self cacheDirectory];
    NSString *fullXPSPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.xps", 
                                                                        self.bookIdentifier, self.ContentMetadataItem.Version]];
	return fullXPSPath;    
}

- (NSString *)coverImagePath
{
	NSString *cacheDir = [self cacheDirectory];
	NSString *fullImagePath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", 
                                                                        self.bookIdentifier]];
    
	return fullImagePath;
}	

- (NSNumber *)BookCoverExists
{
    [self willAccessValueForKey:kSCHAppBookBookCoverExists];
    NSNumber *rawBookCoverExists = [self primitiveValueForKey:kSCHAppBookBookCoverExists];
    [self didAccessValueForKey:kSCHAppBookBookCoverExists];
    
    if (rawBookCoverExists == nil || [rawBookCoverExists boolValue] == NO) {
        NSFileManager *localFileManager = [[NSFileManager alloc] init];  
        
        rawBookCoverExists = [NSNumber numberWithBool:[localFileManager fileExistsAtPath:[self coverImagePath]]];
        [self setPrimitiveValue:rawBookCoverExists forKey:kSCHAppBookBookCoverExists];
        
        [localFileManager release], localFileManager = nil;        
    }
    
    return(rawBookCoverExists);
}

- (NSNumber *)XPSExists
{
    [self willAccessValueForKey:kSCHAppBookXPSExists];
    NSNumber *rawXPSExists = [self primitiveValueForKey:kSCHAppBookXPSExists];
    [self didAccessValueForKey:kSCHAppBookXPSExists];
    
    if (rawXPSExists == nil || [rawXPSExists boolValue] == NO) {
        NSFileManager *localFileManager = [[NSFileManager alloc] init];  
        
        rawXPSExists = [NSNumber numberWithBool:[localFileManager fileExistsAtPath:[self xpsPath]]];
        [self setPrimitiveValue:rawXPSExists forKey:kSCHAppBookXPSExists];
        
        [localFileManager release], localFileManager = nil;        
    }
    
    return(rawXPSExists);
}

- (NSString *)thumbPathForSize:(CGSize)size
{
	NSString *cacheDir  = [self cacheDirectory];

    float scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    NSString *thumbPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d_%d.png", self.bookIdentifier, (int)size.width, (int)size.height]];
    if (scale != 1) {
        thumbPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d_%d@%dx.png", self.bookIdentifier, (int)size.width, (int)size.height, (int) scale]];
    }    

	return thumbPath;
}

- (float)currentDownloadedPercentage
{
	float percentage = 0.0f;
	
	NSString *xpsPath = [self xpsPath];
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:xpsPath]) {
		// check to see how much of the file has been downloaded
		
		unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:xpsPath error:&error] fileSize];
		percentage = (float) ((float) fileSize/[self.ContentMetadataItem.FileSize floatValue]);
		
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
		}
	} 
	
	return percentage;
}

- (NSString *)processingStateAsString
{
	NSString *status = @"Unknown!";
	switch ([[self State] intValue]) {
		case SCHBookProcessingStateURLsNotPopulated:
			status = @"Error URLs not Populated";
			break;
		case SCHBookProcessingStateDownloadFailed:
			status = @"Error Download Failed";
			break;
		case SCHBookProcessingStateNonDRMBookWithDRM:
			status = @"Error NonDRm book with DRM";
			break;
		case SCHBookProcessingStateUnableToAcquireLicense:
			status = @"Error Unable to Acquire License";
			break;
		case SCHBookProcessingStateError:
			status = @"Error";
			break;
		case SCHBookProcessingStateBookVersionNotSupported:
			status = @"Error Book Version Not Supported";
			break;            
		case SCHBookProcessingStateNoURLs:
			status = @"URLs..";
			break;
		case SCHBookProcessingStateNoCoverImage:
			status = @"Cover Img...";
			break;
		case SCHBookProcessingStateReadyForBookFileDownload:
			status = @"Download";
			break;
		case SCHBookProcessingStateDownloadStarted:
			status = @"Loading...";
			break;
		case SCHBookProcessingStateDownloadPaused:
			status = @"Paused";
			break;
        case SCHBookProcessingStateReadyForLicenseAcquisition:
            status = @"License..";
            break;
		case SCHBookProcessingStateReadyForRightsParsing:
			status = @"Rights...";
			break;
		case SCHBookProcessingStateReadyForAudioInfoParsing:
			status = @"Audio...";
			break;
        case SCHBookProcessingStateReadyForTextFlowPreParse:
			status = @"Textflow...";
			break;
        case SCHBookProcessingStateReadyForSmartZoomPreParse:
			status = @"Zoom...";
			break;
        case SCHBookProcessingStateReadyForPagination:
			status = @"Paginate...";
			break;
		case SCHBookProcessingStateReadyToRead:
			status = @"";
			break;
		default:
			break;
	}
	
	return status;
}

- (BOOL)canOpenBookError:(NSError **)error 
{
    BOOL ret = NO;
    
	if ([self.State intValue] == SCHBookProcessingStateReadyToRead) {
		ret = YES;
	} else if(error != NULL) {
        switch ([self.State intValue]) {
            case SCHBookProcessingStateNonDRMBookWithDRM:
                *error = [self errorWithCode:kSCHAppBookNonDRMBookWithDRMError];
                break;                
            case SCHBookProcessingStateUnableToAcquireLicense:
                *error = [self errorWithCode:kSCHAppBookUnableToAcquireLicenseError];
                break;
            case SCHBookProcessingStateDownloadFailed:
                *error = [self errorWithCode:kSCHAppBookDownloadFailedError];
                break;
            case SCHBookProcessingStateURLsNotPopulated:
                *error = [self errorWithCode:kSCHAppBookURLsNotPopulatedError];
                break;
            case SCHBookProcessingStateError:
                *error = [self errorWithCode:kSCHAppBookUnspecifiedError];
                break;
            default:
                *error = [self errorWithCode:kSCHAppBookStillBeingProcessedError];
                break;
        }
	}
    
    return(ret);
}

- (CGSize)bookCoverImageSize
{
    return CGSizeMake([self.BookCoverWidth intValue], [self.BookCoverHeight intValue]);
}

- (SCHAppBookFeatures)bookFeatures
{
    SCHAppBookFeatures ret = kSCHAppBookFeaturesNone;
    BOOL storyInteractions = [[self HasStoryInteractions] boolValue];
    BOOL sample = ([self.ContentMetadataItem.DRMQualifier DRMQualifierValue] == kSCHDRMQualifiersSample);
    
    if (storyInteractions == YES && sample == YES) {
        ret = kSCHAppBookFeaturesSampleWithStoryInteractions;
    } else if (storyInteractions == YES) {
        ret = kSCHAppBookFeaturesStoryInteractions;        
    } else if (sample == YES) {
        ret = kSCHAppBookFeaturesSample;        
    }
        
    return(ret);    
}

- (void)setForcedProcessing:(BOOL)forceProcess
{
    self.ForceProcess = [NSNumber numberWithBool:forceProcess];
}

#pragma mark - Errors

- (NSError *)errorWithCode:(NSInteger)code
{
    NSString *description = nil;
    
    switch (code) {
        case kSCHAppBookStillBeingProcessedError:
            description = NSLocalizedString(@"The book is still being processed.", @"Still being processed error message from AppBook");
            break;
        case kSCHAppBookNonDRMBookWithDRMError:
            description = NSLocalizedString(@"There was a problem whilst acquiring DRM information for this book. If the problem persists please contact support.", @"Book has DRM when it should not error message from AppBook");
            break;            
        case kSCHAppBookUnableToAcquireLicenseError:
            description = NSLocalizedString(@"It has not been possible to acquire a DRM license for this book. Please make sure this device is authorized and connected to the internet and try again.", @"Decryption not available error message from AppBook");
            break;
        case kSCHAppBookDownloadFailedError:
            description = NSLocalizedString(@"There was a problem whilst downloading this book. Please make sure this device is connected to the internet and try again.", @"Download failed error message from AppBook");
            break;
        case kSCHAppBookURLsNotPopulatedError:
            description = NSLocalizedString(@"There was a problem whilst accessing the URLs for this book. Please make sure this device is connected to the internet and try again. If the problem persists please contact support.", @"URLs not populated error message from AppBook");
            break;
        case kSCHAppBookUnspecifiedError:
        default:
            description = NSLocalizedString(@"An unspecified error occured. Please try again.", @"Unspecified error message from AppBook");
            break;
    }
    
    NSArray *objArray = [NSArray arrayWithObjects:description, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, nil];
    NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray
                                                      forKeys:keyArray];
    
    return [[[NSError alloc] initWithDomain:kSCHAppBookErrorDomain
                                       code:code userInfo:eDict] autorelease];
}

@end

NSString * const kSCHAppBookCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
NSString * const kSCHAppBookDRM_QUALIFIER = @"DRM_QUALIFIER";
