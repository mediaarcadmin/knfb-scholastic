//
//  SCHBookInfo.m
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookInfo.h"
#import "SCHBookManager.h"

@interface SCHBookInfo ()

@end


@implementation SCHBookInfo

@synthesize bookIdentifier;
@synthesize processing;
@synthesize processingState;


#pragma mark -
#pragma mark Memory Management

- (void) dealloc
{
	self.bookIdentifier = nil;

	[super dealloc];
}

- (id) init
{
	if (self = [super init]) {
		self.bookIdentifier = nil;
		self.processingState = SCHBookInfoProcessingStateNoURLs;
	}
	
	return self;
}

#pragma mark -
#pragma mark Core Data Retrieval

- (SCHContentMetadataItem *) contentMetadata
{
	SCHContentMetadataItem *item = nil;
	
	if (self.bookIdentifier) {
		
		NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
		
		if (context) {
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:context]];	
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ContentIdentifier == %@", self.bookIdentifier];
			[fetchRequest setPredicate:predicate];
			
			NSError *error = nil;
			NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
			[fetchRequest release], fetchRequest = nil;
			
			if (error) {
				NSLog(@"Error while fetching book item: %@", [error localizedDescription]);
			} else if (!results || [results count] != 1) {
				NSLog(@"Did not return expected single book.");
			} else {
				item = (SCHContentMetadataItem *) [results objectAtIndex:0];
			}
		}
		
	}
	
	return item;
}

#pragma mark -
#pragma mark Book Status

// FIXME: persist state
- (SCHBookInfoCurrentProcessingState) processingState
{
	return processingState;
}

- (void) setProcessingState:(SCHBookInfoCurrentProcessingState)newState
{
	processingState = newState;
	
	NSLog(@"setting %@ to processing state \"%@\".", self.bookIdentifier, [self currentProcessingStateAsString]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStatusUpdate" object:self];
	
}

#pragma mark -
#pragma mark Cache Directory

+ (NSString *)cacheDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Content Metadata Access

// methods for getting and setting content metadata
- (id) objectForMetadataKey: (NSString *) metadataKey
{
	id returnedResult = nil;
	
	if (!metadataKey) {
		return nil;
	}
	
	if ([metadataKey compare:kSCHBookInfoAuthor] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] Author];
	} else if ([metadataKey compare:kSCHBookInfoVersion] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] Version];
	} else if ([metadataKey compare:kSCHBookInfoEnhanced] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] Enhanced];
	} else if ([metadataKey compare:kSCHBookInfoFileSize] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] FileSize];
	} else if ([metadataKey compare:kSCHBookInfoCoverURL] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] CoverURL];
	} else if ([metadataKey compare:kSCHBookInfoContentURL] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] ContentURL];
	} else if ([metadataKey compare:kSCHBookInfoPageNumber] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] PageNumber];
	} else if ([metadataKey compare:kSCHBookInfoTitle] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] Title];
	} else if ([metadataKey compare:kSCHBookInfoFileName] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] FileName];
	} else if ([metadataKey compare:kSCHBookInfoDescription] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] Description];
	} else if ([metadataKey compare:kSCHBookInfoContentIdentifier] == NSOrderedSame) {
		returnedResult = [[self contentMetadata] ContentIdentifier];
	}
	
	return returnedResult;
}

- (NSString *) stringForMetadataKey: (NSString *) metadataKey
{
	id returnedResult = [self objectForMetadataKey:metadataKey];
	
	if (!returnedResult) {
		return nil;
	}
	
	if ([returnedResult isKindOfClass:[NSString class]]) {
		return returnedResult;
	}
	
	if ([returnedResult isKindOfClass:[NSNumber class]]) {
		NSNumber *number = (NSNumber *) returnedResult;
		return [number stringValue];
	}
	NSLog(@"Unknown metadata class type. %@", NSStringFromClass([returnedResult class]));
	return nil;
}


- (void) setObject: (id) obj forMetadataKey: (NSString *) metadataKey;
{
	
	SCHContentMetadataItem *contentMetadata = [self contentMetadata];
	
	if (!metadataKey) {
		return;
	}
	
	if ([metadataKey compare:kSCHBookInfoAuthor] == NSOrderedSame) {
		contentMetadata.Author = obj;
	} else if ([metadataKey compare:kSCHBookInfoVersion] == NSOrderedSame) {
		contentMetadata.Version = obj;
	} else if ([metadataKey compare:kSCHBookInfoEnhanced] == NSOrderedSame) {
		contentMetadata.Enhanced = obj;
	} else if ([metadataKey compare:kSCHBookInfoFileSize] == NSOrderedSame) {
		contentMetadata.FileSize = obj;
	} else if ([metadataKey compare:kSCHBookInfoCoverURL] == NSOrderedSame) {
		contentMetadata.CoverURL = obj;
	} else if ([metadataKey compare:kSCHBookInfoContentURL] == NSOrderedSame) {
		contentMetadata.ContentURL = obj;
	} else if ([metadataKey compare:kSCHBookInfoPageNumber] == NSOrderedSame) {
		contentMetadata.PageNumber = obj;
	} else if ([metadataKey compare:kSCHBookInfoTitle] == NSOrderedSame) {
		contentMetadata.Title = obj;
	} else if ([metadataKey compare:kSCHBookInfoFileName] == NSOrderedSame) {
		contentMetadata.FileName = obj;
	} else if ([metadataKey compare:kSCHBookInfoDescription] == NSOrderedSame) {
		contentMetadata.Description = obj;
	} else if ([metadataKey compare:kSCHBookInfoContentIdentifier] == NSOrderedSame) {
		contentMetadata.ContentIdentifier = obj;
	}
	
	
	NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];

	NSError *error = nil;
	[context save:&error];
	
	if (error) {
		NSLog(@"Error while saving contentMetadata: %@", [error localizedDescription]);
	}
}

- (void) setString: (NSString *) obj forMetadataKey: (NSString *) metadataKey;
{
	NSString *value = nil;
	
	if ([metadataKey compare:kSCHBookInfoAuthor] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoVersion] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoEnhanced] == NSOrderedSame) {
		value = [(NSNumber *) obj stringValue];
	} else if ([metadataKey compare:kSCHBookInfoFileSize] == NSOrderedSame) {
		value = [(NSNumber *) obj stringValue];
	} else if ([metadataKey compare:kSCHBookInfoCoverURL] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoContentURL] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoPageNumber] == NSOrderedSame) {
		value = [(NSNumber *) obj stringValue];
	} else if ([metadataKey compare:kSCHBookInfoTitle] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoFileName] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoDescription] == NSOrderedSame) {
		value = obj;
	} else if ([metadataKey compare:kSCHBookInfoContentIdentifier] == NSOrderedSame) {
		value = obj;
	}
	
	[self setObject:value forMetadataKey:metadataKey];
}


#pragma mark -
#pragma mark Current Book Information

- (NSString *) xpsPath
{
#ifdef LOCALDEBUG
	return [[NSBundle mainBundle] pathForResource:self.contentMetadata.FileName ofType:@"xps"];
#else
	return [NSString stringWithFormat:@"%@/%@-%@.xps", 
			[SCHBookInfo cacheDirectory], 
			self.contentMetadata.ContentIdentifier, self.contentMetadata.Version];
#endif
}

- (NSString *) coverImagePath
{
	NSString *cacheDir  = [SCHBookInfo cacheDirectory];
	NSString *fullImagePath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.bookIdentifier]];
	return fullImagePath;
}	

- (NSString *) thumbPathForSize: (CGSize) size
{
	NSString *cacheDir  = [SCHBookInfo cacheDirectory];
	NSString *thumbPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png_%d_%d", self.bookIdentifier, (int)size.width, (int)size.height]];
	
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
		percentage = (float) ((float) fileSize/[self.contentMetadata.FileSize floatValue]);

		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
		}
	} 
	
	return percentage;
}

- (NSString *) currentProcessingStateAsString
{
	NSString *status = @"Unknown!";
	switch ([self processingState]) {
		case SCHBookInfoProcessingStateError:
			status = @"Error";
			break;
		case SCHBookInfoProcessingStateNoURLs:
			status = @"URLs..";
			break;
		case SCHBookInfoProcessingStateNoCoverImage:
			status = @"Cover Img...";
			break;
		case SCHBookInfoProcessingStateReadyForBookFileDownload:
			status = @"Download";
			break;
		case SCHBookInfoProcessingStateDownloadStarted:
			status = @"Downloading...";
			break;
		case SCHBookInfoProcessingStateDownloadPaused:
			status = @"Paused";
			break;
		case SCHBookInfoProcessingStateReadyForRightsParsing:
			status = @"Rights...";
			break;
		case SCHBookInfoProcessingStateReadyToRead:
			status = @"";
			break;
		default:
			break;
	}

	return status;
}

- (BOOL) canOpenBook 
{
	if (self.processingState == SCHBookInfoProcessingStateReadyToRead) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark -
#pragma mark Equality overrides

- (BOOL)isEqual:(id)anObject
{
	BOOL result = NO;
	
	if (anObject) {
		if ([anObject isKindOfClass:[SCHBookInfo class]]) {
			SCHBookInfo *item = (SCHBookInfo *) anObject;
			
			if ([self.bookIdentifier isEqualToString:item.bookIdentifier]) {
				result = YES;
			}
		}
	}
	
	return result;
}

- (NSUInteger)hash
{
	return [self.bookIdentifier hash];
}

@end
