//
//  SCHRetrieveRecommendationsForProfileOperation.m
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRetrieveRecommendationsForProfileOperation.h"

#import "SCHRecommendationSyncComponent.h"
#import "SCHRecommendationWebService.h"
#import "SCHAppRecommendationProfile.h"
#import "SCHRecommendationConstants.h"
#import "BITAPIError.h" 

@interface SCHRetrieveRecommendationsForProfileOperation ()

- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles;
- (NSArray *)localRecommendationProfiles;
- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHAppRecommendationProfile *)localRecommendationProfile
                         syncDate:(NSDate *)syncDate;
- (SCHAppRecommendationProfile *)recommendationProfile:(NSDictionary *)recommendationProfile
                                           syncDate:(NSDate *)syncDate;

@end

@implementation SCHRetrieveRecommendationsForProfileOperation

- (void)main
{
    @try {
        NSArray *profiles = [self makeNullNil:[self.result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile]];
        if ([profiles count] > 0) {
            [self syncRecommendationProfiles:profiles];                                    
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [(SCHRecommendationSyncComponent *)self.syncComponent retrieveRecommendationsForProfileCompletionResult:self.result 
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
                [self.syncComponent completeWithFailureMethod:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile 
                                          error:error 
                                    requestInfo:nil 
                                         result:self.result 
                               notificationName:SCHRecommendationSyncComponentDidFailNotification 
                           notificationUserInfo:nil];
            }
        });   
    }                    
}

// the sync can provide partial results so we don't delete here - we leave that to
// localFilteredProfiles:
- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles
{
    NSDate *syncDate = [NSDate date];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationProfiles = [webRecommendationProfiles sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceAge ascending:YES]]];		
	NSArray *localRecommendationProfilesArray = [self localRecommendationProfiles];
    
	NSEnumerator *webEnumerator = [webRecommendationProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localRecommendationProfilesArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHAppRecommendationProfile *localItem = [localEnumerator nextObject];
	
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
		
        id webItemID =  [self makeNullNil:[webItem valueForKey:kSCHRecommendationWebServiceAge]];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceAge];
		
        if (webItemID == nil || [SCHAppRecommendationProfile isValidProfileID:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncRecommendationProfile:webItem 
                          withRecommendationProfile:localItem 
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
        [self recommendationProfile:webItem 
                           syncDate:syncDate];
	}
    
	[self saveWithManagedObjectContext:self.backgroundThreadManagedObjectContext];    
}

- (NSArray *)localRecommendationProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationProfile
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceAge ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	[fetchRequest release], fetchRequest = nil;
    
	return(ret);
}

- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHAppRecommendationProfile *)localRecommendationProfile
                         syncDate:(NSDate *)syncDate
{
    if (webRecommendationProfile != nil) {
        localRecommendationProfile.age = [self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceAge]];
        localRecommendationProfile.fetchDate = syncDate;
        
        [(SCHRecommendationSyncComponent *)self.syncComponent syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
                                                              withRecommendationItems:localRecommendationProfile.recommendationItems
                                                                           insertInto:localRecommendationProfile
                                                                 managedObjectContext:self.backgroundThreadManagedObjectContext];
    }
}

- (SCHAppRecommendationProfile *)recommendationProfile:(NSDictionary *)webRecommendationProfile
                                              syncDate:(NSDate *)syncDate
{
	SCHAppRecommendationProfile *ret = nil;
	id recommendationProfileID =  [self makeNullNil:[webRecommendationProfile valueForKey:kSCHRecommendationWebServiceAge]];
    
	if (webRecommendationProfile != nil && [SCHAppRecommendationProfile isValidProfileID:recommendationProfileID] == YES) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppRecommendationProfile
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];			
        
        ret.age = recommendationProfileID;
        ret.fetchDate = syncDate;
        
        [(SCHRecommendationSyncComponent *)self.syncComponent syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
                                                              withRecommendationItems:ret.recommendationItems
                                                                           insertInto:ret
                                                                 managedObjectContext:self.backgroundThreadManagedObjectContext];            
    }
	
	return ret;
}

@end
