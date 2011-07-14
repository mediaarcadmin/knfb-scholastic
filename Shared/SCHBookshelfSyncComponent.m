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
#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHAppBook.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHBookIdentifier.h"
#import "SCHReadingStatsContentItem.h"

@interface SCHBookshelfSyncComponent ()

- (BOOL)updateContentMetadataItems;

- (NSArray *)localContentMetadataItems;
- (NSArray *)localUserContentItems;
- (void)syncContentMetadataItems:(NSArray *)contentMetadataList;
- (void)addContentMetadataItem:(NSDictionary *)webContentMetadataItem;
- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem;
- (void)deleteUnusedBooks;
- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier;
- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier;

@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation SCHBookshelfSyncComponent

@synthesize useIndividualRequests;
@synthesize requestCount;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.useIndividualRequests = YES;	
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
    [super clear];
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHContentMetadataItem error:&error]) {
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
				NSString *DRMQualifier = [[list objectAtIndex:0] valueForKey:kSCHLibreAccessWebServiceDRMQualifier];                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                if (ISBN != nil) {
                    [userInfo setObject:ISBN forKey:kSCHLibreAccessWebServiceContentIdentifier];
                }
                if (DRMQualifier != nil) {
                    [userInfo setObject:DRMQualifier forKey:kSCHLibreAccessWebServiceDRMQualifier];
                }
				NSLog(@"%@ Book information received", ISBN);
				[[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentBookReceivedNotification 
                                                                    object:self 
                                                                  userInfo:userInfo];				
			} else {
				NSLog(@"Book information received");				
			}
			
			if (requestCount < 1) {
				[[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentCompletedNotification object:self];
				[super method:method didCompleteWithResult:nil];				
			}
		} else {
			NSLog(@"Book information received");		
			[[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentCompletedNotification object:self];
			[super method:method didCompleteWithResult:nil];				
		}
	}	
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	if (self.useIndividualRequests == YES) {
		requestCount--;
	}

	[super method:method didFailWithError:error];
}

- (BOOL)updateContentMetadataItems
{		
	BOOL ret = YES;
	
	[self deleteUnusedBooks];
	
	NSArray *results = [self localUserContentItems];
	
	requestCount = 0;
	if([results count] > 0) {
		if (self.useIndividualRequests == YES) {
			for (NSDictionary *ISBN in results) {				
				self.isSynchronizing = [self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:ISBN] includeURLs:NO];
				if (self.isSynchronizing == NO) {
					[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
					ret = NO;			
				} else {
					requestCount++;
					NSLog(@"Requesting %@ Book information", [ISBN valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);					
				}
			}
		} else {			
			self.isSynchronizing = [self.libreAccessWebService listContentMetadata:results includeURLs:NO];
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
	
	return(ret);	
}

- (NSArray *)localContentMetadataItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (NSArray *)localUserContentItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (void)syncContentMetadataItems:(NSArray *)contentMetadataList
{		
	NSMutableSet *creationPool = [NSMutableSet set];
	
	NSArray *webProfiles = [contentMetadataList sortedArrayUsingDescriptors:
                            [NSArray arrayWithObjects:
                             [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                             nil]];		
	NSArray *localProfiles = [self localContentMetadataItems];
		
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHContentMetadataItem *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
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
    
    newContentMetadataItem.AppBook = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook inManagedObjectContext:self.managedObjectContext];
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
	NSString *coverURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]];
	if (coverURL != nil){
		localContentMetadataItem.CoverURL = coverURL;
	}
	NSString *contentURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]];
	if (contentURL != nil) {
		localContentMetadataItem.ContentURL = contentURL;
	}
	localContentMetadataItem.PageNumber = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]];
	localContentMetadataItem.Title = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]];
	localContentMetadataItem.Description = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]];
}

- (void)deleteUnusedBooks
{
	NSMutableSet *deletePool = [NSMutableSet set];
	
	NSEnumerator *contentMetadataEnumerator = [[self localContentMetadataItems] objectEnumerator];			  
	NSEnumerator *userContentEnumerator = [[self localUserContentItems] objectEnumerator];			  			  
	
	NSDictionary *contentMetadataItem = [contentMetadataEnumerator nextObject];
	NSDictionary *userContentItem = [userContentEnumerator nextObject];
	
	while (contentMetadataItem != nil || userContentItem != nil) {		
		if (contentMetadataItem == nil) {
			break;
		}
		
		if (userContentItem == nil) {
			while (contentMetadataItem != nil) {
				[deletePool addObject:contentMetadataItem];
				contentMetadataItem = [contentMetadataEnumerator nextObject];
			} 
			break;			
		}
		
		id contentMetadataItemID = [contentMetadataItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
		id userContentItemID = [userContentItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier];
		
		switch ([contentMetadataItemID compare:userContentItemID]) {
			case NSOrderedSame:
				contentMetadataItem = nil;
				userContentItem = nil;
				break;
			case NSOrderedAscending:
				[deletePool addObject:contentMetadataItem];
				contentMetadataItem = nil;
				break;
			case NSOrderedDescending:
				userContentItem = nil;
				break;			
		}		
		
		if (contentMetadataItem == nil) {
			contentMetadataItem = [contentMetadataEnumerator nextObject];
		}
		if (userContentItem == nil) {
			userContentItem = [userContentEnumerator nextObject];
		}		
	}
	
    if ([deletePool count] > 0) {
        NSMutableArray *deletedBookIdentifiers = [NSMutableArray array];
        for (SCHContentMetadataItem *contentMetadataItem in deletePool) {
            [deletedBookIdentifiers addObject:[contentMetadataItem bookIdentifier]];            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentWillDeleteNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:deletedBookIdentifiers 
                                                                                               forKey:SCHBookshelfSyncComponentDeletedBookIdentifiers]];        
        
        for (SCHContentMetadataItem *contentMetadataItem in deletePool) {
            [self deleteStatisticsForBook:[contentMetadataItem bookIdentifier]];
            [self deleteAnnotationsForBook:[contentMetadataItem bookIdentifier]];
            [self.managedObjectContext deleteObject:contentMetadataItem];
        }
    }

	[self save];
}

- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier
{
    NSError *error = nil;
    
    if (identifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHAnnotationsContentItem
                                                  inManagedObjectContext:self.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHAppBookFetchWithContentIdentifier 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObjectsAndKeys:
                                                               identifier.isbn, kSCHAppBookCONTENT_IDENTIFIER,
                                                               identifier.DRMQualifier, kSCHAppBookDRM_QUALIFIER,
                                                               nil]];
        NSArray *bookArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([bookArray count] > 0) {
            [self.managedObjectContext deleteObject:[bookArray objectAtIndex:0]];
        }
    }    
}

- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier
{
    NSError *error = nil;
    
    if (identifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHReadingStatsContentItem
                                                  inManagedObjectContext:self.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHReadingStatsContentItemFetchReadingStatsContentItemForBook 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObjectsAndKeys:
                                                               identifier.isbn, kSCHReadingStatsContentItemCONTENT_IDENTIFIER,
                                                               identifier.DRMQualifier, kSCHReadingStatsContentItemDRM_QUALIFIER,
                                                               nil]];
        NSArray *bookArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([bookArray count] > 0) {
            [self.managedObjectContext deleteObject:[bookArray objectAtIndex:0]];
        }
    }    
}

@end
