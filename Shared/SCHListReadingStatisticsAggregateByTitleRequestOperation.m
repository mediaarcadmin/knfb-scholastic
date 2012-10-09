//
//  SCHListReadingStatisticsAggregateByTitleRequest.m
//  Scholastic
//
//  Created by John S. Eddie on 30/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListReadingStatisticsAggregateByTitleRequestOperation.h"

#import "SCHListReadingStatisticsSyncComponent.h"
#import "SCHAppContentProfileItem.h"
#import "SCHLibreAccessConstants.h"
#import "BITAPIError.h"
#import "SCHMakeNullNil.h"

@interface SCHListReadingStatisticsAggregateByTitleRequestOperation ()

- (void)syncProfiles:(NSArray *)profileList;
- (NSArray *)appContentProfileItem:(NSNumber *)profileID isbn:(NSString *)isbn;

@end

@implementation SCHListReadingStatisticsAggregateByTitleRequestOperation

@synthesize profileID;

- (void)main
{
    @try {
        NSArray *profileList = [self.result objectForKey:kSCHLibreAccessWebServiceAggregateByTitleProfileList];
        if (profileList != nil) {
            [self syncProfiles:profileList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [(SCHListReadingStatisticsSyncComponent *)self.syncComponent syncCompleted:self.profileID
                                                                                  userInfo:self.userInfo];                
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
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListReadingStatisticsAggregateByTitle
                                                        error:error
                                                  requestInfo:nil
                                                       result:self.result
                                             notificationName:SCHListReadingStatisticsSyncComponentDidFailNotification
                                         notificationUserInfo:nil];
            }
        });
    }
}

- (void)syncProfiles:(NSArray *)profileList
{
    for (NSDictionary *profile in profileList) {
        NSNumber *theProfileID = makeNullNil([profile objectForKey:kSCHLibreAccessWebServiceProfileID]);
        if (theProfileID != nil && [theProfileID isEqualToNumber:self.profileID] == YES) {
            for (NSDictionary *item in makeNullNil([profile objectForKey:kSCHLibreAccessWebServiceAggregateByTitleList])) {
                NSString *isbn = makeNullNil([item objectForKey:kSCHLibreAccessWebServiceContentIdentifier]);
                if (isbn != nil) {
                    NSDictionary *quizItem = makeNullNil([item objectForKey:kSCHLibreAccessWebServiceQuizItem]);
                    NSNumber *bestScore = makeNullNil([quizItem objectForKey:kSCHLibreAccessWebServiceBestScore]);
                    
                    for (SCHAppContentProfileItem *appContentProfileItem in [self appContentProfileItem:self.profileID isbn:isbn]) {
                        appContentProfileItem.bestScore = bestScore;
                    }
                }
            }
        }
        [self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
    }
}

- (NSArray *)appContentProfileItem:(NSNumber *)theProfileID isbn:(NSString *)isbn
{
    NSArray *ret = nil;

    if (theProfileID != nil && isbn != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHAppContentProfileItem
                                                  inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ISBN = %@ AND ProfileItem.ID = %@", isbn, theProfileID];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest
                                                                                           error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            ret = fetchedObjects;
        }
        
        [fetchRequest release];
    }
    
    return ret;
}

@end
