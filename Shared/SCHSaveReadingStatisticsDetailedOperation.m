//
//  SCHSaveReadingStatisticsDetailedOperation.m
//  Scholastic
//
//  Created by John Eddie on 18/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSaveReadingStatisticsDetailedOperation.h"

#import "SCHReadingStatsSyncComponent.h"
#import "BITAPIError.h"
#import "SCHLibreAccessWebService.h"

@implementation SCHSaveReadingStatisticsDetailedOperation

- (void)main
{
    @try {
        [(SCHReadingStatsSyncComponent *)self.syncComponent clearCoreDataUsingContext:self.backgroundThreadManagedObjectContext];
        [self save];
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed 
                                                        error:error 
                                                  requestInfo:nil 
                                                       result:self.result 
                                             notificationName:SCHReadingStatsSyncComponentDidFailNotification 
                                         notificationUserInfo:nil];
            }
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isCancelled == NO) {
            [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed 
                                                   result:self.result 
                                                 userInfo:self.userInfo 
                                         notificationName:SCHReadingStatsSyncComponentDidCompleteNotification 
                                     notificationUserInfo:nil];
        }
    });                
}

@end
