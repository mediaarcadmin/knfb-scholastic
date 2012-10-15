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
#import "SCHReadingStatsDetailItem.h"

@implementation SCHSaveReadingStatisticsDetailedOperation

@synthesize profileID;

- (void)main
{
    @try {
        if (self.profileID != nil) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHReadingStatsDetailItem
                                                      inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            [fetchRequest setEntity:entity];

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ProfileID == %@",
                                      self.profileID];
            [fetchRequest setPredicate:predicate];

            NSError *error = nil;
            NSArray *readingStats = [self.backgroundThreadManagedObjectContext
                                     executeFetchRequest:fetchRequest error:&error];
            if (readingStats == nil) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            } else {
                for (NSManagedObject *managedObject in readingStats) {
                    [self.backgroundThreadManagedObjectContext deleteObject:managedObject];
                }
            }

            [fetchRequest release];

            [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
        }
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
            [(SCHReadingStatsSyncComponent *)self.syncComponent syncCompleted:self.profileID
                                                                       result:self.result
                                                                     userInfo:self.userInfo];
        }
    });
}

@end
