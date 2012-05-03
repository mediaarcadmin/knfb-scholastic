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
- (void)completeWithSuccess:(NSString *)method 
                     result:(NSDictionary *)result 
                   userInfo:(NSDictionary *)userInfo;
- (void)completeWithFailure:(NSString *)method 
                      error:(NSError *)error 
                requestInfo:(NSDictionary *)requestInfo 
                     result:(NSDictionary *)result;
- (BOOL)retrieveBooks:(NSArray *)books;
- (BOOL)retrieveProfiles:(NSArray *)profiles;
- (NSMutableArray *)removeBatchItemsFrom:(NSMutableArray *)items;
- (NSMutableArray *)localFilteredProfiles;
- (NSMutableArray *)localFilteredBooks;
- (NSArray *)localRecommendationProfiles;
- (NSArray *)localRecommendationISBNs;
- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles;
- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)recommendationProfile
                                           syncDate:(NSDate *)syncDate;
- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHRecommendationProfile *)localRecommendationProfile
                         syncDate:(NSDate *)syncDate;
- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs;
- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate;
- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHRecommendationISBN *)localRecommendationISBN
                      syncDate:(NSDate *)syncDate;
- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
                     insertInto:(id)recommendation;
- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem;
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
            NSMutableArray *books = [self localFilteredBooks];
            
            if ([books count] > 0) {
                self.remainingBatchedItems = [self removeBatchItemsFrom:books];
                ret = [self retrieveBooks:books];
            } else {
                [self completeWithSuccess:nil result:nil userInfo:nil];
            }
        } else {
            [self completeWithSuccess:nil result:nil userInfo:nil];
        }
    } else {
        [self completeWithSuccess:nil result:nil userInfo:nil];
    }
    
    return  ret;
}

- (void)completeWithSuccess:(NSString *)method 
                     result:(NSDictionary *)result 
                   userInfo:(NSDictionary *)userInfo
{
    self.remainingBatchedItems = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentDidCompleteNotification 
                                                        object:self 
                                                      userInfo:nil];                
    [super method:nil didCompleteWithResult:result userInfo:userInfo];                                
}

- (void)completeWithFailure:(NSString *)method 
                      error:(NSError *)error 
                requestInfo:(NSDictionary *)requestInfo 
                     result:(NSDictionary *)result
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentDidFailNotification 
                                                        object:self];        
    self.remainingBatchedItems = nil;
    [super method:method 
 didFailWithError:error 
      requestInfo:requestInfo 
           result:result];    
}

#pragma - Web Service delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    @try {        
        if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile] == YES) {
            NSArray *profiles = [self makeNullNil:[result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile]];
            if ([profiles count] > 0) {
                [self syncRecommendationProfiles:profiles];                        
            }
            
            if (self.saveOnly == NO) {
                if ([self.remainingBatchedItems count] > 0) {
                    NSMutableArray *remainingProfiles = [self removeBatchItemsFrom:self.remainingBatchedItems];
                    [self retrieveProfiles:self.remainingBatchedItems];  
                    self.remainingBatchedItems = remainingProfiles;                    
                } else {
                    NSMutableArray *books = [self localFilteredBooks];
                    
                    if ([books count] > 0) {
                        self.remainingBatchedItems = [self removeBatchItemsFrom:books];
                        [self retrieveBooks:books];
                    } else {
                        [self completeWithSuccess:method result:result userInfo:userInfo];
                    }
                }
            } else {
                [self completeWithSuccess:method result:result userInfo:userInfo];                
            }            
        } else if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks] == YES) {
            NSArray *books = [self makeNullNil:[result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks]];
            if ([books count] > 0) { 
                [self syncRecommendationISBNs:books];            
            }            
            
            if ([self.remainingBatchedItems count] > 0) {
                NSMutableArray *remainingBooks = [self removeBatchItemsFrom:self.remainingBatchedItems];
                [self retrieveBooks:self.remainingBatchedItems];                    
                self.remainingBatchedItems = remainingBooks;                
            } else {
                [self completeWithSuccess:method result:result userInfo:userInfo];
            }
        } else {
            [self completeWithSuccess:method result:result userInfo:userInfo];            
        }
    } 
    @catch (NSException *exception) {
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [self completeWithFailure:method error:error requestInfo:nil 
                           result:result];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [self completeWithFailure:method error:error requestInfo:requestInfo 
                       result:result];
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

- (NSMutableArray *)localFilteredBooks
{
    NSMutableArray *isbns = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    // we only want books that are on a bookshelf
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileList.@count > 0"]];    
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];
	
    NSError *error = nil;
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (results == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        // only return those items that require updating
        isbns = [NSMutableArray arrayWithCapacity:[results count]];
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
                NSString *isbn = [self makeNullNil:[item valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
                if (isbn != nil && [isbns containsObject:isbn] == NO) {
                    [isbns addObject:isbn];
                }
            }
        }                    
    }
	[fetchRequest release], fetchRequest = nil;
    

	return(isbns);
}

- (NSArray *)localRecommendationProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationProfile
                                        inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceAge ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	[fetchRequest release], fetchRequest = nil;
    
	return(ret);
}

- (NSArray *)localRecommendationISBNs
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHRecommendationISBN 
                                        inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceISBN ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
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
{
    NSDate *syncDate = [NSDate date];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationProfiles = [webRecommendationProfiles sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceAge ascending:YES]]];		
	NSArray *localRecommendationProfilesArray = [self localRecommendationProfiles];
    
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
                          withRecommendationProfile:localItem syncDate:syncDate];
                    [self save];
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
        [self recommendationProfile:webItem syncDate:syncDate];
        [self save];
	}
    
	[self save];    
}

- (BOOL)recommendationProfileIDIsValid:(NSNumber *)recommendationProfileID
{
    return [recommendationProfileID integerValue] > 0;
}

- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)webRecommendationProfile
                                           syncDate:(NSDate *)syncDate
{
	SCHRecommendationProfile *ret = nil;
	id recommendationProfileID =  [self makeNullNil:[webRecommendationProfile valueForKey:kSCHRecommendationWebServiceAge]];

	if (webRecommendationProfile != nil && [self recommendationProfileIDIsValid:recommendationProfileID] == YES) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationProfile 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.age = recommendationProfileID;
        ret.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];            
    }
	
	return ret;
}

- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHRecommendationProfile *)localRecommendationProfile
                         syncDate:(NSDate *)syncDate
{
    if (webRecommendationProfile != nil) {
        localRecommendationProfile.age = [self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceAge]];
        localRecommendationProfile.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:localRecommendationProfile.recommendationItems
                     insertInto:localRecommendationProfile];
    }
}

// the sync can provide partial results so we don't delete here - we leave that to
// the book sync
- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs
{
    NSDate *syncDate = [NSDate date];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationISBNs = [webRecommendationISBNs sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceISBN ascending:YES]]];		
	NSArray *localRecommendationISBNsArray = [self localRecommendationISBNs];
    
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
		
        id webItemID = [self makeNullNil:[webItem valueForKey:kSCHRecommendationWebServiceISBN]];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceISBN];
		
        if (webItemID == nil || [self recommendationISBNIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncRecommendationISBN:webItem 
                          withRecommendationISBN:localItem syncDate:syncDate];
                    [self save];
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
        [self recommendationISBN:webItem syncDate:syncDate];
        [self save];
	}
    
	[self save];    
}

- (BOOL)recommendationISBNIDIsValid:(NSString *)recommendationISBNID
{
    return [[recommendationISBNID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate
{
	SCHRecommendationISBN *ret = nil;
	id recommendationISBNID = [self makeNullNil:[webRecommendationISBN valueForKey:kSCHRecommendationWebServiceISBN]];
    
	if (webRecommendationISBN != nil && [self recommendationISBNIDIsValid:recommendationISBNID] == YES) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationISBN 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.isbn = recommendationISBNID;
        ret.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];            
    }
	
	return ret;
}

- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHRecommendationISBN *)localRecommendationISBN
                      syncDate:(NSDate *)syncDate
{
    if (webRecommendationISBN != nil) {
        localRecommendationISBN.isbn = [self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]];
        localRecommendationISBN.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:localRecommendationISBN.recommendationItems
                           insertInto:localRecommendationISBN];
    }
}

- (void)syncRecommendationItems:(NSArray *)webRecommendationItems
        withRecommendationItems:(NSSet *)localRecommendationItems
               insertInto:(id)recommendation
{
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	webRecommendationItems = [webRecommendationItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceProductCode ascending:YES]]];		
	NSArray *localRecommendationItemsArray = [localRecommendationItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHRecommendationWebServiceProductCode ascending:YES]]];
    
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
                    [self save];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentWillDeleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:deletedISBNs]
                                                                                                   forKey:SCHRecommendationSyncComponentISBNs]];
        }        
        for (SCHRecommendationItem *recommendationItem in deletePool) {
            [self.managedObjectContext deleteObject:recommendationItem];
        }                        
    }
      
    if ([creationPool count] > 0) {
        NSMutableArray *insertedISBNs = [NSMutableArray arrayWithCapacity:[creationPool count]];
        for (NSDictionary *webItem in creationPool) {
            SCHRecommendationItem *recommendationItem = [self recommendationItem:webItem];
            if (recommendationItem != nil) {
                NSString *isbn = recommendationItem.product_code;
                if (isbn != nil) {
                    [insertedISBNs addObject:isbn];
                }
                [recommendation addRecommendationItemsObject:recommendationItem];
            }
        }
        
        [self save];
        
        if ([insertedISBNs count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentDidInsertNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:insertedISBNs]
                                                                                                   forKey:SCHRecommendationSyncComponentISBNs]];
        } 
    }
    
	[self save];    
}

- (BOOL)recommendationItemIDIsValid:(NSString *)recommendationItemID
{
    return [[recommendationItemID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem
{
	SCHRecommendationItem *ret = nil;
	id recommendationItemID = [self makeNullNil:[webRecommendationItem valueForKey:kSCHRecommendationWebServiceProductCode]];
    
	if (webRecommendationItem != nil && [self recommendationItemIDIsValid:recommendationItemID] == YES) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationItem 
                                            inManagedObjectContext:self.managedObjectContext];			
        
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
                    [self save];
                }
            }   
        }        
    }
}

@end
