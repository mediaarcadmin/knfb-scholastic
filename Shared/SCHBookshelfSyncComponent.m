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
#import "SCHBooksAssignment.h"
#import "SCHBookIdentifier.h"
#import "SCHLibreAccessWebService.h"
#import "SCHListContentMetadataOperation.h"
#import "SCHProfileItem.h"
#import "SCHAppProfile.h"
#import "SCHProcessingManager.h"

// Constants
NSString * const SCHBookshelfSyncComponentWillDeleteNotification = @"SCHBookshelfSyncComponentWillDeleteNotification";
NSString * const SCHBookshelfSyncComponentBookIdentifiers = @"SCHBookshelfSyncComponentBookIdentifiers";
NSString * const SCHBookshelfSyncComponentBookReceivedNotification = @"SCHBookshelfSyncComponentBookReceivedNotification";
NSString * const SCHBookshelfSyncComponentDidCompleteNotification = @"SCHBookshelfSyncComponentDidCompleteNotification";
NSString * const SCHBookshelfSyncComponentDidFailNotification = @"SCHBookshelfSyncComponentDidFailNotification";

static BOOL const SCHBookshelfSyncComponentIncludeURLs = NO;

@interface SCHBookshelfSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;

- (BOOL)updateContentMetadataItems;
- (NSArray *)localBooksAssignmentsForProfile:(NSNumber *)profileID;

@end

@implementation SCHBookshelfSyncComponent

@synthesize libreAccessWebService;
@synthesize useIndividualRequests;
@synthesize requestCount;
@synthesize didReceiveFailedResponseBooks;
@synthesize profilesForBooks;

- (id)init
{
	self = [super init];
	if (self != nil) {
        libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;

		useIndividualRequests = YES;
		requestCount = 0;
        didReceiveFailedResponseBooks = [[NSMutableArray alloc] init];
        profilesForBooks = [[NSMutableSet set] retain];        
	}
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;

    [didReceiveFailedResponseBooks release], didReceiveFailedResponseBooks = nil;
    [profilesForBooks release], profilesForBooks = nil;
    
    [super dealloc];
}

- (void)addProfile:(NSNumber *)profileID
{
	if (profileID != nil) {
        if ([self.profilesForBooks containsObject:profileID] == NO) {
            [self.profilesForBooks addObject:profileID];
        }
	}
}

- (void)removeProfile:(NSNumber *)profileID
{
	if (self.isSynchronizing == NO && profileID != nil) {
        [self.profilesForBooks removeObject:profileID];
    }
}

- (BOOL)haveProfiles
{
	return([self.profilesForBooks count ] > 0);
}

- (NSNumber *)currentProfile
{
    NSNumber *ret = nil;

    if ([self haveProfiles] == YES) {
        ret = [[[self.profilesForBooks allObjects] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
    }

    return ret;
}

- (BOOL)nextProfile
{
    NSNumber *currentProfile = [self currentProfile];

    if (currentProfile != nil) {
        [self.profilesForBooks removeObject:currentProfile];
    }
    [self clearFailures];

    return [self haveProfiles];
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
    [self.profilesForBooks removeAllObjects];
}

- (void)clearCoreData
{
	NSError *error = nil;
    
	if (![self.managedObjectContext BITemptyEntity:kSCHContentMetadataItem error:&error priorToDeletionBlock: ^(NSManagedObject *managedObject) {
        [(SCHContentMetadataItem *)managedObject deleteAllFiles];
    }]) {
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
        operation.profileID = [self currentProfile];
        [self.backgroundProcessingQueue addOperation:operation];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
        SCHListContentMetadataOperation *operation = [[[SCHListContentMetadataOperation alloc] initWithSyncComponent:self
                                                                                                              result:result
                                                                                                            userInfo:nil] autorelease];
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        operation.useIndividualRequests = self.useIndividualRequests;
        operation.profileID = [self currentProfile];
        operation.requestInfo = requestInfo;
        operation.responseError = error;
        [self.backgroundProcessingQueue addOperation:operation];
    }
}

- (BOOL)updateContentMetadataItems
{		
	BOOL ret = YES;

	NSMutableArray *results = [NSMutableArray array];

    // only update books we don't already have unless there is a version change
    NSNumber *profileID = [self currentProfile];
    [[self localBooksAssignmentsForProfile:profileID] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SCHBooksAssignment *booksAssignment = obj;
        NSSet *contentMetadataItems = (NSSet *)[obj ContentMetadataItem];

        if (([contentMetadataItems count] < 1 ||
            [[[contentMetadataItems anyObject] Version] integerValue] != [booksAssignment.version integerValue])) {
            [results addObject:obj];
        }
    }];

	self.requestCount = 0;
    [self.didReceiveFailedResponseBooks removeAllObjects];
	if([results count] > 0) {
		if (self.useIndividualRequests == YES) {
            // batch the requests
            for (NSUInteger location = 0; location < [results count]; location += kSCHProcessingManagerBatchSize) {
                NSUInteger remainingResults = [results count] - location;
                NSUInteger length = MIN(kSCHProcessingManagerBatchSize, remainingResults);
                NSRange batchRange = NSMakeRange(location, length);
                NSArray *requestResults = [results subarrayWithRange:batchRange];
                
				self.isSynchronizing = [self.libreAccessWebService listContentMetadata:requestResults
                                                                           includeURLs:SCHBookshelfSyncComponentIncludeURLs
                                                                          coverURLOnly:NO];
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
					self.requestCount += [requestResults count];
                    NSLog(@"Requesting %@ Book information", [requestResults valueForKeyPath:@"@unionOfObjects.ContentIdentifier"]);
				}
			}
		} else {			
			self.isSynchronizing = [self.libreAccessWebService listContentMetadata:results 
                                                                       includeURLs:SCHBookshelfSyncComponentIncludeURLs
                                                                      coverURLOnly:NO];
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
        // remove the profile if there are no books to request
        if (profileID != nil) {
            [self.profilesForBooks removeObject:profileID];
        }

        [self completeWithSuccessMethod:kSCHLibreAccessWebServiceListContentMetadata
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHBookshelfSyncComponentDidCompleteNotification 
                   notificationUserInfo:nil];
        
		ret = NO;
	}
	
	return(ret);	
}

- (NSArray *)localBooksAssignmentsForProfile:(NSNumber *)profileID
{
    NSArray *ret = [NSArray array];

    if (profileID != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error = nil;

        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHBooksAssignment inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY profileList.ProfileID == %@", profileID]];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                          [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceContentIdentifier ascending:YES],
                                          [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceDRMQualifier ascending:YES],
                                          nil]];

        NSArray *bookAssignments = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                            error:&error];
        [fetchRequest release], fetchRequest = nil;
        
        if (bookAssignments == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            ret = bookAssignments;
        }
	}
    
	return ret;
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
    }

    return ret;
}

@end
