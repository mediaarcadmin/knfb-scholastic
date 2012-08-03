//
//  SCHSaveProfileContentAnnotationsOperation.m
//  Scholastic
//
//  Created by John Eddie on 19/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSaveProfileContentAnnotationsOperation.h"

#import "SCHAnnotationSyncComponent.h"
#import "SCHAppStateManager.h"
#import "BITAPIError.h"
#import "SCHLibreAccessWebService.h"
#import "SCHSyncEntity.h"

@interface SCHSaveProfileContentAnnotationsOperation ()

- (void)processSaveProfileContentAnnotations;
- (void)applyAnnotationSaves:(NSArray *)annotationsArray;

@end

@implementation SCHSaveProfileContentAnnotationsOperation

@synthesize profileID;

- (void)dealloc
{
    [profileID release], profileID = nil;
    
    [super dealloc];
}

- (void)main
{
    @try {
        [self processSaveProfileContentAnnotations];
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(self.profileID == nil ? (id)[NSNull null] : self.profileID)
                                                                                 forKey:SCHAnnotationSyncComponentProfileIDs];            
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHAnnotationSyncComponentDidFailNotification
                                         notificationUserInfo:notificationUserInfo];
                [((SCHAnnotationSyncComponent *)self.syncComponent).savedAnnotations removeAllObjects];                
            }
        });   
    }            
}

- (void)processSaveProfileContentAnnotations
{
    SCHAnnotationSyncComponent *annotationSyncComponent = (SCHAnnotationSyncComponent *)self.syncComponent; 
    BOOL shouldSyncNotes = NO;
    
    if (self.result != nil && [annotationSyncComponent.savedAnnotations count] > 0) {
        shouldSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
        for (NSDictionary *annotationStatusItem in [self.result objectForKey:kSCHLibreAccessWebServiceAnnotationStatusList]) {
            NSNumber *annotationProfileID = [annotationStatusItem objectForKey:kSCHLibreAccessWebServiceProfileID];
            if (annotationProfileID != nil && self.profileID != nil &&
                [annotationProfileID isEqualToNumber:self.profileID] == YES) {
                for (NSDictionary *annotationStatusContentItem in [annotationStatusItem objectForKey:kSCHLibreAccessWebServiceAnnotationStatusContentList]) {            
                    NSDictionary *privateAnnotationsStatus = [annotationStatusContentItem objectForKey:kSCHLibreAccessWebServicePrivateAnnotationsStatus];
                    
                    [self applyAnnotationSaves:[privateAnnotationsStatus objectForKey:kSCHLibreAccessWebServiceHighlightsStatusList]];
                    if (shouldSyncNotes == YES) {
                        [self applyAnnotationSaves:[privateAnnotationsStatus objectForKey:kSCHLibreAccessWebServiceNotesStatusList]];
                    }
                    [self applyAnnotationSaves:[privateAnnotationsStatus objectForKey:kSCHLibreAccessWebServiceBookmarksStatusList]];
                }
                break;
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isCancelled == NO) {
            [annotationSyncComponent requestListProfileContentAnnotationsForProfileID:self.profileID];
        }
    });
}

// apply annotations changes by checking the server response
// confirmed deletions are deleted, confirmed creation ID's are applied
// any issues such as missing ID will be removed by removeNewlyCreatedAndSavedAnnotations
// the next list annotation will then resolve the issue
- (void)applyAnnotationSaves:(NSArray *)annotationsArray
{
    NSManagedObjectID *managedObjectID = nil;
    NSManagedObject *annotationManagedObject = nil;
    SCHAnnotationSyncComponent *annotationSyncComponent = (SCHAnnotationSyncComponent *)self.syncComponent;
    
    for (NSDictionary *annotation in annotationsArray) {
        if ([annotationSyncComponent.savedAnnotations count] > 0) {
            managedObjectID = [annotationSyncComponent.savedAnnotations objectAtIndex:0];
            if (managedObjectID != nil) {
                BOOL updatedID = NO;
                annotationManagedObject = [self.backgroundThreadManagedObjectContext objectWithID:managedObjectID];
                
                if ([[[annotation objectForKey:kSCHLibreAccessWebServiceStatusMessage] 
                      objectForKey:kSCHLibreAccessWebServiceStatus] statusCodeValue] == kSCHStatusCodesSuccess) {
                    switch ([[annotation objectForKey:kSCHLibreAccessWebServiceAction] saveActionValue]) {
                        case kSCHSaveActionsCreate:
                        {
                            NSNumber *annotationID = [self makeNullNil:[annotation objectForKey:kSCHLibreAccessWebServiceID]];
                            if ([annotationSyncComponent annotationIDIsValid:annotationID] == YES) {
                                updatedID = YES;
                                [annotationManagedObject setValue:annotationID forKey:kSCHLibreAccessWebServiceID];
                            }                                                   
                        }
                            break;
                        case kSCHSaveActionsRemove:                            
                        {
                            [self.backgroundThreadManagedObjectContext deleteObject:annotationManagedObject];
                        }
                            break;
                            
                        default:
                            //nop
                            break;
                    }
                }
                
                // We've attempted to save changes, reset to unmodified and now 
                // sync will update this with the truth from the server
                if (updatedID == YES && annotationManagedObject.isDeleted == NO) {
                    [annotationManagedObject setValue:[NSNumber numberWithStatus:kSCHStatusUnmodified] 
                                               forKey:SCHSyncEntityState];
                }
            }
            if ([annotationSyncComponent.savedAnnotations count] > 0) {
                [annotationSyncComponent.savedAnnotations removeObjectAtIndex:0];
            }
        }
    }
    [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];    
}

@end
