// 
//  SCHAppBook.m
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAppBook.h"

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

- (BOOL)haveURLs
{
	return(!(self.BookCoverURL == nil || self.BookFileURL == nil));
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
	return [[SCHProcessingManager sharedProcessingManager] ISBNisProcessing:self.ContentIdentifier];
}

- (void)setProcessing:(BOOL)value
{
	[[SCHProcessingManager sharedProcessingManager] setProcessing:value forISBN:self.ContentIdentifier];
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
#if LOCALDEBUG
    return [NSString stringWithFormat:@"%@/%@.xps", 
            [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject], 
            self.ContentMetadataItem.FileName];
#else
	return [NSString stringWithFormat:@"%@/%@-%@.xps", 
			[self cacheDirectory], 
			self.ContentMetadataItem.ContentIdentifier, self.ContentMetadataItem.Version];
#endif
}

- (NSString *)coverImagePath
{
	NSString *cacheDir  = [self cacheDirectory];
	NSString *fullImagePath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.ContentIdentifier]];
    
	return fullImagePath;
}	

- (NSString *)thumbPathForSize:(CGSize)size
{
	NSString *cacheDir  = [self cacheDirectory];

    float scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    NSString *thumbPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d_%d.png", self.ContentIdentifier, (int)size.width, (int)size.height]];
    if (scale != 1) {
        thumbPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d_%d@%dx.png", self.ContentIdentifier, (int)size.width, (int)size.height, (int) scale]];
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
		case SCHBookProcessingStateError:
			status = @"Error";
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

- (BOOL)canOpenBook 
{
	if ([self.State intValue] == SCHBookProcessingStateReadyToRead) {
		return YES;
	} else {
		return NO;
	}
}

- (CGSize)bookCoverImageSize
{
    return CGSizeMake([self.BookCoverWidth intValue], [self.BookCoverHeight intValue]);
}

@end
