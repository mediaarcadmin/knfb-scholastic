//
//  SCHListReadingStatisticsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 28/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHListReadingStatisticsSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHBookIdentifier.h"
#import "BITAPIError.h"
#import "SCHListReadingStatisticsAggregateByTitleRequestOperation.h"

// Constants
NSString * const SCHListReadingStatisticsSyncComponentDidCompleteNotification = @"SCHListReadingStatisticsSyncComponentDidCompleteNotification";
NSString * const SCHListReadingStatisticsSyncComponentDidFailNotification = @"SCHListReadingStatisticsSyncComponentDidFailNotification";

@interface SCHListReadingStatisticsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (atomic, retain) NSMutableDictionary *statisticsForProfilesWithBooks;

- (NSNumber *)currentProfile;

@end

@implementation SCHListReadingStatisticsSyncComponent

@synthesize libreAccessWebService;
@synthesize statisticsForProfilesWithBooks;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];
		libreAccessWebService.delegate = self;
        
		statisticsForProfilesWithBooks = [[NSMutableDictionary dictionary] retain];        
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
    
	[statisticsForProfilesWithBooks release], statisticsForProfilesWithBooks = nil;    
    
	[super dealloc];
}

- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (profileID != nil && [books count] > 0) {
        NSMutableArray *profileBooks = [self.statisticsForProfilesWithBooks objectForKey:profileID];
        if (profileBooks != nil) {
            // Only add books that do not already exist
            for (NSDictionary *book in books) {
                SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:book];
                if (bookIdentifier != nil) {
                    __block BOOL bookAlreadyExists = NO;
                    [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                        if (profileBookIdentifier != nil &&
                            [bookIdentifier isEqual:profileBookIdentifier] == YES) {
                            bookAlreadyExists = YES;
                            *stop = YES;
                        }
                        [profileBookIdentifier release], profileBookIdentifier = nil;
                    }];
                    [bookIdentifier release], bookIdentifier = nil;
                    
                    if (bookAlreadyExists == NO) {
                        [profileBooks addObject:book];
                    }
                }
            }
        } else {
            [self.statisticsForProfilesWithBooks setObject:[NSMutableArray arrayWithArray:books] forKey:profileID];
        }
	}
}

// books is an array of BookIdentifiers
- (void)removeProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (self.isSynchronizing == NO && profileID != nil && [books count] > 0) {
        NSMutableArray *profileBooks = [self.statisticsForProfilesWithBooks objectForKey:profileID];
        if (profileBooks != nil) {
            for (SCHBookIdentifier *bookIdentifier in books) {
                __block NSUInteger removeBook = NSUIntegerMax;
                [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                    if (profileBookIdentifier != nil &&
                        [bookIdentifier isEqual:profileBookIdentifier] == YES) {
                        removeBook = idx;
                        *stop = YES;
                    }
                    [profileBookIdentifier release], profileBookIdentifier = nil;
                }];
                if (removeBook != NSUIntegerMax && removeBook < [profileBooks count]) {
                    [profileBooks removeObjectAtIndex:removeBook];
                }
            }
            if ([profileBooks count] < 1) {
                [self.statisticsForProfilesWithBooks removeObjectForKey:profileID];
            }
        }
	}
}

- (BOOL)haveProfiles
{
	return([self.statisticsForProfilesWithBooks count ] > 0);
}

- (NSNumber *)currentProfile
{
    NSNumber *ret = nil;
    
    if ([self haveProfiles] == YES) {
        ret = [[[self.statisticsForProfilesWithBooks allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
    }
    
    return ret;
}

- (BOOL)nextProfile
{
    NSNumber *currentProfile = [self currentProfile];
    
    if (currentProfile != nil) {
        [self.statisticsForProfilesWithBooks removeObjectForKey:currentProfile];
    }
    [self clearFailures];
    
    return [self haveProfiles];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
    
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];

        NSNumber *profileID = [self currentProfile];
        if (profileID != nil) {
            NSArray *books = [self.statisticsForProfilesWithBooks objectForKey:profileID];
            
            if ([books count] > 0) {
                self.isSynchronizing = [self.libreAccessWebService listReadingStatisticsAggregateByTitle:books forProfile:profileID];
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
                // remove the profile if there are no books
                [self.statisticsForProfilesWithBooks removeObjectForKey:profileID];

                [self completeWithSuccessMethod:nil
                                         result:nil
                                       userInfo:nil
                               notificationName:SCHListReadingStatisticsSyncComponentDidCompleteNotification
                           notificationUserInfo:nil];
            }
        } else {
            [self completeWithSuccessMethod:nil
                                     result:nil
                                   userInfo:nil
                           notificationName:SCHListReadingStatisticsSyncComponentDidCompleteNotification
                       notificationUserInfo:nil];
        }
    
        if (ret == NO) {
            [self endBackgroundTask];
        }
	}
    
	return(ret);
}
#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];
}

- (void)clearComponent
{
    [self.statisticsForProfilesWithBooks removeAllObjects];
}

- (void)clearCoreData
{
    // nop
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    NSNumber *profileID = [self currentProfile];
    
    if (profileID != nil) {
        SCHListReadingStatisticsAggregateByTitleRequestOperation *operation = [[[SCHListReadingStatisticsAggregateByTitleRequestOperation alloc] initWithSyncComponent:self
                                                                                                                                                                result:result
                                                                                                                                                              userInfo:nil] autorelease];
        
        operation.profileID = profileID;
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    } else {
        [self completeWithSuccessMethod:kSCHLibreAccessWebServiceListReadingStatisticsAggregateByTitle
                                 result:result
                               userInfo:userInfo
                       notificationName:SCHListReadingStatisticsSyncComponentDidCompleteNotification
                   notificationUserInfo:nil];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    NSNumber *profileID = [self currentProfile];
    
    // server error so process the result
    if ([error domain] == kBITAPIErrorDomain &&
        profileID != nil) {
        SCHListReadingStatisticsAggregateByTitleRequestOperation *operation = [[[SCHListReadingStatisticsAggregateByTitleRequestOperation alloc] initWithSyncComponent:self
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
                       notificationName:SCHListReadingStatisticsSyncComponentDidFailNotification
                   notificationUserInfo:nil];
    }
}

- (void)syncCompleted:(NSNumber *)profileID
             userInfo:(NSDictionary *)userInfo
{
    NSParameterAssert(profileID);
    
    if (profileID != nil) {
        [self.statisticsForProfilesWithBooks removeObjectForKey:profileID];
    }
    
    [self completeWithSuccessMethod:kSCHLibreAccessWebServiceListReadingStatisticsAggregateByTitle
                             result:nil
                           userInfo:userInfo
                   notificationName:SCHListReadingStatisticsSyncComponentDidCompleteNotification
               notificationUserInfo:nil];
}

@end
