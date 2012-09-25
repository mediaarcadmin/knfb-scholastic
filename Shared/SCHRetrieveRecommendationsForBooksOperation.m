//
//  SCHRetrieveRecommendationsForBooksOperation.m
//  Scholastic
//
//  Created by John Eddie on 25/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRetrieveRecommendationsForBooksOperation.h"

#import "SCHRecommendationSyncComponent.h"
#import "SCHRecommendationWebService.h"
#import "SCHAppRecommendationISBN.h"
#import "SCHLibreAccessConstants.h"
#import "SCHRecommendationConstants.h"
#import "BITAPIError.h" 
#import "SCHBookIdentifier.h"
#import "SCHProfileSyncComponent.h"
#import "SCHMakeNullNil.h"

@interface SCHRetrieveRecommendationsForBooksOperation ()

- (NSArray *)localRecommendationISBNsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHAppRecommendationISBN *)localRecommendationISBN
                      syncDate:(NSDate *)syncDate
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHAppRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate
                         managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

@end

@implementation SCHRetrieveRecommendationsForBooksOperation

- (void)main
{
    @try {
        NSArray *books = makeNullNil([self.result objectForKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks]);
        if ([books count] > 0) { 
            [self syncRecommendationISBNs:books 
                     managedObjectContext:self.backgroundThreadManagedObjectContext];            
        }            
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCancelled == NO) {
                [(SCHRecommendationSyncComponent *)self.syncComponent retrieveRecommendationsForBooksResult:self.result 
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
                [self.syncComponent completeWithFailureMethod:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks 
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
	SCHAppRecommendationISBN *localItem = [localEnumerator nextObject];
	
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
        
        SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:makeNullNil([webItem objectForKey:kSCHRecommendationWebServiceISBN])
                                                                          DRMQualifier:makeNullNil([webItem objectForKey:kSCHRecommendationWebServiceDRMQualifier])];
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

- (NSArray *)localRecommendationISBNsWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAppRecommendationISBN
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

- (void)syncRecommendationISBN:(NSDictionary *)webRecommendationISBN 
        withRecommendationISBN:(SCHAppRecommendationISBN *)localRecommendationISBN
                      syncDate:(NSDate *)syncDate
          managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (webRecommendationISBN != nil) {
        localRecommendationISBN.isbn = makeNullNil([webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN]);
        localRecommendationISBN.DRMQualifier = makeNullNil([webRecommendationISBN objectForKey:kSCHRecommendationWebServiceDRMQualifier]);
        localRecommendationISBN.fetchDate = syncDate;
        
        [(SCHRecommendationSyncComponent *)self.syncComponent syncRecommendationItems:makeNullNil([webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems])
              withRecommendationItems:localRecommendationISBN.recommendationItems
                           insertInto:localRecommendationISBN
                 managedObjectContext:aManagedObjectContext];
    }
}

- (SCHAppRecommendationISBN *)recommendationISBN:(NSDictionary *)webRecommendationISBN
                                     syncDate:(NSDate *)syncDate
                         managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	SCHAppRecommendationISBN *ret = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:makeNullNil([webRecommendationISBN objectForKey:kSCHRecommendationWebServiceISBN])
                                                                      DRMQualifier:makeNullNil([webRecommendationISBN objectForKey:kSCHRecommendationWebServiceDRMQualifier])];
    
	if (webRecommendationISBN != nil && webRecommendationISBN != nil) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppRecommendationISBN
                                            inManagedObjectContext:aManagedObjectContext];			
        
        ret.isbn = webBookIdentifier.isbn;
        ret.DRMQualifier = webBookIdentifier.DRMQualifier;        
        ret.fetchDate = syncDate;
        
        [(SCHRecommendationSyncComponent *)self.syncComponent syncRecommendationItems:makeNullNil([webRecommendationISBN objectForKey:kSCHRecommendationWebServiceItems])
                                                              withRecommendationItems:ret.recommendationItems
                                                                           insertInto:ret
                                                                 managedObjectContext:aManagedObjectContext];            
    }
    [webBookIdentifier release], webBookIdentifier = nil;
    
	return ret;
}

@end
