//
//  SCHListBooksAssignmentOperation.m
//  Scholastic
//
//  Created by John Eddie on 19/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListBooksAssignmentOperation.h"

#import "SCHContentSyncComponent.h"
#import "SCHLibreAccessWebService.h"
#import "SCHBooksAssignment.h"
#import "SCHContentProfileItem.h"
#import "SCHProfileItem.h"
#import "SCHAnnotationsItem.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHLastPage.h"
#import "SCHRating.h"
#import "SCHPrivateAnnotations.h"
#import "SCHAppContentProfileItem.h"
#import "SCHBookIdentifier.h"
#import "BITAPIError.h"
#import "SCHContentMetadataItem.h"
#import "SCHAppRecommendationISBN.h"
#import "SCHRecommendationItem.h"

@interface SCHListBooksAssignmentOperation ()

- (NSArray *)localBooksAssignmentsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)addAnnotationStructure:(SCHBooksAssignment *)booksAssignment
                    forProfile:(SCHContentProfileItem *)contentProfileItem
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)removeAnnotationStructure:(SCHBooksAssignment *)booksAssignment
                       forProfile:(SCHContentProfileItem *)contentProfileItem
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem
                                         forBook:(SCHBookIdentifier *)bookIdentifier
                            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncBooksAssignments:(NSDictionary *)webBooksAssignment
         withBooksAssignment:(SCHBooksAssignment *)localBooksAssignment
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncContentProfileItems:(NSArray *)webContentProfileList
        localContentProfileList:(NSSet *)localContentProfileList
                     insertInto:(SCHBooksAssignment *)booksAssignment
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem 
        withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem;
- (void)deleteUnusedContentMetadataItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)removeRecommendationForBook:(SCHContentMetadataItem *)contentMetadataItem
               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHListBooksAssignmentOperation

- (void)main
{
    @try {
        NSArray *content = [self.result objectForKey:kSCHLibreAccessWebServiceBooksAssignmentList];
        [self syncBooksAssignments:content
              managedObjectContext:self.backgroundThreadManagedObjectContext];
        
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListBooksAssignment
                                                       result:self.result 
                                                     userInfo:self.userInfo 
                                             notificationName:SCHContentSyncComponentDidCompleteNotification 
                                         notificationUserInfo:nil];
            }
        });                
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListBooksAssignment 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHContentSyncComponentDidFailNotification 
                                         notificationUserInfo:nil];
            }
        });   
    }            
}

- (void)syncBooksAssignments:(NSArray *)booksAssignmentList
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [booksAssignmentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                         [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                         nil]];	
	NSArray *localProfiles = [self localBooksAssignmentsWithManagedObjectContext:aManagedObjectContext];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHBooksAssignment *localItem = [localEnumerator nextObject];
	
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
                    [self syncBooksAssignments:webItem
                           withBooksAssignment:localItem
                          managedObjectContext:aManagedObjectContext];
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
	
    if ([deletePool count] > 0) {
        // send notifications for deletions
        NSMutableDictionary *profilesWithBookIdentifiers = [NSMutableDictionary dictionary];        
        for (SCHBooksAssignment *booksAssignment in deletePool) {
            SCHBookIdentifier *bookIdentifier = [booksAssignment bookIdentifier];
            if (bookIdentifier != nil) {
                for (SCHContentProfileItem *contentProfileItem in booksAssignment.profileList) {
                    NSNumber *profileID = contentProfileItem.ProfileID;
                    if (profileID != nil) {
                        NSMutableArray *books = [profilesWithBookIdentifiers objectForKey:profileID];
                        if (books == nil) {
                            books = [NSMutableArray array];
                            [profilesWithBookIdentifiers setObject:books forKey:profileID];
                        }
                        [books addObject:bookIdentifier];
                    }
                }
            }
        }
        if ([profilesWithBookIdentifiers count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isCancelled == NO) {        
                    for (NSNumber *profileID in [profilesWithBookIdentifiers allKeys]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentWillDeleteNotification 
                                                                            object:self 
                                                                          userInfo:[NSDictionary dictionaryWithObject:[profilesWithBookIdentifiers objectForKey:profileID]
                                                                                                               forKey:profileID]];                    
                    }
                }
            });
        }
        
        // delete objects
        for (SCHBooksAssignment *booksAssignment in deletePool) {
            SCHBookIdentifier *bookIdentifier = [booksAssignment bookIdentifier];
            for (SCHContentProfileItem *contentProfileItem in booksAssignment.profileList) {
                if (bookIdentifier != nil) {
                    [contentProfileItem deleteStatisticsForBook:bookIdentifier];    
                    [contentProfileItem deleteAnnotationsForBook:bookIdentifier];
                } 
                [self removeAnnotationStructure:booksAssignment
                                     forProfile:contentProfileItem
                           managedObjectContext:aManagedObjectContext];                
            }
            
            [aManagedObjectContext deleteObject:booksAssignment];
        }
    }
    
    for (NSDictionary *webItem in creationPool) {
        [self addBooksAssignment:webItem managedObjectContext:aManagedObjectContext];
    }
	
	[self saveWithManagedObjectContext:aManagedObjectContext];
    
    [self deleteUnusedContentMetadataItemsWithManagedObjectContext:aManagedObjectContext];
}

- (NSArray *)localBooksAssignmentsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHBooksAssignment
                                        inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (SCHBooksAssignment *)addBooksAssignment:(NSDictionary *)webBooksAssignment
                      managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHBooksAssignment *newBooksAssignment = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webBooksAssignment];
    
    if (webBooksAssignment != nil && webBookIdentifier != nil) {
        newBooksAssignment = [NSEntityDescription insertNewObjectForEntityForName:kSCHBooksAssignment
                                                           inManagedObjectContext:aManagedObjectContext];
        
        newBooksAssignment.DRMQualifier = webBookIdentifier.DRMQualifier;
        newBooksAssignment.version = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceVersion]];
        newBooksAssignment.ContentIdentifier = webBookIdentifier.isbn;
        newBooksAssignment.format = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceFormat]];
        newBooksAssignment.defaultAssignment = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];
        newBooksAssignment.ContentIdentifierType = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
        
        newBooksAssignment.lastVersion = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceLastVersion]];
        newBooksAssignment.freeBook = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceFreeBook]];
        newBooksAssignment.averageRating = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceAverageRating]];
        newBooksAssignment.numVotes = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceNumVotes]];
        newBooksAssignment.quantity = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceQuantity]];
        newBooksAssignment.quantityInit = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceQuantityInit]];
        
        NSArray *profileList = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceProfileList]];
        for (NSDictionary *profileItem in profileList) {     
            SCHContentProfileItem *contentProfileItem = [self addContentProfileItem:profileItem
                                                                            forBook:newBooksAssignment.bookIdentifier
                                                               managedObjectContext:aManagedObjectContext];
            if (contentProfileItem != nil) {
                [newBooksAssignment addProfileListObject:contentProfileItem];
                [self addAnnotationStructure:newBooksAssignment 
                                  forProfile:contentProfileItem
                        managedObjectContext:aManagedObjectContext];
            }
        }
    	
        newBooksAssignment.lastOrderDate = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceLastOrderDate]];
    }
    [webBookIdentifier release], webBookIdentifier = nil;
    
    return newBooksAssignment;
}

- (void)addAnnotationStructure:(SCHBooksAssignment *)booksAssignment
                    forProfile:(SCHContentProfileItem *)contentProfileItem
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (booksAssignment != nil && contentProfileItem != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem 
                                            inManagedObjectContext:aManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", contentProfileItem.ProfileID]];
        
        NSArray *annotationsItems = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
        [fetchRequest release], fetchRequest = nil;
        if (annotationsItems == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if([annotationsItems count] > 0) {
            SCHLastPage *newLastPage = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage 
                                                                     inManagedObjectContext:aManagedObjectContext];
            [newLastPage setInitialValues];
            
            SCHRating *newRating = [NSEntityDescription insertNewObjectForEntityForName:kSCHRating 
                                                                 inManagedObjectContext:aManagedObjectContext];
            [newRating setInitialValues];
            
            SCHPrivateAnnotations *newPrivateAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations 
                                                                                         inManagedObjectContext:aManagedObjectContext];
            newPrivateAnnotations.LastPage = newLastPage;
            newPrivateAnnotations.rating = newRating;
            
            SCHAnnotationsContentItem *newAnnotationsContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem 
                                                                                                 inManagedObjectContext:aManagedObjectContext];
            newAnnotationsContentItem.AnnotationsItem = [annotationsItems objectAtIndex:0];
            newAnnotationsContentItem.DRMQualifier = booksAssignment.DRMQualifier;
            newAnnotationsContentItem.ContentIdentifier = booksAssignment.ContentIdentifier;
            newAnnotationsContentItem.Format = booksAssignment.format;
            newAnnotationsContentItem.ContentIdentifierType = booksAssignment.ContentIdentifierType;
            newAnnotationsContentItem.PrivateAnnotations = newPrivateAnnotations;
        }
    }
}

- (void)removeAnnotationStructure:(SCHBooksAssignment *)booksAssignment
                       forProfile:(SCHContentProfileItem *)contentProfileItem
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (booksAssignment != nil && contentProfileItem != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem 
                                            inManagedObjectContext:aManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", contentProfileItem.ProfileID]];
        
        NSArray *annotationsItems = [aManagedObjectContext executeFetchRequest:fetchRequest 
                                                                         error:&error];	
        [fetchRequest release], fetchRequest = nil;
        if (annotationsItems == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([annotationsItems count] > 0) {
            SCHBookIdentifier *bookIdentifier = [booksAssignment bookIdentifier];
            for (SCHAnnotationsContentItem *item in [[annotationsItems objectAtIndex:0] AnnotationsContentItem]) {
                if ([bookIdentifier isEqual:item.bookIdentifier] == YES)
                    [aManagedObjectContext deleteObject:item];
            }        
        }
    }    
}

- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem 
                                         forBook:(SCHBookIdentifier *)bookIdentifier
                            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
{
	SCHContentProfileItem *ret = nil;
    NSError *error = nil;
    id profileID = [self makeNullNil:[contentProfileItem valueForKey:kSCHLibreAccessWebServiceProfileID]];
    
	if (contentProfileItem != nil && bookIdentifier != nil && [SCHProfileItem isValidProfileID:profileID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem 
                                            inManagedObjectContext:aManagedObjectContext];			
		
		ret.LastModified = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
		
		ret.ProfileID = profileID;
		ret.LastPageLocation = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
        ret.Rating = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceRating]];
        
        SCHAppContentProfileItem *newAppContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppContentProfileItem 
                                                                                           inManagedObjectContext:aManagedObjectContext];    
        
        newAppContentProfileItem.ISBN = bookIdentifier.isbn;       
        newAppContentProfileItem.DRMQualifier = bookIdentifier.DRMQualifier;
        newAppContentProfileItem.ContentProfileItem = ret;
        // IsNewBook is derived on request as it requires the annotations to be available
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                            inManagedObjectContext:aManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@", ret.ProfileID]];
        NSArray *results = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (results == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if([results count] > 0) {
            newAppContentProfileItem.ProfileItem = [results objectAtIndex:0];    
            
            NSArray *dictionaryObjects = [NSArray arrayWithObjects:[newAppContentProfileItem bookIdentifier], ret.ProfileID, nil];
            NSArray *dictionaryKeys    = [NSArray arrayWithObjects:SCHContentSyncComponentAddedBookIdentifier, SCHContentSyncComponentAddedProfileIdentifier, nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isCancelled == NO) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidAddBookToProfileNotification 
                                                                        object:self 
                                                                      userInfo:[NSDictionary dictionaryWithObjects:dictionaryObjects forKeys:dictionaryKeys]];   
                }
            });
        }
	}
	
	return ret;
}

- (void)syncBooksAssignments:(NSDictionary *)webBooksAssignment
         withBooksAssignment:(SCHBooksAssignment *)localBooksAssignment
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (webBooksAssignment != nil) {
        localBooksAssignment.DRMQualifier = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
        localBooksAssignment.version = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceVersion]];
        localBooksAssignment.ContentIdentifier = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        localBooksAssignment.format = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceFormat]];
        localBooksAssignment.defaultAssignment = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];
        localBooksAssignment.ContentIdentifierType = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
                
        [self syncContentProfileItems:[self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceProfileList]] 
              localContentProfileList:localBooksAssignment.profileList
                           insertInto:localBooksAssignment
                 managedObjectContext:aManagedObjectContext];
        
        localBooksAssignment.lastVersion = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceLastVersion]];
        localBooksAssignment.freeBook = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceFreeBook]];
        localBooksAssignment.averageRating = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceAverageRating]];
        localBooksAssignment.numVotes = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceNumVotes]];
        localBooksAssignment.quantity = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceQuantity]];
        localBooksAssignment.quantityInit = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceQuantityInit]];
        
        localBooksAssignment.lastOrderDate = [self makeNullNil:[webBooksAssignment objectForKey:kSCHLibreAccessWebServiceLastOrderDate]];
    }
}

- (void)syncContentProfileItems:(NSArray *)webContentProfileList
        localContentProfileList:(NSSet *)localContentProfileList
                     insertInto:(SCHBooksAssignment *)booksAssignment
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{		
	NSArray *sortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceProfileID ascending:YES]];
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [webContentProfileList sortedArrayUsingDescriptors:sortDescriptor];		
	NSArray *localProfiles = [localContentProfileList sortedArrayUsingDescriptors:sortDescriptor];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHContentProfileItem *localItem = [localEnumerator nextObject];
	
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
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceProfileID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceProfileID];
		
        if (webItemID == nil || [SCHProfileItem isValidProfileID:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {                
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncContentProfileItem:webItem withContentProfileItem:localItem];
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
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
	
    if ([deletePool count] > 0) {
        // send notifications for deletions
        NSMutableDictionary *profilesWithBookIdentifiers = [NSMutableDictionary dictionaryWithCapacity:[deletePool count]];
        for (SCHContentProfileItem *contentProfileItem in deletePool) {
            NSNumber *profileID = [contentProfileItem ProfileID];
            SCHBookIdentifier *bookIdentifier = [contentProfileItem.booksAssignment bookIdentifier];
            if (profileID != nil && bookIdentifier != nil) {
                NSMutableArray *books = [profilesWithBookIdentifiers objectForKey:profileID];
                if (books == nil) {
                    books = [NSMutableArray array];
                    [profilesWithBookIdentifiers setObject:books forKey:profileID];
                }                
                [books addObject:bookIdentifier];
            }
        }
        if ([profilesWithBookIdentifiers count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isCancelled == NO) {        
                    for (NSNumber *profileID in [profilesWithBookIdentifiers allKeys]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentWillDeleteNotification 
                                                                            object:self 
                                                                          userInfo:[NSDictionary dictionaryWithObject:[profilesWithBookIdentifiers objectForKey:profileID]
                                                                                                               forKey:profileID]];                    
                    }
                }
            });
        }
        
        // delete objects
        for (SCHContentProfileItem *contentProfileItem in deletePool) {
            
            SCHBookIdentifier *bookIdentifier = [contentProfileItem.booksAssignment bookIdentifier];
            
            if (bookIdentifier != nil) {
                [contentProfileItem deleteStatisticsForBook:bookIdentifier];    
                [contentProfileItem deleteAnnotationsForBook:bookIdentifier];
            }  
            
            [aManagedObjectContext deleteObject:contentProfileItem];            
        }
        
    }
    
	for (NSDictionary *webItem in creationPool) {
        SCHContentProfileItem *item = [self addContentProfileItem:webItem
                                                          forBook:[booksAssignment bookIdentifier]
                                             managedObjectContext:aManagedObjectContext];
        
        if (item != nil) {
            [booksAssignment addProfileListObject:item];
        }
	}
}

- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem
{
    if (webContentProfileItem != nil) {
        localContentProfileItem.LastModified = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localContentProfileItem.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];
        
        localContentProfileItem.ProfileID = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
        localContentProfileItem.LastPageLocation = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
        // IsNewBook is derived on request as it requires the annotations to be available
        localContentProfileItem.Rating = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceRating]];
    }
}

// if a book does not belong on at least one bookshelf then we remove it and thus
// any of the on disk files
- (void)deleteUnusedContentMetadataItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
    NSError *error = nil;    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem
                                        inManagedObjectContext:aManagedObjectContext]];
    
    NSArray *contentMetadataItems = [aManagedObjectContext executeFetchRequest:fetchRequest 
                                                                         error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (contentMetadataItems == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    for (SCHContentMetadataItem *contentMetadataItem in contentMetadataItems) {
        SCHBooksAssignment *booksAssignment = [contentMetadataItem booksAssignment];
        if (booksAssignment == nil || [booksAssignment.profileList count] == 0) {
            [self removeRecommendationForBook:contentMetadataItem
                         managedObjectContext:aManagedObjectContext];
            [contentMetadataItem deleteAllFiles];
            [aManagedObjectContext deleteObject:contentMetadataItem];
        }
    }   
    
    [self saveWithManagedObjectContext:aManagedObjectContext];
}

- (void)removeRecommendationForBook:(SCHContentMetadataItem *)contentMetadataItem
               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (contentMetadataItem != nil) {
        SCHAppRecommendationISBN *recommendationISBN = [contentMetadataItem.AppBook appRecommendationISBN];
        if (recommendationISBN != nil) {
            [aManagedObjectContext deleteObject:recommendationISBN];
            [self saveWithManagedObjectContext:aManagedObjectContext];
        }
    }
}

@end
