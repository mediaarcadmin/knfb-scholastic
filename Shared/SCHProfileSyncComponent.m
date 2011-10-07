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

// Constants
NSString * const SCHProfileSyncComponentWillDeleteNotification = @"SCHProfileSyncComponentWillDeleteNotification";
NSString * const SCHProfileSyncComponentDeletedProfileIDs = @"SCHProfileSyncComponentDeletedProfileIDs";
NSString * const SCHProfileSyncComponentDidCompleteNotification = @"SCHProfileSyncComponentDidCompleteNotification";
NSString * const SCHProfileSyncComponentDidFailNotification = @"SCHProfileSyncComponentDidFailNotification";

@interface SCHProfileSyncComponent ()

@property (retain, nonatomic) NSMutableArray *savedProfiles;

- (void)trackProfileSaves:(NSArray *)profilesArray;
- (void)applyProfileSaves:(NSArray *)profilesArray;
- (void)processSaveUserProfilesWithResult:(NSDictionary *)result;
- (BOOL)updateProfiles;
- (void)syncProfiles:(NSArray *)profileList;
- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile;

@end

@implementation SCHProfileSyncComponent

@synthesize savedProfiles;

- (id)init 
{
    self = [super init];
    if (self) {
        savedProfiles = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc 
{
    [savedProfiles release], savedProfiles = nil;
    [super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		ret = [self updateProfiles];		
	}

	return(ret);	
}

- (void)clear
{
    [super clear];
	NSError *error = nil;
	
    [self.savedProfiles removeAllObjects];
    
	if (![self.managedObjectContext BITemptyEntity:kSCHProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {
        [self processSaveUserProfilesWithResult:result];
	} else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
		[self syncProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
		[[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentDidCompleteNotification 
                                                            object:self];		
		[super method:method didCompleteWithResult:nil];	
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
    NSManagedObjectID *managedObjectID = nil;
    NSManagedObject *profileManagedObject = nil;
    
    for (NSDictionary *profile in profilesArray) {
        if ([self.savedProfiles count] > 0) {
            managedObjectID = [self.savedProfiles objectAtIndex:0];
            if (managedObjectID != nil) {
                profileManagedObject = [self.managedObjectContext objectWithID:managedObjectID];
                
                if ([[profile objectForKey:kSCHLibreAccessWebServiceStatus] statusCodeValue] == kSCHStatusCodesSuccess) {
                    switch ([[profile objectForKey:kSCHLibreAccessWebServiceStatus] saveActionValue]) {
                        case kSCHSaveActionsCreate:
                        {
                            NSNumber *profileID = [self makeNullNil:[profile objectForKey:kSCHLibreAccessWebServiceID]];
                            if (profileID != nil) {
                                [profileManagedObject setValue:profileID forKey:kSCHLibreAccessWebServiceID];
                            } else {
                                // if the server didnt give us an ID then we remove the profile
                                [self.managedObjectContext deleteObject:profileManagedObject];
                            }                                                    
                        }
                            break;
                        case kSCHSaveActionsRemove:                            
                        {
                            [self.managedObjectContext deleteObject:profileManagedObject];
                        }
                            break;
                            
                        default:
                            //nop
                            break;
                    }
                } else {
                    // if the server wasnt happy then we remove the profile
                    [self.managedObjectContext deleteObject:profileManagedObject];
                }
                
                // We've attempted to save changes, reset to unmodified and now 
                // sync will update this with the truth from the server
                if (profileManagedObject.isDeleted == NO) {
                    [profileManagedObject setValue:[NSNumber numberWithStatus:kSCHStatusUnmodified] 
                                               forKey:SCHSyncEntityState];
                }
            }
            [self.savedProfiles removeObjectAtIndex:0];
        }
        [self save];
    }
}

- (void)processSaveUserProfilesWithResult:(NSDictionary *)result
{
    if (result != nil && [self.savedProfiles count] > 0) {
        [self applyProfileSaves:[result objectForKey:kSCHLibreAccessWebServiceProfileStatusList]];
    }        
    
    self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
    if (self.isSynchronizing == NO) {
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
    }		    
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    // when saving we accept there could be errors and process anything that succeeds then continue
    if(result != nil && [method compare:kSCHLibreAccessWebServiceSaveUserProfiles] == NSOrderedSame) {	    
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
	
    [self.savedProfiles removeAllObjects];
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"State IN %@", 
								[NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
								 [NSNumber numberWithStatus:kSCHStatusDeleted], nil]]];
	NSArray *updatedProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	if([updatedProfiles count] > 0) {
        
        [self trackProfileSaves:updatedProfiles];
        
		self.isSynchronizing = [self.libreAccessWebService saveUserProfiles:updatedProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;			
		}		
	} else {
		
		self.isSynchronizing = [self.libreAccessWebService getUserProfiles];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
			ret = NO;
		}
	}
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (NSArray *)localProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (void)syncProfiles:(NSArray *)profileList
{		
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

		id webItemID = [webItem valueForKey:kSCHLibreAccessWebServiceID];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];

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
            [deletedIDs addObject:profileItem.ID];
        }        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentWillDeleteNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:deletedIDs 
                                                                                               forKey:SCHProfileSyncComponentDeletedProfileIDs]];				
        for (SCHProfileItem *profileItem in deletePool) {
            [self.managedObjectContext deleteObject:profileItem];
        }                
    }
    
	for (NSDictionary *webItem in creationPool) {
		[self addProfile:webItem];
	}
	
	[self save];
}

- (void)addProfile:(NSDictionary *)webProfile
{
	SCHProfileItem *newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
	
	newProfileItem.StoryInteractionEnabled = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]];
	newProfileItem.ID = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceID]];
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
    
    newProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile inManagedObjectContext:self.managedObjectContext];

    SCHAnnotationsItem *newAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext];
    newAnnotationsItem.ProfileID = newProfileItem.ID;
    
    NSLog(@"Added profile with screenname %@ and ID %@", newProfileItem.ScreenName, newProfileItem.ID);
}

- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile
{	
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

@end
