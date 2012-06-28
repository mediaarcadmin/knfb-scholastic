//
//  SCHGetWishListItemsOperation.m
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHGetWishListItemsOperation.h"

#import "SCHWishListSyncComponent.h"
#import "SCHWishListConstants.h"
#import "SCHWishListProfile.h"
#import "SCHWishListItem.h"
#import "BITAPIError.h" 

@interface SCHGetWishListItemsOperation ()

- (NSArray *)localWishListProfiles;
- (void)syncWishListProfiles:(NSArray *)webWishListProfiles;
- (BOOL)wishListProfileIDIsValid:(NSNumber *)wishListProfileID;
- (SCHWishListProfile *)wishListProfile:(NSDictionary *)wishListProfile;
- (void)syncWishListProfile:(NSDictionary *)webWishListProfile 
        withWishListProfile:(SCHWishListProfile *)localWishListProfile;
- (void)syncWishListItems:(NSArray *)webWishListItems
        withWishListItems:(NSSet *)localWishListItems
               insertInto:(SCHWishListProfile *)wishListProfile;
- (BOOL)wishListItemIDIsValid:(NSString *)wishListItemID;
- (SCHWishListItem *)wishListItem:(NSDictionary *)wishListItem;
- (void)syncWishListItem:(NSDictionary *)webWishListItem 
        withWishListItem:(SCHWishListItem *)localWishListItem;

@end

@implementation SCHGetWishListItemsOperation

- (void)main
{
    @try {
        NSDictionary *wishListItems = [self makeNullNil:[self.result objectForKey:kSCHWishListWebServiceGetWishListItems]];
        NSArray *profileItems = [self makeNullNil:[wishListItems objectForKey:kSCHWishListWebServiceProfileItemList]];
        
        [self syncWishListProfiles:profileItems];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [self.syncComponent completeWithSuccessMethod:kSCHWishListWebServiceGetWishListItems 
                                                       result:self.result 
                                                     userInfo:self.userInfo 
                                             notificationName:SCHWishListSyncComponentDidCompleteNotification 
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
                [self.syncComponent completeWithFailureMethod:kSCHWishListWebServiceGetWishListItems 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHWishListSyncComponentDidFailNotification 
                                         notificationUserInfo:nil];                
            }
        });   
    }                    
}

- (NSArray *)localWishListProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListProfile inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];
    
	NSArray *ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (void)syncWishListProfiles:(NSArray *)webWishListProfiles
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webWishListProfiles = [webWishListProfiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];		
	NSArray *localWishListProfilesArray = [self localWishListProfiles];
    
	NSEnumerator *webEnumerator = [webWishListProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localWishListProfilesArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHWishListProfile *localItem = [localEnumerator nextObject];
	
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
		
        id webProfile = [self makeNullNil:[webItem valueForKey:kSCHWishListWebServiceProfile]];
        id webItemID =  [self makeNullNil:[webProfile valueForKey:kSCHWishListWebServiceProfileID]];
		id localItemID = [localItem valueForKey:kSCHWishListWebServiceProfileID];
		
        if (webItemID == nil || [self wishListProfileIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncWishListProfile:webItem 
                          withWishListProfile:localItem];
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
    
    for (SCHWishListProfile *wishListProfile in deletePool) {
        // we leave the actual deletion to the profile sync but we do delete 
        // the items
        [wishListProfile removeItemList:wishListProfile.ItemList];
    }                
    
	for (NSDictionary *webItem in creationPool) {
        [self wishListProfile:webItem];
	}
    
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];    
}

- (BOOL)wishListProfileIDIsValid:(NSNumber *)wishListProfileID
{
    return [wishListProfileID integerValue] > 0;
}

- (SCHWishListProfile *)wishListProfile:(NSDictionary *)wishListProfile
{
	SCHWishListProfile *ret = nil;
	
	if (wishListProfile != nil) {
        id webProfile = [self makeNullNil:[wishListProfile valueForKey:kSCHWishListWebServiceProfile]];
        id wishListProfileID = [self makeNullNil:[webProfile valueForKey:kSCHWishListWebServiceProfileID]];
        
        if (webProfile != nil && [self wishListProfileIDIsValid:wishListProfileID] == YES) {            
            ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                                inManagedObjectContext:self.backgroundThreadManagedObjectContext];			
            
            // convert timestamp to lastmodified
            ret.LastModified = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceTimestamp]];
            ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
            
            ret.ProfileID = wishListProfileID;
            ret.ProfileName = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceProfileName]];
            
            [self syncWishListItems:[self makeNullNil:[wishListProfile objectForKey:kSCHWishListWebServiceItemList]] 
                  withWishListItems:[ret ItemList]
                         insertInto:ret];            
        }
    }
	
	return ret;
}

- (void)syncWishListProfile:(NSDictionary *)webWishListProfile 
        withWishListProfile:(SCHWishListProfile *)localWishListProfile
{
    if (webWishListProfile != nil) {
        id webProfile = [self makeNullNil:[webWishListProfile valueForKey:kSCHWishListWebServiceProfile]];
        if (webProfile != nil) {                    
            // convert timestamp to lastmodified
            localWishListProfile.LastModified = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceTimestamp]];
            localWishListProfile.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];
            
            localWishListProfile.ProfileID = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceProfileID]];
            localWishListProfile.ProfileName = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceProfileName]];
            
            [self syncWishListItems:[self makeNullNil:[webWishListProfile objectForKey:kSCHWishListWebServiceItemList]] 
                  withWishListItems:localWishListProfile.ItemList
                         insertInto:localWishListProfile];
        }
    }
}

- (void)syncWishListItems:(NSArray *)webWishListItems
        withWishListItems:(NSSet *)localWishListItems
               insertInto:(SCHWishListProfile *)wishListProfile
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webWishListItems = [webWishListItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceISBN ascending:YES]]];		
	NSArray *localWishListItemsArray = [localWishListItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceISBN ascending:YES]]];
    localWishListItemsArray = [(SCHWishListSyncComponent *)self.syncComponent removeNewlyCreatedDeletedWishListItems:localWishListItemsArray
                                                      managedObjectContext:self.backgroundThreadManagedObjectContext];
    
	NSEnumerator *webEnumerator = [webWishListItems objectEnumerator];			  
	NSEnumerator *localEnumerator = [localWishListItemsArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHWishListItem *localItem = [localEnumerator nextObject];
	
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
		
		id webItemID =  [self makeNullNil:[webItem valueForKey:kSCHWishListWebServiceISBN]];
		id localItemID = [localItem valueForKey:kSCHWishListWebServiceISBN];
		
        if (webItemID == nil || [self wishListItemIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncWishListItem:webItem withWishListItem:localItem];
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
    
    for (SCHWishListItem *wishListItem in deletePool) {
        [self.backgroundThreadManagedObjectContext deleteObject:wishListItem];
    }                        
    
    if ([creationPool count] > 0) {
        NSMutableArray *insertedISBNs = [NSMutableArray arrayWithCapacity:[creationPool count]];
        for (NSDictionary *webItem in creationPool) {
            SCHWishListItem *wishListItem = [self wishListItem:webItem];
            if (wishListItem != nil) {
                NSString *isbn = wishListItem.ISBN;
                if (isbn != nil) {
                    [insertedISBNs addObject:isbn];
                }
                [wishListProfile addItemListObject:wishListItem];
            }
        }
        if ([insertedISBNs count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{  
                if (self.isCancelled == NO) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidInsertNotification 
                                                                        object:self 
                                                                      userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:insertedISBNs]
                                                                                                           forKey:SCHWishListSyncComponentISBNs]];
                }
            });
        } 
    }
    
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];    
}

- (BOOL)wishListItemIDIsValid:(NSString *)wishListItemID
{
    return [[wishListItemID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

- (SCHWishListItem *)wishListItem:(NSDictionary *)wishListItem
{
	SCHWishListItem *ret = nil;
	id wishListItemID = [self makeNullNil:[wishListItem valueForKey:kSCHWishListWebServiceISBN]];
    
	if (wishListItem != nil && [self wishListItemIDIsValid:wishListItemID] == YES) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];			
        
        // convert timestamp to lastmodified
        ret.LastModified = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceTimestamp]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.Author = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceAuthor]];
		ret.InitiatedBy = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceInitiatedBy]];
        ret.ISBN = wishListItemID;
        ret.Title = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceTitle]];  
        
        [ret assignAppRecommendationItem];
	}
	
	return ret;
}

- (void)syncWishListItem:(NSDictionary *)webWishListItem 
        withWishListItem:(SCHWishListItem *)localWishListItem
{
    if (webWishListItem != nil) {
        // convert timestamp to lastmodified
        localWishListItem.LastModified = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceTimestamp]];
        localWishListItem.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];
        
        localWishListItem.Author = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceAuthor]];
        localWishListItem.InitiatedBy = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceInitiatedBy]];
        localWishListItem.ISBN = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceISBN]];
        localWishListItem.Title = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceTitle]];
    }
}

@end
