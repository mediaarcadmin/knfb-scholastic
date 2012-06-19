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
#import "BITAPIError.h"

@interface SCHSaveUserProfilesOperation ()

- (void)processSaveUserProfiles;
- (void)applyProfileSaves:(NSArray *)profilesArray;

@end

@implementation SCHSaveUserProfilesOperation

- (void)main
{
    @try {
        [self processSaveUserProfiles];
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceSaveUserProfiles 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHProfileSyncComponentDidFailNotification
                                         notificationUserInfo:nil];
                [((SCHProfileSyncComponent *)self.syncComponent).savedProfiles removeAllObjects];        
            }
        });   
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
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
}


@end
