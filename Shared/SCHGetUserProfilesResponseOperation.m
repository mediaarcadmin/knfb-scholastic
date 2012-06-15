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

@interface SCHGetUserProfilesResponseOperation ()

- (void)syncProfiles:(NSArray *)profileList;
- (NSArray *)localProfiles;
- (BOOL)profileIDIsValid:(NSNumber *)profileID;
- (void)syncProfile:(NSDictionary *)webProfile 
        withProfile:(SCHProfileItem *)localProfile;

@end

@implementation SCHGetUserProfilesResponseOperation

- (void)beginOperation
{
    if (self.isCancelled == NO) {
        NSArray *profileList = [self.result objectForKey:kSCHLibreAccessWebServiceProfileList];
        if (profileList != nil) {
            [self syncProfiles:profileList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceGetUserProfiles
                                                       result:nil
                                                     userInfo:self.userInfo 
                                             notificationName:SCHProfileSyncComponentDidCompleteNotification];
            }
        });                
    }
    
    [self saveAndEndOperation];
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
                                         managedObjectContext:self.backgroundThreadManagedObjectContext];
            [self.backgroundThreadManagedObjectContext deleteObject:profileItem];
        }                
    }
    
	for (NSDictionary *webItem in creationPool) {
		[self addProfile:webItem managedObjectContext:self.backgroundThreadManagedObjectContext];
	}
	
	[self save];
}

- (NSArray *)localProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
	NSArray *ret = [self.backgroundThreadManagedObjectContext 
                    executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (BOOL)profileIDIsValid:(NSNumber *)profileID
{
    return [profileID integerValue] > 0;
}

- (SCHProfileItem *)addProfile:(NSDictionary *)webProfile
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    SCHProfileItem *newProfileItem = nil;
    id profileID = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceID]];
    
    if (webProfile != nil && [self profileIDIsValid:profileID] == YES) {
        newProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHProfileItem 
                                                       inManagedObjectContext:aManagedObjectContext];
        
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
        newProfileItem.recommendationsOn = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceRecommendationsOn]];        
        newProfileItem.LastModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]];
        newProfileItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
        
        newProfileItem.AppProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppProfile 
                                                                  inManagedObjectContext:aManagedObjectContext];
        
        SCHAnnotationsItem *newAnnotationsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsItem 
                                                                               inManagedObjectContext:aManagedObjectContext];
        newAnnotationsItem.ProfileID = newProfileItem.ID;
        
        SCHWishListProfile *newWishListProfile = [NSEntityDescription insertNewObjectForEntityForName:kSCHWishListProfile 
                                                                               inManagedObjectContext:aManagedObjectContext];    
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
        localProfile.recommendationsOn = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceRecommendationsOn]];
        localProfile.LastModified = [self makeNullNil:[webProfile valueForKey:kSCHLibreAccessWebServiceLastModified]];
        localProfile.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				
    }
}

@end
