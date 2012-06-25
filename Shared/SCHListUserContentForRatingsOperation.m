//
//  SCHListUserContentForRatingsOperation.m
//  Scholastic
//
//  Created by John Eddie on 19/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListUserContentForRatingsOperation.h"

#import "SCHContentSyncComponent.h"
#import "SCHLibreAccessWebService.h"
#import "SCHUserContentItem.h"
#import "SCHOrderItem.h"
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
#import "SCHRecommendationISBN.h"
#import "SCHRecommendationItem.h"

@interface SCHListUserContentForRatingsOperation ()

- (NSArray *)localUserContentItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem 
                    forProfile:(SCHContentProfileItem *)contentProfileItem
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)removeAnnotationStructure:(SCHUserContentItem *)userContentItem 
                       forProfile:(SCHContentProfileItem *)contentProfileItem
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHOrderItem *)addOrderItem:(NSDictionary *)orderItem
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem
                                         forBook:(SCHBookIdentifier *)bookIdentifier
                            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncUserContentItem:(NSDictionary *)webUserContentItem 
        withUserContentItem:(SCHUserContentItem *)localUserContentItem
       managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncOrderItems:(NSArray *)webOrderList 
        localOrderList:(NSSet *)localOrderList
            insertInto:(SCHUserContentItem *)userContentItem
  managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (BOOL)orderIDIsValid:(NSNumber *)orderID;
- (void)syncOrderItem:(NSDictionary *)webOrderItem 
        withOrderItem:(SCHOrderItem *)localOrderItem;
- (void)syncContentProfileItems:(NSArray *)webContentProfileList 
        localContentProfileList:(NSSet *)localContentProfileList
                     insertInto:(SCHUserContentItem *)userContentItem
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (BOOL)profileIDIsValid:(NSNumber *)profileID;
- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem 
        withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem;
- (void)deleteUnusedContentMetadataItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)removeRecommendationForBook:(SCHContentMetadataItem *)contentMetadataItem
               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHListUserContentForRatingsOperation

- (void)main
{
    @try {
        NSArray *content = [self.result objectForKey:kSCHLibreAccessWebServiceUserContentList];
        [self syncUserContentItems:content
              managedObjectContext:self.backgroundThreadManagedObjectContext];
        
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListUserContentForRatings 
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
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListUserContentForRatings 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHContentSyncComponentDidFailNotification 
                                         notificationUserInfo:nil];
            }
        });   
    }            
}

- (void)syncUserContentItems:(NSArray *)userContentList
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{		
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [userContentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                         [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                         nil]];	
	NSArray *localProfiles = [self localUserContentItemsWithManagedObjectContext:aManagedObjectContext];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHUserContentItem *localItem = [localEnumerator nextObject];
	
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
                    [self syncUserContentItem:webItem 
                          withUserContentItem:localItem
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
        for (SCHUserContentItem *userContentItem in deletePool) {
            SCHBookIdentifier *bookIdentifier = [userContentItem bookIdentifier];
            if (bookIdentifier != nil) {
                for (SCHContentProfileItem *contentProfileItem in userContentItem.ProfileList) {
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
        for (SCHUserContentItem *userContentItem in deletePool) {
            for (SCHContentProfileItem *contentProfileItem in userContentItem.ProfileList) {
                [self removeAnnotationStructure:userContentItem 
                                     forProfile:contentProfileItem
                           managedObjectContext:aManagedObjectContext];                
            }
            
            [aManagedObjectContext deleteObject:userContentItem];
        }
    }
    
    for (NSDictionary *webItem in creationPool) {
        [self addUserContentItem:webItem managedObjectContext:aManagedObjectContext];
    }
	
	[self saveWithManagedObjectContext:aManagedObjectContext];
    
    [self deleteUnusedContentMetadataItemsWithManagedObjectContext:aManagedObjectContext];
}

- (NSArray *)localUserContentItemsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
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

- (SCHUserContentItem *)addUserContentItem:(NSDictionary *)webUserContentItem
                      managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHUserContentItem *newUserContentItem = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webUserContentItem];
    
    if (webUserContentItem != nil && webBookIdentifier != nil) {
        newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem 
                                                           inManagedObjectContext:aManagedObjectContext];
        
        newUserContentItem.DRMQualifier = webBookIdentifier.DRMQualifier;
        newUserContentItem.Version = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
        newUserContentItem.ContentIdentifier = webBookIdentifier.isbn;
        newUserContentItem.Format = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
        newUserContentItem.DefaultAssignment = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
        newUserContentItem.ContentIdentifierType = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
        
        newUserContentItem.LastVersion = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastVersion]];
        newUserContentItem.FreeBook = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFreeBook]];    
        newUserContentItem.AverageRating = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceAverageRating]];        
        
        NSArray *orderList = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]];
        for (NSDictionary *orderItem in orderList) {
            SCHOrderItem *newOrderItem = [self addOrderItem:orderItem
                                       managedObjectContext:aManagedObjectContext];
            if (newOrderItem != nil) { 
                [newUserContentItem addOrderListObject:newOrderItem];
            }
        }
        
        NSArray *profileList = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
        for (NSDictionary *profileItem in profileList) {     
            SCHContentProfileItem *contentProfileItem = [self addContentProfileItem:profileItem
                                                                            forBook:newUserContentItem.bookIdentifier
                                                               managedObjectContext:aManagedObjectContext];
            if (contentProfileItem != nil) {
                [newUserContentItem addProfileListObject:contentProfileItem];
                [self addAnnotationStructure:newUserContentItem 
                                  forProfile:contentProfileItem
                        managedObjectContext:aManagedObjectContext];
            }
        }
    	
        newUserContentItem.LastModified = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
        newUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];	
    }
    [webBookIdentifier release], webBookIdentifier = nil;
    
    return newUserContentItem;
}

- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem 
                    forProfile:(SCHContentProfileItem *)contentProfileItem
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (userContentItem != nil && contentProfileItem != nil) {
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
            newAnnotationsContentItem.DRMQualifier = userContentItem.DRMQualifier;
            newAnnotationsContentItem.ContentIdentifier = userContentItem.ContentIdentifier;
            newAnnotationsContentItem.Format = userContentItem.Format;
            newAnnotationsContentItem.ContentIdentifierType = userContentItem.ContentIdentifierType;
            newAnnotationsContentItem.PrivateAnnotations = newPrivateAnnotations;
        }
    }
}

- (void)removeAnnotationStructure:(SCHUserContentItem *)userContentItem 
                       forProfile:(SCHContentProfileItem *)contentProfileItem
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (userContentItem != nil && contentProfileItem != nil) {
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
            SCHBookIdentifier *bookIdentifier = userContentItem.bookIdentifier;
            for (SCHAnnotationsContentItem *item in [[annotationsItems objectAtIndex:0] AnnotationsContentItem]) {
                if ([bookIdentifier isEqual:item.bookIdentifier] == YES)
                    [aManagedObjectContext deleteObject:item];
            }        
        }
    }    
}

- (SCHOrderItem *)addOrderItem:(NSDictionary *)orderItem
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHOrderItem *ret = nil;
    id orderID = [self makeNullNil:[orderItem valueForKey:kSCHLibreAccessWebServiceOrderID]];
    
	if (orderItem != nil && [self orderIDIsValid:orderID] == YES) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHOrderItem 
                                            inManagedObjectContext:aManagedObjectContext];			
		
		ret.OrderID = orderID;
		ret.OrderDate = [self makeNullNil:[orderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
	}
	
	return ret;
}

- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem 
                                         forBook:(SCHBookIdentifier *)bookIdentifier
                            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
{
	SCHContentProfileItem *ret = nil;
    NSError *error = nil;
    id profileID = [self makeNullNil:[contentProfileItem valueForKey:kSCHLibreAccessWebServiceProfileID]];
    
	if (contentProfileItem != nil && bookIdentifier != nil && [self profileIDIsValid:profileID] == YES) {		
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

- (void)syncUserContentItem:(NSDictionary *)webUserContentItem 
        withUserContentItem:(SCHUserContentItem *)localUserContentItem
       managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (webUserContentItem != nil) {
        localUserContentItem.DRMQualifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
        localUserContentItem.Version = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
        localUserContentItem.ContentIdentifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        localUserContentItem.Format = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
        localUserContentItem.DefaultAssignment = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
        localUserContentItem.ContentIdentifierType = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
        
        [self syncOrderItems:[self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]] 
              localOrderList:localUserContentItem.OrderList
                  insertInto:localUserContentItem
        managedObjectContext:aManagedObjectContext];
        
        [self syncContentProfileItems:[self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]] 
              localContentProfileList:localUserContentItem.ProfileList
                           insertInto:localUserContentItem
                 managedObjectContext:aManagedObjectContext];
        
        localUserContentItem.LastVersion = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastVersion]];
        localUserContentItem.FreeBook = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFreeBook]];
        localUserContentItem.AverageRating = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceAverageRating]];
        
        localUserContentItem.LastModified = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				
    }
}

- (void)syncOrderItems:(NSArray *)webOrderList 
        localOrderList:(NSSet *)localOrderList
            insertInto:(SCHUserContentItem *)userContentItem
  managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{		
	NSArray *sortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceOrderID ascending:YES]];
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [webOrderList sortedArrayUsingDescriptors:sortDescriptor];		
	NSArray *localProfiles = [localOrderList sortedArrayUsingDescriptors:sortDescriptor];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHOrderItem *localItem = [localEnumerator nextObject];
	
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
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceOrderID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceOrderID];
		
        if (webItemID == nil || [self orderIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncOrderItem:webItem withOrderItem:localItem];
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
	
	for (SCHOrderItem *localItem in deletePool) {
		[aManagedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
        SCHOrderItem *newOrderItem = [self addOrderItem:webItem
                                   managedObjectContext:aManagedObjectContext];
        if (newOrderItem != nil) {
            [userContentItem addOrderListObject:newOrderItem];
        }
	}
}

- (BOOL)orderIDIsValid:(NSNumber *)orderID
{
    return [orderID integerValue] > 0;
}

- (void)syncOrderItem:(NSDictionary *)webOrderItem withOrderItem:(SCHOrderItem *)localOrderItem
{
    if (webOrderItem != nil) {
        localOrderItem.OrderID = [self makeNullNil:[webOrderItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
        localOrderItem.OrderDate = [self makeNullNil:[webOrderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
    }
}

- (void)syncContentProfileItems:(NSArray *)webContentProfileList 
        localContentProfileList:(NSSet *)localContentProfileList
                     insertInto:(SCHUserContentItem *)userContentItem
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
		
        if (webItemID == nil || [self profileIDIsValid:webItemID] == NO) {
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
            SCHBookIdentifier *bookIdentifier = [contentProfileItem.UserContentItem bookIdentifier];
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
            [aManagedObjectContext deleteObject:contentProfileItem];            
        }
        
    }
    
	for (NSDictionary *webItem in creationPool) {
        SCHContentProfileItem *item = [self addContentProfileItem:webItem
                                                          forBook:userContentItem.bookIdentifier
                                             managedObjectContext:aManagedObjectContext];
        
        if (item != nil) {
            [userContentItem addProfileListObject:item];
        }
	}
}

- (BOOL)profileIDIsValid:(NSNumber *)profileID
{
    return [profileID integerValue] > 0;
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
        SCHUserContentItem *userContentItem = [contentMetadataItem UserContentItem];
        if (userContentItem == nil || [userContentItem.ProfileList count] == 0) {
            [self removeRecommendationForBook:contentMetadataItem
                         managedObjectContext:aManagedObjectContext];
            [aManagedObjectContext deleteObject:contentMetadataItem];
        }
    }   
    
    [self saveWithManagedObjectContext:aManagedObjectContext];
}

- (void)removeRecommendationForBook:(SCHContentMetadataItem *)contentMetadataItem
               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (contentMetadataItem != nil) {
        SCHRecommendationISBN *recommendationISBN = [contentMetadataItem.AppBook recommendationISBN];
        if (recommendationISBN != nil) {
            [aManagedObjectContext deleteObject:recommendationISBN];
            [self saveWithManagedObjectContext:aManagedObjectContext];
        }
    }
}

@end
