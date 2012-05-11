//
//  SCHContentSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHContentSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHUserContentItem.h"
#import "SCHOrderItem.h"
#import "SCHContentProfileItem.h"
#import "SCHProfileItem.h"
#import "SCHAnnotationsItem.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHLastPage.h"
#import "SCHRating.h"
#import "SCHPrivateAnnotations.h"
#import "SCHAppContentProfileItem.h"
#import "SCHBookIdentifier.h"
#import "BITAPIError.h"
#import "SCHContentMetadataItem.h"
#import "SCHRecommendationISBN.h"
#import "SCHRecommendationItem.h"
#import "SCHRecommendationSyncComponent.h"

// Constants
NSString * const SCHContentSyncComponentWillDeleteNotification = @"SCHContentSyncComponentWillDeleteNotification";
NSString * const SCHContentSyncComponentDidAddBookToProfileNotification = @"SCHContentSyncComponentDidAddBookToProfileNotification";
NSString * const SCHContentSyncComponentAddedBookIdentifier = @"SCHContentSyncComponentAddedBookIdentifier";
NSString * const SCHContentSyncComponentAddedProfileIdentifier = @"SCHContentSyncComponentAddedProfileIdentifier";
NSString * const SCHContentSyncComponentDidCompleteNotification = @"SCHContentSyncComponentDidCompleteNotification";
NSString * const SCHContentSyncComponentDidFailNotification = @"SCHContentSyncComponentDidFailNotification";

@interface SCHContentSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;

- (BOOL)updateUserContentItems;

- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem 
                    forProfile:(SCHContentProfileItem *)contentProfileItem;
- (void)removeAnnotationStructure:(SCHUserContentItem *)userContentItem 
                       forProfile:(SCHContentProfileItem *)contentProfileItem;
- (SCHOrderItem *)addOrderItem:(NSDictionary *)orderItem;
- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem
                                         forBook:(SCHBookIdentifier *)bookIdentifier;
- (void)syncUserContentItem:(NSDictionary *)webUserContentItem 
        withUserContentItem:(SCHUserContentItem *)localUserContentItem;
- (void)syncOrderItems:(NSArray *)webOrderList 
        localOrderList:(NSSet *)localOrderList
            insertInto:(SCHUserContentItem *)userContentItem;
- (BOOL)orderIDIsValid:(NSNumber *)orderID;
- (void)syncOrderItem:(NSDictionary *)webOrderItem 
        withOrderItem:(SCHOrderItem *)localOrderItem;
- (void)syncContentProfileItems:(NSArray *)webContentProfileList 
        localContentProfileList:(NSSet *)localContentProfileList
                     insertInto:(SCHUserContentItem *)userContentItem;
- (BOOL)profileIDIsValid:(NSNumber *)profileID;
- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem 
        withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem;
- (void)deleteUnusedContentMetadataItems;
- (void)removeRecommendationForBook:(SCHContentMetadataItem *)contentMetadataItem;
- (void)backgroundSave:(BOOL)batch;

@end

@implementation SCHContentSyncComponent

@synthesize libreAccessWebService;
@synthesize backgroundThreadManagedObjectContext;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;        
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
    [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateUserContentItems];
        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);		
}

#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];    
}

- (void)clearComponent
{
    // nop
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHUserContentItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHOrderItem error:&error] ||
		![self.managedObjectContext BITemptyEntity:kSCHContentProfileItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
    @try {
        if([method compare:kSCHLibreAccessWebServiceSaveContentProfileAssignment] == NSOrderedSame) {	
            if (self.saveOnly == NO) {
                self.isSynchronizing = [self.libreAccessWebService listUserContent];
                if (self.isSynchronizing == NO) {
                    [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                        if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                            [self.delegate authenticationDidSucceed];
                        } else {
                            self.isSynchronizing = NO;
                        }
                    } failureBlock:^(NSError *error){
                        self.isSynchronizing = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                            object:self];                    
                    }];				
                }
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidCompleteNotification 
                                                                    object:self];
                [super method:method didCompleteWithResult:result userInfo:userInfo];				                
            }
        } else if([method compare:kSCHLibreAccessWebServiceListUserContentForRatings] == NSOrderedSame) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
                [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];

                NSArray *content = [result objectForKey:kSCHLibreAccessWebServiceUserContentList];
                [self syncUserContentItems:content];

                [self backgroundSave:NO];
                self.backgroundThreadManagedObjectContext = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidCompleteNotification 
                                                                        object:self];
                    [super method:method didCompleteWithResult:result userInfo:userInfo];				
                });                
            });            
        }
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidFailNotification 
                                                            object:self];            
        
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [super method:method didFailWithError:error requestInfo:nil result:result];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidFailNotification 
                                                        object:self];            
    
    [super method:method didFailWithError:error requestInfo:requestInfo result:result];        
}

- (BOOL)updateUserContentItems
{		
	BOOL ret = YES;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
	NSArray *changedStates = [NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
					   [NSNumber numberWithStatus:kSCHStatusDeleted], nil];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY ProfileList.State IN %@", changedStates]];
	
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	if ([results count] > 0) {
		self.isSynchronizing = [self.libreAccessWebService saveContentProfileAssignment:results];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                    [self.delegate authenticationDidSucceed];
                } else {
                    self.isSynchronizing = NO;
                }
            } failureBlock:^(NSError *error){
                self.isSynchronizing = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                    object:self];                
            }];					
			ret = NO;			
		}		
	} else {
        if (self.saveOnly == NO) {
            self.isSynchronizing = [self.libreAccessWebService listUserContent];
            if (self.isSynchronizing == NO) {
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        [self.delegate authenticationDidSucceed];
                    } else {
                        self.isSynchronizing = NO;
                    }
                } failureBlock:^(NSError *error){
                    self.isSynchronizing = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                        object:self];                
                }];				
                ret = NO;
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidCompleteNotification 
                                                                object:self];
            [super method:nil didCompleteWithResult:nil userInfo:nil];				                            
        }
	}
	[fetchRequest release], fetchRequest = nil;
	
	return(ret);	
}

- (NSArray *)localUserContentItems
{
    NSAssert([NSThread isMainThread] == NO, @"localUserContentItems MUST NOT be executed on the main thread");        
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem 
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (void)syncUserContentItems:(NSArray *)userContentList
{		
    NSAssert([NSThread isMainThread] == NO, @"syncUserContentItems MUST NOT be executed on the main thread");    
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [userContentList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                                                         [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],                                                                             
                                                                         nil]];	
	NSArray *localProfiles = [self localUserContentItems];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHUserContentItem *localItem = [localEnumerator nextObject];
	
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
        
        if (webBookIdentifier == nil) {
            webItem = nil;
        } else if (localBookIdentifier == nil) {
            localItem = nil;
        } else {
            switch ([webBookIdentifier compare:localBookIdentifier]) {
                case NSOrderedSame:
                    [self syncUserContentItem:webItem withUserContentItem:localItem];
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

        [webBookIdentifier release];            
		
		if (webItem == nil) {
			webItem = [webEnumerator nextObject];
		}
		if (localItem == nil) {
			localItem = [localEnumerator nextObject];
		}		
	}
	
    for (SCHUserContentItem *userContentItem in deletePool) {
        for (SCHContentProfileItem *contentProfileItem in userContentItem.ProfileList) {
            [self removeAnnotationStructure:userContentItem forProfile:contentProfileItem];        
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentWillDeleteNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[userContentItem bookIdentifier]]
                                                                                                       forKey:[contentProfileItem ProfileID]]];
            });
        }
        [self.backgroundThreadManagedObjectContext deleteObject:userContentItem];
    }
            
    for (NSDictionary *webItem in creationPool) {
        [self addUserContentItem:webItem];
    }
	
	[self backgroundSave:NO];
    
    [self deleteUnusedContentMetadataItems];
}

- (SCHUserContentItem *)addUserContentItem:(NSDictionary *)webUserContentItem
{
    NSAssert([NSThread isMainThread] == NO, @"addUserContentItem MUST NOT be executed on the main thread");        
	SCHUserContentItem *newUserContentItem = nil;
	SCHBookIdentifier *webBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:webUserContentItem];
    
    if (webUserContentItem != nil && webBookIdentifier != nil) {
        newUserContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHUserContentItem inManagedObjectContext:self.backgroundThreadManagedObjectContext];
        
        newUserContentItem.DRMQualifier = webBookIdentifier.DRMQualifier;
        newUserContentItem.Version = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
        newUserContentItem.ContentIdentifier = webBookIdentifier.isbn;
        newUserContentItem.Format = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
        newUserContentItem.DefaultAssignment = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
        newUserContentItem.ContentIdentifierType = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
        
        newUserContentItem.LastVersion = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastVersion]];
        newUserContentItem.FreeBook = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFreeBook]];    
        newUserContentItem.AverageRating = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceAverageRating]];        
        
        NSArray *orderList = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]];
        for (NSDictionary *orderItem in orderList) {
            SCHOrderItem *newOrderItem = [self addOrderItem:orderItem];
            if (newOrderItem != nil) { 
                [newUserContentItem addOrderListObject:newOrderItem];
            }
        }
        
        NSArray *profileList = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]];
        for (NSDictionary *profileItem in profileList) {     
            SCHContentProfileItem *contentProfileItem = [self addContentProfileItem:profileItem
                                                                            forBook:newUserContentItem.bookIdentifier];
            if (contentProfileItem != nil) {
                [newUserContentItem addProfileListObject:contentProfileItem];
                [self addAnnotationStructure:newUserContentItem forProfile:contentProfileItem];
            }
        }
    	
        newUserContentItem.LastModified = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
        newUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];	
    }
    [webBookIdentifier release], webBookIdentifier = nil;
    
    return newUserContentItem;
}

- (void)addAnnotationStructure:(SCHUserContentItem *)userContentItem 
                    forProfile:(SCHContentProfileItem *)contentProfileItem
{
    NSAssert([NSThread isMainThread] == NO, @"addAnnotationStructure MUST NOT be executed on the main thread");            
    if (userContentItem != nil && contentProfileItem != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", contentProfileItem.ProfileID]];
        
        NSArray *annotationsItems = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];	
        [fetchRequest release], fetchRequest = nil;
        if (annotationsItems == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        if([annotationsItems count] > 0) {
            SCHLastPage *newLastPage = [NSEntityDescription insertNewObjectForEntityForName:kSCHLastPage 
                                                                     inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            [newLastPage setInitialValues];

            SCHRating *newRating = [NSEntityDescription insertNewObjectForEntityForName:kSCHRating 
                                                                     inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            [newRating setInitialValues];

            SCHPrivateAnnotations *newPrivateAnnotations = [NSEntityDescription insertNewObjectForEntityForName:kSCHPrivateAnnotations 
                                                                                         inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            newPrivateAnnotations.LastPage = newLastPage;
            newPrivateAnnotations.rating = newRating;
            
            SCHAnnotationsContentItem *newAnnotationsContentItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAnnotationsContentItem 
                                                                                                 inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            newAnnotationsContentItem.AnnotationsItem = [annotationsItems objectAtIndex:0];
            newAnnotationsContentItem.DRMQualifier = userContentItem.DRMQualifier;
            newAnnotationsContentItem.ContentIdentifier = userContentItem.ContentIdentifier;
            newAnnotationsContentItem.Format = userContentItem.Format;
            newAnnotationsContentItem.ContentIdentifierType = userContentItem.ContentIdentifierType;
            newAnnotationsContentItem.PrivateAnnotations = newPrivateAnnotations;
        }
    }
}

- (void)removeAnnotationStructure:(SCHUserContentItem *)userContentItem 
                       forProfile:(SCHContentProfileItem *)contentProfileItem
{
    NSAssert([NSThread isMainThread] == NO, @"removeAnnotationStructure MUST NOT be executed on the main thread");        
    if (userContentItem != nil && contentProfileItem != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileID == %@", contentProfileItem.ProfileID]];
        
        NSArray *annotationsItems = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest 
                                                                                             error:&error];	
        [fetchRequest release], fetchRequest = nil;
        if (annotationsItems == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        if ([annotationsItems count] > 0) {
            SCHBookIdentifier *bookIdentifier = userContentItem.bookIdentifier;
            for (SCHAnnotationsContentItem *item in [[annotationsItems objectAtIndex:0] AnnotationsContentItem]) {
                if ([bookIdentifier isEqual:item.bookIdentifier] == YES)
                    [self.backgroundThreadManagedObjectContext deleteObject:item];
            }        
        }
    }    
}

- (SCHOrderItem *)addOrderItem:(NSDictionary *)orderItem
{
    NSAssert([NSThread isMainThread] == NO, @"addOrderItem MUST NOT be executed on the main thread");            
	SCHOrderItem *ret = nil;
    id orderID = [self makeNullNil:[orderItem valueForKey:kSCHLibreAccessWebServiceOrderID]];
    
	if (orderItem != nil && [self orderIDIsValid:orderID] == YES) {	
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHOrderItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];			
		
		ret.OrderID = orderID;
		ret.OrderDate = [self makeNullNil:[orderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
	}
	
	return ret;
}

- (SCHContentProfileItem *)addContentProfileItem:(NSDictionary *)contentProfileItem 
                                         forBook:(SCHBookIdentifier *)bookIdentifier;
{
    NSAssert([NSThread isMainThread] == NO, @"addContentProfileItem MUST NOT be executed on the main thread");        
	SCHContentProfileItem *ret = nil;
    NSError *error = nil;
    id profileID = [self makeNullNil:[contentProfileItem valueForKey:kSCHLibreAccessWebServiceProfileID]];
    
	if (contentProfileItem != nil && bookIdentifier != nil && [self profileIDIsValid:profileID] == YES) {		
		ret = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentProfileItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext];			
		
		ret.LastModified = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
		ret.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];
		
		ret.ProfileID = profileID;
		ret.LastPageLocation = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
        ret.Rating = [self makeNullNil:[contentProfileItem objectForKey:kSCHLibreAccessWebServiceRating]];
        
        SCHAppContentProfileItem *newAppContentProfileItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppContentProfileItem 
                                                                             inManagedObjectContext:self.backgroundThreadManagedObjectContext];    

        newAppContentProfileItem.ISBN = bookIdentifier.isbn;       
        newAppContentProfileItem.DRMQualifier = bookIdentifier.DRMQualifier;
        newAppContentProfileItem.ContentProfileItem = ret;
        // IsNewBook is derived on request as it requires the annotations to be available

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem 
                                            inManagedObjectContext:self.backgroundThreadManagedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@", ret.ProfileID]];
        NSArray *results = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (results == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
 
        if([results count] > 0) {
            newAppContentProfileItem.ProfileItem = [results objectAtIndex:0];    
            
            NSArray *dictionaryObjects = [NSArray arrayWithObjects:[newAppContentProfileItem bookIdentifier], ret.ProfileID, nil];
            NSArray *dictionaryKeys    = [NSArray arrayWithObjects:SCHContentSyncComponentAddedBookIdentifier, SCHContentSyncComponentAddedProfileIdentifier, nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentDidAddBookToProfileNotification 
                                                                    object:self 
                                                                  userInfo:[NSDictionary dictionaryWithObjects:dictionaryObjects forKeys:dictionaryKeys]];   
            });
        }
	}
	
	return ret;
}

- (void)syncUserContentItem:(NSDictionary *)webUserContentItem withUserContentItem:(SCHUserContentItem *)localUserContentItem
{
    NSAssert([NSThread isMainThread] == NO, @"syncUserContentItem MUST NOT be executed on the main thread");        
    if (webUserContentItem != nil) {
        localUserContentItem.DRMQualifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDRMQualifier]];
        localUserContentItem.Version = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceVersion]];
        localUserContentItem.ContentIdentifier = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]];
        localUserContentItem.Format = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFormat]];		
        localUserContentItem.DefaultAssignment = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceDefaultAssignment]];		
        localUserContentItem.ContentIdentifierType = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceContentIdentifierType]];				
        
        [self syncOrderItems:[self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceOrderList]] 
              localOrderList:localUserContentItem.OrderList
                  insertInto:localUserContentItem];
        
        [self syncContentProfileItems:[self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceProfileList]] 
              localContentProfileList:localUserContentItem.ProfileList
                           insertInto:localUserContentItem];

        localUserContentItem.LastVersion = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastVersion]];
        localUserContentItem.FreeBook = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceFreeBook]];
        localUserContentItem.AverageRating = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceAverageRating]];
        
        localUserContentItem.LastModified = [self makeNullNil:[webUserContentItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localUserContentItem.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];				
    }
}

- (void)syncOrderItems:(NSArray *)webOrderList 
        localOrderList:(NSSet *)localOrderList
            insertInto:(SCHUserContentItem *)userContentItem
{		
    NSAssert([NSThread isMainThread] == NO, @"syncOrderItems MUST NOT be executed on the main thread");            
	NSArray *sortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceOrderID ascending:YES]];
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [webOrderList sortedArrayUsingDescriptors:sortDescriptor];		
	NSArray *localProfiles = [localOrderList sortedArrayUsingDescriptors:sortDescriptor];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHOrderItem *localItem = [localEnumerator nextObject];
	
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
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceOrderID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceOrderID];
		
        if (webItemID == nil || [self orderIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncOrderItem:webItem withOrderItem:localItem];
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
	
	for (SCHOrderItem *localItem in deletePool) {
		[self.backgroundThreadManagedObjectContext deleteObject:localItem];
	}
	
	for (NSDictionary *webItem in creationPool) {
        SCHOrderItem *newOrderItem = [self addOrderItem:webItem];
        if (newOrderItem != nil) {
            [userContentItem addOrderListObject:newOrderItem];
        }
	}
}

- (BOOL)orderIDIsValid:(NSNumber *)orderID
{
    return [orderID integerValue] > 0;
}

- (void)syncOrderItem:(NSDictionary *)webOrderItem withOrderItem:(SCHOrderItem *)localOrderItem
{
    if (webOrderItem != nil) {
        localOrderItem.OrderID = [self makeNullNil:[webOrderItem objectForKey:kSCHLibreAccessWebServiceOrderID]];
        localOrderItem.OrderDate = [self makeNullNil:[webOrderItem objectForKey:kSCHLibreAccessWebServiceOrderDate]];
    }
}

- (void)syncContentProfileItems:(NSArray *)webContentProfileList 
        localContentProfileList:(NSSet *)localContentProfileList
                    insertInto:(SCHUserContentItem *)userContentItem

{		
    NSAssert([NSThread isMainThread] == NO, @"syncContentProfileItems MUST NOT be executed on the main thread");            
	NSArray *sortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceProfileID ascending:YES]];
	NSMutableArray *deletePool = [NSMutableArray array];
	NSMutableArray *creationPool = [NSMutableArray array];
	
	NSArray *webProfiles = [webContentProfileList sortedArrayUsingDescriptors:sortDescriptor];		
	NSArray *localProfiles = [localContentProfileList sortedArrayUsingDescriptors:sortDescriptor];
	
	NSEnumerator *webEnumerator = [webProfiles objectEnumerator];			  
	NSEnumerator *localEnumerator = [localProfiles objectEnumerator];			  			  
	
	NSDictionary *webItem = [webEnumerator nextObject];
	SCHContentProfileItem *localItem = [localEnumerator nextObject];
	
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
		
		id webItemID = [self makeNullNil:[webItem valueForKey:kSCHLibreAccessWebServiceProfileID]];
		id localItemID = [localItem valueForKey:kSCHLibreAccessWebServiceProfileID];
		
        if (webItemID == nil || [self profileIDIsValid:webItemID] == NO) {
            webItem = nil;
        } else if (localItemID == nil) {
            localItem = nil;            
        } else {                
            switch ([webItemID compare:localItemID]) {
                case NSOrderedSame:
                    [self syncContentProfileItem:webItem withContentProfileItem:localItem];
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
	
    for (SCHContentProfileItem *contentProfileItem in deletePool) {
        dispatch_sync(dispatch_get_main_queue(), ^{        
            [[NSNotificationCenter defaultCenter] postNotificationName:SCHContentSyncComponentWillDeleteNotification 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[contentProfileItem.UserContentItem bookIdentifier]]
                                                                                                   forKey:[contentProfileItem ProfileID]]];
        });
        [self.backgroundThreadManagedObjectContext deleteObject:contentProfileItem];            
    }

	for (NSDictionary *webItem in creationPool) {
        SCHContentProfileItem *item = [self addContentProfileItem:webItem
                                                          forBook:userContentItem.bookIdentifier];

        if (item != nil) {
            [userContentItem addProfileListObject:item];
        }
	}
}

- (BOOL)profileIDIsValid:(NSNumber *)profileID
{
    return [profileID integerValue] > 0;
}

- (void)syncContentProfileItem:(NSDictionary *)webContentProfileItem withContentProfileItem:(SCHContentProfileItem *)localContentProfileItem
{
    if (webContentProfileItem != nil) {
        localContentProfileItem.LastModified = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceLastModified]];
        localContentProfileItem.State = [NSNumber numberWithStatus:kSCHStatusSyncUpdate];
        
        localContentProfileItem.ProfileID = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceProfileID]];
        localContentProfileItem.LastPageLocation = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceLastPageLocation]];
        // IsNewBook is derived on request as it requires the annotations to be available
        localContentProfileItem.Rating = [self makeNullNil:[webContentProfileItem objectForKey:kSCHLibreAccessWebServiceRating]];
    }
}

// if a book does not belong on at least one bookshelf then we remove it and thus
// any of the on disk files
- (void)deleteUnusedContentMetadataItems
{
    NSAssert([NSThread isMainThread] == NO, @"deleteUnusedContentMetadataItems MUST NOT be executed on the main thread");                
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; 
    NSError *error = nil;    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem
                                        inManagedObjectContext:self.backgroundThreadManagedObjectContext]];
    
    NSArray *contentMetadataItems = [self.backgroundThreadManagedObjectContext executeFetchRequest:fetchRequest 
                                                                             error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (contentMetadataItems == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    for (SCHContentMetadataItem *contentMetadataItem in contentMetadataItems) {
        SCHUserContentItem *userContentItem = [contentMetadataItem UserContentItem];
        if (userContentItem == nil || [userContentItem.ProfileList count] == 0) {
            [self removeRecommendationForBook:contentMetadataItem];
            [self.backgroundThreadManagedObjectContext deleteObject:contentMetadataItem];
        }
    }   
    
    [self backgroundSave:NO];
}

- (void)removeRecommendationForBook:(SCHContentMetadataItem *)contentMetadataItem
{
    NSAssert([NSThread isMainThread] == NO, @"removeRecommendationForBook MUST NOT be executed on the main thread");                    
    if (contentMetadataItem != nil) {
        SCHRecommendationISBN *recommendationISBN = [contentMetadataItem.AppBook recommendationISBN];
        if (recommendationISBN != nil) {
            NSMutableArray *deletedISBNs = [NSMutableArray array];
            for (SCHRecommendationItem *item in recommendationISBN.recommendationItems) {
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
            [self.backgroundThreadManagedObjectContext deleteObject:recommendationISBN];
            [self backgroundSave:NO];
        }
    }
}

- (void)backgroundSave:(BOOL)batch
{
    NSAssert([NSThread isMainThread] == NO, @"backgroundSave MUST NOT be executed on the main thread");
    
    NSError *error = nil;
    static NSUInteger batchCount = 0;
    
    if (batch == NO || ++batchCount > 250) {
        batchCount = 0;
        if ([self.backgroundThreadManagedObjectContext hasChanges] == YES &&
            ![self.backgroundThreadManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

@end
