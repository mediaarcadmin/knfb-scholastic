//
//  SCHWishListSyncComponent.m
//  Scholastic
//
//  Created by John Eddie on 23/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHWishListSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHWishListWebService.h"
#import "SCHWishListConstants.h"
#import "SCHProfileItem.h"
#import "SCHWishListProfile.h"
#import "SCHWishListItem.h"
#import "SCHLibreAccessConstants.h"
#import "BITAPIError.h" 
#import "SCHAppRecommendationItem.h"

// Constants
NSString * const SCHWishListSyncComponentDidInsertNotification = @"SCHWishListSyncComponentDidInsertNotification";
NSString * const SCHWishListSyncComponentWillDeleteNotification = @"SCHWishListSyncComponentWillDeleteNotification";
NSString * const SCHWishListSyncComponentISBNs = @"SCHWishListSyncComponentISBNs";
NSString * const SCHWishListSyncComponentDidCompleteNotification = @"SCHWishListSyncComponentDidCompleteNotification";
NSString * const SCHWishListSyncComponentDidFailNotification = @"SCHWishListSyncComponentDidFailNotification";

@interface SCHWishListSyncComponent ()

@property (nonatomic, retain) SCHWishListWebService *wishListWebService;

- (BOOL)updateWishListItems;
- (BOOL)createWishLists:(NSArray *)wishListProfiles;
- (BOOL)retrieveWishLists:(NSArray *)profiles;
- (BOOL)deleteWishLists:(NSArray *)wishListProfiles;
- (void)processDeletedWishListItems:(NSArray *)wishListItems;

- (NSArray *)localProfiles;
- (NSArray *)localWishListProfilesWithItemStates:(NSArray *)changedStates;
- (void)syncWishListProfiles:(NSArray *)webWishListProfiles;
- (SCHWishListProfile *)wishListProfile:(NSDictionary *)wishListProfile;
- (void)syncWishListProfile:(NSDictionary *)webWishListProfile 
        withWishListProfile:(SCHWishListProfile *)localWishListProfile;
- (void)syncWishListItems:(NSArray *)webWishListItems
        withWishListItems:(NSSet *)localWishListItems
               insertInto:(SCHWishListProfile *)wishListProfile;
- (SCHWishListItem *)wishListItem:(NSDictionary *)wishListItem;
- (void)syncWishListItem:(NSDictionary *)webWishListItem 
        withWishListItem:(SCHWishListItem *)localWishListItem;

@end

@implementation SCHWishListSyncComponent

@synthesize wishListWebService;

- (id)init
{
	self = [super init];
	if (self != nil) {
		wishListWebService = [[SCHWishListWebService alloc] init];	
		wishListWebService.delegate = self;
	}
	
	return(self);
}

- (void)dealloc
{
    wishListWebService.delegate = nil;
	[wishListWebService release], wishListWebService = nil;
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
            [self endBackgroundTask];
		}];
		
		ret = [self updateWishListItems];
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);		
}

- (void)clear
{
	NSError *error = nil;
	
    [self.wishListWebService clear];
    
	if (![self.managedObjectContext BITemptyEntity:kSCHWishListProfile error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHWishListItem error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHAppRecommendationItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	    
    @try {
        if([method compare:kSCHWishListWebServiceDeleteWishListItems] == NSOrderedSame) {            
            NSDictionary *deleteWishListItems = [self makeNullNil:[result objectForKey:kSCHWishListWebServiceDeleteWishListItems]];
            
            // TODO: is this the correct thing to do?
            // if we have a general error don't delete the items - thus try again
            if ([self makeNullNil:[deleteWishListItems objectForKey:kSCHWishListWebServiceWishListError]] == nil) {            
                NSArray *profileStatusList = [self makeNullNil:[deleteWishListItems objectForKey:kSCHWishListWebServiceProfileStatusList]];                
                
                if ([profileStatusList count] > 0) {
                    [self processDeletedWishListItems:profileStatusList];
                }
            }

            NSArray *wishListProfilesToCreate = [self localWishListProfilesWithItemStates:
                                                 [NSArray arrayWithObject:[NSNumber numberWithStatus:kSCHStatusCreated]]];
            if ([wishListProfilesToCreate count] > 0) {
                [self createWishLists:wishListProfilesToCreate];
            } else if (self.saveOnly == NO) {
                NSArray *profiles = [self localProfiles];
                if ([profiles count] > 0) {
                    [self retrieveWishLists:profiles];       
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                        object:self 
                                                                      userInfo:nil];                
                    [super method:nil didCompleteWithResult:nil userInfo:nil];                                
                }
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                    object:self 
                                                                  userInfo:nil];                
                [super method:nil didCompleteWithResult:nil userInfo:nil];                
            }
        } else if([method compare:kSCHWishListWebServiceAddItemsToWishList] == NSOrderedSame) {
            NSArray *profiles = [self localProfiles];
            if ([profiles count] > 0) {
                [self retrieveWishLists:profiles];       
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                    object:self 
                                                                  userInfo:nil];                
                [super method:nil didCompleteWithResult:nil userInfo:nil];                                
            }
        } else if([method compare:kSCHWishListWebServiceGetWishListItems] == NSOrderedSame) {
            NSDictionary *wishListItems = [self makeNullNil:[result objectForKey:kSCHWishListWebServiceGetWishListItems]];
            NSArray *profileItems = [self makeNullNil:[wishListItems objectForKey:kSCHWishListWebServiceProfileItemList]];
            
            [self syncWishListProfiles:profileItems];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                object:self];		            
            [super method:method didCompleteWithResult:result userInfo:userInfo];				                
        }        
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidFailNotification 
                                                            object:self];		    
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [super method:method didFailWithError:error requestInfo:nil result:result];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidFailNotification 
                                                        object:self];        
    [super method:method didFailWithError:error requestInfo:requestInfo result:result];
}

- (BOOL)updateWishListItems
{
    BOOL ret = YES;
    
    NSArray *wishListProfilesToDelete = [self localWishListProfilesWithItemStates:
                                         [NSArray arrayWithObject:[NSNumber numberWithStatus:kSCHStatusDeleted]]];
    if ([wishListProfilesToDelete count] > 0) {
        ret = [self deleteWishLists:wishListProfilesToDelete];        
    } else {
        NSArray *wishListProfilesToCreate = [self localWishListProfilesWithItemStates:
                                             [NSArray arrayWithObject:[NSNumber numberWithStatus:kSCHStatusCreated]]];
        if ([wishListProfilesToCreate count] > 0) {
            ret = [self createWishLists:wishListProfilesToCreate];
        } else if (self.saveOnly == NO) {
            NSArray *profiles = [self localProfiles];
            if ([profiles count] > 0) {
            ret = [self retrieveWishLists:profiles];       
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                    object:self 
                                                                  userInfo:nil];                
                [super method:nil didCompleteWithResult:nil userInfo:nil];                                
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                object:self 
                                                              userInfo:nil];                
            [super method:nil didCompleteWithResult:nil userInfo:nil];                
        }
    }
    
    return ret;
}

- (BOOL)createWishLists:(NSArray *)wishListProfiles
{
    BOOL ret = NO;
    
    if ([wishListProfiles count] > 0) {
        self.isSynchronizing = [wishListWebService addItemsToWishList:wishListProfiles];
        if (self.isSynchronizing == YES) {
            ret = YES;
        } else {
            [[SCHAuthenticationManager sharedAuthenticationManager] pTokenWithValidation:^(NSString *pToken, NSError *error) {
                if (error == nil) {
                    [self.delegate authenticationDidSucceed];
                }
            }];           
        }
    }
    
    return ret;    
}

- (BOOL)retrieveWishLists:(NSArray *)profiles
{
    BOOL ret = NO;
    
    if ([profiles count] > 0) {
        NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
        for (id item in profiles) {
            NSNumber *profileID = [self makeNullNil:[item valueForKey:kSCHLibreAccessWebServiceID]];
            if ([profileID integerValue] > 0) {
                [profileIDs addObject:profileID];
            }
        }    
        self.isSynchronizing = [wishListWebService getWishListItems:profileIDs];                                
        if (self.isSynchronizing == YES) {
            ret = YES;
        } else {
            [[SCHAuthenticationManager sharedAuthenticationManager] pTokenWithValidation:^(NSString *pToken, NSError *error) {
                if (error == nil) {                
                    [self.delegate authenticationDidSucceed];                
                }
            }];   
        }
    }
    return ret;
}

- (BOOL)deleteWishLists:(NSArray *)wishListProfiles
{
    BOOL ret = NO;
    
    if ([wishListProfiles count] > 0) {
        self.isSynchronizing = [wishListWebService deleteWishListItems:wishListProfiles];
        if (self.isSynchronizing == YES) {
            ret = YES;
        } else {
            [[SCHAuthenticationManager sharedAuthenticationManager] pTokenWithValidation:^(NSString *pToken, NSError *error) {
                if (error == nil) {
                    [self.delegate authenticationDidSucceed];                                
                }
            }];  
        }
    }
    
    return ret;    
}

- (void)processDeletedWishListItems:(NSArray *)wishListItems
{
    if ([wishListItems count] > 0) {
        for (NSDictionary *wishListItem in wishListItems) {
            NSNumber *profileID = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceProfileID]];
            if ([profileID integerValue] > 0) {
                for (NSDictionary *item in [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceItemStatusList]]) {
                    NSString *isbn = [self makeNullNil:[item objectForKey:kSCHWishListWebServiceISBN]];
                    if (isbn != nil) {
                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                        NSError *error = nil;
                        
                        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListItem inManagedObjectContext:self.managedObjectContext]];	
                        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                    @"ISBN = %@ AND WishListProfile.ProfileID = %@", isbn, profileID]];
                        
                        NSArray *wishListItem = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
                        [fetchRequest release], fetchRequest = nil;
                        if (wishListItem == nil) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        } else if ([wishListItem count] > 0) {
                            [self.managedObjectContext deleteObject:[wishListItems objectAtIndex:0]];
                        }
                    }
                }
            }
        }
    }
}

- (NSArray *)localProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

// changedStates == nil will return all profiles
- (NSArray *)localWishListProfilesWithItemStates:(NSArray *)changedStates
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListProfile inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];
	if ([changedStates count] > 0) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                    @"ANY ItemList.State IN %@", changedStates]];
    }
    
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
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
	NSArray *localWishListProfilesArray = [self localWishListProfilesWithItemStates:nil];
    
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
        id webItemID = [webProfile valueForKey:kSCHWishListWebServiceProfileID];
		id localItemID = [localItem valueForKey:kSCHWishListWebServiceProfileID];
		
        if ((id)webItemID == [NSNull null]) {
            webItem = nil;
        } else if ((id)localItemID == [NSNull null]) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncWishListProfile:webItem 
                          withWishListProfile:localItem];
                    [self save];
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
        NSMutableArray *deletedISBNs = [NSMutableArray array];
        for (SCHWishListItem *item in wishListProfile.ItemList) {
            NSString *isbn = item.ISBN;
            if (isbn != nil) {
                [deletedISBNs addObject:isbn];
            }            
        }
        if ([deletedISBNs count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentWillDeleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:deletedISBNs]
                                                                                                   forKey:SCHWishListSyncComponentISBNs]];
            
        }           
        
        [wishListProfile removeItemList:wishListProfile.ItemList];
        [self save];
    }                
    
	for (NSDictionary *webItem in creationPool) {
        [self wishListProfile:webItem];
        [self save];
	}
    
	[self save];    
}

- (SCHWishListProfile *)wishListProfile:(NSDictionary *)wishListProfile
{
	SCHWishListProfile *ret = nil;
	
	if (wishListProfile != nil) {
        id webProfile = [self makeNullNil:[wishListProfile valueForKey:kSCHWishListWebServiceProfile]];
        if (webProfile != nil) {            
            ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                                inManagedObjectContext:self.managedObjectContext];			
            
            // convert timestamp to lastmodified
            ret.LastModified = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceTimestamp]];
            ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
            
            ret.ProfileID = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceProfileID]];
            ret.ProfileName = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceProfileName]];
            
            [self syncWishListItems:[self makeNullNil:[wishListProfile objectForKey:kSCHWishListWebServiceItemList]] 
                  withWishListItems:[ret ItemList]
                         insertInto:ret];            
        }
    }
	
	return(ret);
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
		
		id webItemID = [webItem valueForKey:kSCHWishListWebServiceISBN];
		id localItemID = [localItem valueForKey:kSCHWishListWebServiceISBN];
		
        if ((id)webItemID == [NSNull null]) {
            webItem = nil;
        } else if ((id)localItemID == [NSNull null]) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncWishListItem:webItem withWishListItem:localItem];
                    [self save];
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
        NSMutableArray *deletedISBNs = [NSMutableArray arrayWithCapacity:[deletePool count]];
        for (SCHWishListItem *item in deletePool) {
            NSString *isbn = item.ISBN;
            if (isbn != nil) {
                [deletedISBNs addObject:isbn];
            }
        }
        if ([deletedISBNs count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentWillDeleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:deletedISBNs]
                                                                                                   forKey:SCHWishListSyncComponentISBNs]];
        }        
        for (SCHWishListItem *wishListItem in deletePool) {
            [self.managedObjectContext deleteObject:wishListItem];
            [self save];
        }                        
    }

    if ([creationPool count] > 0) {
        NSMutableArray *insertedISBNs = [NSMutableArray arrayWithCapacity:[creationPool count]];
        for (NSDictionary *webItem in creationPool) {
            SCHWishListItem *wishListItem = [self wishListItem:webItem];
            if (wishListItem != nil) {
                [insertedISBNs addObject:wishListItem.ISBN];
                [wishListProfile addItemListObject:wishListItem];
                [self save];
            }
        }
        if ([insertedISBNs count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidInsertNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:insertedISBNs]
                                                                                                   forKey:SCHWishListSyncComponentISBNs]];
        } 
    }
    
	[self save];    
}

- (SCHWishListItem *)wishListItem:(NSDictionary *)wishListItem
{
	SCHWishListItem *ret = nil;
	
	if (wishListItem != nil) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListItem 
                                            inManagedObjectContext:self.managedObjectContext];			

        // convert timestamp to lastmodified
        ret.LastModified = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceTimestamp]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];

		ret.Author = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceAuthor]];
		ret.InitiatedBy = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceInitiatedBy]];
        ret.ISBN = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceISBN]];
        ret.Title = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceTitle]];  
        
        [ret assignAppRecommendationItem];
	}
	
	return(ret);
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
