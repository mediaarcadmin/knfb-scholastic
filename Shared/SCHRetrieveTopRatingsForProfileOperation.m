//
//  SCHRetrieveTopRatingsForProfileOperation.m
//  Scholastic
//
//  Created by John S. Eddie on 28/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRetrieveTopRatingsForProfileOperation.h"

#import "SCHRecommendationTopRating.h"
#import "SCHTopRatingsSyncComponent.h"
#import "SCHRecommendationSyncComponent.h"
#import "SCHRecommendationConstants.h"
#import "SCHLibreAccessConstants.h"
#import "BITAPIError.h"

@interface SCHRetrieveTopRatingsForProfileOperation ()

- (void)syncRecommendationTopRatings:(NSArray *)webRecommendationTopRatings;
- (NSArray *)localTopRatings;
- (void)syncRecommendationTopRating:(NSDictionary *)webRecommendationTopRating
        withRecommendationTopRating:(SCHRecommendationTopRating *)localRecommendationTopRating
                           syncDate:(NSDate *)syncDate;
- (SCHRecommendationTopRating *)recommendationTopRating:(NSDictionary *)webRecommendationTopRating
                                               syncDate:(NSDate *)syncDate;

@end

@implementation SCHRetrieveTopRatingsForProfileOperation

- (void)main
{
    @try {
        NSArray *topRatings = [self makeNullNil:[self.result objectForKey:kSCHLibreAccessWebServiceTopRatingsList]];
        if ([topRatings count] > 0) {
            [self syncRecommendationTopRatings:topRatings];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [self.syncComponent completeWithSuccessMethod:kSCHLibreAccessWebServiceListTopRatings
                                                       result:self.result
                                                     userInfo:self.userInfo
                                             notificationName:SCHRecommendationSyncComponentDidCompleteNotification
                                         notificationUserInfo:nil];
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
                [self.syncComponent completeWithFailureMethod:kSCHLibreAccessWebServiceListTopRatings
                                                        error:error
                                                  requestInfo:nil
                                                       result:self.result
                                             notificationName:SCHTopRatingsSyncComponentDidFailNotification
                                         notificationUserInfo:nil];
            }
        });
    }
}

// the sync can provide partial results so we don't delete here - we leave that
// to localFilteredProfileCategoryClasses:
- (void)syncRecommendationTopRatings:(NSArray *)webRecommendationTopRatings
{
    NSDate *syncDate = [NSDate date];
	NSMutableArray *creationPool = [NSMutableArray array];

	webRecommendationTopRatings = [webRecommendationTopRatings sortedArrayUsingDescriptors:
                                   [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceTopRatingsTypeValue ascending:YES]]];
	NSArray *localRecommendationProfilesArray = [self localTopRatings];

	NSEnumerator *webEnumerator = [webRecommendationTopRatings objectEnumerator];
	NSEnumerator *localEnumerator = [localRecommendationProfilesArray objectEnumerator];

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHRecommendationTopRating *localItem = [localEnumerator nextObject];

	while (webItem != nil || localItem != nil) {
        if (webItem == nil) {
			break;
		}

		if (localItem == nil) {
			while (webItem != nil) {
                [creationPool addObject:webItem];
				webItem = [webEnumerator nextObject];
			}
			break;
		}

        id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceTopRatingsTypeValue]];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceCategoryClass];

        if (webItemID == nil || [SCHRecommendationTopRating isValidCategoryClass:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncRecommendationTopRating:webItem
                          withRecommendationTopRating:localItem
                                             syncDate:syncDate];
                    webItem = nil;
                    localItem = nil;
                    break;
                case NSOrderedAscending:
                    [creationPool addObject:webItem];
                    webItem = nil;
                    break;
                case NSOrderedDescending:
                    localItem = nil;
                    break;
            }
        }

		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}
	}

	for (NSDictionary *webItem in creationPool) {
        [self recommendationTopRating:webItem
                             syncDate:syncDate];
	}

	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
}

- (NSArray *)localTopRatings
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationTopRating
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext]];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceCategoryClass ascending:YES]]];

    NSError *error = nil;
	NSArray *ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

	[fetchRequest release], fetchRequest = nil;

	return(ret);
}

- (void)syncRecommendationTopRating:(NSDictionary *)webRecommendationTopRating
        withRecommendationTopRating:(SCHRecommendationTopRating *)localRecommendationTopRating
                           syncDate:(NSDate *)syncDate
{
    if (webRecommendationTopRating != nil) {
        localRecommendationTopRating.categoryClass = [self makeNullNil:[webRecommendationTopRating objectForKey:kSCHLibreAccessWebServiceTopRatingsTypeValue]];
        localRecommendationTopRating.fetchDate = syncDate;

        SCHRecommendationSyncComponent *recommendationSyncComponent = [[[SCHRecommendationSyncComponent alloc] init] autorelease];
        [recommendationSyncComponent syncRecommendationItems:[self makeNullNil:[webRecommendationTopRating objectForKey:kSCHRecommendationWebServiceItems]]
                                     withRecommendationItems:localRecommendationTopRating.recommendationItems
                                                  insertInto:webRecommendationTopRating
                                        managedObjectContext:self.backgroundThreadManagedObjectContext];
    }
}

- (SCHRecommendationTopRating *)recommendationTopRating:(NSDictionary *)webRecommendationTopRating
                                               syncDate:(NSDate *)syncDate
{
	SCHRecommendationTopRating *ret = nil;
	id topRatingCategoryClass =  [self makeNullNil:[webRecommendationTopRating valueForKey:kSCHLibreAccessWebServiceTopRatingsTypeValue]];

	if (webRecommendationTopRating != nil && [SCHRecommendationTopRating isValidCategoryClass:topRatingCategoryClass] == YES) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationTopRating
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];

        ret.categoryClass = topRatingCategoryClass;
        ret.fetchDate = syncDate;

        SCHRecommendationSyncComponent *recommendationSyncComponent = [[[SCHRecommendationSyncComponent alloc] init] autorelease];
        [recommendationSyncComponent syncRecommendationItems:[self makeNullNil:[webRecommendationTopRating objectForKey:kSCHLibreAccessWebServiceTopRatingsContentItems]]
                                     withRecommendationItems:ret.recommendationItems
                                                  insertInto:ret
                                        managedObjectContext:self.backgroundThreadManagedObjectContext];
    }

	return ret;
}

@end
