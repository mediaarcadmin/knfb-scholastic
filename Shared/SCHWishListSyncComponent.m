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
#import "SCHAccountValidation.h"
#import "SCHUserDefaults.h"
#import "SFHFKeychainUtils.h"
#import "SCHProfileItem.h"
#import "SCHWishListProfile.h"
#import "SCHWishListItem.h"
#import "SCHLibreAccessConstants.h"

// Constants
NSString * const SCHWishListSyncComponentDidCompleteNotification = @"SCHWishListSyncComponentDidCompleteNotification";
NSString * const SCHWishListSyncComponentDidFailNotification = @"SCHWishListSyncComponentDidFailNotification";

@interface SCHWishListSyncComponent ()

@property (nonatomic, retain) SCHWishListWebService *wishListWebService;

- (BOOL)updateWishListItems;

- (NSArray *)localProfiles;
- (NSArray *)localWishListProfiles;
- (void)syncWishListProfiles:(NSArray *)webWishListProfiles
        withWishListProfiles:(NSSet *)localWishListProfiles;
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
    
    [super method:method didCompleteWithResult:result userInfo:userInfo];				                
//    @try {
//        if([method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
//            [self processSaveUserProfilesWithResult:result];
//        } else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
//            [self syncProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
//                                                                object:self];		
//            [super method:method didCompleteWithResult:result userInfo:userInfo];	
//        }
//    }
//    @catch (NSException *exception) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidFailNotification 
//                                                            object:self];		    
//        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
//                                             code:kBITAPIExceptionError 
//                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
//                                                                              forKey:NSLocalizedDescriptionKey]];
//        [super method:method didFailWithError:error requestInfo:nil result:result];
//        [self.savedProfiles removeAllObjects];        
//    }
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
        
    SCHAccountValidation *accountValidation = [[SCHAccountValidation alloc] init];
    
    NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:storedUsername andServiceName:@"Scholastic" error:nil];
    
    NSString *pToken = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
    
    if (pToken == nil) {
        [accountValidation validateWithUserName:storedUsername withPassword:storedPassword validateBlock:^(NSString *pToken2, NSError *error) {
            if (error != nil) {
                //            [weakSelf authenticationDidFailWithError:error];                            
            } else {
                NSArray *profiles = [self localProfiles];
                if ([profiles count] > 0) {
                    NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
                    for (id item in profiles) {
                        [profileIDs addObject:[item valueForKey:kSCHLibreAccessWebServiceID]];
                    }
                    
                    [wishListWebService getWishListItems:pToken2 profiles:profileIDs];            
                    
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
            }
        }];
    } else {
        NSArray *profiles = [self localProfiles];
        if ([profiles count] > 0) {
            NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
            for (SCHProfileItem *item in profiles) {
                [profileIDs addObject:item.ID];
            }
            
            [wishListWebService getWishListItems:pToken profiles:profileIDs];            
        }        
    }   
    
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
        withWishListProfiles:(NSSet *)localWishListProfiles
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webWishListProfiles = [webWishListProfiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];		
	NSArray *localWishListProfilesArray = [localWishListProfiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];
    
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
		
		id webItemID = [webItem valueForKey:kSCHWishListWebServiceProfileID];
		id localItemID = [localItem valueForKey:kSCHWishListWebServiceProfileID];
		
        if ((id)webItemID == [NSNull null]) {
            webItem = nil;
        } else if ((id)localItemID == [NSNull null]) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncWishListProfile:webItem withWishListProfile:localItem];
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
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        // convert timestamp to lastmodified
        ret.LastModified = [self makeNullNil:[wishListProfile objectForKey:kSCHWishListWebServiceTimestamp]];
        ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
		ret.profileID = [self makeNullNil:[wishListProfile objectForKey:kSCHWishListWebServiceProfileID]];
		ret.profileName = [self makeNullNil:[wishListProfile objectForKey:kSCHWishListWebServiceProfileName]];
	}
	
	return(ret);
}

- (void)syncWishListProfile:(NSDictionary *)webWishListProfile 
           withWishListProfile:(SCHWishListProfile *)localWishListProfile
{
    if (webWishListProfile != nil) {
        // convert timestamp to lastmodified
        localWishListProfile.LastModified = [self makeNullNil:[webWishListProfile objectForKey:kSCHWishListWebServiceTimestamp]];
        localWishListProfile.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];
        
        localWishListProfile.profileID = [self makeNullNil:[webWishListProfile objectForKey:kSCHWishListWebServiceProfileID]];
        localWishListProfile.profileName = [self makeNullNil:[webWishListProfile objectForKey:kSCHWishListWebServiceProfileName]];
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

		ret.author = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceAuthor]];
		ret.initiatedBy = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceInitiatedBy]];
        ret.isbn = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceISBN]];
        ret.title = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceTitle]];        
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

        localWishListItem.author = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceAuthor]];
        localWishListItem.initiatedBy = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceInitiatedBy]];
        localWishListItem.isbn = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceISBN]];
        localWishListItem.title = [self makeNullNil:[webWishListItem objectForKey:kSCHWishListWebServiceTitle]];
    }
}

@end
