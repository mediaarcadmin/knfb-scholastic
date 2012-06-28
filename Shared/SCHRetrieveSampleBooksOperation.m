//
//  SCHRetrieveSampleBooksOperation.m
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRetrieveSampleBooksOperation.h"

#import "SCHRecommendationSyncComponent.h"
#import "SCHRecommendationWebService.h"
#import "SCHRecommendationProfile.h"
#import "SCHRecommendationISBN.h"
#import "SCHProfileItem.h"
#import "SCHLibreAccessConstants.h"
#import "SCHRecommendationConstants.h"
#import "SCHRecommendationItem.h"
#import "SCHUserContentItem.h"
#import "BITAPIError.h" 
#import "SCHContentMetadataItem.h"
#import "SCHAppRecommendationItem.h"
#import "SCHBookIdentifier.h"
#import "SCHProfileSyncComponent.h"
#import "SCHRetrieveRecommendationsForBooksOperation.h"

@interface SCHRetrieveSampleBooksOperation ()

@end

@implementation SCHRetrieveSampleBooksOperation

- (void)main
{
    NSMutableArray *sampleBooks = [(SCHRecommendationSyncComponent *)self.syncComponent localFilteredBooksForDRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample] 
                                                                                                                   asISBN:NO
                                                                                                     managedObjectContext:self.backgroundThreadManagedObjectContext];
    if ([sampleBooks count] > 0) {
        NSMutableArray *sampleBooksObject = [NSMutableArray arrayWithCapacity:[sampleBooks count]];
        
        for (SCHUserContentItem *item in sampleBooks) {
            SCHContentMetadataItem *contentMetadateItem = [[item ContentMetadataItem] anyObject];
            if (contentMetadateItem != nil) {
                NSMutableDictionary *currentRecommendation = [NSMutableDictionary dictionary];
                
                // we only have enough information to supply these properties
                [currentRecommendation setValue:contentMetadateItem.Title forKey:kSCHRecommendationWebServiceName];
                [currentRecommendation setValue:item.ContentIdentifier forKey:kSCHRecommendationWebServiceProductCode];
                [currentRecommendation setValue:contentMetadateItem.Author forKey:kSCHRecommendationWebServiceAuthor];
                [currentRecommendation setValue:[NSNumber numberWithInteger:0] forKey:kSCHRecommendationWebServiceOrder];
                
                [sampleBooksObject addObject:[NSDictionary dictionaryWithObjectsAndKeys:item.ContentIdentifier, kSCHRecommendationWebServiceISBN,
                                              [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample], kSCHRecommendationWebServiceDRMQualifier,
                                              [NSArray arrayWithObject:currentRecommendation], kSCHRecommendationWebServiceItems, nil]];
            }
        }
        
        SCHRetrieveRecommendationsForBooksOperation *operation = [[[SCHRetrieveRecommendationsForBooksOperation alloc] initWithSyncComponent:self.syncComponent 
                                                                                                                                      result:nil
                                                                                                                                    userInfo:nil] autorelease];
        
        [operation syncRecommendationISBNs:sampleBooksObject 
                      managedObjectContext:self.backgroundThreadManagedObjectContext]; 
    }
}

@end
