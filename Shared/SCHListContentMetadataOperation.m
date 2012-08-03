//
//  SCHListContentMetadataOperation.m
//  Scholastic
//
//  Created by John Eddie on 22/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListContentMetadataOperation.h"

#import "SCHBookshelfSyncComponent.h"
#import "SCHLibreAccessConstants.h"
#import "SCHContentMetadataItem.h"
#import "SCHAppBook.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHReadingStatsContentItem.h"
#import "BITAPIError.h"
#import "SCHBookIdentifier.h"

@interface SCHListContentMetadataOperation ()

- (void)postBookshelfSyncComponentBookReceivedNotification:(NSArray *)contentMetadataItems;
- (NSArray *)localContentMetadataItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHListContentMetadataOperation

@synthesize useIndividualRequests;

- (void)main
{
    SCHBookshelfSyncComponent *bookshelfSyncComponent = (SCHBookshelfSyncComponent *)self.syncComponent;
    
    @try {
        BOOL triggerDidCompleteNotification = NO;
        if (self.useIndividualRequests == YES) {
            bookshelfSyncComponent.requestCount--;
            triggerDidCompleteNotification = (bookshelfSyncComponent.requestCount < 1);
        }
                
        NSArray *list = [self.result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
        [self syncContentMetadataItems:list 
                  managedObjectContext:self.backgroundThreadManagedObjectContext];
        
        if (self.useIndividualRequests == YES) {
            if ([list count] > 0) {
                [self postBookshelfSyncComponentBookReceivedNotification:[NSArray arrayWithObject:[list objectAtIndex:0]]];
            }
            
            if (triggerDidCompleteNotification == YES) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.isCancelled == NO) {
                        [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListContentMetadata 
                                                               result:nil 
                                                             userInfo:self.userInfo 
                                                     notificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                 notificationUserInfo:nil];
                    }
                });
            }
        } else {
            [self postBookshelfSyncComponentBookReceivedNotification:list];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isCancelled == NO) {
                    [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListContentMetadata 
                                                           result:nil 
                                                         userInfo:self.userInfo 
                                                 notificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                             notificationUserInfo:nil];
                }
            });
        }
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSArray *bookIdentifiers = [bookshelfSyncComponent bookIdentifiersFromRequestInfo:[self.result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]];
                
                if (self.useIndividualRequests == YES) {
                    [bookshelfSyncComponent.didReceiveFailedResponseBooks addObjectsFromArray:bookIdentifiers];
                    
                    if (bookshelfSyncComponent.requestCount < 1) {
                        NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:bookshelfSyncComponent.didReceiveFailedResponseBooks 
                                                                                         forKey:SCHBookshelfSyncComponentBookIdentifiers];
                        
                        
                        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                             code:kBITAPIExceptionError 
                                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                              forKey:NSLocalizedDescriptionKey]];
                        [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListContentMetadata 
                                                  error:error 
                                            requestInfo:nil 
                                                 result:self.result 
                                       notificationName:SCHBookshelfSyncComponentDidFailNotification 
                                   notificationUserInfo:notificationUserInfo];
                    }
                } else {
                    NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:bookIdentifiers 
                                                                                     forKey:SCHBookshelfSyncComponentBookIdentifiers];
                    
                    NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                         code:kBITAPIExceptionError 
                                                     userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListContentMetadata 
                                              error:error 
                                        requestInfo:nil 
                                             result:self.result 
                                   notificationName:SCHBookshelfSyncComponentDidFailNotification 
                               notificationUserInfo:notificationUserInfo];
                }    
            }
        });   
    }                    
}

- (void)postBookshelfSyncComponentBookReceivedNotification:(NSArray *)contentMetadataItems
{
    NSMutableArray *bookIdentifiers = [NSMutableArray arrayWithCapacity:[contentMetadataItems count]];
    
    for (NSDictionary *book in contentMetadataItems) {
        SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:book] autorelease];
        if (bookIdentifier) {
            [bookIdentifiers addObject:bookIdentifier];
        }
    }
    
    if ([bookIdentifiers count] > 0) {
        NSLog(@"Book information received:\n%@", bookIdentifiers);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentBookReceivedNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:bookIdentifiers forKey:@"bookIdentifiers"]];				
            }
        });
    }
}

- (void)syncContentMetadataItems:(NSArray *)contentMetadataList 
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{		
	NSMutableArray *deletePool = [NSMutableArray array];    
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [contentMetadataList sortedArrayUsingDescriptors:
                            [NSArray arrayWithObjects:
                             [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                             nil]];		
	NSArray *localProfiles = [self localContentMetadataItemsWithManagedObjectContext:aManagedObjectContext];
    
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
		
        SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webItem];
        SCHBookIdentifier *localBookIdentifier = localItem.bookIdentifier;
        
        if (webBookIdentifier == nil) {
            webItem = nil;
        } else if (localBookIdentifier == nil) {
            localItem = nil;                
        } else {
            switch ([webBookIdentifier compare:localBookIdentifier]) {
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
        }
        
        [webBookIdentifier release];            
        
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
    
    if (self.useIndividualRequests == NO && [deletePool count] > 0) {
        NSMutableArray *deletedBookIdentifiers = [NSMutableArray array];
        for (SCHContentMetadataItem *contentMetadataItem in deletePool) {
            SCHBookIdentifier *bookIdentifier = [contentMetadataItem bookIdentifier];
            if (bookIdentifier != nil) {
                [deletedBookIdentifiers addObject:bookIdentifier];            
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentWillDeleteNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:deletedBookIdentifiers 
                                                                                                       forKey:SCHBookshelfSyncComponentBookIdentifiers]];        
            }
        });
        
        for (SCHContentMetadataItem *contentMetadataItem in deletePool) {
            [self deleteStatisticsForBook:[contentMetadataItem bookIdentifier]
                     managedObjectContext:aManagedObjectContext];
            [self deleteAnnotationsForBook:[contentMetadataItem bookIdentifier]
                      managedObjectContext:aManagedObjectContext];
            [aManagedObjectContext deleteObject:contentMetadataItem];
        }
    }
    
	for (NSDictionary *webItem in creationPool) {
		[self addContentMetadataItem:webItem
                managedObjectContext:aManagedObjectContext];
	}
	
    [self saveWithManagedObjectContext:aManagedObjectContext];
}

- (NSArray *)localContentMetadataItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem 
                                        inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
	return(ret);
}

- (SCHContentMetadataItem *)addContentMetadataItem:(NSDictionary *)webContentMetadataItem
                              managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    SCHContentMetadataItem *newContentMetadataItem = nil;
    SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webContentMetadataItem];
    
    if (webContentMetadataItem != nil && webBookIdentifier != nil) {
        newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem 
                                                               inManagedObjectContext:aManagedObjectContext];
        
        newContentMetadataItem.DRMQualifier = webBookIdentifier.DRMQualifier;
        newContentMetadataItem.ContentIdentifierType = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
        newContentMetadataItem.ContentIdentifier = webBookIdentifier.isbn;
        
        newContentMetadataItem.Author = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]];
        newContentMetadataItem.Version = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]];
        newContentMetadataItem.Enhanced = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]];
        newContentMetadataItem.FileSize = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]];
        newContentMetadataItem.CoverURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]];
        newContentMetadataItem.ContentURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]];
        newContentMetadataItem.PageNumber = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]];
        newContentMetadataItem.Title = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]];
        newContentMetadataItem.Description = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]];
        newContentMetadataItem.AverageRating = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAverageRating]];
        
        newContentMetadataItem.AppBook = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook 
                                                                       inManagedObjectContext:aManagedObjectContext];
    }
    [webBookIdentifier release], webBookIdentifier = nil;
    
    return newContentMetadataItem;
}

- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem 
        withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem
{
    if (webContentMetadataItem != nil) {
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
        localContentMetadataItem.AverageRating = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAverageRating]];
    }
}

- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSError *error = nil;
    
    if (identifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHReadingStatsContentItem
                                                  inManagedObjectContext:aManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHReadingStatsContentItemFetchReadingStatsContentItemForBook 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObjectsAndKeys:
                                                               identifier.isbn, kSCHReadingStatsContentItemCONTENT_IDENTIFIER,
                                                               identifier.DRMQualifier, kSCHReadingStatsContentItemDRM_QUALIFIER,
                                                               nil]];
        NSArray *bookArray = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (bookArray == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([bookArray count] > 0) {
            [aManagedObjectContext deleteObject:[bookArray objectAtIndex:0]];
        }
    }    
}

- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSError *error = nil;
    
    if (identifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHAnnotationsContentItem
                                                  inManagedObjectContext:aManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHAppBookFetchWithContentIdentifier 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObjectsAndKeys:
                                                               identifier.isbn, kSCHAppBookCONTENT_IDENTIFIER,
                                                               identifier.DRMQualifier, kSCHAppBookDRM_QUALIFIER,
                                                               nil]];
        NSArray *bookArray = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (bookArray == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([bookArray count] > 0) {
            [aManagedObjectContext deleteObject:[bookArray objectAtIndex:0]];
        }
    }    
}

@end
