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

// Constants
NSString * const SCHRecommendationSyncComponentDidCompleteNotification = @"SCHRecommendationSyncComponentDidCompleteNotification";
NSString * const SCHRecommendationSyncComponentDidFailNotification = @"SCHRecommendationSyncComponentDidFailNotification";

@interface SCHRecommendationSyncComponent ()

@property (nonatomic, retain) SCHRecommendationWebService *recommendationWebService;

- (BOOL)updateRecommendations;
- (NSArray *)localProfiles;
- (NSArray *)localBooks;
- (NSArray *)localRecommendationProfiles;
- (NSArray *)localRecommendationISBNs;
- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles;
- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)recommendationProfile;
- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHRecommendationProfile *)localRecommendationProfile;
- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs;
- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN;
- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHRecommendationISBN *)localRecommendationISBN;
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

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    NSLog(@"%@", result);

    NSArray *books = [result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks];
    [self syncRecommendationISBNs:books];

//    NSArray *profiles = [result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile];
//    [self syncRecommendationProfiles:profiles];
    
//    @try {
//        [self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidCompleteNotification object:self];			
//        [super method:method didCompleteWithResult:nil userInfo:userInfo];	
//    }
//    @catch (NSException *exception) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidFailNotification 
//                                                            object:self];        
//        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
//                                             code:kBITAPIExceptionError 
//                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
//                                                                              forKey:NSLocalizedDescriptionKey]];
//        [super method:method didFailWithError:error requestInfo:nil result:result];
//    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHRecommendationSyncComponentDidFailNotification 
                                                        object:self];        
    [super method:method didFailWithError:error requestInfo:requestInfo result:result];
}

// TODO: batch these buggers into 10s
- (BOOL)updateRecommendations
{	
    BOOL ret = YES;
    
    self.isSynchronizing = YES;
    NSArray *books = [self localBooks];
    
    if ([books count] > 0) {
        NSMutableArray *isbns = [NSMutableArray arrayWithCapacity:[books count]];
        for (id item in books) {
            NSString *isbn = [self makeNullNil:[item valueForKey:kSCHLibreAccessWebServiceContentIdentifier]];
            if (isbn != nil) {
                [isbns addObject:isbn];
            }
        }    
        
        [self.recommendationWebService retrieveRecommendationsForBooks:isbns];
        
    }

//    NSArray *profiles = [self localProfiles];
//    
//    if ([profiles count] > 0) {
//        NSMutableArray *profileIDs = [NSMutableArray arrayWithCapacity:[profiles count]];
//        for (SCHProfileItem *item in profiles) {
//            [profileIDs addObject:[NSNumber numberWithUnsignedInteger:[item age]]];
//        }    
//        
//        [self.recommendationWebService retrieveRecommendationsForProfileWithAges:profileIDs];
//    }
    
    return  ret;
}

- (NSArray *)localProfiles
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	[fetchRequest release], fetchRequest = nil;
    
	return(ret);
}

- (NSArray *)localBooks
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES]]];
	
    NSError *error = nil;
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	[fetchRequest release], fetchRequest = nil;
    
	return(ret);
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

- (void)syncRecommendationProfiles:(NSArray *)webRecommendationProfiles
{
	NSMutableArray *deletePool = [NSMutableArray array];
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
                          withRecommendationProfile:localItem];
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
    
    for (SCHRecommendationProfile *recommendationProfile in deletePool) {
        [self.managedObjectContext deleteObject:recommendationProfile];
        [self save];
    }                
    
	for (NSDictionary *webItem in creationPool) {
        [self recommendationProfile:webItem];
        [self save];
	}
    
	[self save];    
}

- (SCHRecommendationProfile *)recommendationProfile:(NSDictionary *)webRecommendationProfile
{
	SCHRecommendationProfile *ret = nil;
	
	if (webRecommendationProfile != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationProfile 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.age = [self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceAge]];
        ret.fetchDate = [NSDate date];
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];            
    }
	
	return(ret);
}

- (void)syncRecommendationProfile:(NSDictionary *)webRecommendationProfile 
        withRecommendationProfile:(SCHRecommendationProfile *)localRecommendationProfile
{
    if (webRecommendationProfile != nil) {
        localRecommendationProfile.age = [self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceAge]];
        localRecommendationProfile.fetchDate = [NSDate date];
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationProfile objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:localRecommendationProfile.recommendationItems
                     insertInto:localRecommendationProfile];
    }
}

- (void)syncRecommendationISBNs:(NSArray *)webRecommendationISBNs
{
	NSMutableArray *deletePool = [NSMutableArray array];
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
                          withRecommendationISBN:localItem];
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
    
    for (SCHRecommendationISBN *recommendationISBN in deletePool) {
        [self.managedObjectContext deleteObject:recommendationISBN];
        [self save];
    }                
    
	for (NSDictionary *webItem in creationPool) {
        [self recommendationISBN:webItem];
        [self save];
	}
    
	[self save];    
}

- (SCHRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
{
	SCHRecommendationISBN *ret = nil;
	
	if (webRecommendationISBN != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHRecommendationISBN 
                                            inManagedObjectContext:self.managedObjectContext];			
        
        ret.isbn = [self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]];
        ret.fetchDate = [NSDate date];
        
        [self syncRecommendationItems:[self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems]] 
              withRecommendationItems:ret.recommendationItems
                           insertInto:ret];            
    }
	
	return(ret);
}

- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHRecommendationISBN *)localRecommendationISBN
{
    if (webRecommendationISBN != nil) {
        localRecommendationISBN.isbn = [self makeNullNil:[webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]];
        localRecommendationISBN.fetchDate = [NSDate date];
        
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
