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

#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHBookIdentifier.h"
#import "SCHLibreAccessWebService.h"
#import "SCHListContentMetadataOperation.h"

// Constants
NSString * const SCHBookshelfSyncComponentWillDeleteNotification = @"SCHBookshelfSyncComponentWillDeleteNotification";
NSString * const SCHBookshelfSyncComponentBookIdentifiers = @"SCHBookshelfSyncComponentBookIdentifiers";
NSString * const SCHBookshelfSyncComponentBookReceivedNotification = @"SCHBookshelfSyncComponentBookReceivedNotification";
NSString * const SCHBookshelfSyncComponentDidCompleteNotification = @"SCHBookshelfSyncComponentDidCompleteNotification";
NSString * const SCHBookshelfSyncComponentDidFailNotification = @"SCHBookshelfSyncComponentDidFailNotification";

@interface SCHBookshelfSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (BOOL)updateContentMetadataItems;
- (NSArray *)localUserContentItems;

@end

@implementation SCHBookshelfSyncComponent

@synthesize libreAccessWebService;
@synthesize useIndividualRequests;
@synthesize requestCount;
@synthesize didReceiveFailedResponseBooks;

- (id)init
{
	self = [super init];
	if (self != nil) {
        libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;

		useIndividualRequests = YES;	
		requestCount = 0;
        didReceiveFailedResponseBooks = [[NSMutableArray alloc] init];
	}
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;

    [didReceiveFailedResponseBooks release], didReceiveFailedResponseBooks = nil;
    
    [super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		ret = [self updateContentMetadataItems];
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
    self.requestCount = 0;
    [self.didReceiveFailedResponseBooks removeAllObjects];
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHContentMetadataItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
    if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
        SCHListContentMetadataOperation *operation = [[[SCHListContentMetadataOperation alloc] initWithSyncComponent:self
                                                                                                              result:result
                                                                                                            userInfo:userInfo] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        operation.useIndividualRequests = self.useIndividualRequests;
        [self.backgroundProcessingQueue addOperation:operation];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    NSArray *bookIdentifiers = [self bookIdentifiersFromRequestInfo:[requestInfo objectForKey:kSCHLibreAccessWebServiceListContentMetadata]];    
    
	if (self.useIndividualRequests == YES) {
		self.requestCount--;
        [self.didReceiveFailedResponseBooks addObjectsFromArray:bookIdentifiers];
        
        if (self.requestCount < 1) {            
            NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:self.didReceiveFailedResponseBooks 
                                                                             forKey:SCHBookshelfSyncComponentBookIdentifiers];
            
            [self completeWithFailureMethod:method 
                                      error:error 
                                requestInfo:requestInfo 
                                     result:result 
                           notificationName:SCHBookshelfSyncComponentDidFailNotification 
                       notificationUserInfo:notificationUserInfo];
        }
    } else {
        NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:bookIdentifiers 
                                                                         forKey:SCHBookshelfSyncComponentBookIdentifiers];
        
        [self completeWithFailureMethod:method 
                                  error:error 
                            requestInfo:requestInfo 
                                 result:result 
                       notificationName:SCHBookshelfSyncComponentDidFailNotification 
                   notificationUserInfo:notificationUserInfo];
    }
}

- (NSArray *)bookIdentifiersFromRequestInfo:(NSArray *)contentMetadataItems
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[contentMetadataItems count]];

    if (contentMetadataItems != nil) {
        for (NSDictionary *contentMetadataItem in contentMetadataItems) {
            SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:contentMetadataItem];
            if (bookIdentifier != nil) {
                [ret addObject:bookIdentifier];
                [bookIdentifier release];
            }
        }        
    }
    
    return ret;
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
    [self.didReceiveFailedResponseBooks removeAllObjects];
	if([results count] > 0) {
		if (self.useIndividualRequests == YES) {
			for (NSDictionary *ISBN in results) {				
				self.isSynchronizing = [self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:ISBN] 
                                                                           includeURLs:NO coverURLOnly:NO];
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
				} else {
					self.requestCount++;
					NSLog(@"Requesting %@ Book information", [ISBN valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);					
				}
			}
		} else {			
			self.isSynchronizing = [self.libreAccessWebService listContentMetadata:results 
                                                                       includeURLs:NO coverURLOnly:NO];
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
			} else {
				NSLog(@"Requesting ALL Book information");
			}
		}
	} else {
        [self completeWithSuccessMethod:nil 
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                   notificationUserInfo:nil];
        
		ret = NO;
	}
	
	return(ret);	
}

- (NSArray *)localUserContentItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext]];	
    // we only want books that are on a bookshelf
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ProfileList.@count > 0"]];    
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                      nil]];
	
	NSArray *ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];	
	[fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);
}

- (void)syncContentMetadataItemsFromMainThread:(NSArray *)contentMetadataList
{
    if (contentMetadataList != nil) {
        SCHListContentMetadataOperation *operation = [[[SCHListContentMetadataOperation alloc] initWithSyncComponent:self 
                                                                                                              result:nil
                                                                                                            userInfo:nil] autorelease];
        [operation syncContentMetadataItems:contentMetadataList managedObjectContext:self.managedObjectContext];
    }
    
}

- (SCHContentMetadataItem *)addContentMetadataItemFromMainThread:(NSDictionary *)webContentMetadataItem
{
    SCHContentMetadataItem *ret = nil;
    
    if (webContentMetadataItem != nil) {
        SCHListContentMetadataOperation *operation = [[[SCHListContentMetadataOperation alloc] initWithSyncComponent:self 
                                                                                                              result:nil
                                                                                                            userInfo:nil] autorelease];
        
        ret = [operation addContentMetadataItem:webContentMetadataItem managedObjectContext:self.managedObjectContext];
        [self saveWithManagedObjectContext:self.managedObjectContext];
    }

    return ret;
}

@end
