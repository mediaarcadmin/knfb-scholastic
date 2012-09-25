//
//  SCHTopRatingsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 27/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTopRatingsSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHLibreAccessConstants.h"
#import "SCHRecommendationTopRating.h"
#import "SCHProfileItem.h"
#import "SCHRecommendationItem.h"
#import "SCHAppRecommendationItem.h"
#import "SCHRetrieveTopRatingsForProfileOperation.h"

// Constants
NSString * const SCHTopRatingsSyncComponentDidCompleteNotification = @"SCHTopRatingsSyncComponentDidCompleteNotification";
NSString * const SCHTopRatingsSyncComponentDidFailNotification = @"SCHTopRatingsSyncComponentDidFailNotification";

static NSInteger const kSCHTopRatingsSyncComponentTopCount = 10;
static NSTimeInterval const kSCHTopRatingsSyncComponentSyncDelayTimeInterval = 86400.0;  // 24h

@interface SCHTopRatingsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (BOOL)updateTopRatings;
- (NSArray *)localFilteredProfileCategoryClasses;
- (NSArray *)dictionaryForCategoryClasses:(NSArray *)categoryClasses;
- (void)deleteUnusedCategoryClasses:(NSArray *)categoryClasses;

@end

@implementation SCHTopRatingsSyncComponent

@synthesize libreAccessWebService;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];
		libreAccessWebService.delegate = self;
	}

	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;

	[super dealloc];
}

- (BOOL)synchronize
{
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    NSAssert(YES, @"Something is very wrong we are not using Top Ratings for profile recommendations");
#endif

	BOOL ret = YES;

	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];

		ret = [self updateTopRatings];
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
    // nop
}

- (void)clearCoreData
{
	NSError *error = nil;

	if (![self.managedObjectContext BITemptyEntity:kSCHAppRecommendationTopRating error:&error priorToDeletionBlock:nil] ||
        ![self.managedObjectContext BITemptyEntity:kSCHRecommendationItem error:&error priorToDeletionBlock:nil] ||
        ![self.managedObjectContext BITemptyEntity:kSCHAppRecommendationItem error:&error priorToDeletionBlock:^(NSManagedObject *managedObject) {
        [(SCHAppRecommendationItem *)managedObject deleteAllFiles];
    }]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

#pragma mark - Overridden methods

- (void)completeWithSuccessMethod:(NSString *)method
                           result:(NSDictionary *)result
                         userInfo:(NSDictionary *)userInfo
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
    [SCHAppRecommendationItem purgeUnusedAppRecommendationItemsUsingManagedObjectContext:self.managedObjectContext];
    [super completeWithSuccessMethod:method
                              result:result
                            userInfo:userInfo
                    notificationName:notificationName
                notificationUserInfo:notificationUserInfo];
}

#pragma - Web Service delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    if ([method isEqualToString:kSCHLibreAccessWebServiceListTopRatings] == YES) {
        SCHRetrieveTopRatingsForProfileOperation *operation = [[[SCHRetrieveTopRatingsForProfileOperation alloc] initWithSyncComponent:self
                                                                                                                                result:result
                                                                                                                              userInfo:userInfo] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);

    [self completeWithFailureMethod:method
                              error:error
                        requestInfo:requestInfo
                             result:result
                   notificationName:SCHTopRatingsSyncComponentDidFailNotification
               notificationUserInfo:nil];
}

- (BOOL)updateTopRatings
{
	BOOL ret = YES;

    if (self.saveOnly == NO) {
        NSArray *categoryClasses = [self localFilteredProfileCategoryClasses];

        if ([categoryClasses count] > 0) {
            self.isSynchronizing = [self.libreAccessWebService listTopRatings:[self dictionaryForCategoryClasses:categoryClasses]
                                                                    withCount:kSCHTopRatingsSyncComponentTopCount];
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
            [self completeWithSuccessMethod:nil
                                     result:nil
                                   userInfo:nil
                           notificationName:SCHTopRatingsSyncComponentDidCompleteNotification
                       notificationUserInfo:nil];
        }
    } else {
        [self completeWithSuccessMethod:nil
                                 result:nil
                               userInfo:nil
                       notificationName:SCHTopRatingsSyncComponentDidCompleteNotification
                   notificationUserInfo:nil];
    }
    
	return ret;
}

#pragma - Information retrieval methods

- (NSArray *)localFilteredProfileCategoryClasses
{
    NSMutableArray *allProfileCategoryClasses = nil;
    NSMutableArray *filteredProfileCategoryClasses = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem
                                        inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];

    NSError *error = nil;
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        // only return those items that require updating
        allProfileCategoryClasses = [NSMutableArray arrayWithCapacity:[results count]];
        filteredProfileCategoryClasses = [NSMutableArray arrayWithCapacity:[results count]];
        for (SCHProfileItem *item in results) {
            SCHAppRecommendationTopRating *topRating = [[item AppProfile] appRecommendationTopRating];
            NSDate *nextUpdate = [topRating.fetchDate dateByAddingTimeInterval:kSCHTopRatingsSyncComponentSyncDelayTimeInterval];
            NSString *categoryClass = [item categoryClass];

            if ([allProfileCategoryClasses containsObject:categoryClass] == NO) {
                [allProfileCategoryClasses addObject:categoryClass];
            }

            if (topRating == nil ||
                nextUpdate == nil ||
                [[NSDate date] earlierDate:nextUpdate] == nextUpdate) {
                if ([filteredProfileCategoryClasses containsObject:categoryClass] == NO) {
                    [filteredProfileCategoryClasses addObject:categoryClass];
                }
            }
        }
    }
	[fetchRequest release], fetchRequest = nil;

    [self deleteUnusedCategoryClasses:allProfileCategoryClasses];

	return [NSArray arrayWithArray:filteredProfileCategoryClasses];
}

- (NSArray *)dictionaryForCategoryClasses:(NSArray *)categoryClasses
{
    NSMutableArray *ret = [NSMutableArray array];

    for (NSString *categoryClass in categoryClasses) {
        [ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithTopFavoritesType:kSCHTopRatingsTypeseReaderCategoryClass], kSCHLibreAccessWebServiceTopRatingsType,
                        categoryClass, kSCHLibreAccessWebServiceTopRatingsTypeValue,
                        nil]];
    }

    return [NSArray arrayWithArray:ret];
}

- (void)deleteUnusedCategoryClasses:(NSArray *)categoryClasses
{
    if ([categoryClasses count] > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationTopRating
                                            inManagedObjectContext:self.managedObjectContext]];

        NSArray *recommendationTopRatings = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                                   error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (recommendationTopRatings == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            for (SCHAppRecommendationTopRating *topRating in recommendationTopRatings) {
                if ([categoryClasses containsObject:topRating.categoryClass] == NO) {
                    [self.managedObjectContext deleteObject:topRating];
                }
            }
            [self saveWithManagedObjectContext:self.managedObjectContext];
        }
    }
}

@end
