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
#import "SCHAppRecommendationItem.h"
#import "SCHDeleteWishListItemsOperation.h"
#import "SCHGetWishListItemsOperation.h"

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
- (NSArray *)localProfiles;
- (NSArray *)localWishListProfilesWithItemStates:(NSArray *)changedStates;

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
    if([method compare:kSCHWishListWebServiceDeleteWishListItems] == NSOrderedSame) {            
        SCHDeleteWishListItemsOperation *operation = [[[SCHDeleteWishListItemsOperation alloc] initWithSyncComponent:self
                                                                                                              result:result
                                                                                                            userInfo:userInfo] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    } else if([method compare:kSCHWishListWebServiceAddItemsToWishList] == NSOrderedSame) {
        NSArray *profiles = [self localProfiles];
        if ([profiles count] > 0) {
            [self retrieveWishLists:profiles];       
        } else {
            [self completeWithSuccessMethod:nil 
                                     result:nil 
                                   userInfo:nil 
                           notificationName:SCHWishListSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
    } else if([method compare:kSCHWishListWebServiceGetWishListItems] == NSOrderedSame) {
        SCHGetWishListItemsOperation *operation = [[[SCHGetWishListItemsOperation alloc] initWithSyncComponent:self
                                                                                                        result:result
                                                                                                      userInfo:userInfo] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];        
    }        
}

- (void)deleteWishListItemsCompletion
{
    NSArray *wishListProfilesToCreate = [self localWishListProfilesWithItemStates:
                                         [NSArray arrayWithObject:[NSNumber numberWithStatus:kSCHStatusCreated]]];
    if ([wishListProfilesToCreate count] > 0) {
        [self createWishLists:wishListProfilesToCreate];
    } else if (self.saveOnly == NO) {
        NSArray *profiles = [self localProfiles];
        if ([profiles count] > 0) {
            [self retrieveWishLists:profiles];       
        } else {
            [self completeWithSuccessMethod:nil 
                                     result:nil 
                                   userInfo:nil 
                           notificationName:SCHWishListSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
    } else {
        [self completeWithSuccessMethod:nil 
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHWishListSyncComponentDidCompleteNotification 
                   notificationUserInfo:nil];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [self completeWithFailureMethod:method 
                              error:error 
                        requestInfo:requestInfo 
                             result:result 
                   notificationName:SCHWishListSyncComponentDidFailNotification 
               notificationUserInfo:nil];
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
                [self completeWithSuccessMethod:nil 
                                         result:nil 
                                       userInfo:nil 
                               notificationName:SCHWishListSyncComponentDidCompleteNotification 
                           notificationUserInfo:nil];
            }
        } else {
            [self completeWithSuccessMethod:nil 
                                     result:nil 
                                   userInfo:nil 
                           notificationName:SCHWishListSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
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
