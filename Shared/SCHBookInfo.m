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
@synthesize coverURL, bookFileURL;


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
	
	NSString *state = @"Unknown";
	
	switch (self.processingState) {
		case SCHBookInfoProcessingStateNoURLs:
			state = @"No URLs";
			break;
		case SCHBookInfoProcessingStateNoCoverImage:
			state = @"No Cover Image";
			break;
		case SCHBookInfoProcessingStateReadyForBookFileDownload:
			state = @"Ready for Download";
			break;
		case SCHBookInfoProcessingStateDownloadStarted:
			state = @"Downloading";
			break;
		case SCHBookInfoProcessingStateDownloadPaused:
			state = @"Download Paused";
			break;
		case SCHBookInfoProcessingStateReadyToRead:
			state = @"Ready to Read";
			break;
		case SCHBookInfoProcessingStateError:
			state = @"Processing Error";
			break;
		default:
			break;
	}	
	
	NSLog(@"setting %@ to processing state \"%@\".", self.bookIdentifier, state);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStatusUpdate" object:self];
	
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
