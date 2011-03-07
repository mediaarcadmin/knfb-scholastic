//
//  SCHBookInfo.m
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookInfo.h"
#import "SCHBookManager.h"
#import "SCHProcessingManager.h"

@interface SCHBookInfo ()

- (void) threadCheck;

@end


@implementation SCHBookInfo

@synthesize currentThread;
//@synthesize metadataItemID;
@synthesize bookIdentifier;


- (id) init
{
	if (self = [super init]) {
		self.currentThread = pthread_self();
		self.bookIdentifier = nil;
	}
	
	return self;
}

- (id) initWithContentMetadataItem: (SCHContentMetadataItem *) metadataItem
{
	if (self = [self init]) {
		//self.metadataItemID = [metadataItem objectID];
		self.bookIdentifier = [metadataItem ContentIdentifier];
	}
	
	return self;
}

- (SCHContentMetadataItem *) contentMetadata
{
	//[self threadCheck];
	
	SCHContentMetadataItem *item = nil;
	
	if (self.bookIdentifier) {
		
		NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
		
		if (context) {
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			[fetchRequest setEntity:[NSEntityDescription entityForName:@"SCHContentMetadataItem" inManagedObjectContext:context]];	
			
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

- (NSString *) xpsPath
{
	//[self threadCheck];
#ifdef LOCALDEBUG
	return [[NSBundle mainBundle] pathForResource:self.contentMetadata.FileName ofType:@"xps"];
#else
	return [NSString stringWithFormat:@"%@/%@-%@.xps", 
			[SCHProcessingManager cacheDirectory], 
			self.contentMetadata.ContentIdentifier, self.contentMetadata.Version];
#endif
}

- (BOOL) processedCovers
{
	return NO;
}

- (BookFileProcessingState) processingState
{
	NSString *xpsPath = [self xpsPath];
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:xpsPath]) {
		// check to see how much of the file has been downloaded

		unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:xpsPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
			return bookFileProcessingStateError;
		}
		
		if (fileSize == [self.contentMetadata.FileSize unsignedLongLongValue]) {
			return bookFileProcessingStateFullyDownloaded;
		} else {
			return bookFileProcessingStatePartiallyDownloaded;
		}
	} 

	return bookFileProcessingStateNoFileDownloaded;
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
	

- (BOOL) isCurrentlyDownloading
{
	return [[SCHProcessingManager defaultManager] isCurrentlyDownloading:self];
}

- (BOOL) isWaitingForDownload
{
	return [[SCHProcessingManager defaultManager] isCurrentlyWaiting:self];
}

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


- (id) copyWithZone: (NSZone *) zone
{
	SCHBookInfo *bookInfo = [[SCHBookInfo allocWithZone:zone] initWithContentMetadataItem:[self contentMetadata]];
	return bookInfo;
}

- (void) threadCheck
{
	// FIXME: make this conditional
	if (self.currentThread != pthread_self()) {
		[NSException raise:@"SCHBookInfo thread exception" 
					format:@"Passed SCHBookInfo between threads %p and %p", self.currentThread, pthread_self()];
	}
}



@end
