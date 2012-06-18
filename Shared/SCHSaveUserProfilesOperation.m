//
//  SCHSaveUserProfilesOperation.m
//  Scholastic
//
//  Created by John Eddie on 15/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSaveUserProfilesOperation.h"

#import "SCHProfileSyncComponent.h"
#import "SCHProfileItem.h"
#import "SCHLibreAccessWebService.h"

@interface SCHSaveUserProfilesOperation ()

- (void)processSaveUserProfiles;
- (void)applyProfileSaves:(NSArray *)profilesArray;

@end

@implementation SCHSaveUserProfilesOperation

- (void)main
{
    if (self.isCancelled == NO) {
        [self processSaveUserProfiles];
        
        [self save];
    }
}

- (void)processSaveUserProfiles
{
    if (self.result != nil && [[(SCHProfileSyncComponent *)self.syncComponent savedProfiles] count] > 0) {
        [self applyProfileSaves:[self.result objectForKey:kSCHLibreAccessWebServiceProfileStatusList]];
    }        
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isCancelled == NO) {
            [(SCHProfileSyncComponent *)self.syncComponent requestUserProfiles];
        }
    });
}

- (void)applyProfileSaves:(NSArray *)profilesArray
{
    NSManagedObjectID *managedObjectID = nil;
    NSManagedObject *profileManagedObject = nil;
    SCHProfileSyncComponent *profileSyncComponent = (SCHProfileSyncComponent *)self.syncComponent;
    
    for (NSDictionary *profile in profilesArray) {
        if (self.isCancelled == YES) {
            return;
        }
        if ([profileSyncComponent.savedProfiles count] > 0) {
            managedObjectID = [profileSyncComponent.savedProfiles objectAtIndex:0];
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
                            [SCHProfileSyncComponent removeWishListForProfile:(SCHProfileItem *)profileManagedObject 
                                                         managedObjectContext:self.backgroundThreadManagedObjectContext];
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
            if ([profileSyncComponent.savedProfiles count] > 0) {
                [profileSyncComponent.savedProfiles removeObjectAtIndex:0];
            }
        }
        [self save];
    }
}


@end
