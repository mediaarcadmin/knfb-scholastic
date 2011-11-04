//
//  SCHBookshelfSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookshelfSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessConstants.h"
#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHAppBook.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHBookIdentifier.h"
#import "SCHReadingStatsContentItem.h"
#import "BITAPIError.h"

// Constants
NSString * const SCHBookshelfSyncComponentWillDeleteNotification = @"SCHBookshelfSyncComponentWillDeleteNotification";
NSString * const SCHBookshelfSyncComponentDeletedBookIdentifiers = @"SCHBookshelfSyncComponentDeletedBookIdentifiers";
NSString * const SCHBookshelfSyncComponentBookReceivedNotification = @"SCHBookshelfSyncComponentBookReceivedNotification";
NSString * const SCHBookshelfSyncComponentDidCompleteNotification = @"SCHBookshelfSyncComponentDidCompleteNotification";
NSString * const SCHBookshelfSyncComponentDidFailNotification = @"SCHBookshelfSyncComponentDidFailNotification";

@interface SCHBookshelfSyncComponent ()

- (void)postBookshelfSyncComponentBookReceivedNotification:(NSArray *)contentMetadataItems;
- (BOOL)updateContentMetadataItems;

- (NSArray *)localContentMetadataItems;
- (NSArray *)localUserContentItems;
- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier;
- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier;

@property (nonatomic, assign) NSInteger requestCount;
@property (nonatomic, assign) BOOL didReceiveFailedResponse;

@end

@implementation SCHBookshelfSyncComponent

@synthesize useIndividualRequests;
@synthesize requestCount;
@synthesize didReceiveFailedResponse;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.useIndividualRequests = YES;	
		self.requestCount = 0;
        self.didReceiveFailedResponse = NO;
	}
	return(self);
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.isSynchronizing = NO;
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		ret = [self updateContentMetadataItems];
	}
	
	return(ret);		
}

- (void)clear
{
    [super clear];
	NSError *error = nil;
    
    self.requestCount = 0;
    self.didReceiveFailedResponse = NO;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHContentMetadataItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
    @try {
        if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
            if (self.useIndividualRequests == YES) {
                self.requestCount--;
            }
            
            NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
            [self syncContentMetadataItems:list];
            
            if (self.useIndividualRequests == YES) {
                if ([list count] > 0) {
                    [self postBookshelfSyncComponentBookReceivedNotification:[NSArray arrayWithObject:[list objectAtIndex:0]]];
                }
                
                if (self.requestCount < 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                                        object:self];
                    [super method:method didCompleteWithResult:nil];				
                }
            } else {
                [self postBookshelfSyncComponentBookReceivedNotification:list];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                                    object:self];
                [super method:method didCompleteWithResult:nil];				
            }
        }
    }
    @catch (NSException *exception) {
        if (self.useIndividualRequests == YES) {
            self.didReceiveFailedResponse = YES;
            
            if (self.requestCount < 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidFailNotification 
                                                                    object:self];
                
                NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                     code:kBITAPIExceptionError 
                                                 userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                      forKey:NSLocalizedDescriptionKey]];
                [super method:method didFailWithError:error requestInfo:nil result:result];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidFailNotification 
                                                                object:self];        
            NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                                 code:kBITAPIExceptionError 
                                             userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                                  forKey:NSLocalizedDescriptionKey]];
            [super method:method didFailWithError:error requestInfo:nil result:result];            
        }            
    }
}

- (void)postBookshelfSyncComponentBookReceivedNotification:(NSArray *)contentMetadataItems
{
    NSMutableArray *bookIdentifiers = [NSMutableArray arrayWithCapacity:[contentMetadataItems count]];
    
    for (NSDictionary *book in contentMetadataItems) {
        @try {
            [bookIdentifiers addObject:[[[SCHBookIdentifier alloc] initWithObject:book] autorelease]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            // if any of the responses do not have the book identifier 
            // information then we just ignore them and continue
        }
    }
    
    if ([bookIdentifiers count] > 0) {
        NSLog(@"Book information received:\n%@", bookIdentifiers);
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentBookReceivedNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:bookIdentifiers forKey:@"bookIdentifiers"]];				
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
	if (self.useIndividualRequests == YES) {
		self.requestCount--;
        self.didReceiveFailedResponse = YES;
        
        if (self.requestCount < 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidFailNotification 
                                                                object:self];
            
            [super method:method didFailWithError:error requestInfo:requestInfo result:result];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidFailNotification 
                                                            object:self];
        
        [super method:method didFailWithError:error requestInfo:requestInfo result:result];
    }
}

- (BOOL)updateContentMetadataItems
{		
	BOOL ret = YES;

	NSMutableArray *results = [NSMutableArray array];

    // only update books we don't already have unless there is a Version change
    [[self localUserContentItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSSet *contentMetadataItems = (NSSet *)[obj ContentMetadataItem];
        
        if ([contentMetadataItems count] < 1 || 
            [[[contentMetadataItems anyObject] Version] integerValue] != [[obj Version] integerValue]) {
            [results addObject:obj];
        }
    }];

	self.requestCount = 0;
    self.didReceiveFailedResponse = NO;
	if([results count] > 0) {
		if (self.useIndividualRequests == YES) {
			for (NSDictionary *ISBN in results) {				
				self.isSynchronizing = [self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:ISBN] includeURLs:NO];
				if (self.isSynchronizing == NO) {
					[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(BOOL offlineMode){
                        if (!offlineMode) {
                            [self.delegate authenticationDidSucceed];
                        }
                    } failureBlock:nil];				
					ret = NO;			
				} else {
					requestCount++;
					NSLog(@"Requesting %@ Book information", [ISBN valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);					
				}
			}
		} else {			
			self.isSynchronizing = [self.libreAccessWebService listContentMetadata:results includeURLs:NO];
			if (self.isSynchronizing == NO) {
				[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(BOOL offlineMode){
                    if (!offlineMode) {
                        [self.delegate authenticationDidSucceed];
                    }
                } failureBlock:nil];			
				ret = NO;			
			} else {
				NSLog(@"Requesting ALL Book information");
			}
		}
	} else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                                                            object:self];
        
        [super method:nil didCompleteWithResult:nil];			
        
		ret = NO;
	}
	
	return(ret);	
}

- (NSArray *)localContentMetadataItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
	
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (NSArray *)localUserContentItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
    // we only want books that are on a bookshelf
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileList.@count > 0"]];    
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
               
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);
}

- (void)syncContentMetadataItems:(NSArray *)contentMetadataList
{		
	NSMutableArray *deletePool = [NSMutableArray array];    
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [contentMetadataList sortedArrayUsingDescriptors:
                            [NSArray arrayWithObjects:
                             [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                             nil]];		
	NSArray *localProfiles = [self localContentMetadataItems];
		
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  

	NSDictionary *webItem = [webEnumerator nextObject];
	SCHContentMetadataItem *localItem = [localEnumerator nextObject];
	
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
		
        SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webItem];
        SCHBookIdentifier *localBookIdentifier = localItem.bookIdentifier;
        
		switch ([webBookIdentifier compare:localBookIdentifier]) {
			case NSOrderedSame:
				[self syncContentMetadataItem:webItem withContentMetadataItem:localItem];
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
		
        [webBookIdentifier release], webBookIdentifier = nil;

		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
		
    if (self.useIndividualRequests == NO &&
        [deletePool count] > 0) {
        NSMutableArray *deletedBookIdentifiers = [NSMutableArray array];
        for (SCHContentMetadataItem *contentMetadataItem in deletePool) {
            [deletedBookIdentifiers addObject:[contentMetadataItem bookIdentifier]];            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHBookshelfSyncComponentWillDeleteNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:deletedBookIdentifiers 
                                                                                               forKey:SCHBookshelfSyncComponentDeletedBookIdentifiers]];        
        
        for (SCHContentMetadataItem *contentMetadataItem in deletePool) {
            [self deleteStatisticsForBook:[contentMetadataItem bookIdentifier]];
            [self deleteAnnotationsForBook:[contentMetadataItem bookIdentifier]];
            [self.managedObjectContext deleteObject:contentMetadataItem];
        }
    }
    
	for (NSDictionary *webItem in creationPool) {
		[self addContentMetadataItem:webItem];
	}
	
	[self save];
}

- (SCHContentMetadataItem *)addContentMetadataItem:(NSDictionary *)webContentMetadataItem
{
	SCHContentMetadataItem *newContentMetadataItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem inManagedObjectContext:self.managedObjectContext];
	
	newContentMetadataItem.DRMQualifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
	newContentMetadataItem.ContentIdentifierType = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
	newContentMetadataItem.ContentIdentifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
	
	newContentMetadataItem.Author = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]];
	newContentMetadataItem.Version = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]];
	newContentMetadataItem.Enhanced = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]];
	newContentMetadataItem.FileSize = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]];
	newContentMetadataItem.CoverURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]];
	newContentMetadataItem.ContentURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]];
	newContentMetadataItem.PageNumber = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]];
	newContentMetadataItem.Title = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]];
	newContentMetadataItem.Description = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]];
    
    newContentMetadataItem.AppBook = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook inManagedObjectContext:self.managedObjectContext];
    
    return(newContentMetadataItem);
}

- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem
{
    if (webContentMetadataItem != nil) {
        localContentMetadataItem.DRMQualifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
        localContentMetadataItem.ContentIdentifierType = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];
        localContentMetadataItem.ContentIdentifier = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        
        localContentMetadataItem.Author = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceAuthor]];
        localContentMetadataItem.Version = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceVersion]];
        localContentMetadataItem.Enhanced = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceEnhanced]];
        localContentMetadataItem.FileSize = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceFileSize]];
        NSString *coverURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceCoverURL]];
        if (coverURL != nil){
            localContentMetadataItem.CoverURL = coverURL;
        }
        NSString *contentURL = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentURL]];
        if (contentURL != nil) {
            localContentMetadataItem.ContentURL = contentURL;
        }
        localContentMetadataItem.PageNumber = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServicePageNumber]];
        localContentMetadataItem.Title = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceTitle]];
        localContentMetadataItem.Description = [self makeNullNil:[webContentMetadataItem objectForKey:kSCHLibreAccessWebServiceDescription]];
    }
}

- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)identifier
{
    NSError *error = nil;
    
    if (identifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHAnnotationsContentItem
                                                  inManagedObjectContext:self.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHAppBookFetchWithContentIdentifier 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObjectsAndKeys:
                                                               identifier.isbn, kSCHAppBookCONTENT_IDENTIFIER,
                                                               identifier.DRMQualifier, kSCHAppBookDRM_QUALIFIER,
                                                               nil]];
        NSArray *bookArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([bookArray count] > 0) {
            [self.managedObjectContext deleteObject:[bookArray objectAtIndex:0]];
        }
    }    
}

- (void)deleteStatisticsForBook:(SCHBookIdentifier *)identifier
{
    NSError *error = nil;
    
    if (identifier != nil) {
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHReadingStatsContentItem
                                                  inManagedObjectContext:self.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHReadingStatsContentItemFetchReadingStatsContentItemForBook 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObjectsAndKeys:
                                                               identifier.isbn, kSCHReadingStatsContentItemCONTENT_IDENTIFIER,
                                                               identifier.DRMQualifier, kSCHReadingStatsContentItemDRM_QUALIFIER,
                                                               nil]];
        NSArray *bookArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([bookArray count] > 0) {
            [self.managedObjectContext deleteObject:[bookArray objectAtIndex:0]];
        }
    }    
}

@end
