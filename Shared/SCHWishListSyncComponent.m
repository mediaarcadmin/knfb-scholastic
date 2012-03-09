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

// Constants
NSString * const SCHWishListSyncComponentDidCompleteNotification = @"SCHWishListSyncComponentDidCompleteNotification";
NSString * const SCHWishListSyncComponentDidFailNotification = @"SCHWishListSyncComponentDidFailNotification";

@interface SCHWishListSyncComponent ()

@property (nonatomic, retain) SCHWishListWebService *wishListWebService;

- (BOOL)updateWishListItems;

- (NSArray *)localProfiles;
- (NSArray *)localWishListProfiles;
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
    
	if (![self.managedObjectContext BITemptyEntity:kSCHWishListProfile error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    NSLog(@"%@:didCompleteWithResult\n%@", method, result);
    
    @try {
        if([method compare:kSCHWishListWebServiceGetWishListItems] == NSOrderedSame) {
            NSDictionary *wishListItems = [self makeNullNil:[result objectForKey:kSCHWishListWebServiceGetWishListItems]];
            NSArray *profileItems = [self makeNullNil:[wishListItems objectForKey:kSCHWishListWebServiceProfileItemList]];
            
            [self syncWishListProfiles:profileItems];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                object:self];		            
            [super method:method didCompleteWithResult:result userInfo:userInfo];				                
        } else if([method compare:kSCHWishListWebServiceDeleteWishListItems] == NSOrderedSame) {
            [super method:method didCompleteWithResult:result userInfo:userInfo];				                            
        } else if([method compare:kSCHWishListWebServiceAddItemsToWishList] == NSOrderedSame) {
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
    __block BOOL ret = YES;
    
    ret = [[SCHAuthenticationManager sharedAuthenticationManager] pTokenWithValidation:^(NSString *pToken, NSError *error) {
        if (error == nil) {
            NSArray *profiles = [self localProfiles];
            if ([profiles count] > 0) {
                NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
                for (id item in profiles) {
                    [profileIDs addObject:[item valueForKey:kSCHLibreAccessWebServiceID]];
                }
                
                [wishListWebService getWishListItems:pToken profiles:profileIDs];            
                
                NSMutableDictionary *wlpi = [NSMutableDictionary dictionary];
                NSMutableDictionary *wli = [NSMutableDictionary dictionary];
                NSMutableDictionary *ib = [NSMutableDictionary dictionary];
                
                [ib setObject:@"CHILD" forKey:kSCHWishListWebServiceValue];
                
                [wli setObject:@"Norman Bridwell" forKey:kSCHWishListWebServiceAuthor];
                [wli setObject:ib forKey:kSCHWishListWebServiceInitiatedBy];                    
                [wli setObject:@"9780545323024" forKey:kSCHWishListWebServiceISBN];
                [wli setObject:[NSDate date] forKey:kSCHWishListWebServiceTimestamp];
                [wli setObject:@"Clifford's Good Deeds" forKey:kSCHWishListWebServiceTitle];
                
                NSMutableDictionary *profile = [NSMutableDictionary dictionary];
                
                NSDictionary *p = [profiles objectAtIndex:0];
                [profile setObject:[p valueForKey:kSCHLibreAccessWebServiceID] forKey:kSCHWishListWebServiceProfileID];
                [profile setObject:[p valueForKey:kSCHLibreAccessWebServiceScreenName] forKey:kSCHWishListWebServiceProfileName];
                [profile setObject:[NSDate date] forKey:kSCHWishListWebServiceTimestamp];
                
                [wlpi setObject:[NSArray arrayWithObject:wli] forKey:kSCHWishListWebServiceItemList];
                [wlpi setObject:profile forKey:kSCHWishListWebServiceProfile];                    
                
                //  [wishListWebService addItemsToWishList:pToken2 wishListItems:[NSArray arrayWithObject:wlpi]];      
                
                //   [wishListWebService deleteWishList:pToken2 wishListProfiles:[NSArray arrayWithObject:profile]];
                
                NSMutableDictionary *pi = [NSMutableDictionary dictionary];
                [pi setObject:[NSArray arrayWithObject:wli] forKey:kSCHWishListWebServiceItemList];
                [pi setObject:profile forKey:kSCHWishListWebServiceProfile];
                
                //                    [wishListWebService deleteWishListItems:pToken2 wishListItems:[NSArray arrayWithObject:pi]];
                
            }
        } else {
            // failed to get pToken
            ret = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidFailNotification 
                                                                object:self];        
            [super method:nil didFailWithError:error requestInfo:nil result:nil];                
        }
    }];
    
    return ret;
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

- (NSArray *)localWishListProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListProfile inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];
	
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
        [self.managedObjectContext deleteObject:wishListProfile];
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
            
            [self syncWishListItems:[self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceItemList]] 
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
    
    for (SCHWishListItem *wishListItem in deletePool) {
        [self.managedObjectContext deleteObject:wishListItem];
        [self save];
    }                
    
	for (NSDictionary *webItem in creationPool) {
        [wishListProfile addItemListObject:[self wishListItem:webItem]];
        [self save];
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
