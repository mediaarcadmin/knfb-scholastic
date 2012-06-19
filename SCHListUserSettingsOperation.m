//
//  SCHListUserSettingsOperation.m
//  Scholastic
//
//  Created by John Eddie on 18/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListUserSettingsOperation.h"

#import "SCHLibreAccessWebService.h"
#import "SCHSettingItem.h"
#import "SCHSettingsSyncComponent.h"
#import "BITAPIError.h"

@interface SCHListUserSettingsOperation ()

- (void)updateUserSettings:(NSArray *)settingsList;

@end

@implementation SCHListUserSettingsOperation

- (void)main
{
    @try {
        [self updateUserSettings:[self.result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListUserSettings 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHSettingsSyncComponentDidFailNotification 
                                         notificationUserInfo:nil];
            }
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isCancelled == NO) {
            [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListUserSettings 
                                                   result:self.result 
                                                 userInfo:self.userInfo 
                                         notificationName:SCHSettingsSyncComponentDidCompleteNotification 
                                     notificationUserInfo:nil];
        }
    });                
}
    
- (void)updateUserSettings:(NSArray *)settingsList
{	
    if ([settingsList count] > 0) {
        [(SCHSettingsSyncComponent *)self.syncComponent clearCoreDataUsingContext:self.backgroundThreadManagedObjectContext];
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        for (id setting in settingsList) {
            SCHSettingItem *newUserSettingsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHSettingItem 
                                                                                inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            
            newUserSettingsItem.SettingName = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingName]];
            newUserSettingsItem.SettingValue = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingValue]];
        }
        
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
}

@end
