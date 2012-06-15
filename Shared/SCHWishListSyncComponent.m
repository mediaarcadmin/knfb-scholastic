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
NSString * const SCHWishListSyncComponentISBNs = @"SCHWishListSyncComponentISBNs";
NSString * const SCHWishListSyncComponentDidCompleteNotification = @"SCHWishListSyncComponentDidCompleteNotification";
NSString * const SCHWishListSyncComponentDidFailNotification = @"SCHWishListSyncComponentDidFailNotification";

@interface SCHWishListSyncComponent ()

@property (nonatomic, retain) SCHWishListWebService *wishListWebService;
@property (atomic, retain) NSDate *lastSyncSaveCalled;

- (BOOL)updateWishListItems;
- (BOOL)createWishLists:(NSArray *)wishListProfiles;
- (BOOL)retrieveWishLists:(NSArray *)profiles;
- (BOOL)deleteWishLists:(NSArray *)wishListProfiles;
- (void)processDeletedWishListItems:(NSArray *)wishListItems
               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (NSArray *)localProfiles;
- (NSArray *)localWishListProfilesWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (NSArray *)localWishListProfilesWithItemStates:(NSArray *)changedStates;
- (void)syncWishListProfiles:(NSArray *)webWishListProfiles
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (BOOL)wishListProfileIDIsValid:(NSNumber *)wishListProfileID;
- (SCHWishListProfile *)wishListProfile:(NSDictionary *)wishListProfile
                   managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncWishListProfile:(NSDictionary *)webWishListProfile 
        withWishListProfile:(SCHWishListProfile *)localWishListProfile
       managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncWishListItems:(NSArray *)webWishListItems
        withWishListItems:(NSSet *)localWishListItems
               insertInto:(SCHWishListProfile *)wishListProfile
     managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (BOOL)wishListItemIDIsValid:(NSString *)wishListItemID;
- (SCHWishListItem *)wishListItem:(NSDictionary *)wishListItem
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncWishListItem:(NSDictionary *)webWishListItem 
        withWishListItem:(SCHWishListItem *)localWishListItem;
- (NSArray *)removeNewlyCreatedDeletedWishListItems:(NSArray *)annotationArray
                               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHWishListSyncComponent

@synthesize wishListWebService;
@synthesize lastSyncSaveCalled;

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
    [lastSyncSaveCalled release], lastSyncSaveCalled = nil;
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateWishListItems];
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);		
}

#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.wishListWebService clear];
}

- (void)clearComponent
{
    self.lastSyncSaveCalled = nil;    
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHWishListProfile error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHWishListItem error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHAppRecommendationItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	    
    @try {
        if([method compare:kSCHWishListWebServiceDeleteWishListItems] == NSOrderedSame) {            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSManagedObjectContext *backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
                [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

                NSDictionary *deleteWishListItems = [self makeNullNil:[result objectForKey:kSCHWishListWebServiceDeleteWishListItems]];
                NSArray *profileStatusList = [self makeNullNil:[deleteWishListItems objectForKey:kSCHWishListWebServiceProfileStatusList]];                
                
                if ([profileStatusList count] > 0) {
                    [self processDeletedWishListItems:profileStatusList 
                                 managedObjectContext:backgroundThreadManagedObjectContext];
                }
                
                [self saveWithManagedObjectContext:backgroundThreadManagedObjectContext];
                [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;

                dispatch_async(dispatch_get_main_queue(), ^{
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
                });
            });
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSManagedObjectContext *backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
                [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                
                NSDictionary *wishListItems = [self makeNullNil:[result objectForKey:kSCHWishListWebServiceGetWishListItems]];
                NSArray *profileItems = [self makeNullNil:[wishListItems objectForKey:kSCHWishListWebServiceProfileItemList]];
                
                [self syncWishListProfiles:profileItems
                      managedObjectContext:backgroundThreadManagedObjectContext];
                
                [self saveWithManagedObjectContext:backgroundThreadManagedObjectContext];
                [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidCompleteNotification 
                                                                        object:self];		            
                    [super method:method didCompleteWithResult:result userInfo:userInfo];				                
                });
            });
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
    
    self.lastSyncSaveCalled = nil;
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
            self.lastSyncSaveCalled = [NSDate date];
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
            self.lastSyncSaveCalled = [NSDate date];            
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
               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if ([wishListItems count] > 0) {
        for (NSDictionary *wishListItem in wishListItems) {
            NSNumber *profileID = [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceProfileID]];
            if ([profileID integerValue] > 0) {
                for (NSDictionary *item in [self makeNullNil:[wishListItem objectForKey:kSCHWishListWebServiceItemStatusList]]) {
                    NSString *isbn = [self makeNullNil:[item objectForKey:kSCHWishListWebServiceISBN]];
                    NSDictionary *wishListError = [self makeNullNil:[item objectForKey:kSCHWishListWebServiceWishListError]];
                    if (wishListError != nil) {
                        NSNumber *errorCode = [self makeNullNil:[wishListError objectForKey:kSCHWishListWebServiceErrorCode]];
                        
                        if (isbn != nil && errorCode != nil && [errorCode integerValue] == 0) {
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            NSError *error = nil;
                            
                            [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListItem 
                                                                inManagedObjectContext:aManagedObjectContext]];	
                            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                        @"ISBN = %@ AND WishListProfile.ProfileID = %@", isbn, profileID]];
                            
                            NSArray *localWishListItem = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
                            [fetchRequest release], fetchRequest = nil;
                            if (localWishListItem == nil) {
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            } else if ([localWishListItem count] > 0) {
                                [aManagedObjectContext deleteObject:[localWishListItem objectAtIndex:0]];
                            }
                        }
                    }
                }
            }
        }
        [self saveWithManagedObjectContext:aManagedObjectContext];
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

- (NSArray *)localWishListProfilesWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHWishListProfile inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];
    
	NSArray *ret = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
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
        managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webWishListProfiles = [webWishListProfiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceProfileID ascending:YES]]];		
	NSArray *localWishListProfilesArray = [self localWishListProfilesWithManagedObjectContext:aManagedObjectContext];
    
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
                          withWishListProfile:localItem
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
        [self wishListProfile:webItem
         managedObjectContext:aManagedObjectContext];
	}
    
	[self saveWithManagedObjectContext:aManagedObjectContext];    
}

- (BOOL)wishListProfileIDIsValid:(NSNumber *)wishListProfileID
{
    return [wishListProfileID integerValue] > 0;
}

- (SCHWishListProfile *)wishListProfile:(NSDictionary *)wishListProfile
                   managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHWishListProfile *ret = nil;
	
	if (wishListProfile != nil) {
        id webProfile = [self makeNullNil:[wishListProfile valueForKey:kSCHWishListWebServiceProfile]];
        id wishListProfileID = [self makeNullNil:[webProfile valueForKey:kSCHWishListWebServiceProfileID]];
        
        if (webProfile != nil && [self wishListProfileIDIsValid:wishListProfileID] == YES) {            
            ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                                inManagedObjectContext:aManagedObjectContext];			
            
            // convert timestamp to lastmodified
            ret.LastModified = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceTimestamp]];
            ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
            
            ret.ProfileID = wishListProfileID;
            ret.ProfileName = [self makeNullNil:[webProfile objectForKey:kSCHWishListWebServiceProfileName]];
            
            [self syncWishListItems:[self makeNullNil:[wishListProfile objectForKey:kSCHWishListWebServiceItemList]] 
                  withWishListItems:[ret ItemList]
                         insertInto:ret
               managedObjectContext:aManagedObjectContext];            
        }
    }
	
	return ret;
}

- (void)syncWishListProfile:(NSDictionary *)webWishListProfile 
           withWishListProfile:(SCHWishListProfile *)localWishListProfile
       managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
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
                         insertInto:localWishListProfile
               managedObjectContext:aManagedObjectContext];
        }
    }
}

- (void)syncWishListItems:(NSArray *)webWishListItems
        withWishListItems:(NSSet *)localWishListItems
               insertInto:(SCHWishListProfile *)wishListProfile
     managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webWishListItems = [webWishListItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceISBN ascending:YES]]];		
	NSArray *localWishListItemsArray = [localWishListItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHWishListWebServiceISBN ascending:YES]]];
    localWishListItemsArray = [self removeNewlyCreatedDeletedWishListItems:localWishListItemsArray
                               managedObjectContext:aManagedObjectContext];
    
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
        [aManagedObjectContext deleteObject:wishListItem];
    }                        

    if ([creationPool count] > 0) {
        NSMutableArray *insertedISBNs = [NSMutableArray arrayWithCapacity:[creationPool count]];
        for (NSDictionary *webItem in creationPool) {
            SCHWishListItem *wishListItem = [self wishListItem:webItem
                                          managedObjectContext:aManagedObjectContext];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentDidInsertNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:insertedISBNs]
                                                                                                       forKey:SCHWishListSyncComponentISBNs]];
            });
        } 
    }
    
	[self saveWithManagedObjectContext:aManagedObjectContext];    
}

- (BOOL)wishListItemIDIsValid:(NSString *)wishListItemID
{
    return [[wishListItemID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

- (SCHWishListItem *)wishListItem:(NSDictionary *)wishListItem
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHWishListItem *ret = nil;
	id wishListItemID = [self makeNullNil:[wishListItem valueForKey:kSCHWishListWebServiceISBN]];

	if (wishListItem != nil && [self wishListItemIDIsValid:wishListItemID] == YES) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListItem 
                                            inManagedObjectContext:aManagedObjectContext];			

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

// remove any created or deleted wishlist items that had issues
// the next get will then up date with the truth
- (NSArray *)removeNewlyCreatedDeletedWishListItems:(NSArray *)annotationArray
                               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSMutableArray *ret = nil;
    
    if (self.lastSyncSaveCalled == nil || [annotationArray count] < 1) {
        return annotationArray;
    } else {
        ret = [NSMutableArray arrayWithCapacity:[annotationArray count]];
        
        [annotationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SCHStatus status = [[obj State] statusValue];
            NSDate *lastModified = [obj LastModified];
            if ((status == kSCHStatusCreated || status == kSCHStatusDeleted) &&
                [lastModified earlierDate:self.lastSyncSaveCalled] == lastModified) {
                [aManagedObjectContext deleteObject:obj];
            } else {
                [ret addObject:obj];
            }
        }];
        
        [self saveWithManagedObjectContext:aManagedObjectContext];
    }
    
    return ret;
}

@end
