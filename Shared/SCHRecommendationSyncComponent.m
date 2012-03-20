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

// Constants
NSString * const SCHRecommendationSyncComponentDidCompleteNotification = @"SCHRecommendationSyncComponentDidCompleteNotification";
NSString * const SCHRecommendationSyncComponentDidFailNotification = @"SCHRecommendationSyncComponentDidFailNotification";

static NSTimeInterval const kSCHRecommendationSyncComponentProfileSyncDelayTimeInterval = 86400.0;  // 24h
static NSTimeInterval const kSCHRecommendationSyncComponentBookSyncDelayTimeInterval = 86400.0;  // 24h

@interface SCHRecommendationSyncComponent ()

@property (nonatomic, retain) SCHRecommendationWebService *recommendationWebService;

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
- (NSArray *)localFilteredProfiles;
- (NSArray *)localFilteredBooks;
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

@end

@implementation SCHRecommendationSyncComponent

@synthesize recommendationWebService;

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
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
            [self endBackgroundTask];
		}];
		
		ret = [self updateRecommendations];
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);		
}

- (void)clear
{
	NSError *error = nil;
	
    [self.recommendationWebService clear];
    
	if (![self.managedObjectContext BITemptyEntity:kSCHRecommendationProfile error:&error] ||
        ![self.managedObjectContext BITemptyEntity:kSCHRecommendationISBN error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

// TODO: batch these buggers into 10s
- (BOOL)updateRecommendations
{	
    BOOL ret = YES;

    if (self.saveOnly == NO) {
        NSArray *profiles = [self localFilteredProfiles];
        
        if ([profiles count] > 0) {
            ret = [self retrieveProfiles:profiles];
        } else if (self.saveOnly == NO) {
            NSArray *books = [self localFilteredBooks];
            
            if ([books count] > 0) {
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
    [super method:method 
 didFailWithError:error 
      requestInfo:requestInfo 
           result:result];    
}

#pragma - Web Service delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    NSLog(@"%@:didCompleteWithResult\n%@", method, result);
    
    @try {        
        if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile] == YES) {
            NSArray *profiles = [self makeNullNil:[result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile]];
            if ([profiles count] > 0) {
                [self syncRecommendationProfiles:profiles];                        
            }
            
            if (self.saveOnly == NO) {
                NSArray *books = [self localFilteredBooks];
                
                if ([books count] > 0) {
                    [self retrieveBooks:books];
                } else {
                    [self completeWithSuccess:method result:result userInfo:userInfo];
                }
            } else {
                [self completeWithSuccess:method result:result userInfo:userInfo];                
            }            
        } else if ([method isEqualToString:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks] == YES) {
            NSArray *books = [self makeNullNil:[result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks]];
            if ([books count] > 0) { 
                [self syncRecommendationISBNs:books];            
            }            
            
            [self completeWithSuccess:method result:result userInfo:userInfo];
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

#pragma - Information retrieval methods

- (NSArray *)localFilteredProfiles
{
    NSMutableArray *profileAges = nil;
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
        profileAges = [NSMutableArray arrayWithCapacity:[results count]];
        for (SCHProfileItem *item in results) {
            SCHRecommendationProfile *profile = [[item AppProfile] recommendationProfile];
            NSDate *nextUpdate = [profile.fetchDate dateByAddingTimeInterval:kSCHRecommendationSyncComponentProfileSyncDelayTimeInterval];
            
            if (profile == nil || 
                nextUpdate == nil ||
                [[NSDate date] earlierDate:nextUpdate] == nextUpdate) {
                NSNumber *age = [NSNumber numberWithUnsignedInteger:[item age]];
                if ([profileAges containsObject:age] == NO) {
                    [profileAges addObject:age];
                }    
            }
        }                
    }
	[fetchRequest release], fetchRequest = nil;
        
	return(profileAges);
}

- (NSArray *)localFilteredBooks
{
    NSMutableArray *isbns = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
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

// the sync can provide partial results so we don't delete
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
		
        id webItemID = [webItem valueForKey:kSCHRecommendationWebServiceAge];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceAge];
		
        if ((id)webItemID == [NSNull null]) {
            webItem = nil;
        } else if ((id)localItemID == [NSNull null]) {
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

- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)webRecommendationProfile
                                           syncDate:(NSDate *)syncDate
{
	SCHRecommendationProfile *ret = nil;
	
	if (webRecommendationProfile != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationProfile 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.age = [self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceAge]];
        ret.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];            
    }
	
	return(ret);
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
		
        id webItemID = [webItem valueForKey:kSCHRecommendationWebServiceISBN];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceISBN];
		
        if ((id)webItemID == [NSNull null]) {
            webItem = nil;
        } else if ((id)localItemID == [NSNull null]) {
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

- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate
{
	SCHRecommendationISBN *ret = nil;
	
	if (webRecommendationISBN != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationISBN 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.isbn = [self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]];
        ret.fetchDate = syncDate;
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];            
    }
	
	return(ret);
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
		
		id webItemID = [webItem valueForKey:kSCHRecommendationWebServiceProductCode];
		id localItemID = [localItem valueForKey:kSCHRecommendationWebServiceProductCode];
		
        if ((id)webItemID == [NSNull null]) {
            webItem = nil;
        } else if ((id)localItemID == [NSNull null]) {
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
    
    for (SCHRecommendationItem *recommendationItem in deletePool) {
        [self.managedObjectContext deleteObject:recommendationItem];
        [self save];
    }                
    
	for (NSDictionary *webItem in creationPool) {
        [recommendation addRecommendationItemsObject:[self recommendationItem:webItem]];
        [self save];
	}
    
	[self save];    
}

- (SCHRecommendationItem *)recommendationItem:(NSDictionary *)webRecommendationItem
{
	SCHRecommendationItem *ret = nil;
	
	if (webRecommendationItem != nil) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationItem 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.name = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceName]];
        ret.link = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceLink]];
        ret.image_link = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceImageLink]];
        ret.regular_price = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceRegularPrice]];
        ret.sale_price = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceSalePrice]];        
        ret.product_code = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceProductCode]];                
        ret.format = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceFormat]];                        
        ret.author = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceAuthor]];                                
        ret.order = [self makeNullNil:[webRecommendationItem objectForKey:kSCHRecommendationWebServiceOrder]];                                        
	}
	
	return(ret);
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

@end
