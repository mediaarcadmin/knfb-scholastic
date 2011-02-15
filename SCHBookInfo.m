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

- (void) threadCheck;

@end


@implementation SCHBookInfo

@synthesize currentThread;
@synthesize metadataItemID;


- (id) init
{
	if (self = [super init]) {
		self.currentThread = pthread_self();
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
	[self threadCheck];
	
	SCHContentMetadataItem *item = nil;
	
	if (self.metadataItemID) {
		
		NSManagedObjectContext *moc = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
		
		if (moc) {
			item = (SCHContentMetadataItem *) [moc objectWithID:self.metadataItemID];
		}
	}
	
	return item;
}

- (NSString *) xpsPath
{
	[self threadCheck];
	return [[NSBundle mainBundle] pathForResource:self.contentMetadata.FileName ofType:@"xps"];
}

- (UIImageView *) thumbImageForBook
{
	[self threadCheck];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	
	NSLog(@"Cache path: %@", cachePath);

//	NSString *thumbImagePath = [NSString stringWithFormat:@"%@-%@", [self contentMetadata].
	
	return nil;
	
//	NSString *imageFileName = [[
	
	// has the thumb been processed?
	// check for the thumb thumbnail
	
	
	
	// has the image downloaded?
	// check for the original image thumbnail
	
	
	
	// download the image
	
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
