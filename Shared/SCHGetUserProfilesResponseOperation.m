//
//  SCHGetUserProfilesResponseOperation.m
//  Scholastic
//
//  Created by John Eddie on 14/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHGetUserProfilesResponseOperation.h"

#import "SCHProfileSyncComponent.h"
#import "SCHProfileItem.h"
#import "SCHAppProfile.h"
#import "SCHAnnotationsItem.h"
#import "SCHLibreAccessWebService.h"
#import "SCHWishListProfile.h"
#import "SCHWishListItem.h"
#import "SCHWishListSyncComponent.h"
#import "BITAPIError.h"
#import "SCHMakeNullNil.h"

@interface SCHGetUserProfilesResponseOperation ()

- (NSArray *)localProfilesUsingManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncProfile:(NSDictionary *)webProfile 
        withProfile:(SCHProfileItem *)localProfile;

@end

@implementation SCHGetUserProfilesResponseOperation

- (void)main
{
    @try {
        NSArray *profileList = [self.result objectForKey:kSCHLibreAccessWebServiceProfileList];
        if (profileList != nil) {
            [self syncProfiles:profileList 
          managedObjectContext:self.backgroundThreadManagedObjectContext];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceGetUserProfiles
                                                       result:self.result
                                                     userInfo:self.userInfo 
                                             notificationName:SCHProfileSyncComponentDidCompleteNotification
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
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceGetUserProfiles 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHProfileSyncComponentDidFailNotification
                                         notificationUserInfo:nil];
            }
        });   
    }                    
}

- (void)syncProfiles:(NSArray *)profileList 
managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{		
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [profileList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];		
	NSArray *localProfiles = [self localProfilesUsingManagedObjectContext:aManagedObjectContext];
    
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

		id webItemID = makeNullNil([webItem valueForKey:kSCHLibreAccessWebServiceID]);
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceID];
        
        if (webItemID == nil || [SCHProfileItem isValidProfileID:webItemID] == NO) {
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {    
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHProfileSyncComponentWillDeleteNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:deletedIDs 
                                                                                                       forKey:SCHProfileSyncComponentDeletedProfileIDs]];				
            }
        });
        for (SCHProfileItem *profileItem in deletePool) {
            [SCHProfileSyncComponent removeWishListForProfile:profileItem 
                                         managedObjectContext:aManagedObjectContext];
            
            [profileItem deleteAnnotations];
            [profileItem deleteStatistics];

            [aManagedObjectContext deleteObject:profileItem];
        }                
    }
    
	for (NSDictionary *webItem in creationPool) {
		[self addProfile:webItem managedObjectContext:aManagedObjectContext];
	}
    
    [self saveWithManagedObjectContext:aManagedObjectContext];    
}

- (NSArray *)localProfilesUsingManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                        inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [aManagedObjectContext
                    executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (SCHProfileItem *)addProfile:(NSDictionary *)webProfile
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    SCHProfileItem *newProfileItem = nil;
    id profileID = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceID]);
    
    if (webProfile != nil && [SCHProfileItem isValidProfileID:profileID] == YES) {
        newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem 
                                                       inManagedObjectContext:aManagedObjectContext];
        
        newProfileItem.StoryInteractionEnabled = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]);
        newProfileItem.ID = profileID;
        newProfileItem.LastPasswordModified = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastPasswordModified]);
        newProfileItem.Password = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServicePassword]);
        newProfileItem.Birthday = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceBirthday]);
        newProfileItem.FirstName = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceFirstName]);
        newProfileItem.ProfilePasswordRequired = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]);
        newProfileItem.Type = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceType]);
        newProfileItem.ScreenName = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceScreenName]);
        newProfileItem.AutoAssignContentToProfiles = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]);
        newProfileItem.LastScreenNameModified = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastScreenNameModified]);
        newProfileItem.UserKey = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceUserKey]);
        newProfileItem.BookshelfStyle = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceBookshelfStyle]);
        newProfileItem.LastName = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastName]);
        newProfileItem.allowReadThrough = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceAllowReadThrough]);
        newProfileItem.recommendationsOn = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceRecommendationsOn]);
        newProfileItem.LastModified = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]);
        newProfileItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
        newProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile 
                                                                  inManagedObjectContext:aManagedObjectContext];
        
        SCHAnnotationsItem *newAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem 
                                                                               inManagedObjectContext:aManagedObjectContext];
        newAnnotationsItem.ProfileID = newProfileItem.ID;
        
        SCHWishListProfile *newWishListProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                                                               inManagedObjectContext:aManagedObjectContext];    
        newWishListProfile.ProfileID = newProfileItem.ID;
        newWishListProfile.ProfileName = [newProfileItem profileName];
        
        NSLog(@"Added profile with screenname %@ and ID %@", newProfileItem.ScreenName, newProfileItem.ID);
    }
    
    return newProfileItem;
}

- (void)syncProfile:(NSDictionary *)webProfile withProfile:(SCHProfileItem *)localProfile
{	
    if (webProfile != nil) {
        localProfile.StoryInteractionEnabled = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceStoryInteractionEnabled]);
        localProfile.ID = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceID]);
        localProfile.LastPasswordModified = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastPasswordModified]);
        localProfile.Password = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServicePassword]);
        localProfile.Birthday = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceBirthday]);
        localProfile.FirstName = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceFirstName]);
        localProfile.ProfilePasswordRequired = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired]);
        localProfile.Type = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceType]);
        localProfile.ScreenName = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceScreenName]);
        localProfile.AutoAssignContentToProfiles = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles]);
        localProfile.LastScreenNameModified = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastScreenNameModified]);
        localProfile.UserKey = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceUserKey]);
        localProfile.BookshelfStyle = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceBookshelfStyle]);
        localProfile.LastName = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastName]);
        localProfile.recommendationsOn = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceRecommendationsOn]);
        localProfile.allowReadThrough = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceAllowReadThrough]);
        localProfile.LastModified = makeNullNil([webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]);
        localProfile.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				
    }
}

@end
