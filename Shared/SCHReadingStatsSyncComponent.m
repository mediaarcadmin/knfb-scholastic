//
//  SCHReadingStatsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStatsSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHReadingStatsDetailItem.h"
#import "BITAPIError.h"
#import "SCHSaveReadingStatisticsDetailedOperation.h"

// Constants
NSString * const SCHReadingStatsSyncComponentDidCompleteNotification = @"SCHReadingStatsSyncComponentDidCompleteNotification";
NSString * const SCHReadingStatsSyncComponentDidFailNotification = @"SCHReadingStatsSyncComponentDidFailNotification";

@interface SCHReadingStatsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (atomic, retain) NSMutableSet *profilesForStatistics;

@end

@implementation SCHReadingStatsSyncComponent

@synthesize libreAccessWebService;
@synthesize profilesForStatistics;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;

        profilesForStatistics = [[NSMutableSet set] retain];
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;

    [profilesForStatistics release], profilesForStatistics = nil;
    
	[super dealloc];
}

- (void)addProfile:(NSNumber *)profileID
{
	if (profileID != nil) {
        if ([self.profilesForStatistics containsObject:profileID] == NO) {
            [self.profilesForStatistics addObject:profileID];
        }
	}
}

- (void)removeProfile:(NSNumber *)profileID
{
	if (self.isSynchronizing == NO && profileID != nil) {
        [self.profilesForStatistics removeObject:profileID];
    }
}

- (BOOL)haveProfiles
{
	return([self.profilesForStatistics count ] > 0);
}

- (NSNumber *)currentProfile
{
    NSNumber *ret = nil;

    if ([self haveProfiles] == YES) {
        ret = [[[self.profilesForStatistics allObjects] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
    }

    return ret;
}

- (BOOL)nextProfile
{
    NSNumber *currentProfile = [self currentProfile];

    if (currentProfile != nil) {
        [self.profilesForStatistics removeObject:currentProfile];
    }
    [self clearFailures];

    return [self haveProfiles];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];

        NSNumber *profileID = [self currentProfile];
        if (profileID != nil) {
            [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHReadingStatsDetailItem inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", profileID]];
            [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"ReadingStatsContentItem.ReadingStatsEntryItem"]];

            NSArray *readingStats = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (readingStats == nil) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }

            if ([readingStats count] > 0) {
                self.isSynchronizing = [self.libreAccessWebService saveReadingStatisticsDetailed:readingStats];
                if (self.isSynchronizing == NO) {
                    [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                        if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                            [self.delegate authenticationDidSucceed];
                        } else {
                            self.isSynchronizing = NO;
                        }
                    } failureBlock:^(NSError *error){
                        self.isSynchronizing = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                            object:self];
                    }];
                    ret = NO;
                }
            } else {
                // remove the profile if there are no statistics
                [self.profilesForStatistics removeObject:profileID];

                [self completeWithSuccessMethod:nil
                                         result:nil
                                       userInfo:nil
                               notificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                           notificationUserInfo:nil];
            }
        } else {
            [self completeWithSuccessMethod:nil
                                     result:nil
                                   userInfo:nil
                           notificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                       notificationUserInfo:nil];
        }

        if (ret == NO) {
            [self endBackgroundTask];
        }
	}
    [fetchRequest release], fetchRequest = nil;
    
	return ret;		
}

#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];    
}

- (void)clearComponent
{
    [self.profilesForStatistics removeAllObjects];
}

- (void)clearCoreData
{
    [self clearCoreDataUsingContext:self.managedObjectContext];
}

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSError *error = nil;
	
	if (![aManagedObjectContext BITemptyEntity:kSCHReadingStatsDetailItem error:&error priorToDeletionBlock:nil]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    NSNumber *profileID = [self currentProfile];

    if (profileID != nil) {
        SCHSaveReadingStatisticsDetailedOperation *operation = [[[SCHSaveReadingStatisticsDetailedOperation alloc] initWithSyncComponent:self
                                                                                                                                  result:result
                                                                                                                                userInfo:userInfo] autorelease];
        operation.profileID = profileID;
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    } else {
        [self completeWithSuccessMethod:kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed
                                 result:result
                               userInfo:userInfo
                       notificationName:SCHReadingStatsSyncComponentDidCompleteNotification
                   notificationUserInfo:nil];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    NSNumber *profileID = [self currentProfile];

    // server error so clear the stats
    if ([error domain] == kBITAPIErrorDomain && profileID != nil) {
        SCHSaveReadingStatisticsDetailedOperation *operation = [[[SCHSaveReadingStatisticsDetailedOperation alloc] initWithSyncComponent:self
                                                                                                                                  result:result
                                                                                                                                userInfo:nil] autorelease];
        operation.profileID = profileID;
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    } else {
        [self completeWithFailureMethod:method
                                  error:error
                            requestInfo:requestInfo
                                 result:result
                       notificationName:SCHReadingStatsSyncComponentDidFailNotification
                   notificationUserInfo:nil];
    }
}

- (void)syncCompleted:(NSNumber *)profileID
               result:(NSDictionary *)result
             userInfo:(NSDictionary *)userInfo
{
    NSParameterAssert(profileID);

    if (profileID != nil) {
        [self.profilesForStatistics removeObject:profileID];
    }

    [self completeWithSuccessMethod:kSCHLibreAccessWebServiceSaveReadingStatisticsDetailed
                             result:result
                           userInfo:userInfo
                   notificationName:SCHReadingStatsSyncComponentDidCompleteNotification
               notificationUserInfo:nil];
}

@end
