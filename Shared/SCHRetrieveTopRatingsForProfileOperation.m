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
#import "SCHRecommendationItem.h"
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
- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
                     insertInto:(id)recommendation;
- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem;
- (void)syncRecommendationItem:(NSDictionary *)webRecommendationItem
        withRecommendationItem:(SCHRecommendationItem *)localRecommendationItem;

@end

@implementation SCHRetrieveTopRatingsForProfileOperation

- (void)main
{
#if USE_TOP_RATINGS_FOR_PROFILE_RECOMMENDATIONS
    NSAssert(YES, @"Something is very wrong we are not using Top Ratings for profile recommendations");
#endif

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
                                             notificationName:SCHTopRatingsSyncComponentDidCompleteNotification
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

        [self syncRecommendationItems:[self makeNullNil:[webRecommendationTopRating objectForKey:kSCHLibreAccessWebServiceTopRatingsContentItems]]
              withRecommendationItems:localRecommendationTopRating.recommendationItems
                           insertInto:localRecommendationTopRating];
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

        [self syncRecommendationItems:[self makeNullNil:[webRecommendationTopRating objectForKey:kSCHLibreAccessWebServiceTopRatingsContentItems]]
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];
    }

	return ret;
}

#pragma - Syncing methods

- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
                     insertInto:(id)recommendation
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];

	webRecommendationItems = [webRecommendationItems sortedArrayUsingDescriptors:
                              [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier
                                                                                     ascending:YES]]];
	NSArray *localRecommendationItemsArray = [localRecommendationItems sortedArrayUsingDescriptors:
                                              [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceProductCode
                                                                                                     ascending:YES]]];

	NSEnumerator *webEnumerator = [webRecommendationItems objectEnumerator];
	NSEnumerator *localEnumerator = [localRecommendationItemsArray objectEnumerator];

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHRecommendationItem *localItem = [localEnumerator nextObject];

	while (webItem != nil || localItem != nil) {
        if (webItem == nil) {
			while (localItem != nil) {
				[deletePool addObject:localItem];
				localItem = [localEnumerator nextObject];
			}
			break;
		}

		if (localItem == nil) {
			while (webItem != nil) {
                [creationPool addObject:webItem];
				webItem = [webEnumerator nextObject];
			}
			break;
		}

		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceProductCode];

        if (webItemID == nil || [SCHRecommendationItem isValidItemID:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncRecommendationItem:webItem
                          withRecommendationItem:localItem];
                    webItem = nil;
                    localItem = nil;
                    break;
                case NSOrderedAscending:
                    [creationPool addObject:webItem];
                    webItem = nil;
                    break;
                case NSOrderedDescending:
                    [deletePool addObject:localItem];
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

    for (SCHRecommendationItem *recommendationItem in deletePool) {
        [self.backgroundThreadManagedObjectContext deleteObject:recommendationItem];
    }

    for (NSDictionary *webItem in creationPool) {
        SCHRecommendationItem *recommendationItem = [self recommendationItem:webItem];
        if (recommendationItem != nil) {
            [recommendation addRecommendationItemsObject:recommendationItem];
        }
    }

	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];
}

- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem
{
	SCHRecommendationItem *ret = nil;
	id recommendationItemID = [self makeNullNil:[webRecommendationItem valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];

	if (webRecommendationItem != nil && [SCHRecommendationItem isValidItemID:recommendationItemID] == YES) {
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationItem
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];

        ret.product_code = recommendationItemID;
        ret.order = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceOrder]];

        [ret assignAppRecommendationItem];
	}

	return ret;
}

- (void)syncRecommendationItem:(NSDictionary *)webRecommendationItem
        withRecommendationItem:(SCHRecommendationItem *)localRecommendationItem
{
    if (webRecommendationItem != nil) {
        localRecommendationItem.product_code = [self makeNullNil:[webRecommendationItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        localRecommendationItem.order = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceOrder]];
    }
}

@end
