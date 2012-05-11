//
//  SCHProfileSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHProfileItem.h"
#import "SCHAppProfile.h"
#import "SCHAnnotationsItem.h"
#import "BITAPIError.h"
#import "SCHLibreAccessWebService.h"
#import "SCHWishListProfile.h"
#import "SCHWishListItem.h"
#import "SCHWishListSyncComponent.h"

// Constants
NSString * const SCHProfileSyncComponentWillDeleteNotification = @"SCHProfileSyncComponentWillDeleteNotification";
NSString * const SCHProfileSyncComponentDeletedProfileIDs = @"SCHProfileSyncComponentDeletedProfileIDs";
NSString * const SCHProfileSyncComponentDidCompleteNotification = @"SCHProfileSyncComponentDidCompleteNotification";
NSString * const SCHProfileSyncComponentDidFailNotification = @"SCHProfileSyncComponentDidFailNotification";

@interface SCHProfileSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;
@property (retain, nonatomic) NSMutableArray *savedProfiles;

- (void)trackProfileSaves:(NSArray *)profilesArray;
- (void)applyProfileSaves:(NSArray *)profilesArray;
- (void)processSaveUserProfilesWithResult:(NSDictionary *)result;
- (BOOL)updateProfiles;
- (BOOL)profileIDIsValid:(NSNumber *)profileID;
- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile;
- (void)removeWishListForProfile:(SCHProfileItem *)profileItem;
- (void)backgroundSave:(BOOL)batch;

@end

@implementation SCHProfileSyncComponent

@synthesize libreAccessWebService;
@synthesize backgroundThreadManagedObjectContext;
@synthesize savedProfiles;

- (id)init 
{
    self = [super init];
    if (self) {
        libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;

        savedProfiles = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc 
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
	[backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    
    [savedProfiles release], savedProfiles = nil;
    [super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateProfiles];	
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}

	return(ret);	
}
#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];    
}

- (void)clearComponent
{
    [self.savedProfiles removeAllObjects];    
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    @try {
        if([method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
                [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                
                [self processSaveUserProfilesWithResult:result];
                
                [self backgroundSave:NO];
                self.backgroundThreadManagedObjectContext = nil;
            });                                
        } else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
                [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                
                [self syncProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
                
                [self backgroundSave:NO];
                self.backgroundThreadManagedObjectContext = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                                        object:self];		
                    [super method:method didCompleteWithResult:result userInfo:userInfo];	
                });                
            });            
        }
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidFailNotification 
                                                            object:self];		    
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [super method:method didFailWithError:error requestInfo:nil result:result];
        [self.savedProfiles removeAllObjects];        
    }
}

// track profiles that need to be saved
- (void)trackProfileSaves:(NSArray *)profilesArray
{
    for (SCHProfileItem *profile in profilesArray) {
        if ([profile.Action saveActionValue] != kSCHSaveActionsNone) {
            [self.savedProfiles addObject:[profile objectID]];
        }
    }
}

- (void)applyProfileSaves:(NSArray *)profilesArray
{
    NSAssert([NSThread isMainThread] == NO, @"applyProfileSaves MUST NOT be executed on the main thread");            
    NSManagedObjectID *managedObjectID = nil;
    NSManagedObject *profileManagedObject = nil;
    
    for (NSDictionary *profile in profilesArray) {
        if ([self.savedProfiles count] > 0) {
            managedObjectID = [self.savedProfiles objectAtIndex:0];
            if (managedObjectID != nil) {
                profileManagedObject = [self.backgroundThreadManagedObjectContext objectWithID:managedObjectID];
                
                if ([[profile objectForKey:kSCHLibreAccessWebServiceStatus] statusCodeValue] == kSCHStatusCodesSuccess) {
                    switch ([[profile objectForKey:kSCHLibreAccessWebServiceStatus] saveActionValue]) {
                        case kSCHSaveActionsCreate:
                        {
                            NSNumber *profileID = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceID]];
                            if (profileID != nil) {
                                [profileManagedObject setValue:profileID forKey:kSCHLibreAccessWebServiceID];
                            } else {
                                // if the server didnt give us an ID then we remove the profile
                                [self.backgroundThreadManagedObjectContext deleteObject:profileManagedObject];
                            }                                                    
                        }
                            break;
                        case kSCHSaveActionsRemove:                            
                        {
                            [self removeWishListForProfile:(SCHProfileItem *)profileManagedObject];
                            [self.backgroundThreadManagedObjectContext deleteObject:profileManagedObject];
                        }
                            break;
                            
                        default:
                            //nop
                            break;
                    }
                } else {
                    // if the server wasnt happy then we remove the profile
                    [self.backgroundThreadManagedObjectContext deleteObject:profileManagedObject];
                }
                
                // We've attempted to save changes, reset to unmodified and now 
                // sync will update this with the truth from the server
                if (profileManagedObject.isDeleted == NO) {
                    [profileManagedObject setValue:[NSNumber numberWithStatus:kSCHStatusUnmodified] 
                                               forKey:SCHSyncEntityState];
                }
            }
            if ([self.savedProfiles count] > 0) {
                [self.savedProfiles removeObjectAtIndex:0];
            }
        }
        [self backgroundSave:NO];
    }
}

- (void)processSaveUserProfilesWithResult:(NSDictionary *)result
{
    NSAssert([NSThread isMainThread] == NO, @"processSaveUserProfilesWithResult MUST NOT be executed on the main thread");        
    if (result != nil && [self.savedProfiles count] > 0) {
        [self applyProfileSaves:[result objectForKey:kSCHLibreAccessWebServiceProfileStatusList]];
    }        
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.saveOnly == NO) {
            self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
            if (self.isSynchronizing == NO) {
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        [self.delegate authenticationDidSucceed];
                    } else {
                        self.isSynchronizing = NO;
                    }
                } failureBlock:^(NSError *error){
                    self.isSynchronizing = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                        object:self];            
                }];				
            }	
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                                object:self];		
            [super method:nil didCompleteWithResult:result userInfo:nil];	
        }
    });
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    // server error so process the result
    if ([error domain] == kBITAPIErrorDomain && 
        [method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
        [self processSaveUserProfilesWithResult:result];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidFailNotification 
                                                            object:self];		    
        [super method:method didFailWithError:error requestInfo:requestInfo result:result];
    }
    [self.savedProfiles removeAllObjects];
}

- (BOOL)updateProfiles
{
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    [self.savedProfiles removeAllObjects];
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"State IN %@", 
								[NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
								 [NSNumber numberWithStatus:kSCHStatusDeleted], nil]]];
	NSArray *updatedProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (updatedProfiles == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
	if([updatedProfiles count] > 0) {
        
        [self trackProfileSaves:updatedProfiles];
        
		self.isSynchronizing = [self.libreAccessWebService saveUserProfiles:updatedProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                    [self.delegate authenticationDidSucceed];
                } else {
                    self.isSynchronizing = NO;
                }
            } failureBlock:^(NSError *error){
                self.isSynchronizing = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                    object:self];                
            }];				
			ret = NO;			
		}		
	} else if (self.saveOnly == NO) {
		
		self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                    [self.delegate authenticationDidSucceed];
                } else {
                    self.isSynchronizing = NO;
                }
            } failureBlock:^(NSError *error){
                self.isSynchronizing = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                    object:self];                
            }];					
			ret = NO;
		}
	} else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                            object:self];		
        [super method:nil didCompleteWithResult:nil userInfo:nil];
    }
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (NSArray *)localProfiles
{
    NSAssert([NSThread isMainThread] == NO, @"localProfiles MUST NOT be executed on the main thread");
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (void)syncProfiles:(NSArray *)profileList
{		
    NSAssert([NSThread isMainThread] == NO, @"syncProfiles MUST NOT be executed on the main thread");
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [profileList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localProfiles = [self localProfiles];
						   
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHProfileItem *localItem = [localEnumerator nextObject];
	
	while (webItem != nil || localItem != nil) {		
		if (webItem == nil) {
			while (localItem != nil) {
                if ([localItem.State statusValue] == kSCHStatusUnmodified) {
                    [deletePool addObject:localItem];
                }
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

		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];

        if (webItemID == nil || [self profileIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {        
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncProfile:webItem withProfile:localItem];
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
        NSMutableArray *deletedIDs = [NSMutableArray array];
        for (SCHProfileItem *profileItem in deletePool) {
            NSNumber *profileID = profileItem.ID;
            if (profileID != nil) {
                [deletedIDs addObject:profileID];
            }
        }        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentWillDeleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:deletedIDs 
                                                                                                   forKey:SCHProfileSyncComponentDeletedProfileIDs]];				
        });
        for (SCHProfileItem *profileItem in deletePool) {
            [self removeWishListForProfile:profileItem];
            [self.backgroundThreadManagedObjectContext deleteObject:profileItem];
        }                
    }
    
	for (NSDictionary *webItem in creationPool) {
		[self addProfile:webItem];
	}
	
	[self backgroundSave:NO];
}

- (BOOL)profileIDIsValid:(NSNumber *)profileID
{
    return [profileID integerValue] > 0;
}

- (SCHProfileItem *)addProfile:(NSDictionary *)webProfile
{
    NSAssert([NSThread isMainThread] == NO, @"addProfile MUST NOT be executed on the main thread");
    SCHProfileItem *newProfileItem = nil;
    id profileID = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceID]];
    
    if (webProfile != nil && [self profileIDIsValid:profileID] == YES) {
        newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem 
                                                       inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        newProfileItem.StoryInteractionEnabled = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
        newProfileItem.ID = profileID;
        newProfileItem.LastPasswordModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastPasswordModified]];
        newProfileItem.Password = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServicePassword]];
        newProfileItem.Birthday = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBirthday]];
        newProfileItem.FirstName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceFirstName]];
        newProfileItem.ProfilePasswordRequired = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
        newProfileItem.Type = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceType]];
        newProfileItem.ScreenName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceScreenName]];
        newProfileItem.AutoAssignContentToProfiles = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
        newProfileItem.LastScreenNameModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastScreenNameModified]];
        newProfileItem.UserKey = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceUserKey]];
        newProfileItem.BookshelfStyle = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBookshelfStyle]];
        newProfileItem.LastName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastName]];
        newProfileItem.LastModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]];
        newProfileItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
        newProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile 
                                                                  inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        SCHAnnotationsItem *newAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem 
                                                                               inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        newAnnotationsItem.ProfileID = newProfileItem.ID;
        
        SCHWishListProfile *newWishListProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                                                               inManagedObjectContext:self.backgroundThreadManagedObjectContext];    
        newWishListProfile.ProfileID = newProfileItem.ID;
        newWishListProfile.ProfileName = newProfileItem.ScreenName;
        
        NSLog(@"Added profile with screenname %@ and ID %@", newProfileItem.ScreenName, newProfileItem.ID);
    }
    
    return newProfileItem;
}

- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile
{	
    if (webProfile != nil) {
        localProfile.StoryInteractionEnabled = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
        localProfile.ID = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceID]];
        localProfile.LastPasswordModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastPasswordModified]];
        localProfile.Password = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServicePassword]];
        localProfile.Birthday = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBirthday]];
        localProfile.FirstName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceFirstName]];
        localProfile.ProfilePasswordRequired = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]];
        localProfile.Type = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceType]];
        localProfile.ScreenName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceScreenName]];
        localProfile.AutoAssignContentToProfiles = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]];
        localProfile.LastScreenNameModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastScreenNameModified]];
        localProfile.UserKey = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceUserKey]];
        localProfile.BookshelfStyle = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceBookshelfStyle]];
        localProfile.LastName = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastName]];
        localProfile.LastModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]];
        localProfile.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				
    }
}

- (void)removeWishListForProfile:(SCHProfileItem *)profileItem
{
    NSAssert([NSThread isMainThread] == NO, @"removeWishListForProfile MUST NOT be executed on the main thread");    
    if (profileItem != nil) {
        SCHWishListProfile *wishListProfile = [profileItem.AppProfile wishListProfile];
        if (wishListProfile != nil) {
            NSMutableArray *deletedISBNs = [NSMutableArray array];
            for (SCHWishListItem *item in wishListProfile.ItemList) {
                NSString *isbn = item.ISBN;
                if (isbn != nil) {
                    [deletedISBNs addObject:isbn];
                }
            }
            if ([deletedISBNs count] > 0) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHWishListSyncComponentWillDeleteNotification 
                                                                        object:self 
                                                                      userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:deletedISBNs]
                                                                                                           forKey:SCHWishListSyncComponentISBNs]];
                });
                
            }   
            [self.backgroundThreadManagedObjectContext deleteObject:wishListProfile];
            [self backgroundSave:NO];
        }    
    }
}

- (void)backgroundSave:(BOOL)batch
{
    NSAssert([NSThread isMainThread] == NO, @"backgroundSave MUST NOT be executed on the main thread");
    
    NSError *error = nil;
    static NSUInteger batchCount = 0;
    
    if (batch == NO || ++batchCount > 250) {
        batchCount = 0;
        if ([self.backgroundThreadManagedObjectContext hasChanges] == YES &&
            ![self.backgroundThreadManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

@end
