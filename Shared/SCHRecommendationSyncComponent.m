//
//  SCHRecommendationSyncComponent.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

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

// Constants
NSString * const SCHRecommendationSyncComponentDidInsertNotification = @"SCHRecommendationSyncComponentDidInsertNotification";
NSString * const SCHRecommendationSyncComponentWillDeleteNotification = @"SCHRecommendationSyncComponentWillDeleteNotification";
NSString * const SCHRecommendationSyncComponentISBNs = @"SCHRecommendationSyncComponentISBNs";
NSString * const SCHRecommendationSyncComponentDidCompleteNotification = @"SCHRecommendationSyncComponentDidCompleteNotification";
NSString * const SCHRecommendationSyncComponentDidFailNotification = @"SCHRecommendationSyncComponentDidFailNotification";

static NSTimeInterval const kSCHRecommendationSyncComponentProfileSyncDelayTimeInterval = 86400.0;  // 24h
static NSTimeInterval const kSCHRecommendationSyncComponentBookSyncDelayTimeInterval = 86400.0;  // 24h

@interface SCHRecommendationSyncComponent ()

@property (nonatomic, retain) SCHRecommendationWebService *recommendationWebService;
@property (nonatomic, retain) NSMutableArray *remainingBatchedItems;

- (BOOL)updateRecommendations;
- (BOOL)retrieveBooks:(NSArray *)books;
- (BOOL)retrieveProfiles:(NSArray *)profiles;
- (NSMutableArray *)removeBatchItemsFrom:(NSMutableArray *)items;
- (NSMutableArray *)localFilteredProfiles;
- (NSMutableArray *)localFilteredBooksForDRMQualifier:(NSNumber *)drmQualifier 
                                               asISBN:(BOOL)asISBN
                                 managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (NSArray *)localRecommendationProfilesWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (NSArray *)localRecommendationISBNsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles
              managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)recommendationProfile
                                           syncDate:(NSDate *)syncDate
                               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHRecommendationProfile *)localRecommendationProfile
                         syncDate:(NSDate *)syncDate
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate
                         managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHRecommendationISBN *)localRecommendationISBN
                      syncDate:(NSDate *)syncDate
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
                     insertInto:(id)recommendation
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem 
                         managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationItem:(NSDictionary *)webRecommendationItem 
        withRecommendationItem:(SCHRecommendationItem *)localRecommendationItem;
- (void)deleteUnusedProfileAges:(NSArray *)profileAges;

@end

@implementation SCHRecommendationSyncComponent

@synthesize recommendationWebService;
@synthesize remainingBatchedItems;

- (id)init
{
	self = [super init];
	if (self != nil) {
		recommendationWebService = [[SCHRecommendationWebService alloc] init];	
		recommendationWebService.delegate = self;
	}
	
	return(self);
}

- (void)dealloc
{
    recommendationWebService.delegate = nil;
	[recommendationWebService release], recommendationWebService = nil;
    [remainingBatchedItems release], remainingBatchedItems = nil;
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateRecommendations];
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);		
}

#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.recommendationWebService clear];
}

- (void)clearComponent
{
    self.remainingBatchedItems = nil;
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHRecommendationProfile error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHRecommendationISBN error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHRecommendationItem error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHAppRecommendationItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

#pragma mark - Delegate methods

- (BOOL)updateRecommendations
{	
    BOOL ret = YES;

    if (self.saveOnly == NO) {
        NSMutableArray *profiles = [self localFilteredProfiles];
        
        if ([profiles count] > 0) {
            self.remainingBatchedItems = [self removeBatchItemsFrom:profiles];
            ret = [self retrieveProfiles:profiles];
        } else if (self.saveOnly == NO) {
            [self retrieveSampleBooks];
            
            NSMutableArray *books = [self localFilteredBooksForDRMQualifier:
                                     [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM] 
                                                                     asISBN:YES
                                     managedObjectContext:self.managedObjectContext];
            
            if ([books count] > 0) {
                self.remainingBatchedItems = [self removeBatchItemsFrom:books];
                ret = [self retrieveBooks:books];
            } else {
                [self completeWithSuccessMethod:nil 
                                         result:nil 
                                       userInfo:nil 
                               notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                           notificationUserInfo:nil];
            }
        } else {
            [self completeWithSuccessMethod:nil 
                                     result:nil 
                                   userInfo:nil 
                           notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
    } else {
        [self completeWithSuccessMethod:nil 
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                   notificationUserInfo:nil];
    }
    
    return  ret;
}

#pragma - Overridden methods

- (void)completeWithSuccessMethod:(NSString *)method 
                           result:(NSDictionary *)result 
                         userInfo:(NSDictionary *)userInfo
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
    self.remainingBatchedItems = nil;
    [super completeWithSuccessMethod:method 
                              result:result 
                            userInfo:userInfo 
                    notificationName:notificationName 
                notificationUserInfo:notificationUserInfo];
}

- (void)completeWithFailureMethod:(NSString *)method 
                            error:(NSError *)error 
                      requestInfo:(NSDictionary *)requestInfo 
                           result:(NSDictionary *)result
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
    self.remainingBatchedItems = nil;
    [super completeWithFailureMethod:method 
                               error:error 
                         requestInfo:requestInfo 
                              result:result 
                    notificationName:notificationName 
                notificationUserInfo:notificationUserInfo];
}

#pragma - Web Service delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    @try {        
        if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile] == YES) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSManagedObjectContext *backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
                [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                
                NSArray *profiles = [self makeNullNil:[result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile]];
                if ([profiles count] > 0) {
                    [self syncRecommendationProfiles:profiles
                                managedObjectContext:backgroundThreadManagedObjectContext];                        
                }
                
                [self saveWithManagedObjectContext:backgroundThreadManagedObjectContext];
                [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.saveOnly == NO) {
                        if ([self.remainingBatchedItems count] > 0) {
                            NSMutableArray *remainingProfiles = [self removeBatchItemsFrom:self.remainingBatchedItems];
                            [self retrieveProfiles:self.remainingBatchedItems];  
                            self.remainingBatchedItems = remainingProfiles;                    
                        } else {
                            [self retrieveSampleBooks];
                            
                            NSMutableArray *books = [self localFilteredBooksForDRMQualifier:
                                                     [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM] 
                                                                                     asISBN:YES
                                                     managedObjectContext:self.managedObjectContext];
                            
                            if ([books count] > 0) {
                                self.remainingBatchedItems = [self removeBatchItemsFrom:books];
                                [self retrieveBooks:books];
                            } else {
                                [self completeWithSuccessMethod:method 
                                                         result:result 
                                                       userInfo:userInfo 
                                               notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                                           notificationUserInfo:nil];
                            }
                        }
                    } else {
                        [self completeWithSuccessMethod:method 
                                                 result:result 
                                               userInfo:userInfo 
                                       notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                                   notificationUserInfo:nil];
                    }            
                });                                        
            });
        } else if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks] == YES) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSManagedObjectContext *backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
                [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
                [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                
                NSArray *books = [self makeNullNil:[result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks]];
                if ([books count] > 0) { 
                    [self syncRecommendationISBNs:books 
                             managedObjectContext:backgroundThreadManagedObjectContext];            
                }            
                
                [self saveWithManagedObjectContext:backgroundThreadManagedObjectContext];
                [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;

                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.remainingBatchedItems count] > 0) {
                        NSMutableArray *remainingBooks = [self removeBatchItemsFrom:self.remainingBatchedItems];
                        [self retrieveBooks:self.remainingBatchedItems];                    
                        self.remainingBatchedItems = remainingBooks;                
                    } else {
                        [self completeWithSuccessMethod:method 
                                                 result:result 
                                               userInfo:userInfo 
                                       notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                                   notificationUserInfo:nil];
                    }
                });
            });
        } else {
            [self completeWithSuccessMethod:method 
                                     result:result 
                                   userInfo:userInfo 
                           notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
    } 
    @catch (NSException *exception) {
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [self completeWithFailureMethod:method 
                                  error:error 
                            requestInfo:nil 
                                 result:result 
                       notificationName:SCHRecommendationSyncComponentDidFailNotification 
                   notificationUserInfo:nil];
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
                   notificationName:SCHRecommendationSyncComponentDidFailNotification 
               notificationUserInfo:nil];
}

#pragma - Web API methods

- (BOOL)retrieveBooks:(NSArray *)isbns
{
    BOOL ret = NO;
    
    if ([isbns count] > 0) {
        self.isSynchronizing = [self.recommendationWebService retrieveRecommendationsForBooks:isbns];
        ret = self.isSynchronizing;
    }
    
    return ret;
}

- (void)retrieveSampleBooks
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *backgroundThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
        [backgroundThreadManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        NSMutableArray *sampleBooks = [self localFilteredBooksForDRMQualifier:
                                       [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample] 
                                                                       asISBN:NO
                                                         managedObjectContext:backgroundThreadManagedObjectContext];
        if ([sampleBooks count] > 0) {
            NSMutableArray *sampleBooksObject = [NSMutableArray arrayWithCapacity:[sampleBooks count]];
            
            for (SCHUserContentItem *item in sampleBooks) {
                SCHContentMetadataItem *contentMetadateItem = [[item ContentMetadataItem] anyObject];
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
            
            [self syncRecommendationISBNs:sampleBooksObject 
                     managedObjectContext:backgroundThreadManagedObjectContext];  
            
            [self saveWithManagedObjectContext:backgroundThreadManagedObjectContext];
        }
        [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    });
}

- (BOOL)retrieveProfiles:(NSArray *)profileAges
{
    BOOL ret = NO;
    
    if ([profileAges count] > 0) {        
        self.isSynchronizing = [self.recommendationWebService retrieveRecommendationsForProfileWithAges:profileAges];
        ret = self.isSynchronizing;
    }
    
    return ret;
}

- (NSMutableArray *)removeBatchItemsFrom:(NSMutableArray *)items
{
    NSMutableArray *ret = nil;
    
    if ([items count] > kSCHRecommendationWebServiceMaxRequestItems) {
        NSRange remainingItems = NSMakeRange(kSCHRecommendationWebServiceMaxRequestItems, 
                                             [items count] - kSCHRecommendationWebServiceMaxRequestItems);
        ret = [NSMutableArray arrayWithArray:[items subarrayWithRange:remainingItems]];
        [items removeObjectsInRange:remainingItems];
    }   
    
    return ret;
}

#pragma - Information retrieval methods

- (NSMutableArray *)localFilteredProfiles
{
    NSMutableArray *allProfileAges = nil;
    NSMutableArray *filteredProfileAges = nil;    
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
        allProfileAges = [NSMutableArray arrayWithCapacity:[results count]];
        filteredProfileAges = [NSMutableArray arrayWithCapacity:[results count]];        
        for (SCHProfileItem *item in results) {
            SCHRecommendationProfile *profile = [[item AppProfile] recommendationProfile];
            NSDate *nextUpdate = [profile.fetchDate dateByAddingTimeInterval:kSCHRecommendationSyncComponentProfileSyncDelayTimeInterval];
            NSNumber *age = [NSNumber numberWithUnsignedInteger:[item age]]; 
            
            if ([allProfileAges containsObject:age] == NO) {
                [allProfileAges addObject:age];
            }
            
            if (profile == nil || 
                nextUpdate == nil ||
                [[NSDate date] earlierDate:nextUpdate] == nextUpdate) {
                if ([filteredProfileAges containsObject:age] == NO) {
                    [filteredProfileAges addObject:age];
                }
            }
        }                
    }
	[fetchRequest release], fetchRequest = nil;
     
    [self deleteUnusedProfileAges:allProfileAges];
    
	return(filteredProfileAges);
}

// drmQualifier = nil for all books
- (NSMutableArray *)localFilteredBooksForDRMQualifier:(NSNumber *)drmQualifier 
                                               asISBN:(BOOL)asISBN
                                 managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSMutableArray *ret = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
                                        inManagedObjectContext:aManagedObjectContext]];	
    // we only want books that are on a bookshelf
    if (drmQualifier == nil) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileList.@count > 0"]];    
    } else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileList.@count > 0 AND DRMQualifier = %@", drmQualifier]];            
    }
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];
	
    NSError *error = nil;
	NSArray *results = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (results == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        // only return those items that require updating
        ret = [NSMutableArray arrayWithCapacity:[results count]];
        for (SCHUserContentItem *item in results) {
            NSSet *contentMetadataItems = [item ContentMetadataItem];            
            SCHRecommendationISBN *isbn = nil;
            if ([contentMetadataItems count] > 0) {
                // it's a book to book relationship so only 1 book in the set
                SCHContentMetadataItem *contentMetadataItem = [contentMetadataItems anyObject];
                isbn = [contentMetadataItem.AppBook recommendationISBN];
            }
            NSDate *nextUpdate = [isbn.fetchDate dateByAddingTimeInterval:kSCHRecommendationSyncComponentBookSyncDelayTimeInterval];
            
            if (isbn == nil || 
                nextUpdate == nil ||
                [[NSDate date] earlierDate:nextUpdate] == nextUpdate) {
                if (asISBN == YES) {
                    NSString *isbn = [self makeNullNil:[item valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
                    if (isbn != nil && [ret containsObject:isbn] == NO) {
                        [ret addObject:isbn];
                    }
                } else {
                    [ret addObject:item];                    
                }
            }
        }                    
    }
	[fetchRequest release], fetchRequest = nil;
    

	return(ret);
}

- (NSArray *)localRecommendationProfilesWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationProfile
                                        inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceAge ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	[fetchRequest release], fetchRequest = nil;
    
	return(ret);
}

- (NSArray *)localRecommendationISBNsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationISBN 
                                        inManagedObjectContext:aManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceISBN ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	[fetchRequest release], fetchRequest = nil;
    
	return(ret);
}

#pragma - Syncing methods

// the sync can provide partial results so we don't delete here - we leave that to
// localFilteredProfiles:
- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles
              managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSDate *syncDate = [NSDate date];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationProfiles = [webRecommendationProfiles sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceAge ascending:YES]]];		
	NSArray *localRecommendationProfilesArray = [self localRecommendationProfilesWithManagedObjectContext:aManagedObjectContext];
    
	NSEnumerator *webEnumerator = [webRecommendationProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localRecommendationProfilesArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHRecommendationProfile *localItem = [localEnumerator nextObject];
	
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
		
        if (webItemID == nil || [self recommendationProfileIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncRecommendationProfile:webItem 
                          withRecommendationProfile:localItem 
                                           syncDate:syncDate
                               managedObjectContext:aManagedObjectContext];
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
                           syncDate:syncDate
               managedObjectContext:aManagedObjectContext];
	}
    
	[self saveWithManagedObjectContext:aManagedObjectContext];    
}

- (BOOL)recommendationProfileIDIsValid:(NSNumber *)recommendationProfileID
{
    return [recommendationProfileID integerValue] > 0;
}

- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)webRecommendationProfile
                                           syncDate:(NSDate *)syncDate
                               managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHRecommendationProfile *ret = nil;
	id recommendationProfileID =  [self makeNullNil:[webRecommendationProfile valueForKey:kSCHRecommendationWebServiceAge]];

	if (webRecommendationProfile != nil && [self recommendationProfileIDIsValid:recommendationProfileID] == YES) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationProfile 
                                            inManagedObjectContext:aManagedObjectContext];			
        
        ret.age = recommendationProfileID;
        ret.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret
                 managedObjectContext:aManagedObjectContext];            
    }
	
	return ret;
}

- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHRecommendationProfile *)localRecommendationProfile
                         syncDate:(NSDate *)syncDate
             managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (webRecommendationProfile != nil) {
        localRecommendationProfile.age = [self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceAge]];
        localRecommendationProfile.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:localRecommendationProfile.recommendationItems
                           insertInto:localRecommendationProfile
                 managedObjectContext:aManagedObjectContext];
    }
}

// the sync can provide partial results so we don't delete here - we leave that to
// the book sync
- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs 
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSDate *syncDate = [NSDate date];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationISBNs = [webRecommendationISBNs sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceISBN ascending:YES]]];		
	NSArray *localRecommendationISBNsArray = [self localRecommendationISBNsWithManagedObjectContext:aManagedObjectContext];
    
	NSEnumerator *webEnumerator = [webRecommendationISBNs objectEnumerator];			  
	NSEnumerator *localEnumerator = [localRecommendationISBNsArray objectEnumerator];			  			  
    
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHRecommendationISBN *localItem = [localEnumerator nextObject];
	
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
				
        SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:[self makeNullNil:[webItem objectForKey:kSCHRecommendationWebServiceISBN]]
                                                                          DRMQualifier:[self makeNullNil:[webItem objectForKey:kSCHRecommendationWebServiceDRMQualifier]]];            
        SCHBookIdentifier *localBookIdentifier = localItem.bookIdentifier;
        
        if (webBookIdentifier == nil) {
            webItem = nil;
        } else if (localBookIdentifier == nil) {
            localItem = nil;
        } else {
            switch ([webBookIdentifier compare:localBookIdentifier]) {
                case NSOrderedSame:
                    [self syncRecommendationISBN:webItem 
                          withRecommendationISBN:localItem 
                                        syncDate:syncDate
                            managedObjectContext:aManagedObjectContext];
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
		
        [webBookIdentifier release];
        
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
        
	for (NSDictionary *webItem in creationPool) {
        [self recommendationISBN:webItem 
                        syncDate:syncDate
            managedObjectContext:aManagedObjectContext];
	}
    
	[self saveWithManagedObjectContext:aManagedObjectContext];    
}

- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate
                         managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHRecommendationISBN *ret = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]]
                                                                                        DRMQualifier:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceDRMQualifier]]];    
    
	if (webRecommendationISBN != nil && webRecommendationISBN != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationISBN 
                                            inManagedObjectContext:aManagedObjectContext];			
        
        ret.isbn = webBookIdentifier.isbn;
        ret.DRMQualifier = webBookIdentifier.DRMQualifier;        
        ret.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret
         managedObjectContext:aManagedObjectContext];            
    }
    [webBookIdentifier release], webBookIdentifier = nil;
    
	return ret;
}

- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHRecommendationISBN *)localRecommendationISBN
                      syncDate:(NSDate *)syncDate
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (webRecommendationISBN != nil) {
        localRecommendationISBN.isbn = [self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]];
        localRecommendationISBN.DRMQualifier = [self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceDRMQualifier]];        
        localRecommendationISBN.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:localRecommendationISBN.recommendationItems
                           insertInto:localRecommendationISBN
                 managedObjectContext:aManagedObjectContext];
    }
}

- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
               insertInto:(id)recommendation
           managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationItems = [webRecommendationItems sortedArrayUsingDescriptors:
                              [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceProductCode 
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
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHRecommendationWebServiceProductCode]];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceProductCode];
		
        if (webItemID == nil || [self recommendationItemIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncRecommendationItem:webItem withRecommendationItem:localItem];
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
    
    if ([deletePool count] > 0) {
        NSMutableArray *deletedISBNs = [NSMutableArray arrayWithCapacity:[deletePool count]];
        for (SCHRecommendationItem *item in deletePool) {
            NSString *isbn = item.product_code;
            if (isbn != nil) {
                [deletedISBNs addObject:isbn];
            }
        }
        if ([deletedISBNs count] > 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentWillDeleteNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:deletedISBNs]
                                                                                                       forKey:SCHRecommendationSyncComponentISBNs]];
            });
        }        
        for (SCHRecommendationItem *recommendationItem in deletePool) {
            [aManagedObjectContext deleteObject:recommendationItem];
        }                        
    }
      
    if ([creationPool count] > 0) {
        NSMutableArray *insertedISBNs = [NSMutableArray arrayWithCapacity:[creationPool count]];
        for (NSDictionary *webItem in creationPool) {
            SCHRecommendationItem *recommendationItem = [self recommendationItem:webItem managedObjectContext:aManagedObjectContext];
            if (recommendationItem != nil) {
                NSString *isbn = recommendationItem.product_code;
                if (isbn != nil) {
                    [insertedISBNs addObject:isbn];
                }
                [recommendation addRecommendationItemsObject:recommendationItem];
            }
        }
        
        if ([insertedISBNs count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentDidInsertNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:insertedISBNs]
                                                                                                       forKey:SCHRecommendationSyncComponentISBNs]];
            });
        } 
    }
    
	[self saveWithManagedObjectContext:aManagedObjectContext];    
}

- (BOOL)recommendationItemIDIsValid:(NSString *)recommendationItemID
{
    return [[recommendationItemID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem 
                         managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHRecommendationItem *ret = nil;
	id recommendationItemID = [self makeNullNil:[webRecommendationItem valueForKey:kSCHRecommendationWebServiceProductCode]];
    
	if (webRecommendationItem != nil && [self recommendationItemIDIsValid:recommendationItemID] == YES) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationItem 
                                            inManagedObjectContext:aManagedObjectContext];			
        
        ret.name = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceName]];
        ret.link = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceLink]];
        ret.image_link = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceImageLink]];
        ret.regular_price = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceRegularPrice]];
        ret.sale_price = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceSalePrice]];        
        ret.product_code = recommendationItemID;
        ret.format = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceFormat]];                        
        ret.author = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceAuthor]];                                
        ret.order = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceOrder]];                                        
        
        [ret assignAppRecommendationItem];        
	}
	
	return ret;
}

- (void)syncRecommendationItem:(NSDictionary *)webRecommendationItem 
        withRecommendationItem:(SCHRecommendationItem *)localRecommendationItem
{
    if (webRecommendationItem != nil) {
        localRecommendationItem.name = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceName]];
        localRecommendationItem.link = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceLink]];
        localRecommendationItem.image_link = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceImageLink]];
        localRecommendationItem.regular_price = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceRegularPrice]];
        localRecommendationItem.sale_price = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceSalePrice]];        
        localRecommendationItem.product_code = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceProductCode]];                
        localRecommendationItem.format = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceFormat]];                        
        localRecommendationItem.author = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceAuthor]];                                
        localRecommendationItem.order = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceOrder]];                                        
    }
}

- (void)deleteUnusedProfileAges:(NSArray *)profileAges
{
    if ([profileAges count] > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
        NSError *error = nil;    
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationProfile
                                            inManagedObjectContext:self.managedObjectContext]];
        
        NSArray *recommendationProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                                                   error:&error];
        [fetchRequest release], fetchRequest = nil;
        if (recommendationProfiles == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            for (SCHRecommendationProfile *profile in recommendationProfiles) {
                if ([profileAges containsObject:profile.age] == NO) {
                    NSMutableArray *deletedISBNs = [NSMutableArray array];
                    for (SCHRecommendationItem *item in profile.recommendationItems) {
                        NSString *isbn = item.product_code;
                        if (isbn != nil) {
                            [deletedISBNs addObject:isbn];
                        }
                    }
                    if ([deletedISBNs count] > 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentWillDeleteNotification 
                                                                            object:self 
                                                                          userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:deletedISBNs]
                                                                                                               forKey:SCHRecommendationSyncComponentISBNs]];
                        
                    }                       
                    [self.managedObjectContext deleteObject:profile];
                }
            }   
            [self saveWithManagedObjectContext:self.managedObjectContext];            
        }        
    }
}

@end
