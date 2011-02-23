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
@synthesize metadataItemID;
@synthesize downloading, waitingForDownload;


- (id) init
{
	if (self = [super init]) {
		self.currentThread = pthread_self();
		self.downloading = NO;
	}
	
	return self;
}

- (id) initWithContentMetadataItem: (SCHContentMetadataItem *) metadataItem
{
	if (self = [self init]) {
		self.metadataItemID = [metadataItem objectID];
	}
	
	return self;
}

- (SCHContentMetadataItem *) contentMetadata
{
	//[self threadCheck];
	
	
    // If we don't do a refresh here, we run the risk that another thread has
    // modified the object while it's been cached by this thread's managed
    // object context.  
    // If I were redesigning this, I'd make only one thread allowed to modify
    // the books, and call 
    // - (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
    // on the other threads when it saved.
/*    NSManagedObjectContext *context = self.managedObjectContextForCurrentThread;
    BlioBook *book = nil;
    
    if (aBookID) {
        book = (BlioBook *)[context objectWithID:aBookID];
    }
    else NSLog(@"WARNING: BlioBookManager bookWithID: aBookID is nil!");
    if (book) {
        [context refreshObject:book mergeChanges:YES];
    }
    
    return book;
*/	
	SCHContentMetadataItem *item = nil;
	
	if (self.metadataItemID) {
		
		NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
		
		if (context) {
			item = (SCHContentMetadataItem *) [context objectWithID:self.metadataItemID];
			if (item) {
				[context refreshObject:item mergeChanges:YES];
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
	if (self.downloading) {
		return bookFileProcessingStateCurrentlyDownloading;
	}
	
	if (self.waitingForDownload) {
		return bookFileProcessingWaitingForDownload;
	}
	
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
