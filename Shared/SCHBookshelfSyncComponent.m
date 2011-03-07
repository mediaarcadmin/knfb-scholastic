//
//  SCHBookshelfSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookshelfSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHUserContentItem+Extensions.h"

@interface SCHBookshelfSyncComponent ()

- (BOOL)updateContentMetadataItems;

- (NSArray *)localContentMetadataItems;
- (void)syncContentMetadataItems:(NSArray *)contentMetadataList;
- (void)addContentMetadataItem:(NSDictionary *)webContentMetadataItem;
- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem;

@property (nonatomic, assign) BOOL includeURLs;
@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation SCHBookshelfSyncComponent

@synthesize useIndividualRequests;
@synthesize includeURLs;
@synthesize requestCount;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.useIndividualRequests = YES;	
		self.includeURLs = NO;
		self.requestCount = 0;
	}
	return(self);
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		ret = [self updateContentMetadataItems];
	}
	
	return(ret);		
}

- (void)clear
{
	NSError *error = nil;
	
	if (![self.managedObjectContext emptyEntity:kSCHContentMetadataItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
		[self syncContentMetadataItems:list];
		
		if (self.useIndividualRequests == YES) {
			requestCount--;
			if ([list count] > 0) {
				NSString *ISBN = [[list objectAtIndex:0] valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
				NSLog(@"%@ Book information received", ISBN);
				[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentBookReceived object:[NSArray arrayWithObject:ISBN]];				
			} else {
				NSLog(@"Book information received");				
			}
			
			if (requestCount < 1) {
				[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentComplete object:nil];
				[super method:method didCompleteWithResult:nil];				
			}
		} else {
			NSMutableArray *ISBNs = [NSMutableArray array];
			for (NSDictionary *book in list) {
				[ISBNs addObject:[book valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentBookReceived object:ISBNs];							
			NSLog(@"Book information received");		
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookshelfSyncComponentComplete object:nil];
			[super method:method didCompleteWithResult:nil];				
		}
	}	
}

- (BOOL)updateContentMetadataItems
{		
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
	
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	requestCount = 0;
	if([results count] > 0) {
		if (self.useIndividualRequests == YES) {
			for (NSDictionary *ISBN in results) {
				self.isSynchronizing = [self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:ISBN] includeURLs:self.includeURLs];
				if (self.isSynchronizing == NO) {
					[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
					ret = NO;			
				} else {
					requestCount++;
					NSLog(@"Requesting %@ Book information", [ISBN valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);					
				}
			}
		} else {
			self.isSynchronizing = [self.libreAccessWebService listContentMetadata:results includeURLs:self.includeURLs];
			if (self.isSynchronizing == NO) {
				[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
				ret = NO;			
			} else {
				NSLog(@"Requesting ALL Book information");
			}
		}
	} else {
		ret = NO;
	}
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);	
}

- (NSArray *)localContentMetadataItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (void)syncContentMetadataItems:(NSArray *)contentMetadataList
{		
	NSMutableSet *deletePool = [NSMutableSet set];
	NSMutableSet *creationPool = [NSMutableSet set];
	
	NSArray *webProfiles = [contentMetadataList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];		
	NSArray *localProfiles = [self localContentMetadataItems];
		
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHContentMetadataItem *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			while (localItem != nil) {
				[deletePool addObject:localItem];
				localItem = [localEnumerator nextObject];
			} 
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
				[creationPool addObject:webItem];
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}
		
		id webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
		
		switch ([webItemID compare:localItemID]) {
			case NSOrderedSame:
				[self syncContentMetadataItem:webItem withContentMetadataItem:localItem];
				webItem = nil;
				localItem = nil;
				break;
			case NSOrderedAscending:
				[creationPool addObject:webItem];
				webItem = nil;
				break;
			case NSOrderedDescending:
				[deletePool addObject:localItem];
				localItem = nil;
				break;			
		}		
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
	
	for (SCHContentMetadataItem *localItem in deletePool) {
		[self.managedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
		[self addContentMetadataItem:webItem];
	}
	
	[self save];
}

- (void)addContentMetadataItem:(NSDictionary *)webContentMetadataItem
{
	SCHContentMetadataItem *newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
	
	newContentMetadataItem.DRMQualifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
	newContentMetadataItem.ContentIdentifierType = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
	newContentMetadataItem.ContentIdentifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
	
	newContentMetadataItem.Author = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]];
	newContentMetadataItem.Version = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]];
	newContentMetadataItem.Enhanced = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]];
	newContentMetadataItem.FileSize = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]];
	newContentMetadataItem.CoverURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]];
	newContentMetadataItem.ContentURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]];
	newContentMetadataItem.PageNumber = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]];
	newContentMetadataItem.Title = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]];
	newContentMetadataItem.Description = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]];
}

- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem
{
	localContentMetadataItem.DRMQualifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
	localContentMetadataItem.ContentIdentifierType = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
	localContentMetadataItem.ContentIdentifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
	
	localContentMetadataItem.Author = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]];
	localContentMetadataItem.Version = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]];
	localContentMetadataItem.Enhanced = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]];
	localContentMetadataItem.FileSize = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]];
	if (includeURLs == YES) {
		localContentMetadataItem.CoverURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]];
		localContentMetadataItem.ContentURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]];
	}
	localContentMetadataItem.PageNumber = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]];
	localContentMetadataItem.Title = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]];
	localContentMetadataItem.Description = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]];
}

@end
