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
#import "SCHMakeNullNil.h"

@interface SCHListContentMetadataOperation ()

- (void)postBookshelfSyncComponentFailureForAllRequestedBooks:(NSArray *)contentMetadataItems;
- (NSArray *)bookIdentifiersFromDictionary:(NSArray *)contentMetadataItems
                              includeValid:(BOOL)includeValid
                            includeInvalid:(BOOL)includeInvalid;
- (BOOL)postBookshelfSyncComponentBookReceivedNotification:(NSArray *)contentMetadataItems;
- (NSArray *)localContentMetadataItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHListContentMetadataOperation

@synthesize useIndividualRequests;
@synthesize profileID;
@synthesize requestInfo;
@synthesize responseError;

- (void)main
{
    SCHBookshelfSyncComponent *bookshelfSyncComponent = (SCHBookshelfSyncComponent *)self.syncComponent;
    
    @try {
        NSArray *list = [self.result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];

        // if the response had no contentmetadataitems then we fail all the
        // requested books, otherwise we process the books
        // for example, this will happen if an invalid property was sent
        if ([list count] < 1) {
            [self postBookshelfSyncComponentFailureForAllRequestedBooks:[requestInfo objectForKey:kSCHLibreAccessWebServiceListContentMetadata]];
        } else {
            BOOL triggerDidCompleteNotification = NO;
            if (self.useIndividualRequests == YES) {
                bookshelfSyncComponent.requestCount -= [list count];
                triggerDidCompleteNotification = (bookshelfSyncComponent.requestCount < 1);
            }

            [self syncContentMetadataItems:list
                  managedObjectContext:self.backgroundThreadManagedObjectContext];

            BOOL hadInvalidBooks = [self postBookshelfSyncComponentBookReceivedNotification:list];

            if (self.useIndividualRequests == NO ||
                triggerDidCompleteNotification == YES) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.isCancelled == NO) {
                        if (hadInvalidBooks == NO) {
                            if (self.profileID != nil) {
                                [((SCHBookshelfSyncComponent *)self.syncComponent).profilesForBooks
                                 removeObject:self.profileID];
                            }

                            [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListContentMetadata
                                                                   result:nil
                                                                 userInfo:self.userInfo
                                                         notificationName:SCHBookshelfSyncComponentDidCompleteNotification
                                                     notificationUserInfo:nil];
                        } else {
                            NSArray *bookIdentifiers = [self bookIdentifiersFromDictionary:[self.result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]
                                                                              includeValid:NO
                                                                            includeInvalid:YES];
                            NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:bookIdentifiers
                                                                                             forKey:SCHBookshelfSyncComponentBookIdentifiers];

                            [bookshelfSyncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListContentMetadata
                                                                        error:self.responseError
                                                                  requestInfo:self.requestInfo
                                                                       result:nil
                                                             notificationName:SCHBookshelfSyncComponentDidFailNotification
                                                         notificationUserInfo:notificationUserInfo];
                        }
                    }
                });
            }
        }
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSArray *bookIdentifiers = [self bookIdentifiersFromDictionary:[self.result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]
                                                                  includeValid:YES
                                                                includeInvalid:YES];

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

- (void)postBookshelfSyncComponentFailureForAllRequestedBooks:(NSArray *)contentMetadataItems;
{
    NSArray *bookIdentifiers = [self bookIdentifiersFromDictionary:contentMetadataItems
                                                      includeValid:YES
                                                    includeInvalid:YES];
    SCHBookshelfSyncComponent *bookshelfSyncComponent = (SCHBookshelfSyncComponent *)self.syncComponent;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isCancelled == NO) {
            if (self.useIndividualRequests == YES) {
                bookshelfSyncComponent.requestCount -= [contentMetadataItems count];
                [bookshelfSyncComponent.didReceiveFailedResponseBooks addObjectsFromArray:bookIdentifiers];

                if (bookshelfSyncComponent.requestCount < 1) {
                    NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:bookshelfSyncComponent.didReceiveFailedResponseBooks
                                                                                     forKey:SCHBookshelfSyncComponentBookIdentifiers];

                    [bookshelfSyncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListContentMetadata
                                                                error:self.responseError
                                                          requestInfo:self.requestInfo
                                                               result:self.result
                                                     notificationName:SCHBookshelfSyncComponentDidFailNotification
                                                 notificationUserInfo:notificationUserInfo];
                }
            } else {
                NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:bookIdentifiers
                                                                                 forKey:SCHBookshelfSyncComponentBookIdentifiers];

                [bookshelfSyncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListContentMetadata
                                                            error:self.responseError
                                                      requestInfo:self.requestInfo
                                                           result:self.result
                                                 notificationName:SCHBookshelfSyncComponentDidFailNotification
                                             notificationUserInfo:notificationUserInfo];
            }
        }
    });
}

- (NSArray *)bookIdentifiersFromDictionary:(NSArray *)contentMetadataItems
                              includeValid:(BOOL)includeValid
                            includeInvalid:(BOOL)includeInvalid
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[contentMetadataItems count]];

    for (NSDictionary *contentMetadataItem in contentMetadataItems) {
        BOOL isValid = [SCHContentMetadataItem isValidContentMetadataItemDictionary:contentMetadataItem];
        if ((includeValid == YES && isValid == YES) ||
            (includeInvalid == YES && isValid == NO)) {
            SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:contentMetadataItem] autorelease];
            if (bookIdentifier != nil) {
                [ret addObject:bookIdentifier];
            }
        }
    }

    return ret;
}

// returns YES if we had any invalid books
- (BOOL)postBookshelfSyncComponentBookReceivedNotification:(NSArray *)contentMetadataItems
{
    NSArray *bookIdentifiers = [self bookIdentifiersFromDictionary:contentMetadataItems
                                                      includeValid:YES
                                                    includeInvalid:NO];
    
    if ([bookIdentifiers count] > 0) {
        NSLog(@"Valid book information received:\n%@", bookIdentifiers);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentBookReceivedNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:bookIdentifiers forKey:@"bookIdentifiers"]];				
            }
        });
    }

    return [contentMetadataItems count] != [bookIdentifiers count];
}

- (void)syncContentMetadataItems:(NSArray *)contentMetadataList 
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{		
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
			break;
		}
		
		if (localItem == nil) {
			while (webItem != nil) {
                if ([SCHContentMetadataItem isValidContentMetadataItemDictionary:webItem] == YES) {
                    [creationPool addObject:webItem];
                }
				webItem = [webEnumerator nextObject];
			} 
			break;			
		}
		
        SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webItem];
        SCHBookIdentifier *localBookIdentifier = localItem.bookIdentifier;
        
        if (webBookIdentifier == nil ||
            [SCHContentMetadataItem isValidContentMetadataItemDictionary:webItem] == NO) {
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
        newContentMetadataItem.ContentIdentifierType = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]);
        newContentMetadataItem.ContentIdentifier = webBookIdentifier.isbn;

        newContentMetadataItem.AverageRating = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAverageRating]);
        newContentMetadataItem.numVotes = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceNumVotes]);
        newContentMetadataItem.Author = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]);
        newContentMetadataItem.Version = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]);
        newContentMetadataItem.Enhanced = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]);
        newContentMetadataItem.FileSize = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]);
        newContentMetadataItem.CoverURL = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]);
        newContentMetadataItem.ContentURL = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]);
        newContentMetadataItem.PageNumber = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]);
        newContentMetadataItem.Title = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]);
        newContentMetadataItem.Description = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]);
        newContentMetadataItem.thumbnailURL = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceThumbnailURL]);

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
        localContentMetadataItem.DRMQualifier = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]);
        localContentMetadataItem.ContentIdentifierType = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]);
        localContentMetadataItem.ContentIdentifier = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]);

        localContentMetadataItem.AverageRating = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAverageRating]);
        localContentMetadataItem.numVotes = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceNumVotes]);
        localContentMetadataItem.Author = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]);
        localContentMetadataItem.Version = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]);
        localContentMetadataItem.Enhanced = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]);
        localContentMetadataItem.FileSize = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]);
        NSString *coverURL = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]);
        if (coverURL != nil){
            localContentMetadataItem.CoverURL = coverURL;
        }
        NSString *contentURL = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]);
        if (contentURL != nil) {
            localContentMetadataItem.ContentURL = contentURL;
        }
        localContentMetadataItem.PageNumber = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]);
        localContentMetadataItem.Title = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]);
        localContentMetadataItem.Description = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]);
        NSString *thumbnailURL = makeNullNil([webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceThumbnailURL]);
        if (thumbnailURL != nil) {
            localContentMetadataItem.thumbnailURL = contentURL;
        }
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
