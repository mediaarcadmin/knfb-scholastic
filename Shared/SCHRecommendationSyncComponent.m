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
#import "SCHContentMetadataItem.h"
#import "SCHAppRecommendationItem.h"
#import "SCHRetrieveRecommendationsForProfileOperation.h"
#import "SCHRetrieveRecommendationsForBooksOperation.h"
#import "SCHRetrieveSampleBooksOperation.h"

// Constants
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
- (BOOL)recommendationItemIDIsValid:(NSString *)recommendationItemID;
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
            SCHRetrieveSampleBooksOperation *operation = [[[SCHRetrieveSampleBooksOperation alloc] initWithSyncComponent:self
                                                                                                                  result:nil
                                                                                                                userInfo:nil] autorelease];
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];    
            
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
        if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile] == YES) {
            SCHRetrieveRecommendationsForProfileOperation *operation = [[[SCHRetrieveRecommendationsForProfileOperation alloc] initWithSyncComponent:self
                                                                                                                                              result:result
                                                                                                                                            userInfo:userInfo] autorelease];
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];
        } else if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks] == YES) {
            SCHRetrieveRecommendationsForBooksOperation *operation = [[[SCHRetrieveRecommendationsForBooksOperation alloc] initWithSyncComponent:self
                                                                                                                                          result:result
                                                                                                                                        userInfo:userInfo] autorelease];
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];
        } else {
            [self completeWithSuccessMethod:method 
                                     result:result 
                                   userInfo:userInfo 
                           notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                       notificationUserInfo:nil];
        }
}

- (void)retrieveRecommendationsForProfileCompletionResult:(NSDictionary *)result 
                                                 userInfo:(NSDictionary *)userInfo
{
    if (self.saveOnly == NO) {
        if ([self.remainingBatchedItems count] > 0) {
            NSMutableArray *remainingProfiles = [self removeBatchItemsFrom:self.remainingBatchedItems];
            [self retrieveProfiles:self.remainingBatchedItems];  
            self.remainingBatchedItems = remainingProfiles;                    
        } else {
            SCHRetrieveSampleBooksOperation *operation = [[[SCHRetrieveSampleBooksOperation alloc] initWithSyncComponent:self
                                                                                                                  result:nil
                                                                                                                userInfo:nil] autorelease];
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];    
            
            NSMutableArray *books = [self localFilteredBooksForDRMQualifier:
                                     [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM] 
                                                                     asISBN:YES
                                                       managedObjectContext:self.managedObjectContext];
            
            if ([books count] > 0) {
                self.remainingBatchedItems = [self removeBatchItemsFrom:books];
                [self retrieveBooks:books];
            } else {
                [self completeWithSuccessMethod:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile 
                                         result:result 
                                       userInfo:userInfo 
                               notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                           notificationUserInfo:nil];
            }
        }
    } else {
        [self completeWithSuccessMethod:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile 
                                 result:result 
                               userInfo:userInfo 
                       notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                   notificationUserInfo:nil];
    }            
}

- (void)retrieveRecommendationsForBooksResult:(NSDictionary *)result 
                                     userInfo:(NSDictionary *)userInfo
{
    if ([self.remainingBatchedItems count] > 0) {
        NSMutableArray *remainingBooks = [self removeBatchItemsFrom:self.remainingBatchedItems];
        [self retrieveBooks:self.remainingBatchedItems];                    
        self.remainingBatchedItems = remainingBooks;                
    } else {
        [self completeWithSuccessMethod:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks 
                                 result:result 
                               userInfo:userInfo 
                       notificationName:SCHRecommendationSyncComponentDidCompleteNotification 
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

#pragma - Syncing methods

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
    
    for (SCHRecommendationItem *recommendationItem in deletePool) {
        [aManagedObjectContext deleteObject:recommendationItem];
    }                        
      
    for (NSDictionary *webItem in creationPool) {
        SCHRecommendationItem *recommendationItem = [self recommendationItem:webItem managedObjectContext:aManagedObjectContext];
        if (recommendationItem != nil) {
            [recommendation addRecommendationItemsObject:recommendationItem];
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
                    [self.managedObjectContext deleteObject:profile];
                }
            }   
            [self saveWithManagedObjectContext:self.managedObjectContext];            
        }        
    }
}

@end
