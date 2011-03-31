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

#pragma mark -
#pragma mark Convenience Methods

#pragma mark Content Metadata

- (NSString *) ContentIdentifier
{
	return self.ContentMetadataItem.ContentIdentifier;
}

- (NSString *) Author
{
	return self.ContentMetadataItem.Author;
}

- (NSString *) Description
{
	return self.ContentMetadataItem.Description;
}

- (NSString *) Version
{
	return self.ContentMetadataItem.Version;
}

- (BOOL) Enhanced
{
	return [self.ContentMetadataItem.Enhanced boolValue];
}

- (NSString *) Title
{
	return self.ContentMetadataItem.Title;
}

- (NSNumber *) FileSize
{
	return self.ContentMetadataItem.FileSize;
}

- (int) PageNumber
{
	return [self.ContentMetadataItem.PageNumber intValue];
}

- (NSString *) FileName
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

- (BOOL) isProcessing
{
	return [[SCHProcessingManager sharedProcessingManager] ISBNisProcessing:self.ContentIdentifier];
}

- (void) setProcessing: (BOOL) value
{
	[[SCHProcessingManager sharedProcessingManager] setProcessing:value forISBN:self.ContentIdentifier];
}

#pragma mark -
#pragma mark Cache Directory

+ (NSString *)cacheDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Current Book Information

- (NSString *) xpsPath
{
#if LOCALDEBUG
	return [[NSBundle mainBundle] pathForResource:self.ContentMetadataItem.FileName ofType:@"xps"];
#else
	return [NSString stringWithFormat:@"%@/%@-%@.xps", 
			[SCHAppBook cacheDirectory], 
			self.ContentMetadataItem.ContentIdentifier, self.ContentMetadataItem.Version];
#endif
}

- (NSString *) coverImagePath
{
	NSString *cacheDir  = [SCHAppBook cacheDirectory];
	NSString *fullImagePath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.ContentIdentifier]];
	return fullImagePath;
}	

- (NSString *) thumbPathForSize: (CGSize) size
{
	NSString *cacheDir  = [SCHAppBook cacheDirectory];
	NSString *thumbPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png_%d_%d", self.ContentIdentifier, (int)size.width, (int)size.height]];
	
	return thumbPath;
}

- (float) currentDownloadedPercentage
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

- (NSString *) processingStateAsString
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
		case SCHBookProcessingStateReadyForRightsParsing:
			status = @"Rights...";
			break;
        case SCHBookProcessingStateReadyForTextFlowPreParse:
			status = @"Textflow...";
			break;
		case SCHBookProcessingStateReadyToRead:
			status = @"";
			break;
		default:
			break;
	}
	
	return status;
}

- (BOOL) canOpenBook 
{
	if ([self.State intValue] == SCHBookProcessingStateReadyToRead) {
		return YES;
	} else {
		return NO;
	}
}

@end
